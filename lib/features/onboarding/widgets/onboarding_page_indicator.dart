import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(AppDimensions.onboardingPageCount, (
        int index,
      ) {
        final bool isActive = currentPage == index;
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
  }
}
