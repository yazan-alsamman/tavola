import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/network/secure_auth_token_store.dart';

void main() {
  group('isKeychainDuplicateItemError', () {
    test('detects iOS errSecDuplicateItem (-25299)', () {
      expect(
        isKeychainDuplicateItemError(
          PlatformException(
            code: 'Unexpected security result code',
            message: 'The specified item already exists in the keychain.',
            details: -25299,
          ),
        ),
        isTrue,
      );
    });

    test('ignores unrelated platform errors', () {
      expect(
        isKeychainDuplicateItemError(
          PlatformException(
            code: 'Unexpected security result code',
            details: -25300,
          ),
        ),
        isFalse,
      );
    });
  });

  group('writeSecureValue', () {
    test(
      'retries after clearing when Keychain reports duplicate item',
      () async {
        int writeCount = 0;
        int clearCount = 0;

        await writeSecureValue(
          write: () async {
            writeCount++;
            if (writeCount == 1) {
              throw PlatformException(
                code: 'Unexpected security result code',
                message: 'The specified item already exists in the keychain.',
                details: -25299,
              );
            }
          },
          clearExisting: () async {
            clearCount++;
          },
        );

        expect(writeCount, 2);
        expect(clearCount, 1);
      },
    );

    test('rethrows non-duplicate platform errors', () async {
      expect(
        () => writeSecureValue(
          write: () async {
            throw PlatformException(code: 'Other', details: -25300);
          },
          clearExisting: () async {},
        ),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('SecureAuthTokenStore', () {
    test(
      'updateSessionTokens schedules disk persist without awaiting Keychain',
      () async {
        final _HangingVault vault = _HangingVault();
        final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

        final Stopwatch watch = Stopwatch()..start();
        await store.updateSessionTokens(
          accessToken: 'mem-only',
          refreshToken: 'mem-refresh',
        );
        watch.stop();

        // Memory is live immediately; Keychain write is fire-and-forget.
        expect(watch.elapsedMilliseconds, lessThan(50));
        expect(await store.readAccessToken(), 'mem-only');
        expect(await store.readRefreshToken(), 'mem-refresh');
      },
    );

    test(
      'updateSessionTokens persistToDisk:false skips Keychain schedule',
      () async {
        final _MemoryVault vault = _MemoryVault();
        final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

        await store.updateSessionTokens(
          accessToken: 'mem-only',
          refreshToken: 'mem-refresh',
          persistToDisk: false,
        );
        await Future<void>.delayed(Duration.zero);

        expect(vault.values, isEmpty);
        expect(await store.readAccessToken(), 'mem-only');

        store.scheduleDiskPersist();
        await store.flushPendingDiskWrites();
        expect(vault.values[SecureAuthTokenStore.accessTokenKey], 'mem-only');
      },
    );

    test(
      'updateSessionTokens writes both tokens to vault and memory',
      () async {
        final _MemoryVault vault = _MemoryVault();
        final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

        await store.updateSessionTokens(
          accessToken: ' access-1 ',
          refreshToken: ' refresh-1 ',
        );
        await store.flushPendingDiskWrites();

        expect(await store.readAccessToken(), 'access-1');
        expect(await store.readRefreshToken(), 'refresh-1');
        expect(vault.values[SecureAuthTokenStore.accessTokenKey], 'access-1');
        expect(vault.values[SecureAuthTokenStore.refreshTokenKey], 'refresh-1');
      },
    );

    test('hydrate loads persisted tokens once', () async {
      final _MemoryVault vault = _MemoryVault()
        ..values[SecureAuthTokenStore.accessTokenKey] = 'saved-access'
        ..values[SecureAuthTokenStore.refreshTokenKey] = 'saved-refresh';
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

      expect(await store.readAccessToken(), 'saved-access');
      expect(await store.readRefreshToken(), 'saved-refresh');
      expect(vault.readCount, 2);

      // Second read uses memory cache — no extra vault reads.
      expect(await store.readAccessToken(), 'saved-access');
      expect(vault.readCount, 2);
    });

    test('clearSessionTokens removes memory and vault entries', () async {
      final _MemoryVault vault = _MemoryVault();
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

      await store.updateSessionTokens(accessToken: 'a', refreshToken: 'r');
      await store.flushPendingDiskWrites();
      await store.clearSessionTokens();
      await store.flushPendingDiskWrites();

      expect(await store.readAccessToken(), isNull);
      expect(await store.readRefreshToken(), isNull);
      expect(
        vault.values.containsKey(SecureAuthTokenStore.accessTokenKey),
        isFalse,
      );
      expect(
        vault.values.containsKey(SecureAuthTokenStore.refreshTokenKey),
        isFalse,
      );
    });

    test('empty tokens delete vault keys', () async {
      final _MemoryVault vault = _MemoryVault()
        ..values[SecureAuthTokenStore.accessTokenKey] = 'old'
        ..values[SecureAuthTokenStore.refreshTokenKey] = 'old';
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

      await store.updateSessionTokens(accessToken: '  ', refreshToken: '');
      await store.flushPendingDiskWrites();

      expect(await store.readAccessToken(), isNull);
      expect(await store.readRefreshToken(), isNull);
      expect(
        vault.values.containsKey(SecureAuthTokenStore.accessTokenKey),
        isFalse,
      );
      expect(
        vault.values.containsKey(SecureAuthTokenStore.refreshTokenKey),
        isFalse,
      );
    });

    test(
      'hanging Keychain does not block updateSessionTokens (Login freeze root cause)',
      () async {
        final _HangingVault vault = _HangingVault();
        final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

        final Stopwatch watch = Stopwatch()..start();
        await store.updateSessionTokens(
          accessToken: 'mem-access',
          refreshToken: 'mem-refresh',
        );
        watch.stop();

        // BEFORE fix: awaited Keychain up to secureStorageTimeout (~3s).
        // AFTER fix: memory path returns without waiting on disk.
        expect(
          watch.elapsedMilliseconds,
          lessThan(AppDimensions.secureStorageTimeout.inMilliseconds ~/ 10),
          reason:
              'updateSessionTokens must not await Keychain on Login path '
              '(was ~${AppDimensions.secureStorageTimeout.inMilliseconds}ms)',
        );
        expect(await store.readAccessToken(), 'mem-access');
        expect(await store.readRefreshToken(), 'mem-refresh');
      },
    );

    test('vault hang still keeps in-memory session after timeout', () async {
      final _HangingVault vault = _HangingVault();
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

      final Stopwatch watch = Stopwatch()..start();
      await store.updateSessionTokens(
        accessToken: 'mem-access',
        refreshToken: 'mem-refresh',
      );
      watch.stop();

      expect(watch.elapsed, lessThan(const Duration(milliseconds: 50)));
      expect(await store.readAccessToken(), 'mem-access');
      expect(await store.readRefreshToken(), 'mem-refresh');
    });

    test('hydrate timeout treats storage as empty without throwing', () async {
      final _HangingVault vault = _HangingVault();
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

      expect(await store.readAccessToken(), isNull);
      expect(await store.readRefreshToken(), isNull);
    });

    test('hydrate in-flight empty vault does not wipe login tokens', () async {
      final _SlowVault vault = _SlowVault(
        delay: AppDimensions.secureStorageTimeout ~/ 4,
        access: '',
        refresh: '',
      );
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

      final Future<String?> pendingRead = store.readAccessToken();
      await store.updateSessionTokens(
        accessToken: 'login-access',
        refreshToken: 'login-refresh',
      );
      await pendingRead;

      expect(await store.readAccessToken(), 'login-access');
      expect(await store.readRefreshToken(), 'login-refresh');
    });

    test(
      'hydrate timeout does not wipe tokens written during Keychain hang',
      () async {
        final _HangingVault vault = _HangingVault();
        final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

        // Start hydrate (will hang on vault).
        final Future<String?> pendingRead = store.readAccessToken();
        // Login writes memory while Keychain is still stuck.
        await store.updateSessionTokens(
          accessToken: 'login-access',
          refreshToken: 'login-refresh',
        );
        // Let hydrate time out.
        await pendingRead;
        expect(await store.readAccessToken(), 'login-access');
        expect(await store.readRefreshToken(), 'login-refresh');
      },
    );

    test('hydrate timeout allows a later vault retry for Hot Restart', () async {
      final _HangingVault vault = _HangingVault();
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

      expect(await store.readAccessToken(), isNull);
      final int readsAfterFirstTimeout = vault.readCount;

      // After timeout, Splash / next read must retry Keychain — not permanently
      // treat the session as logged-out.
      expect(await store.readAccessToken(), isNull);
      expect(vault.readCount, greaterThan(readsAfterFirstTimeout));
    });

    test('concurrent hydrate shares one vault round-trip', () async {
      final _SlowVault vault = _SlowVault(
        delay: AppDimensions.secureStorageTimeout ~/ 4,
        access: 'shared-access',
        refresh: 'shared-refresh',
      );
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

      final List<String?> tokens = await Future.wait<String?>(<Future<String?>>[
        store.readAccessToken(),
        store.readAccessToken(),
        store.readRefreshToken(),
      ]);

      expect(tokens[0], 'shared-access');
      expect(tokens[1], 'shared-access');
      expect(tokens[2], 'shared-refresh');
      // One hydrate = two key reads (access + refresh), not 2× concurrent storms.
      expect(vault.readCount, 2);
    });

    test(
      'failed disk persist keeps refresh dirty so retry can save rotation',
      () async {
        // Two keys write in parallel — fail both on the first persist attempt.
        final _FailThenSucceedVault vault = _FailThenSucceedVault(failures: 2);
        final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);

        await store.updateSessionTokens(
          accessToken: 'rotated-access',
          refreshToken: 'rotated-refresh',
        );
        // updateSessionTokens auto-schedules persist; first attempt fails.
        await store.flushPendingDiskWrites();

        // Memory must never be lost when disk fails.
        expect(await store.readAccessToken(), 'rotated-access');
        expect(await store.readRefreshToken(), 'rotated-refresh');

        // Microtask retry (same dirty-flag path) then succeeds.
        await Future<void>.delayed(Duration.zero);
        await store.flushPendingDiskWrites();

        expect(
          vault.values[SecureAuthTokenStore.accessTokenKey],
          'rotated-access',
        );
        expect(
          vault.values[SecureAuthTokenStore.refreshTokenKey],
          'rotated-refresh',
        );
      },
    );
  });
}

class _MemoryVault implements SecureKeyValueStore {
  final Map<String, String> values = <String, String>{};
  int readCount = 0;

  @override
  Future<String?> read(String key) async {
    readCount++;
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

/// Fails the first [failures] write batches, then persists normally.
class _FailThenSucceedVault implements SecureKeyValueStore {
  _FailThenSucceedVault({required this.failures});

  int failures;
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    if (failures > 0) {
      failures -= 1;
      throw Exception('vault write failed');
    }
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

/// Never completes — forces [AppDimensions.secureStorageTimeout] recovery path.
class _HangingVault implements SecureKeyValueStore {
  int readCount = 0;

  @override
  Future<String?> read(String key) {
    readCount++;
    return Completer<String?>().future;
  }

  @override
  Future<void> write(String key, String value) => Completer<void>().future;

  @override
  Future<void> delete(String key) => Completer<void>().future;
}

/// Completes after [delay] so concurrent hydrate callers overlap.
class _SlowVault implements SecureKeyValueStore {
  _SlowVault({
    required this.delay,
    required this.access,
    required this.refresh,
  });

  final Duration delay;
  final String access;
  final String refresh;
  int readCount = 0;

  @override
  Future<String?> read(String key) async {
    readCount++;
    await Future<void>.delayed(delay);
    if (key == SecureAuthTokenStore.accessTokenKey) {
      return access;
    }
    if (key == SecureAuthTokenStore.refreshTokenKey) {
      return refresh;
    }
    return null;
  }

  @override
  Future<void> write(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}
}
