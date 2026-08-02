import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import 'onboarding_animated_page_layout.dart';
import 'onboarding_rewards_preview_content.dart';

class OnboardingRewardsPreviewPage extends StatelessWidget {
  const OnboardingRewardsPreviewPage({super.key, required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return OnboardingAnimatedPageLayout(
      pageIndex: 3,
      pageController: pageController,
      headline: AppStrings.onboardingRewardsHeadline,
      hint: AppStrings.onboardingRewardsHint,
      preview: const OnboardingRewardsPreviewContent(),
    );
  }
}
