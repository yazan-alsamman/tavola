import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/routes/app_routes.dart';
import '../../../common/widgets/app_confirm_dialog.dart';
import '../../../common/widgets/app_success_toast.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_dependency.dart';
import '../../users/repository/users_repository.dart';
import '../model/auth_validation.dart';
import 'auth_session_controller.dart';

class DeleteAccountController extends GetxController {
  final UsersRepository _usersRepository = Get.find<UsersRepository>();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool canSubmit = false.obs;
  final RxBool showValidationHints = false.obs;
  final RxnString passwordHint = RxnString();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    passwordController.addListener(_onFieldsChanged);
    _updateValidation();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> submit() async {
    showValidationHints.value = true;
    _updateValidation();
    if (!canSubmit.value || isLoading.value) {
      return;
    }

    final bool confirmed = await AppConfirmDialog.show(
      title: AppStrings.areYouSure,
      message: AppStrings.deleteAccountConfirmMessage,
      icon: Symbols.person_off,
      destructiveMessage: true,
    );
    if (!confirmed || isClosed) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    var completed = false;
    String successMessage = AppStrings.deleteAccountSuccess;
    try {
      final result = await _usersRepository.requestAccountDeletion(
        password: passwordController.text,
      );
      if (result.message.trim().isNotEmpty) {
        successMessage = result.message.trim();
      }
      completed = true;
    } on ApiException catch (error) {
      if (!isClosed) {
        errorMessage.value = _mapDeletionError(error);
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

    if (!completed || isClosed) {
      return;
    }

    // Server already revoked every session — clear local state and leave shell.
    if (Get.isRegistered<AuthSessionController>()) {
      await Get.find<AuthSessionController>().logOut();
    } else {
      AppDependency.ensureLoginRouteDependencies();
      Get.offAllNamed(AppRoutes.welcome);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSuccessToast.show(
        title: AppStrings.deleteAccount,
        message: successMessage,
      );
    });
  }

  String _mapDeletionError(ApiException error) {
    if (error.code == 'OPEN_RESERVATIONS_BLOCK_DELETION' ||
        error.statusCode == 409) {
      return AppStrings.deleteAccountOpenReservations;
    }
    return error.message;
  }

  void _onFieldsChanged() {
    if (errorMessage.value != null) {
      errorMessage.value = null;
    }
    _updateValidation();
  }

  void _updateValidation() {
    final bool passwordValid = AuthValidation.isValidPassword(
      passwordController.text,
      AppDimensions.authMinPasswordLength,
    );
    canSubmit.value = passwordValid;
    passwordHint.value =
        !passwordValid &&
            (showValidationHints.value || passwordController.text.isNotEmpty)
        ? AppStrings.authPasswordHint
        : null;
  }

  @override
  void onClose() {
    passwordController.removeListener(_onFieldsChanged);
    passwordController.dispose();
    super.onClose();
  }
}
