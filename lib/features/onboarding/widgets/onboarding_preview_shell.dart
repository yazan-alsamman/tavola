import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Shared card shell for onboarding feature previews.
class OnboardingPreviewShell extends StatelessWidget {
  const OnboardingPreviewShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.onboardingSectionPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingSectionRadius,
        ),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryDark10,
            blurRadius: AppDimensions.shadowBlur,
            offset: Offset(0, AppDimensions.shadowOffsetY),
          ),
        ],
      ),
      child: child,
    );
  }
}

class OnboardingPreviewSectionLabel extends StatelessWidget {
  const OnboardingPreviewSectionLabel({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.reservationSectionLabel);
  }
}

class OnboardingPreviewSectionDivider extends StatelessWidget {
  const OnboardingPreviewSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.compactSpacing),
      child: Divider(
        height: AppDimensions.dividerHeight,
        thickness: AppDimensions.dividerHeight,
        color: AppColors.border,
      ),
    );
  }
}
