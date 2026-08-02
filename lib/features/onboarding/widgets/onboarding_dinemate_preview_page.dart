import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import 'onboarding_animated_page_layout.dart';
import 'onboarding_concierge_preview_content.dart';

class OnboardingDinematePreviewPage extends StatelessWidget {
  const OnboardingDinematePreviewPage({
    super.key,
    required this.pageController,
  });

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return OnboardingAnimatedPageLayout(
      pageIndex: 4,
      pageController: pageController,
      contentTopOffset: AppDimensions.onboardingDinematePageTopOffset,
      bottomSpacerFlex: 2,
      headline: AppStrings.onboardingDinemateHeadline,
      hint: AppStrings.onboardingDinemateHint,
      preview: const OnboardingConciergePreviewContent(),
    );
  }
}