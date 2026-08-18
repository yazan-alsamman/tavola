import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/network/secure_auth_token_store.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/model/customer_auth_response_model.dart';
import 'package:tavla/features/auth/model/session_mode.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/session_mode_preferences.dart';
import 'package:tavla/features/splash/controller/splash_controller.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

/// First login / registration must stay authenticated across restarts until
/// Logout revokes the server session and wipes local tokens + SessionMode.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppStrings.onboardingCompletedKey: true,
      AppStrings.favoriteCuisinesCompletedKey: true,
    });
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test(
    'first completeSignIn stays authenticated after simulated cold start',
    () async {
      final _MemoryVault vault = _MemoryVault();
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);
      Get.put<AuthTokenReader>(store);
      Get.put(ApiClient(tokenReader: store));
      Get.put(UsersRepository(Get.find<ApiClient>(), vault: vault));
      Get.put(AuthRepository());
      Get.put(AuthSessionController());

      await Get.find<AuthSessionController>().completeSignIn(
        const CustomerAuthResponseModel(
          accessToken: 'first-access',
          refreshToken: 'first-refresh',
          sessionId: 'session-1',
          userId: 'user-1',
          username: 'Yazan',
          phone: '+971501234567',
        ),
      );
      await Get.find<AuthSessionController>().flushPostLoginBootstrap();
      await store.flushPendingDiskWrites();

      expect(await SessionModePreferences.read(), SessionMode.authenticated);
      expect(vault.values[SecureAuthTokenStore.accessTokenKey], 'first-access');
      expect(
        vault.values[SecureAuthTokenStore.refreshTokenKey],
        'first-refresh',
      );

      // Cold start / process death: new controllers, same disk.
      Get.reset();
      final SecureAuthTokenStore restoredStore = SecureAuthTokenStore(
        vault: vault,
      );
      Get.put<AuthTokenReader>(restoredStore);
      Get.put(ApiClient(tokenReader: restoredStore));
      Get.put(AuthRepository());
      Get.put(AuthSessionController());

      expect(await SplashController.resolveDestination(), AppRoutes.home);
      final AuthSessionController session = Get.find<AuthSessionController>();
      expect(session.hasAuthenticatedSession.value, isTrue);
      expect(session.isGuest.value, isFalse);
      expect(session.isAnonymousGuest, isFalse);
      expect(await SessionModePreferences.read(), SessionMode.authenticated);
      expect(await restoredStore.readAccessToken(), 'first-access');
    },
  );

  test(
    'logOut POSTs /auth/logout, wipes Keychain + SessionMode, next start Welcome',
    () async {
      final _MemoryVault vault = _MemoryVault();
      final SecureAuthTokenStore store = SecureAuthTokenStore(vault: vault);
      final _RecordingAdapter adapter = _RecordingAdapter();
      final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = adapter;

      Get.put<AuthTokenReader>(store);
      Get.put(ApiClient(tokenReader: store));
      Get.put(UsersRepository(Get.find<ApiClient>(), vault: vault));
      Get.put(AuthRepository(dio: dio));
      Get.put(AuthSessionController());

      await Get.find<AuthSessionController>().completeSignIn(
        const CustomerAuthResponseModel(
          accessToken: 'live-access',
          refreshToken: 'live-refresh',
          sessionId: 'session-1',
          userId: 'user-1',
        ),
      );
      await Get.find<AuthSessionController>().flushPostLoginBootstrap();
      await store.flushPendingDiskWrites();
      expect(vault.values[SecureAuthTokenStore.accessTokenKey], isNotNull);

      try {
        await Get.find<AuthSessionController>().logOut();
      } catch (_) {
        // Navigation may throw without a GetMaterialApp shell.
      }

      expect(adapter.lastMethod, 'POST');
      expect(adapter.lastPath, AppUrls.authLogoutPath);
      expect(adapter.lastAuthorization, 'Bearer live-access');
      expect(await store.readAccessToken(), isNull);
      expect(await store.readRefreshToken(), isNull);
      expect(vault.values[SecureAuthTokenStore.accessTokenKey], isNull);
      expect(vault.values[SecureAuthTokenStore.refreshTokenKey], isNull);
      expect(await SessionModePreferences.read(), SessionMode.none);
      expect(
        Get.find<AuthSessionController>().hasAuthenticatedSession.value,
        isFalse,
      );
      expect(Get.find<AuthSessionController>().isGuest.value, isFalse);

      // Next cold start must be Welcome — not Guest Home, not authenticated.
      Get.reset();
      final SecureAuthTokenStore nextStore = SecureAuthTokenStore(vault: vault);
      Get.put<AuthTokenReader>(nextStore);
      Get.put(ApiClient(tokenReader: nextStore));
      Get.put(AuthRepository());
      Get.put(AuthSessionController());

      expect(await SplashController.resolveDestination(), AppRoutes.welcome);
      expect(
        Get.find<AuthSessionController>().hasAuthenticatedSession.value,
        isFalse,
      );
      expect(Get.find<AuthSessionController>().isAnonymousGuest, isFalse);
      expect(await SessionModePreferences.read(), SessionMode.none);
    },
  );
}

class _MemoryVault implements SecureKeyValueStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

class _RecordingAdapter implements HttpClientAdapter {
  String? lastMethod;
  String? lastPath;
  String? lastAuthorization;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastMethod = options.method;
    lastPath = options.path;
    lastAuthorization = options.headers['Authorization']?.toString();
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{'success': true}),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
