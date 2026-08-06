import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_dimensions.dart';
import 'auth_token_reader.dart';

/// Narrow key/value port so [SecureAuthTokenStore] is testable without
/// platform Keychain / EncryptedSharedPreferences channels.
abstract class SecureKeyValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// True for iOS `errSecDuplicateItem` (-25299) from [FlutterSecureStorage].
bool isKeychainDuplicateItemError(Object error) {
  if (error is! PlatformException) {
    return false;
  }
  final String haystack = <Object?>[
    error.code,
    error.message,
    error.details,
  ].whereType<Object>().join(' ');
  return haystack.contains('-25299') ||
      haystack.toLowerCase().contains('already exists');
}

/// Writes [value], recovering from iOS Keychain duplicate-item conflicts
/// that happen when accessibility options changed between app versions.
Future<void> writeSecureValue({
  required Future<void> Function() write,
  required Future<void> Function() clearExisting,
}) async {
  try {
    await write();
  } on PlatformException catch (error) {
    if (!isKeychainDuplicateItemError(error)) {
      rethrow;
    }
    await clearExisting();
    await write();
  }
}

/// One-at-a-time Keychain / Secure Storage ops.
///
/// Concurrent [FlutterSecureStorage] calls (token write + identity write +
/// legacy delete) can deadlock the iOS Keychain on the platform main thread.
/// While that thread is blocked inside `SecItem*`, Dart timers and frames
/// cannot run — so [Future.timeout] never fires and the UI freezes permanently.
class SerializingSecureKeyValueStore implements SecureKeyValueStore {
  SerializingSecureKeyValueStore(this._inner);

  final SecureKeyValueStore _inner;
  Future<void> _queue = Future<void>.value();

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final Completer<T> completer = Completer<T>();
    _queue = _queue.catchError((Object _) {}).then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stack) {
        completer.completeError(error, stack);
      }
    });
    return completer.future;
  }

  @override
  Future<String?> read(String key) => _enqueue(() => _inner.read(key));

  @override
  Future<void> write(String key, String value) =>
      _enqueue(() => _inner.write(key, value));

  @override
  Future<void> delete(String key) => _enqueue(() => _inner.delete(key));
}

/// [FlutterSecureStorage] adapter used in production.
class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore([FlutterSecureStorage? storage])
    : _storage = storage ?? SecureAuthTokenStore.defaultStorage;

  final FlutterSecureStorage _storage;

  /// Default plugin options — tokens written before
  /// [SecureAuthTokenStore.defaultStorage] used a different accessibility.
  static const FlutterSecureStorage legacyStorage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) async {
    final String? current = await _storage.read(key: key);
    if (current != null && current.isNotEmpty) {
      return current;
    }

    final String? legacy = await legacyStorage.read(key: key);
    if (legacy == null || legacy.isEmpty) {
      return null;
    }

    // Migrate into the current accessibility so later writes succeed.
    await write(key, legacy);
    return legacy;
  }

  @override
  Future<void> write(String key, String value) {
    return writeSecureValue(
      write: () => _storage.write(key: key, value: value),
      clearExisting: () => delete(key),
    );
  }

  @override
  Future<void> delete(String key) async {
    // Current accessibility only. Dual-delete (current + legacy) on every write
    // recovery contended the iOS Keychain on physical devices and froze Login.
    // Legacy copies are still migrated on read when present.
    await _storage.delete(key: key);
  }
}

/// Secure Storage–backed [AuthTokenSession] for access + refresh tokens.
///
/// Tokens are never hardcoded; they are written by the auth flow
/// (login) or by [ApiClient] after a successful refresh.
///
/// Persistence is best-effort. In-memory tokens are the source of truth for
/// the current process; disk writes are scheduled off the Login critical path
/// so a stuck iOS Keychain cannot freeze the UI isolate.
class SecureAuthTokenStore implements AuthTokenSession {
  SecureAuthTokenStore({
    SecureKeyValueStore? vault,
    FlutterSecureStorage? storage,
  }) : _vault =
           vault ??
           (storage != null
               ? SerializingSecureKeyValueStore(
                   FlutterSecureKeyValueStore(storage),
                 )
               : sharedVault);

  /// Process-wide vault shared by tokens + customer identity.
  ///
  /// A single serial queue prevents concurrent Keychain storms from Login
  /// token writes racing identity writes after [completeSignIn].
  static final SecureKeyValueStore sharedVault = SerializingSecureKeyValueStore(
    FlutterSecureKeyValueStore(),
  );

  static const String accessTokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';

  /// Avoids Keychain accessibility deadlocks that freeze auth on iOS.
  static const FlutterSecureStorage defaultStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final SecureKeyValueStore _vault;

  String? _accessTokenCache;
  String? _refreshTokenCache;
  bool _hydrated = false;
  /// After one Keychain timeout, allow a single retry (Hot Restart recovery).
  /// A second timeout marks hydrated empty so Home bands cannot storm SecItem*.
  bool _hydrateTimedOutOnce = false;
  Future<void>? _hydrateInFlight;
  Future<void>? _diskPersistInFlight;
  bool _diskDirty = false;
  bool _diskPersistRetryScheduled = false;
  String? _pendingDiskAccess;
  String? _pendingDiskRefresh;

  /// Loads tokens from Secure Storage once per process.
  ///
  /// Concurrent callers share a single in-flight read. After a timeout or
  /// storage error, [_hydrated] stays true so Home auth bands cannot re-enter
  /// Keychain and pile up uncancellable platform-channel reads. In-memory
  /// tokens written by [updateSessionTokens] / [clearSessionTokens] during an
  /// in-flight hydrate are never overwritten by a late vault snapshot.
  Future<void> hydrate() async {
    if (_hydrated) {
      return;
    }
    final Future<void>? inFlight = _hydrateInFlight;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final Completer<void> completer = Completer<void>();
    _hydrateInFlight = completer.future;
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final List<String?> values = await Future.wait<String?>(<Future<String?>>[
        _vault.read(accessTokenKey),
        _vault.read(refreshTokenKey),
      ]).timeout(AppDimensions.secureStorageTimeout);
      // Login / logout may finish while Keychain is still reading. Never
      // overwrite an in-memory session they already established — an empty
      // vault snapshot after Login wiped Bearer tokens and made reservation
      // APIs return HTTP 401 → "session expired" despite a signed-in UI.
      if (!_hydrated) {
        _accessTokenCache = values[0];
        _refreshTokenCache = values[1];
        _hydrated = true;
      }
      _log('hydrate ok', stopwatch);
    } on TimeoutException {
      // Never wipe in-memory tokens that [updateSessionTokens] may have written
      // while Keychain was hung — that caused "signed in" UI with a null Bearer
      // and reservation calls failing as unauthorized.
      //
      // First timeout: leave [_hydrated] false so Splash can retry once.
      // Second timeout: mark hydrated empty to stop SecItem* storms on Home.
      if (_hydrateTimedOutOnce) {
        _hydrated = true;
        _log('hydrate timeout (final)', stopwatch);
      } else {
        _hydrateTimedOutOnce = true;
        _log('hydrate timeout (will retry)', stopwatch);
      }
    } catch (_) {
      // Leave memory intact; allow one later hydrate retry.
      if (_hydrateTimedOutOnce) {
        _hydrated = true;
      } else {
        _hydrateTimedOutOnce = true;
      }
      _log('hydrate error', stopwatch);
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
      _hydrateInFlight = null;
    }
  }

  @override
  Future<String?> readAccessToken() async {
    await hydrate();
    final String? token = _accessTokenCache;
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  @override
  Future<String?> readRefreshToken() async {
    await hydrate();
    final String? token = _refreshTokenCache;
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  @override
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
    bool persistToDisk = true,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    final String nextAccess = accessToken.trim();
    final String nextRefresh = refreshToken.trim();
    // Memory first — Login / refresh must never await Keychain on the UI
    // isolate. iOS SecItem* runs on the platform main thread; while it blocks,
    // Dart frames and Future.timeout cannot run (complete UI freeze).
    final String? accessCache = nextAccess.isEmpty ? null : nextAccess;
    final String? refreshCache = nextRefresh.isEmpty ? null : nextRefresh;
    _accessTokenCache = accessCache;
    _refreshTokenCache = refreshCache;
    _hydrated = true;
    _pendingDiskAccess = accessCache;
    _pendingDiskRefresh = refreshCache;
    _diskDirty = true;
    _log('updateSessionTokens memory', stopwatch);
    // Login passes persistToDisk: false so SharedPreferences SessionMode can
    // finish before SecItem* occupies the platform thread (otherwise prefs
    // await never completes → Login spinner freezes forever).
    // Refresh / other callers keep the default and persist soon.
    // Never await here — SecItem* must stay off the Login critical path.
    if (persistToDisk) {
      scheduleDiskPersist();
    }
  }

  /// Starts best-effort Keychain persistence for the latest memory session.
  ///
  /// Safe to call after Login→Home first frames. Retries when a write fails —
  /// clearing dirty before success used to leave rotated refresh tokens only
  /// in memory; the next cold start reloaded the pre-rotation refresh and the
  /// API revoked the whole token family (refresh permanently dead).
  void scheduleDiskPersist() {
    if (!_diskDirty) {
      return;
    }
    final Future<void>? inFlight = _diskPersistInFlight;
    if (inFlight != null) {
      // Another write is running — retry after it if still dirty.
      unawaited(
        inFlight.whenComplete(() {
          if (_diskDirty) {
            _scheduleDiskPersistRetry();
          }
        }),
      );
      return;
    }

    final String? access = _pendingDiskAccess;
    final String? refresh = _pendingDiskRefresh;
    final Future<void> request = _persistSessionToDisk(
      access: access,
      refresh: refresh,
    );
    _diskPersistInFlight = request;
    unawaited(
      request.whenComplete(() {
        if (identical(_diskPersistInFlight, request)) {
          _diskPersistInFlight = null;
        }
        if (_diskDirty) {
          _scheduleDiskPersistRetry();
        }
      }),
    );
  }

  void _scheduleDiskPersistRetry() {
    if (_diskPersistRetryScheduled || !_diskDirty) {
      return;
    }
    _diskPersistRetryScheduled = true;
    // Microtask — not a multi-second delay — so a disk clear that raced
    // Login (Guest→Login) is followed by persist before Hot Restart can
    // observe an empty Keychain.
    scheduleMicrotask(() {
      _diskPersistRetryScheduled = false;
      if (_diskDirty) {
        scheduleDiskPersist();
      }
    });
  }

  /// Drops in-memory Bearer tokens without touching Keychain.
  ///
  /// Used on the Welcome → Guest bridge so SecItem* cannot freeze the UI
  /// thread. Call [scheduleDiskClear] after Home has painted.
  void clearMemorySessionOnly() {
    final Stopwatch stopwatch = Stopwatch()..start();
    _accessTokenCache = null;
    _refreshTokenCache = null;
    _pendingDiskAccess = null;
    _pendingDiskRefresh = null;
    _diskDirty = false;
    // Mark hydrated so a late vault snapshot cannot resurrect cleared tokens.
    _hydrated = true;
    _log('clearMemorySessionOnly', stopwatch);
  }

  /// Best-effort Keychain delete — never await on navigation paths.
  void scheduleDiskClear() {
    _diskPersistInFlight = _clearSessionOnDisk();
    unawaited(_diskPersistInFlight);
  }

  @override
  Future<void> clearSessionTokens() async {
    clearMemorySessionOnly();
    // Logout awaits a bounded Keychain wipe so the next cold start cannot
    // hydrate leftover tokens and re-open Home as authenticated.
    // Callers that must not wait should use [clearMemorySessionOnly] +
    // [scheduleDiskClear] (Guest bridge) or `unawaited(clearSessionTokens())`.
    final Future<void> clear = _clearSessionOnDisk();
    _diskPersistInFlight = clear;
    try {
      await clear.timeout(AppDimensions.secureStorageTimeout);
    } catch (_) {
      // Navigation / logout UI must still proceed.
    } finally {
      if (identical(_diskPersistInFlight, clear)) {
        _diskPersistInFlight = null;
      }
    }
  }

  /// Waits for the latest scheduled disk write/clear (tests / diagnostics).
  @visibleForTesting
  Future<void> flushPendingDiskWrites() async {
    if (_diskDirty) {
      scheduleDiskPersist();
    }
    final Future<void>? inFlight = _diskPersistInFlight;
    if (inFlight != null) {
      await inFlight;
    }
  }

  Future<void> _persistSessionToDisk({
    required String? access,
    required String? refresh,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      await Future.wait(<Future<void>>[
        _persist(accessTokenKey, access),
        _persist(refreshTokenKey, refresh),
      ]).timeout(AppDimensions.secureStorageTimeout);
      // Clear dirty only when nothing newer arrived mid-write / clear.
      if (_pendingDiskAccess == access && _pendingDiskRefresh == refresh) {
        _diskDirty = false;
      }
      _log('disk persist ok', stopwatch);
    } catch (_) {
      // Keep dirty only for the still-current session — otherwise a delayed
      // failure after clearSessionTokens would resurrect a disk write.
      if (_pendingDiskAccess == access && _pendingDiskRefresh == refresh) {
        _diskDirty = true;
      }
      _log('disk persist failed/timeout', stopwatch);
    }
  }

  Future<void> _clearSessionOnDisk() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      await Future.wait(<Future<void>>[
        _vault.delete(accessTokenKey),
        _vault.delete(refreshTokenKey),
      ]).timeout(AppDimensions.secureStorageTimeout);
      _log('disk clear ok', stopwatch);
    } catch (_) {
      // Guest / logout UI must not block on storage.
      _log('disk clear failed/timeout', stopwatch);
    }
  }

  Future<void> _persist(String key, String? value) async {
    if (value == null) {
      await _vault.delete(key);
      return;
    }
    await _vault.write(key, value);
  }

  static void _log(String label, Stopwatch stopwatch) {
    if (kDebugMode) {
      debugPrint(
        '[LoginPerf] tokenStore $label: ${stopwatch.elapsedMicroseconds}µs',
      );
    }
  }
}
