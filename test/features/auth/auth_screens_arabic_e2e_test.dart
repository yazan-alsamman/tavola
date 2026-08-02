import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/view/login_screen.dart';
import 'package:tavla/features/auth/view/sign_up_screen.dart';

import 'auth_e2e_helpers.dart';

/// Arabic-locale rendering of the auth screens (local Amiri/Cairo fonts).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String validAePhone = '501234567';
  const String password = 'secret-password';

  testWidgets('login and sign-up render and validate in Arabic locale', (
    tester,
  ) async {
    final AuthE2eHarness harness = AuthE2eHarness();

    await tester.pumpWidget(
      harness.buildApp(
        initialRoute: AppRoutes.login,
        locale: const Locale('ar'),
      ),
    );
    await settleAuth(tester);
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), validAePhone);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.pump();
    expect(Get.find<LoginController>().canSubmit.value, isTrue);
    expect(tester.takeException(), isNull);

    Get.toNamed(AppRoutes.signUp);
    await settleAuth(tester);
    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
