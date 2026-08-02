import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/controller/sign_up_controller.dart';
import 'package:tavla/features/auth/model/customer_auth_response_model.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/login_screen.dart';
import 'package:tavla/features/auth/view/sign_up_screen.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';

import 'auth_e2e_helpers.dart';

/// Login / Sign-up must never spin forever or crash on API errors.
///
/// Single continuous GetMaterialApp session (GetX keeps static navigation
/// state across testWidgets bodies).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  const String validAePhone = '501234567';
  const String password = 'secret-password';

  testWidgets(
    'login/signup: wrong password, unique conflict, and hangs clear loading',
    (tester) async {
      final AuthE2eHarness harness = AuthE2eHarness();

      // ---------- LOGIN: wrong password ----------
      const String apiError = 'Invalid phone or password';
      harness.adapter.responses[AuthRepository.customerLoginPath] = () =>
          jsonResponseBody(
            statusCode: 401,
            body: <String, dynamic>{
              'success': false,
              'message': apiError,
              'code': 'UNAUTHORIZED',
            },
          );

      await tester.pumpWidget(harness.buildApp(initialRoute: AppRoutes.login));
      await settleAuth(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), validAePhone);
      await tester.enterText(find.byType(TextField).at(1), password);
      await tester.pump();

      final LoginController login = Get.find<LoginController>();
      expect(login.canSubmit.value, isTrue);

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(login.isLoading.value, isTrue);

      await settleAuth(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(login.isLoading.value, isFalse);
      expect(login.errorMessage.value, apiError);
      expect(find.text(apiError), findsOneWidget);
      expect(await harness.tokenStore.readAccessToken(), isNull);

      // ---------- LOGIN: unreachable host hang ----------
      harness.adapter.hangForever = true;
      login.errorMessage.value = null;
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(login.isLoading.value, isTrue);

      await tester.pump(AppDimensions.authSubmitTimeout);
      await tester.pump();
      await settleAuth(tester);

      expect(tester.takeException(), isNull);
      expect(login.isLoading.value, isFalse);
      expect(login.errorMessage.value, isNotNull);
      expect(
        login.errorMessage.value,
        anyOf(
          AppStrings.networkTimeoutError,
          AppStrings.networkConnectionError,
          AppStrings.networkUnexpectedError,
        ),
      );

      // ---------- SIGN UP: unique conflict ----------
      harness.adapter.hangForever = false;
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

      Get.toNamed(AppRoutes.signUp);
      await settleAuth(tester);
      expect(find.byType(SignUpScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'UniqueUser');
      await tester.enterText(find.byType(TextField).at(1), validAePhone);
      await tester.pump();

      final SignUpController signUp = Get.find<SignUpController>();
      expect(signUp.canSubmit.value, isTrue);

      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(signUp.isLoading.value, isTrue);

      await settleAuth(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(signUp.isLoading.value, isFalse);
      expect(
        find.text(AppStrings.authUsernameAndPhoneAlreadyUsed),
        findsOneWidget,
      );

      // ---------- SIGN UP: hang ----------
      harness.adapter.hangForever = true;
      signUp.errorMessage.value = null;
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(signUp.isLoading.value, isTrue);

      await tester.pump(AppDimensions.authSubmitTimeout);
      await tester.pump();
      await settleAuth(tester);

      expect(tester.takeException(), isNull);
      expect(signUp.isLoading.value, isFalse);
      expect(signUp.errorMessage.value, isNotNull);
      expect(find.byType(SignUpScreen), findsOneWidget);
    },
  );

  test('malformed login token payload does not throw TypeError', () {
    final CustomerAuthResponseModel model = CustomerAuthResponseModel.fromJson(
      <String, dynamic>{
        'accessToken': <String, dynamic>{'nested': true},
        'refreshToken': 12345,
        'sessionId': null,
        'user': <String, dynamic>{
          'userId': <dynamic>['x'],
          'username': true,
          'phone': null,
        },
      },
    );

    expect(model.isValid, isFalse);
    expect(model.accessToken, isEmpty);
    expect(model.refreshToken, '12345');
  });
}
