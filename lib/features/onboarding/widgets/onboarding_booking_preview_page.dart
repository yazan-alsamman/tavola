import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import 'onboarding_animated_page_layout.dart';
import 'onboarding_booking_preview_content.dart';

class OnboardingBookingPreviewPage extends StatelessWidget {
  const OnboardingBookingPreviewPage({super.key, required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return OnboardingAnimatedPageLayout(
      pageIndex: 1,
      pageController: pageController,
      headline: AppStrings.onboardingBookHeadline,
      hint: AppStrings.onboardingBookHint,
      preview: const OnboardingBookingPreviewContent(),
    );
  }
}
