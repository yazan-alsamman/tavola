import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/auth_field_hint.dart';
import '../../../common/widgets/auth_password_field.dart';
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
                alignment: Alignment.centerLeft,
                child: CircleBackButton(onPressed: Get.back),
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              const Text(
                AppStrings.signUp,
                textAlign: TextAlign.center,
                style: AppTextStyles.authScreenTitle,
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              const Text(
                AppStrings.signUpInstruction,
                textAlign: TextAlign.center,
                style: AppTextStyles.authInstruction,
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              AuthTextField(
                controller: controller.nameController,
                hintText: AppStrings.enterYourName,
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
                onCountryChanged: controller.updateCountryCode,
              ),
              Obx(
                () => controller.phoneHint.value == null
                    ? const SizedBox.shrink()
                    : AuthFieldHint(message: controller.phoneHint.value!),
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              Obx(
                () => AuthPasswordField(
                  controller: controller.passwordController,
                  hintText: AppStrings.enterYourPassword,
                  obscurePassword: controller.obscurePassword.value,
                  onToggleVisibility: controller.togglePasswordVisibility,
                ),
              ),
              Obx(
                () => controller.passwordHint.value == null
                    ? const SizedBox.shrink()
                    : AuthFieldHint(message: controller.passwordHint.value!),
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              Obx(
                () => AuthPasswordField(
                  controller: controller.confirmPasswordController,
                  hintText: AppStrings.confirmYourPassword,
                  obscurePassword: controller.obscureConfirmPassword.value,
                  onToggleVisibility:
                      controller.toggleConfirmPasswordVisibility,
                ),
              ),
              Obx(
                () {
                  if (controller.showPasswordMismatch.value) {
                    return const AuthFieldHint(
                      message: AppStrings.passwordMismatch,
                    );
                  }

                  if (controller.confirmPasswordHint.value == null) {
                    return const SizedBox.shrink();
                  }

                  return AuthFieldHint(
                    message: controller.confirmPasswordHint.value!,
                  );
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
                  child: const Text(AppStrings.login),
                ),
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              Obx(
                () {
                  final Widget button = ElevatedButton(
                    onPressed: controller.submit,
                    style: AppButtonStyles.filledHover(
                      ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: AppColors.textLight,
                        textStyle: AppTextStyles.welcomeButton,
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
                    child: const Text(AppStrings.signUp),
                  );

                  return SizedBox(
                    width: double.infinity,
                    child: controller.canSubmit.value
                        ? HoverableButton(child: button)
                        : button,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
