import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/app_ltr_text.dart';
import '../../../common/widgets/auth_field_hint.dart';
import '../../../common/widgets/circle_back_button.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/otp_controller.dart';
import '../widgets/auth_page_header.dart';
import '../widgets/otp_code_input.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OtpController controller = Get.find<OtpController>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CircleBackButton(onPressed: Get.back),
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              Center(
                child: Container(
                  alignment: Alignment.center,
                  width: AppDimensions.otpIconContainerSize,
                  height: AppDimensions.otpIconContainerSize,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: AppDimensions.cardBorderWidth,
                    ),
                  ),
                  child: const Icon(
                    Symbols.chat,
                    color: AppColors.primary,
                    size: AppDimensions.otpIconSize,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              AuthPageHeader(
                title: AppStrings.checkYourWhatsapp,
                instruction: AppStrings.otpInstruction,
              ),
              const SizedBox(height: AppDimensions.smallSpacing),
              Text.rich(
                TextSpan(
                  style: AppTextStyles.authInstruction,
                  children: [
                    TextSpan(text: '${AppStrings.otpSentTo} '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: AppLtrText(
                        controller.phoneNumber,
                        style: AppTextStyles.authInstruction.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              DefaultTextStyle(
                style: AppTextStyles.otpDigit,
                child: OtpCodeInput(controller: controller),
              ),
              Obx(
                () => controller.errorMessage.value == null
                    ? const SizedBox.shrink()
                    : AuthFieldHint(message: controller.errorMessage.value!),
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              Obx(
                () => Column(
                  children: [
                    Text(controller.timerLabel, style: AppTextStyles.otpTimer),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    TextButton(
                      onPressed:
                          controller.canResend.value &&
                              !controller.isLoading.value
                          ? controller.resendCode
                          : null,
                      style: TextButton.styleFrom(
                        foregroundColor: controller.canResend.value
                            ? AppColors.primaryDark
                            : AppColors.disabled,
                        textStyle: AppTextStyles.authLinkEmphasis,
                      ),
                      child: Text(
                        AppStrings.resendIt,
                        style: AppTextStyles.authLinkEmphasis.copyWith(
                          color: controller.canResend.value
                              ? AppColors.primaryDark
                              : AppColors.disabled,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: HoverableButton(
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.verifyOtp,
                      style: AppButtonStyles.filledHover(
                        ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.textLight,
                          textStyle: AppTextStyles.authPrimaryButton,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.buttonVerticalPadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                          ),
                        ),
                        idleBackground: AppColors.primaryDark,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: AppDimensions.mediumIconSize,
                              height: AppDimensions.mediumIconSize,
                              child: CircularProgressIndicator(
                                strokeWidth:
                                    AppDimensions.progressIndicatorStrokeWidth,
                                color: AppColors.textLight,
                              ),
                            )
                          : Text(
                              AppStrings.verifyOtp,
                              style: AppTextStyles.authPrimaryButton.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
