import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/onboarding_controller.dart';

class OnboardingConfirmationPreviewPage extends StatelessWidget {
  const OnboardingConfirmationPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find<OnboardingController>();

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
                maxWidth: AppDimensions.onboardingContentMaxWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MiniRestaurantCard(),
                  const SizedBox(height: AppDimensions.regularSpacing),
                  const _ConfirmedBanner(),
                  const SizedBox(height: AppDimensions.regularSpacing),
                  const Text(
                    AppStrings.onboardingBookingInformations,
                    style: AppTextStyles.onboardingInfoSectionTitle,
                  ),
                  const SizedBox(height: AppDimensions.smallSpacing),
                  _BookingInfoCard(onCopy: controller.copyConfirmationCode),
                  const SizedBox(height: AppDimensions.regularSpacing),
                  const Text(
                    AppStrings.onboardingContactRestaurant,
                    style: AppTextStyles.onboardingInfoSectionTitle,
                  ),
                  const SizedBox(height: AppDimensions.smallSpacing),
                  const _ContactActionsRow(),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.regularSpacing),
          const Text(
            AppStrings.onboardingPlanHeadline,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBookHeadline,
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          const Text(
            AppStrings.onboardingPlanHint,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBookHint,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _MiniRestaurantCard extends StatelessWidget {
  const _MiniRestaurantCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.onboardingMiniCardHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingSectionRadius,
        ),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Image.asset(
            AppImages.r1,
            width: AppDimensions.onboardingMiniCardImageWidth,
            height: AppDimensions.onboardingMiniCardHeight,
            fit: BoxFit.cover,
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.regularSpacing,
                vertical: AppDimensions.compactSpacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.saffronHouse,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.onboardingMiniCardTitle,
                  ),
                  SizedBox(height: AppDimensions.tinySpacing),
                  Text(
                    AppStrings.onboardingRestaurantCuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.onboardingMiniCardSubtitle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmedBanner extends StatelessWidget {
  const _ConfirmedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.regularSpacing),
      decoration: BoxDecoration(
        color: AppColors.online,
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingConfirmedBannerRadius,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                AppStrings.confirmed,
                style: AppTextStyles.onboardingConfirmedTitle,
              ),
              SizedBox(width: AppDimensions.smallSpacing),
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.textLight,
                size: AppDimensions.onboardingConfirmedIconSize,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          const Text(
            AppStrings.onboardingConfirmedMessage,
            style: AppTextStyles.onboardingConfirmedMessage,
          ),
        ],
      ),
    );
  }
}

class _BookingInfoCard extends StatelessWidget {
  const _BookingInfoCard({required this.onCopy});

  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.regularSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingInfoCardRadius,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.date,
                      style: AppTextStyles.onboardingInfoLabel,
                    ),
                    SizedBox(height: AppDimensions.tinySpacing),
                    Text(
                      AppStrings.onboardingBookingDateLabel,
                      style: AppTextStyles.onboardingInfoValue,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.guests,
                      style: AppTextStyles.onboardingInfoLabel,
                    ),
                    SizedBox(height: AppDimensions.tinySpacing),
                    Text(
                      AppStrings.onboardingPartyGuestsLabel,
                      style: AppTextStyles.onboardingInfoValue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.regularSpacing),
          const Divider(
            height: AppDimensions.dividerHeight,
            thickness: AppDimensions.dividerHeight,
            color: AppColors.border,
          ),
          const SizedBox(height: AppDimensions.regularSpacing),
          const Text(
            AppStrings.onboardingConfirmationCode,
            style: AppTextStyles.onboardingInfoLabel,
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.smallSpacing,
                    vertical: AppDimensions.smallSpacing,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.onboardingCodeFieldRadius,
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    AppStrings.confirmationReferenceCode,
                    style: AppTextStyles.onboardingCodeField,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.compactSpacing),
              GestureDetector(
                onTap: onCopy,
                child: Container(
                  width: AppDimensions.iconButtonSize,
                  height: AppDimensions.iconButtonSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.onboardingCodeFieldRadius,
                    ),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    size: AppDimensions.onboardingCopyIconSize,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactActionsRow extends StatelessWidget {
  const _ContactActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _ContactActionTile(
            label: AppStrings.onboardingCall,
            icon: Icons.call_rounded,
          ),
        ),
        SizedBox(width: AppDimensions.compactSpacing),
        Expanded(
          child: _ContactActionTile(
            label: AppStrings.onboardingDirections,
            icon: Icons.directions_rounded,
          ),
        ),
        SizedBox(width: AppDimensions.compactSpacing),
        Expanded(
          child: _ContactActionTile(
            label: AppStrings.onboardingCancel,
            icon: Icons.cancel_outlined,
            muted: true,
          ),
        ),
      ],
    );
  }
}

class _ContactActionTile extends StatelessWidget {
  const _ContactActionTile({
    required this.label,
    required this.icon,
    this.muted = false,
  });

  final String label;
  final IconData icon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.onboardingActionTilePaddingVertical,
        horizontal: AppDimensions.tinySpacing,
      ),
      decoration: BoxDecoration(
        color: muted ? AppColors.surfaceAlt : AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingActionTileRadius,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.onboardingActionIconSize,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: AppDimensions.tinySpacing),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.onboardingActionButton,
          ),
        ],
      ),
    );
  }
}
