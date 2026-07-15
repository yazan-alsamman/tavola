import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../controller/onboarding_controller.dart';
import 'onboarding_animated_page_layout.dart';
import 'onboarding_booking_preview_content.dart';

class OnboardingBookingPreviewPage extends StatelessWidget {
  const OnboardingBookingPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find<OnboardingController>();

    return OnboardingAnimatedPageLayout(
      pageIndex: 1,
      pageController: controller.pageController,
      headline: AppStrings.onboardingBookHeadline,
      hint: AppStrings.onboardingBookHint,
      preview: const OnboardingBookingPreviewContent(),
    );
  }
}
