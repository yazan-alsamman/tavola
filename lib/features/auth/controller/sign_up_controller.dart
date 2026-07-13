import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../model/auth_validation.dart';

class SignUpController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final RxString countryDialCode = AppStrings.authDefaultDialCode.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool showPasswordMismatch = false.obs;
  final RxBool canSubmit = false.obs;
  final RxBool showValidationHints = false.obs;
  final RxnString nameHint = RxnString();
  final RxnString phoneHint = RxnString();
  final RxnString passwordHint = RxnString();
  final RxnString confirmPasswordHint = RxnString();

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_onFieldsChanged);
    phoneController.addListener(_onFieldsChanged);
    passwordController.addListener(_onFieldsChanged);
    confirmPasswordController.addListener(_onFieldsChanged);
    _updateValidation();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void updateCountryCode(CountryCode countryCode) {
    countryDialCode.value =
        countryCode.dialCode ?? AppStrings.authDefaultDialCode;
  }

  String get fullPhoneNumber {
    final String localNumber = phoneController.text.trim();
    return '${countryDialCode.value} $localNumber';
  }

  void submit() {
    showValidationHints.value = true;
    _updateValidation();

    if (!canSubmit.value) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showPasswordMismatch.value = true;
      return;
    }

    showPasswordMismatch.value = false;
    Get.toNamed(AppRoutes.otp, arguments: fullPhoneNumber);
  }

  void _onFieldsChanged() {
    if (showPasswordMismatch.value) {
      showPasswordMismatch.value = false;
    }
    _updateValidation();
  }

  void _updateValidation() {
    final bool nameValid = nameController.text.trim().isNotEmpty;
    final bool phoneValid = AuthValidation.hasMinDigits(
      phoneController.text,
      AppDimensions.authMinDigitCount,
    );
    final bool passwordValid = AuthValidation.isValidPassword(
      passwordController.text,
      AppDimensions.authMinPasswordLength,
    );
    final bool confirmPasswordValid = AuthValidation.isValidPassword(
      confirmPasswordController.text,
      AppDimensions.authMinPasswordLength,
    );

    canSubmit.value =
        nameValid && phoneValid && passwordValid && confirmPasswordValid;

    nameHint.value =
        !nameValid && showValidationHints.value ? AppStrings.authNameRequiredHint : null;

    phoneHint.value = !phoneValid &&
            (showValidationHints.value || phoneController.text.isNotEmpty)
        ? AppStrings.authMinDigitsHint
        : null;

    passwordHint.value = !passwordValid &&
            (showValidationHints.value || passwordController.text.isNotEmpty)
        ? AppStrings.authPasswordHint
        : null;

    confirmPasswordHint.value = !confirmPasswordValid &&
            (showValidationHints.value ||
                confirmPasswordController.text.isNotEmpty)
        ? AppStrings.authPasswordHint
        : null;
  }

  void openLogin() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.removeListener(_onFieldsChanged);
    phoneController.removeListener(_onFieldsChanged);
    passwordController.removeListener(_onFieldsChanged);
    confirmPasswordController.removeListener(_onFieldsChanged);
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
