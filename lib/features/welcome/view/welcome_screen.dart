import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/app_safe_image.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/welcome_controller.dart';
import '../widgets/welcome_title_shine.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WelcomeController controller = Get.find<WelcomeController>();
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppSafeImage(
            path: AppImages.welcomeHero,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            backgroundColor: AppColors.primaryDark,
            iconColor: AppColors.accent,
            fallbackIcon: Icons.restaurant_menu_rounded,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: AppDimensions.welcomeBottomGradientHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.primaryDark22,
                    AppColors.primaryDark75,
                  ],
                  stops: [
                    AppDimensions.welcomeBottomGradientStart,
                    AppDimensions.welcomeBottomGradientMid,
                    1.0,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: const Alignment(
                AppDimensions.welcomeTitleAlignX,
                AppDimensions.welcomeTitleAlignY,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.welcomeTitleOffsetY,
                ),
                child: SizedBox(
                  width: screenWidth * AppDimensions.welcomeTitleMaxWidthFactor,
                  child: const WelcomeTitleShine(),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: AppDimensions.pagePadding,
            end: AppDimensions.pagePadding,
            bottom: AppDimensions.pagePadding + bottomPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: HoverableButton(
                    child: ElevatedButton(
                      onPressed: controller.signIn,
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
                        idleBackground: AppColors.primaryDark,
                      ),
                      child: Text(AppStrings.loginSignUp),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.regularSpacing),
                SizedBox(
                  width: double.infinity,
                  child: HoverableButton(
                    child: ElevatedButton(
                      onPressed: controller.continueAsGuest,
                      style: AppButtonStyles.filledHover(
                        ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primaryDark,
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
                        idleBackground: AppColors.accent,
                        idleForeground: AppColors.primaryDark,
                      ),
                      child: Text(AppStrings.continueAsGuest),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
