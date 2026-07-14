import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingRewardsPreviewPage extends StatelessWidget {
  const OnboardingRewardsPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePadding,
      ),
      child: Column(
        children: [
          const Spacer(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.onboardingSectionMaxWidth,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.onboardingSectionRadius,
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    _tierProgress(),
                    _stats(),
                    Padding(
                      padding: const EdgeInsets.all(
                        AppDimensions.onboardingSectionPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            AppStrings.onboardingLoyaltyDiscounts,
                            badge: AppStrings.onboardingLoyaltyDiscountsCount,
                          ),
                          const SizedBox(height: AppDimensions.smallSpacing),
                          _offer(
                            title: AppStrings.onboardingLoyaltyOfferOneTitle,
                            points: AppStrings.onboardingLoyaltyOfferOnePoints,
                            place: AppStrings.onboardingLoyaltyOfferOnePlace,
                            needMore: AppStrings.onboardingLoyaltyOfferOneNeed,
                            claimed: true,
                          ),
                          const SizedBox(height: AppDimensions.smallSpacing),
                          _offer(
                            title: AppStrings.onboardingLoyaltyOfferTwoTitle,
                            points: AppStrings.onboardingLoyaltyOfferTwoPoints,
                            place: AppStrings.onboardingLoyaltyOfferTwoPlace,
                          ),
                          const SizedBox(height: AppDimensions.regularSpacing),
                          _sectionTitle(AppStrings.onboardingLoyaltyBenefitsTitle),
                          const SizedBox(height: AppDimensions.smallSpacing),
                          _benefit(AppStrings.onboardingLoyaltyBenefitOne),
                          const SizedBox(height: AppDimensions.compactSpacing),
                          _benefit(AppStrings.onboardingLoyaltyBenefitTwo),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.regularSpacing),
          const Text(
            AppStrings.onboardingRewardsHeadline,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBookHeadline,
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          const Text(
            AppStrings.onboardingRewardsHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBookHint,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.onboardingSectionPadding,
        vertical: AppDimensions.smallSpacing,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondaryLight, AppColors.surface],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.iconButtonSize * 0.7,
            height: AppDimensions.iconButtonSize * 0.7,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(
                AppDimensions.onboardingPartyChipRadius,
              ),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: AppDimensions.smallIconSize,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: AppDimensions.smallSpacing),
          const Text(
            AppStrings.onboardingLoyaltyRewards,
            style: AppTextStyles.onboardingRewardsHeader,
          ),
        ],
      ),
    );
  }

  Widget _tierProgress() {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceAlt,
      padding: const EdgeInsets.all(AppDimensions.onboardingSectionPadding),
      child: Row(
        children: [
          Container(
            width: AppDimensions.onboardingRewardsMedalSize,
            height: AppDimensions.onboardingRewardsMedalSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.primaryDark],
              ),
              border: Border.all(color: AppColors.secondary, width: 2),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.textLight,
              size: AppDimensions.mediumIconSize,
            ),
          ),
          const SizedBox(width: AppDimensions.regularSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      AppStrings.onboardingLoyaltyTierBronze,
                      style: AppTextStyles.onboardingRewardsTier,
                    ),
                    SizedBox(width: AppDimensions.smallSpacing),
                    Text(
                      AppStrings.onboardingLoyaltyPointsValue,
                      style: AppTextStyles.onboardingRewardsPoints,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.smallSpacing),
                const Text(
                  AppStrings.onboardingLoyaltyProgressTitle,
                  style: AppTextStyles.onboardingRewardsProgressLabel,
                ),
                const SizedBox(height: AppDimensions.tinySpacing),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                  child: const LinearProgressIndicator(
                    value: AppDimensions.onboardingRewardsProgressValue,
                    minHeight: AppDimensions.onboardingRewardsProgressHeight,
                    backgroundColor: AppColors.secondary,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: AppDimensions.tinySpacing),
                const Text(
                  AppStrings.onboardingLoyaltyPointsToSilver,
                  style: AppTextStyles.onboardingRewardsProgressHint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.onboardingSectionPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.smallSpacing,
        ),
        decoration: BoxDecoration(
          color: AppColors.secondaryLight,
          borderRadius: BorderRadius.circular(
            AppDimensions.onboardingDateChipRadius,
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _stat(
              AppStrings.onboardingLoyaltyTotalPointsValue,
              AppStrings.onboardingLoyaltyTotalPointsLabel,
            ),
            _divider(),
            _stat(
              AppStrings.onboardingLoyaltyClaimedValue,
              AppStrings.onboardingLoyaltyClaimedLabel,
            ),
            _divider(),
            _stat(
              AppStrings.onboardingLoyaltyAvailableValue,
              AppStrings.onboardingLoyaltyAvailableLabel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.onboardingRewardsStatValue),
          const SizedBox(height: AppDimensions.tinySpacing),
          Text(label, style: AppTextStyles.onboardingRewardsStatLabel),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: AppDimensions.dividerHeight,
      height: AppDimensions.mediumIconSize,
      color: AppColors.border,
    );
  }

  Widget _sectionTitle(String title, {String? badge}) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.onboardingRewardsSectionTitle),
        if (badge != null) ...[
          const SizedBox(width: AppDimensions.smallSpacing),
          Container(
            width: AppDimensions.onboardingRewardsBadgeSize,
            height: AppDimensions.onboardingRewardsBadgeSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: Text(badge, style: AppTextStyles.onboardingRewardsBadge),
          ),
        ],
      ],
    );
  }

  Widget _offer({
    required String title,
    required String points,
    required String place,
    String? needMore,
    bool claimed = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.smallSpacing),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingRewardsOfferRadius,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.onboardingRewardsOfferTitle,
                ),
              ),
              const Icon(
                Icons.star_rounded,
                size: AppDimensions.smallIconSize,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppDimensions.tinySpacing),
              Text(points, style: AppTextStyles.onboardingRewardsOfferMeta),
            ],
          ),
          const SizedBox(height: AppDimensions.tinySpacing),
          Text(place, style: AppTextStyles.onboardingRewardsOfferMeta),
          const SizedBox(height: AppDimensions.smallSpacing),
          Wrap(
            spacing: AppDimensions.compactSpacing,
            children: [
              _chip(
                AppStrings.onboardingLoyaltyDiscounts,
                AppColors.secondary,
                AppColors.primaryDark,
              ),
              if (claimed)
                _chip(
                  AppStrings.onboardingLoyaltyOfferClaimedTag,
                  AppColors.online,
                  AppColors.textLight,
                  icon: Icons.check_rounded,
                ),
            ],
          ),
          if (needMore != null) ...[
            const SizedBox(height: AppDimensions.compactSpacing),
            Text(needMore, style: AppTextStyles.onboardingRewardsNeedMore),
          ],
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    Color background,
    Color foreground, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.compactSpacing,
        vertical: AppDimensions.tinySpacing,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimensions.smallIconSize, color: foreground),
            const SizedBox(width: AppDimensions.tinySpacing),
          ],
          Text(
            label,
            style: AppTextStyles.onboardingRewardsChip.copyWith(
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefit(String label) {
    return Row(
      children: [
        Container(
          width: AppDimensions.mediumIconSize,
          height: AppDimensions.mediumIconSize,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: AppDimensions.smallIconSize,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: AppDimensions.smallSpacing),
        Text(label, style: AppTextStyles.onboardingRewardsBenefit),
      ],
    );
  }
}
