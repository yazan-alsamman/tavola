import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static final detailsHeroTitle = GoogleFonts.cormorantGaramond(
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

  static final detailsAboutBody = GoogleFonts.cormorantGaramond(
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

  static final detailsMenuTitle = GoogleFonts.cormorantGaramond(
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
    return GoogleFonts.cormorantGaramond(
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

  static final headerLogo = GoogleFonts.cormorantGaramond(
    color: AppColors.primary,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: 3,
    height: 1,
  );

  static final splashTitle = GoogleFonts.cormorantGaramond(
    color: AppColors.primaryDark,
    fontSize: 58,
    fontWeight: FontWeight.w700,
    letterSpacing: 10,
    height: 1,
    shadows: const [Shadow(color: AppColors.accent, blurRadius: 24)],
  );

  static final logo = GoogleFonts.cormorantGaramond(
    color: AppColors.textLight,
    fontSize: 35,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
  );

  static final welcomeHeroTitle = GoogleFonts.cormorantGaramond(
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
}
