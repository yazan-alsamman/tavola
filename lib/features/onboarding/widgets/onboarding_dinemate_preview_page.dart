import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../controller/onboarding_controller.dart';
import 'onboarding_animated_page_layout.dart';
import 'onboarding_concierge_preview_content.dart';

class OnboardingDinematePreviewPage extends StatelessWidget {
  const OnboardingDinematePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find<OnboardingController>();

    return OnboardingAnimatedPageLayout(
      pageIndex: 4,
      pageController: controller.pageController,
      contentTopOffset: AppDimensions.onboardingDinematePageTopOffset,
      bottomSpacerFlex: 2,
      headline: AppStrings.onboardingDinemateHeadline,
      hint: AppStrings.onboardingDinemateHint,
      preview: const OnboardingConciergePreviewContent(),
    );
  }
}
