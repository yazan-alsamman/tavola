import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/auth_field_hint.dart';
import '../../../common/widgets/auth_phone_field.dart';
import '../../../common/widgets/auth_text_field.dart';
import '../../../common/widgets/circle_back_button.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/sign_up_controller.dart';
import '../widgets/auth_page_header.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.find<SignUpController>();

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
              AuthPageHeader(
                title: AppStrings.signUp,
                instruction: AppStrings.signUpInstruction,
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              DefaultTextStyle(
                style: AppTextStyles.authInput,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthTextField(
                      controller: controller.nameController,
                      hintText: AppStrings.enterYourUsername,
                      keyboardType: TextInputType.name,
                    ),
                    Obx(
                      () => controller.nameHint.value == null
                          ? const SizedBox.shrink()
                          : AuthFieldHint(message: controller.nameHint.value!),
                    ),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    AuthPhoneField(
                      controller: controller.phoneController,
                      hintText: AppStrings.enterYourNumber,
                      maxLengthRx: controller.phoneMaxLength,
                      onCountryChanged: controller.updateCountryCode,
                      onCountryInit: controller.syncCountryCode,
                    ),
                    Obx(
                      () => controller.phoneHint.value == null
                          ? const SizedBox.shrink()
                          : AuthFieldHint(message: controller.phoneHint.value!),
                    ),
                    Obx(
                      () {
                        final String? message = controller.errorMessage.value;
                        if (message == null) {
                          return const SizedBox.shrink();
                        }
                        return AuthFieldHint(message: message);
                      },
                    ),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    Center(
                      child: TextButton(
                        onPressed: controller.openLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                          textStyle: AppTextStyles.authLinkEmphasis,
                        ),
                        child: Text(
                          AppStrings.login,
                          style: AppTextStyles.authLinkEmphasis,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sectionSpacing),
                    Obx(() {
                      final Widget button = ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.submit,
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
                          idleBackground: controller.canSubmit.value
                              ? AppColors.primaryDark
                              : AppColors.disabled,
                          idleForeground: controller.canSubmit.value
                              ? AppColors.textLight
                              : AppColors.textSecondary,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: AppDimensions.mediumIconSize,
                                height: AppDimensions.mediumIconSize,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppDimensions
                                      .progressIndicatorStrokeWidth,
                                  color: AppColors.textLight,
                                ),
                              )
                            : Text(
                                AppStrings.signUp,
                                style: AppTextStyles.authPrimaryButton.copyWith(
                                  color: controller.canSubmit.value
                                      ? AppColors.textLight
                                      : AppColors.textSecondary,
                                ),
                              ),
                      );

                      return SizedBox(
                        width: double.infinity,
                        child: controller.canSubmit.value
                            ? HoverableButton(child: button)
                            : button,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
