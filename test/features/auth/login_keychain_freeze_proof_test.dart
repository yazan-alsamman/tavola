import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/network/secure_auth_token_store.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/model/customer_auth_response_model.dart';
import 'package:tavla/features/auth/model/session_mode.dart';
import 'package:tavla/features/auth/session_mode_preferences.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

/// Proof: Login freeze was awaiting Keychain inside [updateSessionTokens].
///
/// On iOS, SecItem* runs on the platform main thread. While it blocks,
/// Dart frames and [Future.timeout] cannot run — so awaiting disk on the
/// Login path freezes the UI for the entire native Keychain duration (or
/// forever on Keychain deadlock under concurrent writes).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(Get.reset);

  test('serializing vault runs ops one-at-a-time', () async {
    final _OrderedVault inner = _OrderedVault();
    final SerializingSecureKeyValueStore vault = SerializingSecureKeyValueStore(
      inner,
    );

    final List<Future<void>> writes = <Future<void>>[
      vault.write('a', '1'),
      vault.write('b', '2'),
      vault.write('c', '3'),
    ];
    await Future.wait(writes);

    expect(inner.maxInFlight, 1);
    expect(inner.completed, <String>['a', 'b', 'c']);
  });

  test(
    'completeSignIn returns in << secureStorageTimeout when Keychain hangs',
    () async {
      Get.testMode = true;
      final _HangingVault vault = _HangingVault();
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);
      Get.put<AuthTokenReader>(store, permanent: true);
      Get.put(ApiClient(tokenReader: store), permanent: true);
      // Same vault as production shared Keychain — proves login never queues
      // a competing SecItem read (e.g. pending account-deletion hydrate).
      Get.put(
        UsersRepository(Get.find<ApiClient>(), vault: vault),
        permanent: true,
      );
      Get.put(AuthSessionController(), permanent: true);

      final Stopwatch watch = Stopwatch()..start();
      await Get.find<AuthSessionController>().completeSignIn(
        const CustomerAuthResponseModel(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          sessionId: 'session-id',
          userId: 'user-id',
          username: 'Yazan',
          phone: '+971501234567',
        ),
      );
      watch.stop();

      // Evidence: previously blocked up to secureStorageTimeout awaiting disk.
      expect(
        watch.elapsedMilliseconds,
        lessThan(AppDimensions.secureStorageTimeout.inMilliseconds ~/ 10),
      );
      expect(await store.readAccessToken(), 'access-token');
      expect(
        Get.find<AuthSessionController>().hasAuthenticatedSession.value,
        isTrue,
      );
      // SessionMode is best-effort (unawaited); Keychain is only scheduled
      // (never awaited) so hanging SecItem* / busy platform thread cannot
      // freeze Login after a successful API response.
      // Keychain / SessionMode start only after post-login bootstrap (Home paint).
      await Future<void>.delayed(Duration.zero);
      expect(vault.writeStarts, 0);
      expect(vault.readStarts, 0);
      expect(await SessionModePreferences.read(), isNot(SessionMode.authenticated));

      await Get.find<AuthSessionController>().flushPostLoginBootstrap();

      expect(await SessionModePreferences.read(), SessionMode.authenticated);
      expect(vault.writeStarts, greaterThan(0));
      expect(vault.readStarts, 0);
    },
  );

  test(
    'completeSignIn returns while Guest Keychain clear is still pending',
    () async {
      Get.testMode = true;
      final _HangingVault vault = _HangingVault();
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);
      Get.put<AuthTokenReader>(store, permanent: true);
      Get.put(ApiClient(tokenReader: store), permanent: true);
      Get.put(
        UsersRepository(Get.find<ApiClient>(), vault: _HangingVault()),
        permanent: true,
      );
      Get.put(AuthSessionController(), permanent: true);

      // Simulate Guest cleanup still occupying the Keychain queue.
      store.scheduleDiskClear();
      expect(vault.writeStarts + vault.deleteStarts, greaterThan(0));

      final Stopwatch watch = Stopwatch()..start();
      await Get.find<AuthSessionController>().completeSignIn(
        const CustomerAuthResponseModel(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          sessionId: 'session-id',
          userId: 'user-id',
          username: 'Yazan',
          phone: '+971501234567',
        ),
      );
      watch.stop();

      expect(
        watch.elapsedMilliseconds,
        lessThan(AppDimensions.secureStorageTimeout.inMilliseconds ~/ 10),
      );
      expect(
        Get.find<AuthSessionController>().hasAuthenticatedSession.value,
        isTrue,
      );
      expect(await store.readAccessToken(), 'access-token');
    },
  );
}

class _HangingVault implements SecureKeyValueStore {
  int writeStarts = 0;
  int deleteStarts = 0;
  int readStarts = 0;

  @override
  Future<String?> read(String key) {
    readStarts++;
    return Completer<String?>().future;
  }

  @override
  Future<void> write(String key, String value) {
    writeStarts++;
    return Completer<void>().future;
  }

  @override
  Future<void> delete(String key) {
    deleteStarts++;
    return Completer<void>().future;
  }
}

class _OrderedVault implements SecureKeyValueStore {
  int _inFlight = 0;
  int maxInFlight = 0;
  final List<String> completed = <String>[];

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {
    _inFlight++;
    if (_inFlight > maxInFlight) {
      maxInFlight = _inFlight;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
    completed.add(key);
    _inFlight--;
  }

  @override
  Future<void> delete(String key) async {}
}
