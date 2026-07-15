import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../controller/onboarding_controller.dart';
import 'onboarding_animated_page_layout.dart';
import 'onboarding_rewards_preview_content.dart';

class OnboardingRewardsPreviewPage extends StatelessWidget {
  const OnboardingRewardsPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find<OnboardingController>();

    return OnboardingAnimatedPageLayout(
      pageIndex: 3,
      pageController: controller.pageController,
      headline: AppStrings.onboardingRewardsHeadline,
      hint: AppStrings.onboardingRewardsHint,
      preview: const OnboardingRewardsPreviewContent(),
    );
  }
}
