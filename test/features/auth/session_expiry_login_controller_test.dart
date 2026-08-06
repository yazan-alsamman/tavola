import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/login_screen.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

/// Regression: session expiry during Home must not build Login without
/// [LoginController] (crash: Get.find in LoginScreen.build).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets(
    'handleSessionExpired registers LoginController before Login shell',
    (WidgetTester tester) async {
      final List<FlutterErrorDetails> errors = <FlutterErrorDetails>[];
      final FlutterExceptionHandler? previous = FlutterError.onError;
      FlutterError.onError = errors.add;

      Get.testMode = true;
      final _MemoryTokens tokens = _MemoryTokens(
        accessToken: 'stale-access',
        refreshToken: 'stale-refresh',
      );
      Get.put<AuthTokenReader>(tokens, permanent: true);
      Get.put(AuthRepository(), permanent: true);
      Get.put(AuthSessionController(), permanent: true);
      Get.put(ApiClient(tokenReader: tokens), permanent: true);
      Get.find<AuthSessionController>().hasAuthenticatedSession.value = true;

      // Intentionally omit Login Binding — mirrors interceptor race where the
      // first LoginScreen frame can run before route Bindings finish.
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          getPages: <GetPage<dynamic>>[
            GetPage<void>(
              name: AppRoutes.login,
              page: () => const LoginScreen(),
            ),
            GetPage<void>(
              name: '/home-stub',
              page: () => const Scaffold(body: Text('home-stub')),
            ),
          ],
          home: const Scaffold(body: Text('home-stub')),
        ),
      );
      await tester.pump();

      expect(Get.isRegistered<LoginController>(), isFalse);

      await Get.find<AuthSessionController>().handleSessionExpired();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(Get.isRegistered<LoginController>(), isTrue);
      expect(Get.isRegistered<UsersRepository>(), isFalse);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        errors.where(
          (FlutterErrorDetails e) =>
              e.exceptionAsString().contains('LoginController'),
        ),
        isEmpty,
        reason: errors
            .map((FlutterErrorDetails e) => e.exceptionAsString())
            .join('\n'),
      );

      FlutterError.onError = previous;
    },
  );
}

class _MemoryTokens implements AuthTokenSession {
  _MemoryTokens({
    required String this.accessToken,
    required String this.refreshToken,
  });

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
    bool persistToDisk = true,
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
