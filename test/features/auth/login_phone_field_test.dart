import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/common/widgets/auth_phone_field.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';
import 'package:tavla/features/auth/view/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.testMode = true;
    Get.put(AuthRepository());
    Get.put(LoginController());
  });

  tearDown(Get.reset);

  testWidgets('LoginScreen builds after password-reset success args', (
    tester,
  ) async {
    final LoginController login = Get.find<LoginController>();
    login.successMessage.value = AppStrings.authPasswordResetComplete;
    login.showPasswordResetSuccess.value = true;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        localizationsDelegates: const [
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        home: const LoginScreen(),
      ),
    );
    await tester.pump();
    // Drain LoginController.onReady warmIdle + any deferred timers.
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AuthPhoneField), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text(AppStrings.authPasswordResetComplete), findsWidgets);
    expect(find.text(AppStrings.resetPassword), findsWidgets);
    expect(login.showPasswordResetSuccess.value, isTrue);
  });
}
