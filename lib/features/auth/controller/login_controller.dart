import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../home/home_entry_warmup.dart';
import '../model/auth_device.dart';
import '../model/auth_validation.dart';
import '../model/customer_auth_otp_route_args.dart';
import '../model/customer_auth_response_model.dart';
import '../model/customer_login_request_model.dart';
import '../model/customer_password_reset_request_models.dart';
import '../repository/auth_repository.dart';
import 'auth_session_controller.dart';
import 'sign_up_controller.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxString countryCode = AppStrings.authDefaultCountryCode.obs;
  final RxString countryDialCode = AppStrings.authDefaultDialCode.obs;
  final RxInt phoneMaxLength = AuthValidation.phoneNsnConstraints(
    AppStrings.authDefaultCountryCode,
  ).maxLength.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool canSubmit = false.obs;
  final RxBool showValidationHints = false.obs;
  final RxnString phoneHint = RxnString();
  final RxnString passwordHint = RxnString();
  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_updateValidation);
    passwordController.addListener(_updateValidation);
    final Object? arguments = Get.arguments;
    if (arguments is String && arguments.trim().isNotEmpty) {
      successMessage.value = arguments;
    }
    _updateValidation();
  }

  /// Surfaces one-shot route success copy (e.g. password reset complete)
  /// even when this permanent controller is already alive.
  void showSuccessMessage(String message) {
    final String trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }
    successMessage.value = trimmed;
    errorMessage.value = null;
  }

  /// Called when password reset completes and Login is shown again.
  ///
  /// Clears stale password/error state from the permanent controller so the
  /// next submit uses only the newly entered password. Optionally restores
  /// the phone identity verified during reset — recreating LoginController
  /// would wipe that and leave the country picker on the AE default, so
  /// login would send the wrong `countryCode` with the new password.
  void prepareForPasswordResetReturn(
    String message, {
    String? countryCode,
    String? dialCode,
    String? phoneNumber,
  }) {
    passwordController.clear();
    errorMessage.value = null;
    showValidationHints.value = false;
    if (countryCode != null && countryCode.trim().isNotEmpty) {
      this.countryCode.value = countryCode.trim().toUpperCase();
    }
    if (dialCode != null && dialCode.trim().isNotEmpty) {
      countryDialCode.value = dialCode.trim();
    }
    if (phoneNumber != null) {
      phoneController.text = AuthValidation.digitsOnly(phoneNumber);
    }
    _applyCountryPhoneLimits();
    _updateValidation();
    showSuccessMessage(message);
  }

  @override
  void onReady() {
    super.onReady();
    // Login → Home is the other first-entry path; warm while user types.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (isClosed) {
        return;
      }
      unawaited(HomeEntryWarmup.warmIdle());
    });
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void updateCountryCode(CountryCode selected) {
    countryCode.value = (selected.code ?? AppStrings.authDefaultCountryCode)
        .toUpperCase();
    countryDialCode.value = selected.dialCode ?? AppStrings.authDefaultDialCode;
    _applyCountryPhoneLimits();
    _updateValidation();
  }

  /// [CountryCodePicker.onInit] runs during [State.didChangeDependencies],
  /// so reactive updates must be deferred to avoid Obx rebuild-during-build.
  void syncCountryCode(CountryCode? selected) {
    if (selected == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) {
        return;
      }
      updateCountryCode(selected);
    });
  }

  void _applyCountryPhoneLimits() {
    final PhoneNsnConstraints constraints = AuthValidation.phoneNsnConstraints(
      countryCode.value,
    );
    if (phoneMaxLength.value != constraints.maxLength) {
      phoneMaxLength.value = constraints.maxLength;
    }
    final String digits = AuthValidation.digitsOnly(phoneController.text);
    if (digits.length > constraints.maxLength) {
      phoneController.text = digits.substring(0, constraints.maxLength);
      phoneController.selection = TextSelection.collapsed(
        offset: phoneController.text.length,
      );
    }
  }

  bool _isPhoneValid() {
    return AuthValidation.isValidNationalPhone(
      phoneController.text,
      countryCode.value,
    );
  }

  String? _phoneHintMessage() {
    if (_isPhoneValid()) {
      return null;
    }
    final PhoneNsnConstraints constraints = AuthValidation.phoneNsnConstraints(
      countryCode.value,
    );
    if (constraints.hasLengthMetadata) {
      return AppStrings.authPhoneMinDigitsHint(constraints.minLength);
    }
    return AppStrings.authPhoneInvalidHint;
  }

  Future<void> submit() async {
    final Stopwatch total = Stopwatch()..start();
    showValidationHints.value = true;
    _updateValidation();
    if (!canSubmit.value || isLoading.value) {
      return;
    }

    isLoading.value = true;
    isSuccess.value = false;
    errorMessage.value = null;
    successMessage.value = null;
    var signedIn = false;
    try {
      final Stopwatch httpWatch = Stopwatch()..start();
      final CustomerAuthResponseModel response = await _authRepository
          .loginCustomer(
            CustomerLoginRequestModel(
              countryCode: countryCode.value.trim().toUpperCase(),
              phoneNumber: AuthValidation.digitsOnly(phoneController.text),
              password: passwordController.text,
              deviceName: AuthDevice.name,
              deviceType: AuthDevice.type,
            ),
          );
      _loginPerf('http+decode', httpWatch);

      // Token persistence is memory-first; Keychain is off the critical path.
      final Stopwatch sessionWatch = Stopwatch()..start();
      await Get.find<AuthSessionController>().completeSignIn(response);
      _loginPerf('completeSignIn', sessionWatch);

      if (!isClosed) {
        isSuccess.value = true;
      }
      signedIn = true;
    } on ApiException catch (error) {
      if (!isClosed) {
        errorMessage.value = error.message;
      }
    } on TimeoutException {
      if (!isClosed) {
        errorMessage.value = AppStrings.networkTimeoutError;
      }
    } on DioException catch (error, stack) {
      // Repository should map Dio → ApiException; surface + log if one escapes.
      if (kDebugMode) {
        debugPrint('[Login] unmapped DioException: $error\n$stack');
      }
      if (!isClosed) {
        errorMessage.value = AppStrings.networkUnexpectedError;
      }
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('[Login] unexpected error: $error\n$stack');
      }
      if (!isClosed) {
        errorMessage.value = AppStrings.networkUnexpectedError;
      }
    } finally {
      // Always clear the spinner — permanent LoginController must not stay
      // stuck in loading after a failed/hung API call.
      if (!isClosed) {
        isLoading.value = false;
      }
    }

    // goShell disposes route widgets — never touch Rx after it.
    if (signedIn && !isClosed) {
      final Stopwatch navWatch = Stopwatch()..start();
      AppNavigation.goShell(AppRoutes.home);
      _loginPerf('goShell(home)', navWatch);
      _loginPerf('submit total (pre-Home)', total);
    }
  }

  static void _loginPerf(String label, Stopwatch stopwatch) {
    if (kDebugMode) {
      debugPrint('[LoginPerf] $label: ${stopwatch.elapsedMicroseconds}µs');
    }
  }

  void openSignUp() {
    if (Get.isRegistered<SignUpController>()) {
      Get.find<SignUpController>().resetForEntry();
    }
    AppNavigation.pushOnce(AppRoutes.signUp);
  }

  /// Requests a WhatsApp OTP via `POST /auth/customer/password-reset/start`,
  /// then opens the shared OTP screen (resend/verify use password-reset APIs).
  Future<void> forgotPassword() async {
    showValidationHints.value = true;
    final bool phoneValid = _isPhoneValid();
    phoneHint.value = phoneValid ? null : _phoneHintMessage();
    if (!phoneValid || isLoading.value) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;
    try {
      final String phoneNumber = AuthValidation.digitsOnly(
        phoneController.text,
      );
      final String normalizedCountryCode = countryCode.value
          .trim()
          .toUpperCase();

      // Sends the password-reset OTP (enumeration-resistant on the API).
      await _authRepository.startCustomerPasswordReset(
        CustomerPasswordResetStartRequestModel(
          countryCode: normalizedCountryCode,
          phoneNumber: phoneNumber,
        ),
      );

      AppNavigation.pushNamed(
        AppRoutes.otp,
        allowDuplicate: true,
        arguments: CustomerAuthOtpRouteArgs(
          purpose: CustomerAuthOtpPurpose.passwordReset,
          countryCode: normalizedCountryCode,
          dialCode: countryDialCode.value,
          phoneNumber: phoneNumber,
        ),
      );
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
  }

  void _updateValidation() {
    if (successMessage.value != null &&
        (phoneController.text.isNotEmpty ||
            passwordController.text.isNotEmpty)) {
      successMessage.value = null;
    }
    final bool phoneValid = _isPhoneValid();
    final bool passwordValid = AuthValidation.isLoginPassword(
      passwordController.text,
    );
    canSubmit.value = phoneValid && passwordValid;
    phoneHint.value =
        !phoneValid &&
            (showValidationHints.value || phoneController.text.isNotEmpty)
        ? _phoneHintMessage()
        : null;
    passwordHint.value =
        !passwordValid &&
            (showValidationHints.value || passwordController.text.isNotEmpty)
        ? AppStrings.authLoginPasswordMinHint(
            AppDimensions.authMinPasswordLength,
          )
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
