import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_dependency.dart';
import '../model/auth_validation.dart';
import '../model/customer_auth_otp_route_args.dart';
import '../model/customer_password_reset_request_models.dart';
import '../repository/auth_repository.dart';
import 'login_controller.dart';

class PasswordResetController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  late final CustomerAuthOtpRouteArgs resetArgs;

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool showPasswordMismatch = false.obs;
  final RxBool canSubmit = false.obs;
  final RxBool showValidationHints = false.obs;
  final RxnString passwordHint = RxnString();
  final RxnString confirmPasswordHint = RxnString();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final Object? args = Get.arguments;
    resetArgs = args is CustomerAuthOtpRouteArgs
        ? args
        : const CustomerAuthOtpRouteArgs(
            purpose: CustomerAuthOtpPurpose.passwordReset,
            countryCode: AppStrings.authDefaultCountryCode,
            dialCode: AppStrings.authDefaultDialCode,
            phoneNumber: AppStrings.empty,
          );
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

  Future<void> submit() async {
    showValidationHints.value = true;
    _updateValidation();
    if (!canSubmit.value || isLoading.value) {
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      showPasswordMismatch.value = true;
      return;
    }

    showPasswordMismatch.value = false;
    isLoading.value = true;
    errorMessage.value = null;
    var completed = false;
    try {
      await _authRepository.completeCustomerPasswordReset(
        CustomerPasswordResetCompleteRequestModel(
          countryCode: resetArgs.countryCode,
          phoneNumber: resetArgs.phoneNumber,
          newPassword: passwordController.text,
        ),
      );
      completed = true;
    } on ApiException catch (error) {
      if (!isClosed) {
        errorMessage.value = error.message;
      }
    } catch (_) {
      if (!isClosed) {
        errorMessage.value = AppStrings.networkUnexpectedError;
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }

    // Navigate only after clearing loading — goShell disposes this controller.
    if (completed && !isClosed) {
      // Reset LoginController to avoid stale permanent-state after password
      // reset (old password/error values can survive across route re-entry).
      final LoginController loginController = AppDependency.putPermanent(
        LoginController(),
      );
      loginController.prepareForPasswordResetReturn(
        AppStrings.authPasswordResetComplete,
      );
      AppNavigation.goShell(
        AppRoutes.login,
        arguments: AppStrings.authPasswordResetComplete,
      );
    }
  }

  void _onFieldsChanged() {
    if (showPasswordMismatch.value) {
      showPasswordMismatch.value = false;
    }
    _updateValidation();
  }

  void _updateValidation() {
    final bool passwordValid = AuthValidation.isValidPassword(
      passwordController.text,
      AppDimensions.authMinPasswordLength,
    );
    final bool confirmPasswordValid = AuthValidation.isValidPassword(
      confirmPasswordController.text,
      AppDimensions.authMinPasswordLength,
    );
    canSubmit.value = passwordValid && confirmPasswordValid;
    passwordHint.value =
        !passwordValid &&
            (showValidationHints.value || passwordController.text.isNotEmpty)
        ? AppStrings.authPasswordHint
        : null;
    confirmPasswordHint.value =
        !confirmPasswordValid &&
            (showValidationHints.value ||
                confirmPasswordController.text.isNotEmpty)
        ? AppStrings.authPasswordHint
        : null;
  }

  @override
  void onClose() {
    passwordController.removeListener(_onFieldsChanged);
    confirmPasswordController.removeListener(_onFieldsChanged);
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
