import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import 'onboarding_animated_page_layout.dart';
import 'onboarding_confirmation_preview_content.dart';

class OnboardingConfirmationPreviewPage extends StatelessWidget {
  const OnboardingConfirmationPreviewPage({
    super.key,
    required this.pageController,
  });

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return OnboardingAnimatedPageLayout(
      pageIndex: 2,
      pageController: pageController,
      maxWidth: AppDimensions.onboardingContentMaxWidth,
      headline: AppStrings.onboardingConfirmHeadline,
      hint: AppStrings.onboardingConfirmHint,
      preview: const OnboardingConfirmationPreviewContent(),
    );
  }
}
