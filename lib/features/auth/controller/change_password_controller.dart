import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../common/widgets/app_success_toast.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../../core/utils/app_dependency.dart';
import '../model/auth_session_tokens_model.dart';
import '../model/auth_validation.dart';
import '../model/change_password_request_model.dart';
import '../repository/auth_repository.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool obscureCurrentPassword = true.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool showPasswordMismatch = false.obs;
  final RxBool canSubmit = false.obs;
  final RxBool showValidationHints = false.obs;
  final RxnString currentPasswordHint = RxnString();
  final RxnString passwordHint = RxnString();
  final RxnString confirmPasswordHint = RxnString();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    currentPasswordController.addListener(_onFieldsChanged);
    passwordController.addListener(_onFieldsChanged);
    confirmPasswordController.addListener(_onFieldsChanged);
    _updateValidation();
  }

  void toggleCurrentPasswordVisibility() {
    obscureCurrentPassword.value = !obscureCurrentPassword.value;
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
      if (!Get.isRegistered<AuthTokenReader>()) {
        throw ApiException(message: AppStrings.authRefreshTokenMissing);
      }
      final String? access =
          await Get.find<AuthTokenReader>().readAccessToken();
      if (access == null || access.trim().isEmpty) {
        throw ApiException(message: AppStrings.authRefreshTokenMissing);
      }

      final AuthSessionTokensModel? rotated =
          await _authRepository.changePassword(
        accessToken: access,
        request: ChangePasswordRequestModel(
          currentPassword: currentPasswordController.text,
          newPassword: passwordController.text,
        ),
      );
      if (rotated != null && Get.isRegistered<AuthTokenReader>()) {
        final AuthTokenReader reader = Get.find<AuthTokenReader>();
        if (reader is AuthTokenSession) {
          await reader.updateSessionTokens(
            accessToken: rotated.accessToken,
            refreshToken: rotated.refreshToken,
          );
        }
      }
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

    if (completed && !isClosed) {
      // Skip Home navigation when the shell DI graph is unavailable (unit tests).
      if (!Get.isRegistered<ApiClient>()) {
        return;
      }
      // Return to Home first so the frosted success banner is not torn down
      // with the Change Password route during `offAllNamed`.
      AppDependency.ensureHomeController();
      AppNavigation.goShell(AppRoutes.home);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSuccessToast.show(
          title: AppStrings.changePassword,
          message: AppStrings.changePasswordSuccess,
        );
      });
    }
  }

  void _onFieldsChanged() {
    if (showPasswordMismatch.value) {
      showPasswordMismatch.value = false;
    }
    if (errorMessage.value != null) {
      errorMessage.value = null;
    }
    _updateValidation();
  }

  void _updateValidation() {
    final bool currentValid = AuthValidation.isValidPassword(
      currentPasswordController.text,
      AppDimensions.authMinPasswordLength,
    );
    final bool passwordValid = AuthValidation.isValidPassword(
      passwordController.text,
      AppDimensions.authMinPasswordLength,
    );
    final bool confirmPasswordValid = AuthValidation.isValidPassword(
      confirmPasswordController.text,
      AppDimensions.authMinPasswordLength,
    );
    canSubmit.value = currentValid && passwordValid && confirmPasswordValid;
    currentPasswordHint.value =
        !currentValid &&
            (showValidationHints.value ||
                currentPasswordController.text.isNotEmpty)
        ? AppStrings.authPasswordHint
        : null;
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
    currentPasswordController.removeListener(_onFieldsChanged);
    passwordController.removeListener(_onFieldsChanged);
    confirmPasswordController.removeListener(_onFieldsChanged);
    currentPasswordController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
