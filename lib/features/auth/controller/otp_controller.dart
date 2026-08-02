import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../model/customer_auth_otp_route_args.dart';
import '../model/customer_password_reset_request_models.dart';
import '../model/customer_registration_request_models.dart';
import '../repository/auth_repository.dart';

class OtpController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  static int get otpLength => AppDimensions.otpCodeLength;
  static int get resendDelaySeconds => AppDimensions.otpResendDelaySeconds;

  late final CustomerAuthOtpRouteArgs otpArgs;
  late final List<TextEditingController> digitControllers;
  late final List<FocusNode> focusNodes;

  final RxInt secondsRemaining = AppDimensions.otpResendDelaySeconds.obs;
  final RxBool canResend = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final RxnString errorMessage = RxnString();

  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();
    digitControllers = List.generate(otpLength, (_) => TextEditingController());
    focusNodes = List.generate(otpLength, (_) => FocusNode());

    final Object? args = Get.arguments;
    otpArgs = args is CustomerAuthOtpRouteArgs
        ? args
        : const CustomerAuthOtpRouteArgs(
            purpose: CustomerAuthOtpPurpose.registration,
            countryCode: AppStrings.authDefaultCountryCode,
            dialCode: AppStrings.authDefaultDialCode,
            phoneNumber: AppStrings.empty,
          );
    _startResendTimer();
  }

  String get phoneNumber => otpArgs.displayPhone;

  String get timerLabel {
    final int minutes = secondsRemaining.value ~/ 60;
    final int seconds = secondsRemaining.value % 60;
    final String minuteText = minutes.toString().padLeft(2, '0');
    final String secondText = seconds.toString().padLeft(2, '0');
    return '$minuteText:$secondText';
  }

  void onDigitChanged(int index, String value) {
    if (value.length > 1) {
      digitControllers[index].text = value.substring(value.length - 1);
      digitControllers[index].selection = const TextSelection.collapsed(
        offset: 1,
      );
    }

    if (value.isNotEmpty && index < otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> resendCode() async {
    if (!canResend.value || isLoading.value) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      if (otpArgs.isPasswordReset) {
        await _authRepository.resendCustomerPasswordResetCode(
          CustomerPasswordResetResendRequestModel(
            countryCode: otpArgs.countryCode,
            phoneNumber: otpArgs.phoneNumber,
          ),
        );
      } else {
        await _authRepository.resendCustomerRegistrationCode(
          CustomerRegistrationResendRequestModel(
            countryCode: otpArgs.countryCode,
            phoneNumber: otpArgs.phoneNumber,
          ),
        );
      }
      for (final TextEditingController controller in digitControllers) {
        controller.clear();
      }
      focusNodes.first.requestFocus();
      _startResendTimer();
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = AppStrings.networkUnexpectedError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (isLoading.value) {
      return;
    }
    final String code = digitControllers
        .map((TextEditingController controller) => controller.text)
        .join();
    if (code.length != otpLength) {
      errorMessage.value = AppStrings.otpInstruction;
      return;
    }

    isLoading.value = true;
    isSuccess.value = false;
    errorMessage.value = null;
    try {
      if (otpArgs.isPasswordReset) {
        await _authRepository.verifyCustomerPasswordReset(
          CustomerPasswordResetVerifyRequestModel(
            countryCode: otpArgs.countryCode,
            phoneNumber: otpArgs.phoneNumber,
            code: code,
          ),
        );
        isSuccess.value = true;
        AppNavigation.pushNamed(
          AppRoutes.passwordReset,
          allowDuplicate: true,
          arguments: otpArgs,
        );
      } else {
        await _authRepository.verifyCustomerRegistration(
          CustomerRegistrationVerifyRequestModel(
            countryCode: otpArgs.countryCode,
            phoneNumber: otpArgs.phoneNumber,
            code: code,
          ),
        );
        // Password is set next via `POST /auth/customer/register/complete`.
        isSuccess.value = true;
        AppNavigation.pushNamed(
          AppRoutes.completeRegistration,
          allowDuplicate: true,
          arguments: otpArgs,
        );
      }
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } catch (_) {
      errorMessage.value = AppStrings.networkUnexpectedError;
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendTimer() {
    secondsRemaining.value = resendDelaySeconds;
    canResend.value = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(AppDimensions.otpResendTickInterval, (timer) {
      if (secondsRemaining.value <= 1) {
        secondsRemaining.value = 0;
        canResend.value = true;
        timer.cancel();
      } else {
        secondsRemaining.value--;
      }
    });
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    for (final TextEditingController controller in digitControllers) {
      controller.dispose();
    }
    for (final FocusNode node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}
