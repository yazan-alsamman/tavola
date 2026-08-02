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
    Get.testMode = true;
    Get.reset();
    Get.put(AuthRepository());
    Get.put(LoginController());
  });

  tearDown(Get.reset);

  testWidgets('LoginScreen builds after password-reset success args', (
    tester,
  ) async {
    Get.find<LoginController>().successMessage.value =
        AppStrings.authPasswordResetComplete;

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
    await tester.pump();

    expect(find.byType(AuthPhoneField), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(Get.find<LoginController>().successMessage.value, isNotNull);
  });
}
