import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/controller/sign_up_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets(
    'requireSignInForProtectedAction opens Login when token missing',
    (tester) async {
      Get.testMode = true;
      Get.put<AuthTokenReader>(const EmptyAuthTokenReader(), permanent: true);
      Get.put(
        ApiClient(tokenReader: Get.find<AuthTokenReader>()),
        permanent: true,
      );
      Get.put(AuthSessionController(), permanent: true);
      Get.find<AuthSessionController>().hasAuthenticatedSession.value = true;

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          getPages: <GetPage<dynamic>>[
            GetPage<void>(
              name: '/home-stub',
              page: () => const Scaffold(body: Text('home')),
            ),
            GetPage<void>(
              name: AppRoutes.login,
              page: () => const Scaffold(body: Text('login-stub')),
            ),
          ],
          home: const Scaffold(body: Text('home')),
        ),
      );
      await tester.pump();

      final bool allowed = await Get.find<AuthSessionController>()
          .requireSignInForProtectedAction();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(allowed, isFalse);
      expect(
        Get.find<AuthSessionController>().hasAuthenticatedSession.value,
        isFalse,
      );
      expect(find.text('login-stub'), findsOneWidget);
    },
  );

  test('requireSignInForProtectedAction allows when token present', () async {
    Get.testMode = true;
    final _MemoryTokens tokens = _MemoryTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    Get.put<AuthTokenReader>(tokens, permanent: true);
    Get.put(AuthSessionController(), permanent: true);

    final bool allowed = await Get.find<AuthSessionController>()
        .requireSignInForProtectedAction();
    expect(allowed, isTrue);
    expect(
      Get.find<AuthSessionController>().hasAuthenticatedSession.value,
      isTrue,
    );
  });

  testWidgets('logOut clears session, shows bridge, then Welcome', (
    tester,
  ) async {
    Get.testMode = true;
    final _MemoryTokens tokens = _MemoryTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    Get.put<AuthTokenReader>(tokens, permanent: true);
    Get.put(AuthRepository(), permanent: true);
    Get.put(AuthSessionController(), permanent: true);
    final AuthSessionController session = Get.find<AuthSessionController>();
    session.hasAuthenticatedSession.value = true;
    session.isGuest.value = false;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        getPages: <GetPage<dynamic>>[
          GetPage<void>(
            name: '/home-stub',
            page: () => const Scaffold(body: Text('home')),
          ),
          GetPage<void>(
            name: AppRoutes.logoutTransition,
            page: () => const Scaffold(body: Text('logout-bridge-stub')),
          ),
          GetPage<void>(
            name: AppRoutes.welcome,
            page: () => const Scaffold(body: Text('welcome-stub')),
          ),
        ],
        home: const Scaffold(body: Text('home')),
      ),
    );
    await tester.pump();

    await session.logOut();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(session.hasAuthenticatedSession.value, isFalse);
    expect(session.isGuest.value, isFalse);
    expect(tokens.accessToken, isNull);
    expect(tokens.refreshToken, isNull);
    expect(find.text('logout-bridge-stub'), findsOneWidget);
    expect(find.text('welcome-stub'), findsNothing);
    expect(Get.isRegistered<LoginController>(), isTrue);
    expect(Get.isRegistered<SignUpController>(), isTrue);
  });
}

class _MemoryTokens implements AuthTokenSession {
  _MemoryTokens({this.accessToken, this.refreshToken});

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
