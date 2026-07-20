import 'package:flutter/material.dart';
import 'app_fonts.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle compactRestaurantBody = TextStyle(
    fontSize: AppDimensions.compactRestaurantBodyFontSize,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle guestLoginButton = TextStyle(
    fontSize: AppDimensions.guestLoginButtonFontSize,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  static const TextStyle input = TextStyle(color: AppColors.textPrimary);
  static const TextStyle inputHint = TextStyle(color: AppColors.textSecondary);
  static const TextStyle placeholder = TextStyle();

  static const TextStyle authInput = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle authInputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle authScreenTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.6,
  );

  static const TextStyle authInstruction = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle authLink = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static const TextStyle authLinkEmphasis = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.primaryDark,
  );

  static const TextStyle authFieldErrorHint = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryDark,
  );

  static const TextStyle otpTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.primaryDark,
  );

  static const TextStyle otpTimer = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.primary,
  );

  static const TextStyle otpDigit = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle locationLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle promoTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static const TextStyle promoBody = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight90,
  );

  static const TextStyle profileName = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle partnerTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );

  static const TextStyle partnerBody = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight80,
  );

  static const TextStyle tabLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle settingsHeader = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle settingsItemTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle settingsItemBody = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle reservationTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle reservationPreferencesTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  static const TextStyle reservationPreferencesSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle selectRestaurantTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  static const TextStyle selectRestaurantSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle compactRestaurantTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle reservationSectionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: AppColors.accent,
  );

  static const TextStyle reservationCounterValue = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle reservationChoiceLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle reservationCalendarHeader = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle reservationCalendarWeekday = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle reservationCalendarDay = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle reservationNextButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  static const TextStyle selectTableTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  static const TextStyle selectTableSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle tableStatusLegendLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.9,
    color: AppColors.textPrimary,
  );

  static const TextStyle floorPlanLiveLabel = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle floorPlanLiveTime = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle floorPlanZoneLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.accent,
  );

  static const TextStyle floorPlanTableLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textLight,
  );

  static const TextStyle floorPlanTableLabelOnAccent = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle floorPlanTableLabelMuted = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle floorPlanSeatBadge = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textLight80,
  );

  static const TextStyle floorPlanSeatBadgeOnAccent = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle floorPlanSeatBadgeMuted = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  static const TextStyle floorPlanMapHint = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle tableSeatCount = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle tableStatusChip = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static const TextStyle tableDescription = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle confirmReservationButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static const TextStyle confirmationTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textLight,
  );

  static const TextStyle confirmationReference = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textLight80,
  );

  static const TextStyle confirmationDetailLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle confirmationDetailValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle conciergeTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle conciergeStatus = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.online,
  );

  static const TextStyle conciergeMessage = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle conciergeAction = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static const TextStyle conciergeInput = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle occasionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle occasionLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final detailsHeroTitle = AppFonts.cormorantGaramond(
    color: AppColors.textLight,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    height: 1.1,
  );

  static const TextStyle detailsHeroRating = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
    letterSpacing: 0.4,
  );

  static const TextStyle detailsHeroLocation = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight80,
  );

  static final detailsAboutBody = AppFonts.cormorantGaramond(
    color: AppColors.textSecondary,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.2,
  );

  static const TextStyle detailsAmenityText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle detailsSectionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: AppColors.accent,
  );

  static const TextStyle detailsHoursDay = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle detailsHoursTime = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle detailsContactPhone = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static final detailsMenuTitle = AppFonts.cormorantGaramond(
    color: AppColors.textPrimary,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  static const TextStyle detailsMenuItemName = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle detailsMenuItemDescription = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle detailsMenuItemPrice = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  static const TextStyle detailsLocationNote = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle appBarTitle(BuildContext context) {
    return AppFonts.cormorantGaramond(
      textStyle: Theme.of(context).textTheme.titleLarge,
      fontSize: 40,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle buttonLabel(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.labelLarge!.copyWith(fontSize: 15, fontWeight: FontWeight.w700);
  }

  static TextStyle listSectionTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!;
  }

  static final headerLogo = AppFonts.cormorantGaramond(
    color: AppColors.primary,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: 3,
    height: 1,
  );

  static final splashTitle = AppFonts.cormorantGaramond(
    color: AppColors.primaryDark,
    fontSize: 58,
    fontWeight: FontWeight.w700,
    letterSpacing: 10,
    height: 1,
    shadows: const [Shadow(color: AppColors.accent, blurRadius: 24)],
  );

  static final splashBrandMark = AppFonts.cormorantGaramond(
    color: AppColors.primaryDark,
    fontSize: AppDimensions.splashBrandFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: AppDimensions.splashBrandLetterSpacing,
    height: 1,
  );

  static final splashBrandGlyph = AppFonts.cormorantGaramond(
    color: AppColors.primaryDark,
    fontSize: AppDimensions.splashBrandFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1,
  );

  static final languageSwitchBrand = AppFonts.cormorantGaramond(
    color: AppColors.primary,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 6,
    height: 1,
  );

  static const TextStyle languageSwitchTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle languageSwitchSubtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static final logo = AppFonts.cormorantGaramond(
    color: AppColors.textLight,
    fontSize: 35,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
  );

  static final welcomeHeroTitle = AppFonts.cormorantGaramond(
    color: AppColors.accent,
    fontSize: AppDimensions.welcomeTitleFontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: AppDimensions.welcomeTitleLetterSpacing,
    height: 1,
    shadows: const [
      Shadow(
        color: AppColors.textLight80,
        blurRadius: 10,
      ),
    ],
  );

  static const TextStyle welcomeButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.9,
  );

  static final onboardingWelcomeSubtitle = AppFonts.cormorantGaramond(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 4.0,
    color: AppColors.textSecondary,
  );

  static final onboardingWelcomeBrand = AppFonts.cormorantGaramond(
    color: AppColors.primaryDark,
    fontSize: AppDimensions.onboardingWelcomeBrandSize,
    fontWeight: FontWeight.w700,
    letterSpacing: AppDimensions.onboardingWelcomeLetterSpacing,
    height: 1,
  );

  static const TextStyle onboardingSwipeHint = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingSectionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle onboardingSectionHint = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingPartyChip = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  static const TextStyle onboardingDateWeekday = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingDateNumber = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle onboardingDateLabel = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.primaryDark,
  );

  static const TextStyle onboardingInviteLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  static final onboardingBookHeadline = AppFonts.cormorantGaramond(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textPrimary,
  );

  static final onboardingBookHint = AppFonts.cormorantGaramond(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingConfirmedTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textLight,
  );

  static const TextStyle onboardingConfirmedMessage = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textLight80,
  );

  static const TextStyle onboardingInfoSectionTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle onboardingInfoLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingInfoValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle onboardingCodeField = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle onboardingActionButton = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle onboardingMiniCardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle onboardingMiniCardSubtitle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingRewardsHeader = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle onboardingRewardsTier = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.primaryDark,
  );

  static const TextStyle onboardingRewardsPoints = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingRewardsProgressLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.accent,
  );

  static const TextStyle onboardingRewardsProgressHint = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingRewardsStatValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle onboardingRewardsStatLabel = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingRewardsSectionTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.accent,
  );

  static const TextStyle onboardingRewardsOfferTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle onboardingRewardsOfferMeta = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle onboardingRewardsNeedMore = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.warning,
  );

  static const TextStyle onboardingRewardsChip = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const TextStyle onboardingRewardsBadge = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static const TextStyle onboardingRewardsBenefit = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle onboardingDinemateUserBubble = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textLight,
  );

  static const TextStyle onboardingDinemateHeaderTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static const TextStyle onboardingDinemateHeaderStatus = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
  );

  static const TextStyle favoriteCuisinesTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle favoriteCuisinesSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const TextStyle favoriteCuisineChip = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle favoriteCuisinesSkip = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static const TextStyle onboardingGetStarted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
}
