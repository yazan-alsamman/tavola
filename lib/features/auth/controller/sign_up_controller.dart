import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../model/auth_validation.dart';
import '../model/customer_auth_otp_route_args.dart';
import '../model/customer_registration_request_models.dart';
import '../repository/auth_repository.dart';

enum SignUpErrorKind { none, uniqueConflict, other }

/// Sign-up step 1: username + phone → `POST /auth/customer/register/start`.
class SignUpController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final RxString countryCode = AppStrings.authDefaultCountryCode.obs;
  final RxString countryDialCode = AppStrings.authDefaultDialCode.obs;
  final RxInt phoneMaxLength = AuthValidation.phoneNsnConstraints(
    AppStrings.authDefaultCountryCode,
  ).maxLength.obs;
  final RxBool canSubmit = false.obs;
  final RxBool showValidationHints = false.obs;
  final RxnString nameHint = RxnString();
  final RxnString phoneHint = RxnString();
  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final RxnString errorMessage = RxnString();
  final Rx<SignUpErrorKind> errorKind = SignUpErrorKind.none.obs;

  bool get hasUniqueConflictError =>
      errorKind.value == SignUpErrorKind.uniqueConflict;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_updateValidation);
    phoneController.addListener(_updateValidation);
    _updateValidation();
  }

  /// Reuse-safe reset for permanent SignUp controller instances.
  ///
  /// Keeps TextEditingControllers alive (no dispose/recreate churn) while
  /// clearing stale API/loading/validation state before opening Sign Up again.
  void resetForEntry() {
    if (isLoading.value) {
      return;
    }
    nameController.clear();
    phoneController.clear();
    countryCode.value = AppStrings.authDefaultCountryCode;
    countryDialCode.value = AppStrings.authDefaultDialCode;
    final PhoneNsnConstraints constraints = AuthValidation.phoneNsnConstraints(
      AppStrings.authDefaultCountryCode,
    );
    phoneMaxLength.value = constraints.maxLength;
    canSubmit.value = false;
    showValidationHints.value = false;
    nameHint.value = null;
    phoneHint.value = null;
    isSuccess.value = false;
    errorMessage.value = null;
    errorKind.value = SignUpErrorKind.none;
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
    showValidationHints.value = true;
    _updateValidation();

    if (!canSubmit.value || isLoading.value) {
      return;
    }

    isLoading.value = true;
    isSuccess.value = false;
    errorMessage.value = null;
    errorKind.value = SignUpErrorKind.none;
    var startedOtp = false;
    String? nextUsername;
    String? nextCountryCode;
    String? nextPhoneNumber;
    try {
      final String username = nameController.text.trim();
      final String phoneNumber = AuthValidation.digitsOnly(
        phoneController.text,
      );
      final String normalizedCountryCode = countryCode.value
          .trim()
          .toUpperCase();
      await _authRepository.startCustomerRegistration(
        CustomerRegistrationStartRequestModel(
          username: username,
          countryCode: normalizedCountryCode,
          phoneNumber: phoneNumber,
        ),
      );
      if (!isClosed) {
        isSuccess.value = true;
      }
      startedOtp = true;
      nextUsername = username;
      nextCountryCode = normalizedCountryCode;
      nextPhoneNumber = phoneNumber;
    } on ApiException catch (error) {
      if (!isClosed) {
        final ({String message, SignUpErrorKind kind}) mapped =
            _safeMapSignUpError(error);
        errorMessage.value = mapped.message;
        errorKind.value = mapped.kind;
      }
    } on TimeoutException {
      if (!isClosed) {
        errorMessage.value = AppStrings.networkTimeoutError;
        errorKind.value = SignUpErrorKind.other;
      }
    } catch (_) {
      if (!isClosed) {
        errorMessage.value = AppStrings.networkUnexpectedError;
        errorKind.value = SignUpErrorKind.other;
      }
    } finally {
      // Always clear spinner — unique username/phone must not spin forever
      // when the API is slow, conflicts, or the host is unreachable.
      if (!isClosed) {
        isLoading.value = false;
      }
    }

    // Navigate only after clearing loading — never touch Rx after route work
    // that may dispose listeners mid-frame.
    if (startedOtp &&
        !isClosed &&
        nextUsername != null &&
        nextCountryCode != null &&
        nextPhoneNumber != null) {
      AppNavigation.pushNamed(
        AppRoutes.otp,
        allowDuplicate: true,
        arguments: CustomerAuthOtpRouteArgs(
          purpose: CustomerAuthOtpPurpose.registration,
          username: nextUsername,
          countryCode: nextCountryCode,
          dialCode: countryDialCode.value,
          phoneNumber: nextPhoneNumber,
        ),
      );
    }
  }

  void _updateValidation() {
    final bool nameValid = nameController.text.trim().isNotEmpty;
    final bool phoneValid = _isPhoneValid();

    canSubmit.value = nameValid && phoneValid;

    // As soon as user edits inputs, clear stale API banners from old attempts.
    if (errorMessage.value != null) {
      errorMessage.value = null;
      errorKind.value = SignUpErrorKind.none;
    }

    nameHint.value = !nameValid && showValidationHints.value
        ? AppStrings.authUsernameRequiredHint
        : null;

    phoneHint.value =
        !phoneValid &&
            (showValidationHints.value || phoneController.text.isNotEmpty)
        ? _phoneHintMessage()
        : null;
  }

  ({String message, SignUpErrorKind kind}) _mapSignUpError(ApiException error) {
    final String message = error.message.trim();
    final String lowerMessage = message.toLowerCase();
    final List<String> detailParts = error.errors
        .map((dynamic item) => '$item'.toLowerCase())
        .toList();
    final String details = detailParts.join('\n');

    final bool usernameTaken =
        lowerMessage.contains(AppStrings.apiErrorTokenUsername) &&
            lowerMessage.contains(AppStrings.apiErrorTokenUnique) ||
        details.contains(AppStrings.apiErrorTokenUsername) &&
            details.contains(AppStrings.apiErrorTokenUnique);
    final bool phoneTaken =
        lowerMessage.contains(AppStrings.apiErrorTokenPhone) &&
            (lowerMessage.contains(AppStrings.apiErrorTokenUsed) ||
                lowerMessage.contains(AppStrings.apiErrorTokenExist) ||
                lowerMessage.contains(AppStrings.apiErrorTokenRegister) ||
                lowerMessage.contains(AppStrings.apiErrorTokenUnique)) ||
        details.contains(AppStrings.apiErrorTokenPhone) &&
            (details.contains(AppStrings.apiErrorTokenUsed) ||
                details.contains(AppStrings.apiErrorTokenExist) ||
                details.contains(AppStrings.apiErrorTokenRegister) ||
                details.contains(AppStrings.apiErrorTokenUnique));

    if (usernameTaken && phoneTaken) {
      return (
        message: AppStrings.authUsernameAndPhoneAlreadyUsed,
        kind: SignUpErrorKind.uniqueConflict,
      );
    }
    if (usernameTaken) {
      return (
        message: AppStrings.authUsernameAlreadyTaken,
        kind: SignUpErrorKind.uniqueConflict,
      );
    }
    if (phoneTaken) {
      return (
        message: AppStrings.authPhoneAlreadyRegistered,
        kind: SignUpErrorKind.uniqueConflict,
      );
    }
    return (
      message: message.isNotEmpty ? message : AppStrings.networkUnexpectedError,
      kind: SignUpErrorKind.other,
    );
  }

  ({String message, SignUpErrorKind kind}) _safeMapSignUpError(
    ApiException error,
  ) {
    try {
      return _mapSignUpError(error);
    } catch (_) {
      final String fallback = error.message.trim();
      return (
        message: fallback.isNotEmpty
            ? fallback
            : AppStrings.networkUnexpectedError,
        kind: SignUpErrorKind.other,
      );
    }
  }

  void openLogin() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.removeListener(_updateValidation);
    phoneController.removeListener(_updateValidation);
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
