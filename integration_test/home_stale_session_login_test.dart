import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/login_screen.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/view/home_screen.dart';

class _StaleTokens implements AuthTokenSession {
  String? access = 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MDAwMDAwMDB9.sig';
  String? refresh = 'stale-refresh-token-value';

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
    bool persistToDisk = true,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clearSessionTokens() async {
    access = null;
    refresh = null;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'stale Home session redirects to Login without LoginController crash',
    (WidgetTester tester) async {
      final List<String> errors = <String>[];
      final FlutterExceptionHandler? old = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        errors.add(details.exceptionAsString());
      };

      await runZonedGuarded(
        () async {
          Get.reset();
          final _StaleTokens tokens = _StaleTokens();
          Get.put<AuthTokenReader>(tokens, permanent: true);
          Get.put(AuthRepository(), permanent: true);
          Get.put(AuthSessionController(), permanent: true);
          Get.find<AuthSessionController>().hasAuthenticatedSession.value =
              true;
          Get.put(
            ApiClient(
              tokenReader: tokens,
              authRepository: Get.find<AuthRepository>(),
              onSessionExpired: () async {
                await Get.find<AuthSessionController>().handleSessionExpired();
              },
            ),
            permanent: true,
          );
          Get.put(LocaleController(), permanent: true);
          AppDependency.ensureHomeDependencies();

          // Login page intentionally has no Binding — expiry must pre-register.
          await tester.pumpWidget(
            GetMaterialApp(
              translations: AppTranslations(),
              locale: const Locale('en'),
              fallbackLocale: const Locale('en'),
              initialRoute: AppRoutes.home,
              getPages: <GetPage<dynamic>>[
                GetPage<void>(
                  name: AppRoutes.home,
                  page: () => const HomeScreen(),
                  binding: BindingsBuilder(() {
                    AppDependency.ensureHomeDependencies();
                    AppDependency.putPermanentIfAbsent(HomeController.new);
                  }),
                ),
                GetPage<void>(
                  name: AppRoutes.login,
                  page: () => const LoginScreen(),
                ),
              ],
            ),
          );

          await tester.pump();
          await Future<void>.delayed(const Duration(seconds: 6));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          expect(Get.isRegistered<LoginController>(), isTrue);
          expect(find.byType(LoginScreen), findsOneWidget);
          expect(
            errors.where((String e) => e.contains('LoginController')),
            isEmpty,
            reason: errors.join('\n'),
          );
        },
        (Object error, StackTrace stack) {
          errors.add('$error');
        },
      );

      FlutterError.onError = old;
      expect(
        errors.where((String e) => e.contains('LoginController')),
        isEmpty,
      );
    },
  );
}
