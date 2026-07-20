import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/auth_field_hint.dart';
import '../../../common/widgets/auth_password_field.dart';
import '../../../common/widgets/auth_text_field.dart';
import '../../../common/widgets/circle_back_button.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

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
              Text(
                AppStrings.login,
                textAlign: TextAlign.center,
                style: AppTextStyles.authScreenTitle,
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              Text(
                AppStrings.loginInstruction,
                textAlign: TextAlign.center,
                style: AppTextStyles.authInstruction,
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              AuthTextField(
                controller: controller.phoneController,
                hintText: AppStrings.enterYourNumber,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
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
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: controller.forgotPassword,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: AppTextStyles.authLink,
                  ),
                  child: Text(AppStrings.forgotPassword),
                ),
              ),
              const SizedBox(height: AppDimensions.smallSpacing),
              Center(
                child: TextButton(
                  onPressed: controller.openSignUp,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    textStyle: AppTextStyles.authLinkEmphasis,
                  ),
                  child: Text(AppStrings.signUp),
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
                    child: Text(AppStrings.login),
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
