import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import 'onboarding_welcome_animation.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePadding,
      ),
      child: Column(
        children: [
          const Spacer(flex: 3),
          const OnboardingWelcomeAnimation(),
          const Spacer(flex: 2),
          const Text(
            AppStrings.onboardingSwipeHint,
            style: AppTextStyles.onboardingSwipeHint,
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
        ],
      ),
    );
  }
}
