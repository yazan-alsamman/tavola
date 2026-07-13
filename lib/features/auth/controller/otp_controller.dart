import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import 'auth_session_controller.dart';

class OtpController extends GetxController {
  static int get otpLength => AppDimensions.otpCodeLength;
  static int get resendDelaySeconds => AppDimensions.otpResendDelaySeconds;

  late final String phoneNumber;
  late final List<TextEditingController> digitControllers;
  late final List<FocusNode> focusNodes;

  final RxInt secondsRemaining = AppDimensions.otpResendDelaySeconds.obs;
  final RxBool canResend = false.obs;

  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();
    digitControllers = List.generate(
      otpLength,
      (_) => TextEditingController(),
    );
    focusNodes = List.generate(
      otpLength,
      (_) => FocusNode(),
    );

    final Object? args = Get.arguments;
    phoneNumber = args is String && args.isNotEmpty
        ? args
        : AppStrings.otpDefaultPhone;
    _startResendTimer();
  }

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

  void resendCode() {
    if (!canResend.value) {
      return;
    }

    for (final TextEditingController controller in digitControllers) {
      controller.clear();
    }
    focusNodes.first.requestFocus();
    _startResendTimer();
  }

  void verifyOtp() {
    Get.find<AuthSessionController>().completeSignIn();
    Get.offAllNamed(AppRoutes.home);
  }

  void _startResendTimer() {
    secondsRemaining.value = resendDelaySeconds;
    canResend.value = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
