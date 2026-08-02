import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/auth/controller/sign_up_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/otp_screen.dart';
import 'package:tavla/features/auth/view/sign_up_screen.dart';

import 'auth_e2e_helpers.dart';

/// Full sign-up journey against real screens/routes with a faked HTTP layer.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String validAePhone = '501234567';

  testWidgets(
    'sign-up journey: validation, API failure, success to OTP and back',
    (tester) async {
      final AuthE2eHarness harness = AuthE2eHarness();

      // Phase 1 — sign-up screen renders.
      await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.signUp));
      await settleAuth(tester);
      expect(find.byType(SignUpScreen), findsOneWidget);

      // Phase 2 — name filled but phone too short: blocked, no API call.
      await tester.enterText(find.byType(TextField).at(0), 'Yazan');
      await tester.enterText(find.byType(TextField).at(1), '5012');
      await tester.pump();
      final SignUpController controller = Get.find<SignUpController>();
      expect(controller.canSubmit.value, isFalse);
      expect(controller.phoneHint.value, isNotNull);
      expect(harness.adapter.requestCount, 0);

      // Phase 3 — NestJS-style list `message` must not crash the submit path.
      harness.adapter.responses[AuthRepository.customerRegisterStartPath] =
          () => jsonResponseBody(
            statusCode: 409,
            body: <String, dynamic>{
              'success': false,
              'message': <dynamic>[
                'username must be unique',
                'phoneNumber already used',
              ],
              'code': 409,
            },
          );
      await tester.enterText(find.byType(TextField).at(1), validAePhone);
      await tester.pump();
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await settleAuth(tester);
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        find.text(AppStrings.authUsernameAndPhoneAlreadyUsed),
        findsOneWidget,
      );
      expect(controller.isLoading.value, isFalse);

      // Phase 4 — string API error still surfaces.
      harness.adapter.responses[AuthRepository.customerRegisterStartPath] =
          () => jsonResponseBody(
            statusCode: 409,
            body: <String, dynamic>{
              'success': false,
              'message': 'Phone already registered',
            },
          );
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await settleAuth(tester);
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text(AppStrings.authPhoneAlreadyRegistered), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Phase 5 — API accepts: navigates to the OTP screen.
      harness.adapter.responses[AuthRepository.customerRegisterStartPath] =
          () => jsonResponseBody(
            statusCode: 200,
            body: <String, dynamic>{
              'success': true,
              'message': 'code sent',
              'data': null,
            },
          );
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await settleAuth(tester);
      expect(find.byType(OtpScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(controller.isLoading.value, isFalse);

      // Phase 6 — back from OTP returns to a working sign-up screen and
      // disposes the OTP resend timer with the route.
      Get.back();
      await settleAuth(tester);
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
