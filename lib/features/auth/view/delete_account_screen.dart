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
import '../controller/delete_account_controller.dart';
import '../widgets/auth_page_header.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DeleteAccountController controller =
        Get.find<DeleteAccountController>();

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
                title: AppStrings.deleteAccount,
                instruction: AppStrings.deleteAccountInstruction,
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              DefaultTextStyle(
                style: AppTextStyles.authInput,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(
                      () => AuthPasswordField(
                        controller: controller.passwordController,
                        hintText: AppStrings.enterCurrentPassword,
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
                                AppStrings.deleteAccount,
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
