import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/model/customer_auth_response_model.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

/// Login critical path must return after token persistence — identity Keychain
/// writes must not block navigation to Home.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test(
    'completeSignIn returns before identity Keychain write starts',
    () async {
      Get.testMode = true;
      final _MemoryTokens tokens = _MemoryTokens();
      Get.put<AuthTokenReader>(tokens, permanent: true);
      Get.put(ApiClient(tokenReader: tokens), permanent: true);
      final _SlowIdentityUsers users = _SlowIdentityUsers();
      Get.put<UsersRepository>(users, permanent: true);
      Get.put(AuthSessionController(), permanent: true);

      final Future<void> signIn = Get.find<AuthSessionController>()
          .completeSignIn(
            const CustomerAuthResponseModel(
              accessToken: 'access-token',
              refreshToken: 'refresh-token',
              sessionId: 'session-id',
              userId: 'user-id',
              username: 'Yazan',
              phone: '+971501234567',
            ),
          );

      // Must complete without waiting for the deferred identity write.
      await signIn.timeout(const Duration(milliseconds: 100));
      await Future<void>.delayed(Duration.zero);

      expect(tokens.accessToken, 'access-token');
      expect(tokens.refreshToken, 'refresh-token');
      expect(
        Get.find<AuthSessionController>().hasAuthenticatedSession.value,
        isTrue,
      );
      expect(Get.find<AuthSessionController>().isGuest.value, isFalse);
      // Identity Keychain must stay off the Login critical path.
      expect(users.identityStarted, isFalse);

      final Future<void> deferred = Get.find<AuthSessionController>()
          .persistDeferredSessionArtifacts();
      await Future<void>.delayed(Duration.zero);
      expect(users.identityStarted, isTrue);
      expect(users.identityCompleted, isFalse);

      users.completeIdentity();
      await deferred.timeout(const Duration(milliseconds: 100));
      expect(users.identityCompleted, isTrue);
    },
  );
}

class _MemoryTokens implements AuthTokenSession {
  String? accessToken;
  String? refreshToken;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearSessionTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

class _SlowIdentityUsers extends UsersRepository {
  _SlowIdentityUsers() : super(Get.find<ApiClient>());

  final Completer<void> _identity = Completer<void>();
  bool identityStarted = false;
  bool identityCompleted = false;

  Future<void> get identityFuture => _identity.future;

  void completeIdentity() {
    if (!_identity.isCompleted) {
      _identity.complete();
    }
  }

  @override
  Future<void> rememberCustomerIdentity({
    required String username,
    required String phone,
  }) async {
    identityStarted = true;
    await _identity.future;
    identityCompleted = true;
  }
}
