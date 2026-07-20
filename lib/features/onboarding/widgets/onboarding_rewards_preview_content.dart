import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import 'onboarding_glass_shell.dart';

/// Rewards preview with premium glass styling and readable inner offer cards.
class OnboardingRewardsPreviewContent extends StatelessWidget {
  const OnboardingRewardsPreviewContent({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingGlassShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingGlassHeader(
            icon: Icons.workspace_premium_rounded,
            title: AppStrings.onboardingLoyaltyRewards,
            message: AppStrings.onboardingRewardsHint,
          ),
          const OnboardingGlassDivider(),
          const _MembershipProgressPanel(),
          const OnboardingGlassDivider(),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.onboardingLoyaltyDiscounts,
                  style:
                      AppTextStyles.onboardingRewardsProgressLabel.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.compactSpacing,
                  vertical: AppDimensions.tinySpacing,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                ),
                child: Text(
                  AppStrings.onboardingLoyaltyDiscountsCount,
                  style: AppTextStyles.onboardingRewardsBadge.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.compactSpacing),
          OnboardingGlassInnerCard(
            child: _RewardOfferContent(
              icon: Icons.restaurant_menu_rounded,
              title: AppStrings.onboardingLoyaltyOfferTwoTitle,
              place: AppStrings.onboardingLoyaltyOfferTwoPlace,
              points: AppStrings.onboardingLoyaltyOfferTwoPoints,
              unlocked: true,
            ),
          ),
          const SizedBox(height: AppDimensions.compactSpacing),
          OnboardingGlassInnerCard(
            child: _RewardOfferContent(
              icon: Icons.dinner_dining_rounded,
              title: AppStrings.onboardingLoyaltyOfferOneTitle,
              place: AppStrings.onboardingLoyaltyOfferOnePlace,
              points: AppStrings.onboardingLoyaltyOfferOnePoints,
              needMore: AppStrings.onboardingLoyaltyOfferOneNeed,
            ),
          ),
          const OnboardingGlassDivider(),
          _GlassBenefitRow(
            icon: Icons.event_seat_rounded,
            label: AppStrings.onboardingLoyaltyBenefitOne,
          ),
          const SizedBox(height: AppDimensions.compactSpacing),
          _GlassBenefitRow(
            icon: Icons.cake_rounded,
            label: AppStrings.onboardingLoyaltyBenefitTwo,
          ),
        ],
      ),
    );
  }
}

class _MembershipProgressPanel extends StatelessWidget {
  const _MembershipProgressPanel();

  @override
  Widget build(BuildContext context) {
    return OnboardingGlassFrostPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.onboardingLoyaltyTierBronze,
            style: AppTextStyles.partnerBody,
          ),
          const SizedBox(height: AppDimensions.compactSpacing),
          Row(
            children: [
              Text(
                AppStrings.onboardingLoyaltyPointsValue,
                style: AppTextStyles.onboardingRewardsPoints.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              const Spacer(),
              Text(
                AppStrings.onboardingLoyaltyProgressTitle,
                style: AppTextStyles.onboardingRewardsProgressLabel.copyWith(
                  color: AppColors.textLight80,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.compactSpacing),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
            child: const LinearProgressIndicator(
              value: AppDimensions.onboardingRewardsProgressValue,
              minHeight: AppDimensions.onboardingRewardsProgressHeight,
              backgroundColor: AppColors.primaryDark22,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppDimensions.tinySpacing),
          Text(
            AppStrings.onboardingLoyaltyPointsToSilver,
            style: AppTextStyles.onboardingRewardsProgressHint.copyWith(
              color: AppColors.textLight80,
            ),
          ),
          const SizedBox(height: AppDimensions.compactSpacing),
          Row(
            children: [
              _GlassStatChip(
                value: AppStrings.onboardingLoyaltyTotalPointsValue,
                label: AppStrings.onboardingLoyaltyTotalPointsLabel,
              ),
              const SizedBox(width: AppDimensions.compactSpacing),
              _GlassStatChip(
                value: AppStrings.onboardingLoyaltyAvailableValue,
                label: AppStrings.onboardingLoyaltyAvailableLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassStatChip extends StatelessWidget {
  const _GlassStatChip({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.compactSpacing,
          vertical: AppDimensions.tinySpacing,
        ),
        decoration: BoxDecoration(
          color: AppColors.textLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
          border: Border.all(
            color: AppColors.textLight.withValues(alpha: 0.16),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.onboardingRewardsStatValue.copyWith(
                color: AppColors.textLight,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.onboardingRewardsStatLabel.copyWith(
                color: AppColors.textLight80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardOfferContent extends StatelessWidget {
  const _RewardOfferContent({
    required this.icon,
    required this.title,
    required this.place,
    required this.points,
    this.unlocked = false,
    this.needMore,
  });

  final IconData icon;
  final String title;
  final String place;
  final String points;
  final bool unlocked;
  final String? needMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppDimensions.iconButtonSize,
          height: AppDimensions.iconButtonSize,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(
              AppDimensions.onboardingPartyChipRadius,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryDark,
            size: AppDimensions.mediumIconSize,
          ),
        ),
        const SizedBox(width: AppDimensions.compactSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.onboardingRewardsOfferTitle),
              const SizedBox(height: AppDimensions.tinySpacing),
              Text(place, style: AppTextStyles.onboardingRewardsOfferMeta),
              if (unlocked || needMore != null) ...[
                const SizedBox(height: AppDimensions.compactSpacing),
                if (unlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.compactSpacing,
                      vertical: AppDimensions.tinySpacing,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.pillRadius,
                      ),
                    ),
                    child: Text(
                      AppStrings.onboardingLoyaltyOfferClaimedTag,
                      style: AppTextStyles.onboardingRewardsChip.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  )
                else
                  Text(
                    needMore!,
                    style: AppTextStyles.onboardingRewardsNeedMore,
                  ),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(
              Icons.star_rounded,
              size: AppDimensions.smallIconSize,
              color: AppColors.accent,
            ),
            Text(points, style: AppTextStyles.onboardingRewardsOfferMeta),
          ],
        ),
      ],
    );
  }
}

class _GlassBenefitRow extends StatelessWidget {
  const _GlassBenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppDimensions.iconButtonSize,
          height: AppDimensions.iconButtonSize,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryDark,
            size: AppDimensions.smallIconSize,
          ),
        ),
        const SizedBox(width: AppDimensions.smallSpacing),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.onboardingRewardsBenefit.copyWith(
              color: AppColors.textLight80,
            ),
          ),
        ),
      ],
    );
  }
}
