import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/features/auth/controller/login_controller.dart';
import 'package:tavla/features/auth/repository/auth_repository.dart';

/// Regression: after forgot-password complete, login must keep the verified
/// phone identity. Force-replacing LoginController wiped country/phone and
/// the picker fell back to AE, so login rejected the new password.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put(AuthRepository(), permanent: true);
  });

  tearDown(Get.reset);

  test(
    'prepareForPasswordResetReturn clears password and restores phone identity',
    () {
      final LoginController login = LoginController();
      Get.put(login, permanent: true);

      login.countryCode.value = AppStrings.authDefaultCountryCode;
      login.countryDialCode.value = AppStrings.authDefaultDialCode;
      login.phoneController.text = '501234567';
      login.passwordController.text = 'old-password';
      login.errorMessage.value = 'stale error';

      login.prepareForPasswordResetReturn(
        AppStrings.authPasswordResetComplete,
        countryCode: 'SY',
        dialCode: '+963',
        phoneNumber: '944123456',
      );

      expect(login.passwordController.text, isEmpty);
      expect(login.errorMessage.value, isNull);
      expect(login.countryCode.value, 'SY');
      expect(login.countryDialCode.value, '+963');
      expect(login.phoneController.text, '944123456');
      expect(login.successMessage.value, isNotNull);
    },
  );

  test(
    'password-reset return reuses LoginController instead of force-replacing it',
    () {
      final LoginController existing = AppDependency.putPermanentIfAbsent(
        LoginController.new,
      );
      existing.countryCode.value = 'SY';
      existing.countryDialCode.value = '+963';
      existing.phoneController.text = '944123456';
      existing.passwordController.text = 'typed-before-forgot';

      // Mirrors PasswordResetController success path.
      final LoginController afterReset = AppDependency.putPermanentIfAbsent(
        LoginController.new,
      );
      afterReset.prepareForPasswordResetReturn(
        AppStrings.authPasswordResetComplete,
        countryCode: 'SY',
        dialCode: '+963',
        phoneNumber: '944123456',
      );

      expect(identical(existing, afterReset), isTrue);
      expect(afterReset.countryCode.value, 'SY');
      expect(afterReset.phoneController.text, '944123456');
      expect(afterReset.passwordController.text, isEmpty);

      // Contrast: force putPermanent would wipe identity (the old bug).
      final LoginController forced = AppDependency.putPermanent(
        LoginController(),
      );
      expect(identical(existing, forced), isFalse);
      expect(forced.countryCode.value, AppStrings.authDefaultCountryCode);
      expect(forced.phoneController.text, isEmpty);
    },
  );
}
