import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../controller/onboarding_controller.dart';
import 'onboarding_animated_page_layout.dart';
import 'onboarding_confirmation_preview_content.dart';

class OnboardingConfirmationPreviewPage extends StatelessWidget {
  const OnboardingConfirmationPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find<OnboardingController>();

    return OnboardingAnimatedPageLayout(
      pageIndex: 2,
      pageController: controller.pageController,
      maxWidth: AppDimensions.onboardingContentMaxWidth,
      headline: AppStrings.onboardingConfirmHeadline,
      hint: AppStrings.onboardingConfirmHint,
      preview: const OnboardingConfirmationPreviewContent(),
    );
  }
}
