import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../controller/onboarding_controller.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find<OnboardingController>();

    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(AppDimensions.onboardingPageCount, (
          int index,
        ) {
          final bool isActive = controller.currentPage.value == index;
          return AnimatedContainer(
            duration: AppDimensions.onboardingDotAnimDuration,
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.onboardingDotSpacing / 2,
            ),
            width: isActive
                ? AppDimensions.onboardingDotActiveWidth
                : AppDimensions.onboardingDotSize,
            height: AppDimensions.onboardingDotSize,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryDark : AppColors.accent,
              borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
            ),
          );
        }),
      );
    });
  }
}
