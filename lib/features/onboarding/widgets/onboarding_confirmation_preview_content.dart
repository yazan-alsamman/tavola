import 'package:flutter/material.dart';

import '../../../common/widgets/app_ltr_text.dart';
import '../../../common/widgets/reservation_qr_code.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/model/restaurant_model.dart';
import '../../profile/widgets/profile_reservation_card.dart';
import 'onboarding_glass_shell.dart';

/// Confirmation preview with glass shell and readable inner panels.
class OnboardingConfirmationPreviewContent extends StatelessWidget {
  const OnboardingConfirmationPreviewContent({super.key});

  static RestaurantModel get _restaurant => RestaurantModel(
    id: AppStrings.restaurantIdTwo,
    name: AppStrings.otakoSushi,
    cuisine: AppStrings.sushi,
    occasion: AppStrings.dinner,
    description: AppStrings.otakoDescription,
    imageUrl: AppImages.r3,
    location: AppStrings.marinaBay,
    availabilityLabel: AppStrings.openNow,
    isAvailable: true,
  );

  static List<(String, String)> get _reservationDetails => [
        (AppStrings.date, AppStrings.onboardingReservationDateLabel),
        (AppStrings.time, AppStrings.reservationTime),
        (AppStrings.guests, AppStrings.onboardingPartyGuestsLabel),
      ];

  @override
  Widget build(BuildContext context) {
    return OnboardingGlassShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingGlassHeader(
            icon: Icons.check_rounded,
            title: AppStrings.confirmed,
            message: AppStrings.onboardingConfirmedMessage,
          ),
          const OnboardingGlassDivider(),
          ProfileReservationCard(
            restaurant: _restaurant,
            details: _reservationDetails,
            showBottomMargin: false,
            compact: true,
          ),
          const OnboardingGlassDivider(),
          const OnboardingGlassInnerCard(
            child: _ConfirmationCodeRow(),
          ),
          const OnboardingGlassDivider(),
          OnboardingGlassSectionLabel(
            text: AppStrings.onboardingContactRestaurant,
          ),
          const SizedBox(height: AppDimensions.compactSpacing),
          _QuickActionPill(
            label: AppStrings.onboardingChangeDate,
            icon: Icons.calendar_month_rounded,
            emphasized: true,
          ),
          const SizedBox(height: AppDimensions.compactSpacing),
          Row(
            children: [
              Expanded(
                child: _QuickActionPill(
                  label: AppStrings.onboardingCall,
                  icon: Icons.call_rounded,
                ),
              ),
              SizedBox(width: AppDimensions.compactSpacing),
              Expanded(
                child: _QuickActionPill(
                  label: AppStrings.onboardingDirections,
                  icon: Icons.directions_rounded,
                ),
              ),
              SizedBox(width: AppDimensions.compactSpacing),
              Expanded(
                child: _QuickActionPill(
                  label: AppStrings.onboardingCancel,
                  icon: Icons.close_rounded,
                  muted: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmationCodeRow extends StatelessWidget {
  const _ConfirmationCodeRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.onboardingConfirmationCode,
                style: AppTextStyles.reservationSectionLabel,
              ),
              SizedBox(height: AppDimensions.tinySpacing),
              Text(
                AppStrings.onboardingQrCodeLabel,
                style: AppTextStyles.onboardingSectionHint,
              ),
              SizedBox(height: AppDimensions.compactSpacing),
              AppLtrText(
                AppStrings.confirmationReferenceCode,
                style: AppTextStyles.onboardingCodeField,
              ),
              SizedBox(height: AppDimensions.tinySpacing),
              AppLtrText(
                '${AppStrings.referencePrefix}${AppStrings.confirmationReferenceCode}',
                style: AppTextStyles.onboardingSectionHint,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.compactSpacing),
        const ReservationQrCode(
          data: AppStrings.confirmationReferenceCode,
        ),
      ],
    );
  }
}

class _QuickActionPill extends StatelessWidget {
  const _QuickActionPill({
    required this.label,
    required this.icon,
    this.emphasized = false,
    this.muted = false,
  });

  final String label;
  final IconData icon;
  final bool emphasized;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final Color background = emphasized
        ? AppColors.accent
        : muted
            ? AppColors.textLight.withValues(alpha: 0.1)
            : AppColors.textLight.withValues(alpha: 0.16);
    final Color foreground = emphasized
        ? AppColors.primaryDark
        : AppColors.textLight;
    final Color borderColor = emphasized
        ? AppColors.accent
        : AppColors.textLight.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.compactSpacing,
        vertical: AppDimensions.compactSpacing,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.smallIconSize,
            color: foreground,
          ),
          const SizedBox(width: AppDimensions.tinySpacing),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingActionButton.copyWith(
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
