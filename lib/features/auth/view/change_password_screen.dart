import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/auth_field_hint.dart';
import '../../../common/widgets/auth_password_field.dart';
import '../../../common/widgets/circle_back_button.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/change_password_controller.dart';
import '../widgets/auth_page_header.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangePasswordController controller =
        Get.find<ChangePasswordController>();

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
                title: AppStrings.changePassword,
                instruction: AppStrings.changePasswordInstruction,
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              DefaultTextStyle(
                style: AppTextStyles.authInput,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(
                      () => AuthPasswordField(
                        controller: controller.currentPasswordController,
                        hintText: AppStrings.enterCurrentPassword,
                        obscurePassword: controller.obscureCurrentPassword.value,
                        onToggleVisibility:
                            controller.toggleCurrentPasswordVisibility,
                      ),
                    ),
                    Obx(
                      () => controller.currentPasswordHint.value == null
                          ? const SizedBox.shrink()
                          : AuthFieldHint(
                              message: controller.currentPasswordHint.value!,
                            ),
                    ),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    Obx(
                      () => AuthPasswordField(
                        controller: controller.passwordController,
                        hintText: AppStrings.enterNewPassword,
                        obscurePassword: controller.obscurePassword.value,
                        onToggleVisibility: controller.togglePasswordVisibility,
                      ),
                    ),
                    Obx(
                      () => controller.passwordHint.value == null
                          ? const SizedBox.shrink()
                          : AuthFieldHint(
                              message: controller.passwordHint.value!,
                            ),
                    ),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    Obx(
                      () => AuthPasswordField(
                        controller: controller.confirmPasswordController,
                        hintText: AppStrings.confirmYourPassword,
                        obscurePassword:
                            controller.obscureConfirmPassword.value,
                        onToggleVisibility:
                            controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    Obx(() {
                      if (controller.showPasswordMismatch.value) {
                        return AuthFieldHint(
                          message: AppStrings.passwordMismatch,
                        );
                      }
                      if (controller.confirmPasswordHint.value == null) {
                        return const SizedBox.shrink();
                      }
                      return AuthFieldHint(
                        message: controller.confirmPasswordHint.value!,
                      );
                    }),
                    Obx(
                      () => controller.errorMessage.value == null
                          ? const SizedBox.shrink()
                          : AuthFieldHint(
                              message: controller.errorMessage.value!,
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
                                AppStrings.changePassword,
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
