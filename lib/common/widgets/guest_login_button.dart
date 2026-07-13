import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../features/auth/controller/auth_session_controller.dart';
import 'hoverable_button.dart';

class GuestLoginButton extends StatelessWidget {
  const GuestLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthSessionController controller = Get.find<AuthSessionController>();

    return Obx(() {
      if (!controller.isGuest.value) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(right: AppDimensions.smallSpacing),
        child: HoverableButton(
          child: Material(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
            child: InkWell(
              onTap: controller.openLogin,
              borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.guestLoginButtonHorizontalPadding,
                  vertical: AppDimensions.guestLoginButtonVerticalPadding,
                ),
                child: Text(
                  AppStrings.login,
                  style: AppTextStyles.guestLoginButton,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
