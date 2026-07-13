import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../model/auth_validation.dart';
import 'auth_session_controller.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool canSubmit = false.obs;
  final RxBool showValidationHints = false.obs;
  final RxnString phoneHint = RxnString();
  final RxnString passwordHint = RxnString();

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_updateValidation);
    passwordController.addListener(_updateValidation);
    _updateValidation();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void submit() {
    showValidationHints.value = true;
    _updateValidation();

    if (!canSubmit.value) {
      return;
    }

    Get.find<AuthSessionController>().completeSignIn();
    Get.offAllNamed(AppRoutes.home);
  }

  void openSignUp() {
    Get.toNamed(AppRoutes.signUp);
  }

  void forgotPassword() {}

  void _updateValidation() {
    final bool phoneValid = AuthValidation.hasMinDigits(
      phoneController.text,
      AppDimensions.authMinDigitCount,
    );
    final bool passwordValid = AuthValidation.isValidPassword(
      passwordController.text,
      AppDimensions.authMinPasswordLength,
    );

    canSubmit.value = phoneValid && passwordValid;

    phoneHint.value = !phoneValid &&
            (showValidationHints.value || phoneController.text.isNotEmpty)
        ? AppStrings.authMinDigitsHint
        : null;

    passwordHint.value = !passwordValid &&
            (showValidationHints.value || passwordController.text.isNotEmpty)
        ? AppStrings.authPasswordHint
        : null;
  }

  @override
  void onClose() {
    phoneController.removeListener(_updateValidation);
    passwordController.removeListener(_updateValidation);
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
