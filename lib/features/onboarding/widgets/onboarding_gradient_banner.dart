import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Purple gradient banner shared by onboarding confirmation and rewards previews.
class OnboardingGradientBanner extends StatelessWidget {
  const OnboardingGradientBanner({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.regularSpacing),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryDark75],
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingConfirmedBannerRadius,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.onboardingConfirmedIconSize +
                AppDimensions.smallSpacing,
            height: AppDimensions.onboardingConfirmedIconSize +
                AppDimensions.smallSpacing,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryDark,
              size: AppDimensions.onboardingConfirmedIconSize,
            ),
          ),
          const SizedBox(width: AppDimensions.regularSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.onboardingConfirmedTitle),
                const SizedBox(height: AppDimensions.tinySpacing),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.onboardingConfirmedMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Square accent icon tile used in onboarding preview rows.
class OnboardingPreviewIconTile extends StatelessWidget {
  const OnboardingPreviewIconTile({
    required this.icon,
    super.key,
    this.size = AppDimensions.onboardingQrCodeSize,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingCodeFieldRadius,
        ),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Icon(
        icon,
        color: AppColors.primaryDark,
        size: AppDimensions.mediumIconSize,
      ),
    );
  }
}
