import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/navigation/app_navigation.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/login_screen.dart';

import 'auth_e2e_helpers.dart';

/// Full login journey against real screens/routes with a faked HTTP layer.
///
/// Single continuous GetMaterialApp session (GetX keeps app-wide static
/// navigation state, so phases must run inside one testWidgets body).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String validAePhone = '501234567';
  const String password = 'secret-password';

  testWidgets(
    'login journey: validation, API failure, password-reset re-entry, success',
    (tester) async {
      final AuthE2eHarness harness = AuthE2eHarness();

      // Phase 1 — initial login screen renders.
      await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.login));
      await settleAuth(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      // Phase 2 — short phone: blocked submit + min-digits hint, no API call.
      await tester.enterText(find.byType(TextField).at(0), '5012');
      await tester.pump();
      final LoginController first = Get.find<LoginController>();
      expect(first.canSubmit.value, isFalse);
      expect(first.phoneHint.value, isNotNull);
      expect(harness.adapter.requestCount, 0);

      // Phase 3 — valid input but API rejects: error shown, no crash.
      const String apiError = 'Invalid phone or password';
      harness.adapter.responses[AuthRepository.customerLoginPath] = () =>
          jsonResponseBody(
            statusCode: 401,
            body: <String, dynamic>{'success': false, 'message': apiError},
          );
      await tester.enterText(find.byType(TextField).at(0), validAePhone);
      await tester.enterText(find.byType(TextField).at(1), password);
      await tester.pump();
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await settleAuth(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text(apiError), findsOneWidget);
      expect(Get.find<LoginController>().isLoading.value, isFalse);
      expect(await harness.tokenStore.readAccessToken(), isNull);
      expect(tester.takeException(), isNull);

      // Phase 4 — password-reset completion re-enters login via goShell while
      // the old login route is still mounted. Regression: putFresh must NOT
      // dispose the live controller mid-transition (previously crashed with
      // "TextEditingController was used after being disposed").
      AppNavigation.goShell(
        AppRoutes.login,
        arguments: AppStrings.authPasswordResetComplete,
      );
      await settleAuth(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      final LoginController second = Get.find<LoginController>();
      expect(identical(first, second), isFalse);
      expect(second.successMessage.value, isNotNull);
      expect(tester.takeException(), isNull);

      // Phase 5 — successful login on the fresh controller lands on home
      // with stored session tokens.
      harness.adapter.responses[AuthRepository.customerLoginPath] = () =>
          jsonResponseBody(
            statusCode: 200,
            body: <String, dynamic>{
              'success': true,
              'message': 'ok',
              'data': <String, dynamic>{
                'accessToken': 'access-e2e',
                'refreshToken': 'refresh-e2e',
                'sessionId': 'session-e2e',
                'user': <String, dynamic>{
                  'userId': 'user-e2e',
                  'username': 'Yazan',
                  'phone': '+971501234567',
                },
              },
            },
          );
      await tester.enterText(find.byType(TextField).at(0), validAePhone);
      await tester.enterText(find.byType(TextField).at(1), password);
      await tester.pump();
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await settleAuth(tester);

      expect(find.byKey(const Key('home-stub')), findsOneWidget);
      expect(await harness.tokenStore.readAccessToken(), 'access-e2e');
      expect(await harness.tokenStore.readRefreshToken(), 'refresh-e2e');
      expect(tester.takeException(), isNull);
    },
  );
}
