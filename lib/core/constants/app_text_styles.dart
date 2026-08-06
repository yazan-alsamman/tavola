import 'package:flutter/material.dart';
import 'app_fonts.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTextStyles {
  static TextStyle get headline => AppFonts.heading(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get title => AppFonts.heading(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get compactRestaurantBody => AppFonts.ui(
    fontSize: AppDimensions.compactRestaurantBodyFontSize,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get label => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle get guestLoginButton => AppFonts.ui(
    fontSize: AppDimensions.guestLoginButtonFontSize,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  static TextStyle get input => AppFonts.ui(color: AppColors.textPrimary);
  static TextStyle get inputHint => AppFonts.ui(color: AppColors.textSecondary);
  static TextStyle get placeholder => AppFonts.ui();

  static TextStyle get authInput => AppFonts.ui(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
    height: 1.35,
  );

  static TextStyle get authInputHint => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
    height: 1.35,
  );

  /// Screen titles (LOGIN / SIGN UP) — Playfair Display.
  static TextStyle get authScreenTitle => AppFonts.heading(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
    letterSpacing: 1.4,
    height: 1.1,
  );

  /// Brand lockup above auth titles — Playfair Display.
  static TextStyle get authBrandMark => AppFonts.heading(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 4.0,
    height: 1,
  );

  static TextStyle get authInstruction => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.55,
    letterSpacing: 0.15,
  );

  static TextStyle get authLink => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.2,
  );

  static TextStyle get authLinkEmphasis => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.primaryDark,
  );

  static TextStyle get notificationBadge => AppFonts.ui(
    fontSize: AppDimensions.notificationBadgeFontSize,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
    height: 1.0,
  );

  static TextStyle get authFieldErrorHint => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryDark,
    letterSpacing: 0.1,
    height: 1.35,
  );

  /// Primary CTA on auth screens — Inter.
  static TextStyle get authPrimaryButton => AppFonts.ui(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    height: 1.2,
  );

  /// Country-picker sheet header — Playfair Display.
  static TextStyle get authDialogTitle => AppFonts.heading(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
    letterSpacing: 0.4,
    height: 1.2,
  );

  static TextStyle get otpTitle => AppFonts.heading(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.15,
    color: AppColors.primaryDark,
  );

  static TextStyle get otpTimer => AppFonts.ui(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: AppColors.primary,
  );

  static TextStyle get otpDigit => AppFonts.ui(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle get locationLabel => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get promoTitle => AppFonts.heading(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static TextStyle get promoBody => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight90,
  );

  static TextStyle get profileName => AppFonts.heading(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get partnerTitle => AppFonts.heading(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );

  static TextStyle get partnerBody => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight80,
  );

  static TextStyle get exploreBannerTitle => AppFonts.heading(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.4,
    height: 1.2,
  );

  static TextStyle get reservationHistoryTitle => AppFonts.heading(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryDark,
    letterSpacing: AppDimensions.reservationHistoryTitleLetterSpacing,
    height: 1.15,
  );

  static TextStyle get profileReservationsEmptyTitle => AppFonts.heading(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryDark,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static TextStyle get profileReservationsEmptyBody => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
    letterSpacing: 0.15,
  );

  static TextStyle get reservationHistoryMeta => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
    letterSpacing: 0.15,
  );

  static TextStyle get reservationHistoryStatus => AppFonts.ui(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
    letterSpacing: AppDimensions.reservationHistoryStatusLetterSpacing,
    height: 1.1,
  );

  static TextStyle get reservationReviewEyebrow => AppFonts.ui(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryDark,
    letterSpacing: 1.0,
    height: 1.2,
  );

  static TextStyle get reservationReviewComment => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryDark,
    height: 1.35,
    letterSpacing: 0.1,
  );

  static TextStyle get reservationReviewAction => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
    letterSpacing: 0.4,
    height: 1.2,
  );

  static TextStyle get exploreBannerBody => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight80,
    height: AppDimensions.exploreBannerBodyLineHeight,
    letterSpacing: 0.2,
  );

  static TextStyle get exploreBannerButton => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static TextStyle get tabLabel =>
      AppFonts.ui(fontSize: 13, fontWeight: FontWeight.w600);

  static TextStyle get profileSectionTabLabel => AppFonts.ui(
    fontSize: AppDimensions.profileSectionTabFontSize,
    fontWeight: FontWeight.w600,
    height: AppDimensions.profileSectionTabLineHeight,
    letterSpacing: 0.1,
  );

  static TextStyle get sectionTitle => AppFonts.heading(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get confirmDialogTitle => AppFonts.heading(
    fontSize: AppDimensions.confirmDialogTitleFontSize,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle get confirmDialogMessage => AppFonts.ui(
    fontSize: AppDimensions.confirmDialogMessageFontSize,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: AppDimensions.confirmDialogMessageLineHeight,
  );

  static TextStyle get confirmDialogButton => AppFonts.ui(
    fontSize: AppDimensions.confirmDialogButtonFontSize,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
    letterSpacing: 0.3,
  );

  static TextStyle get settingsHeader => AppFonts.heading(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get settingsItemTitle => AppFonts.ui(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get settingsItemBody => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get reservationTitle => AppFonts.heading(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get reservationPreferencesTitle => AppFonts.heading(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  static TextStyle get reservationPreferencesSubtitle => AppFonts.ui(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle get selectRestaurantTitle => AppFonts.heading(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  static TextStyle get selectRestaurantSubtitle => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle get compactRestaurantTitle => AppFonts.heading(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get reservationSectionLabel => AppFonts.heading(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: AppColors.accent,
  );

  static TextStyle get reservationCounterValue => AppFonts.ui(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get reservationChoiceLabel =>
      AppFonts.ui(fontSize: 14, fontWeight: FontWeight.w700);

  static TextStyle get reservationCalendarHeader => AppFonts.heading(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get reservationCalendarWeekday => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle get reservationCalendarDay => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get reservationNextButton => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  static TextStyle get selectTableTitle => AppFonts.heading(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  static TextStyle get selectTableSubtitle => AppFonts.ui(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle get tableStatusLegendLabel => AppFonts.ui(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.9,
    color: AppColors.textPrimary,
  );

  static TextStyle get floorPlanLiveLabel => AppFonts.ui(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  static TextStyle get floorPlanLiveTime => AppFonts.ui(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static TextStyle get floorPlanZoneLabel => AppFonts.heading(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.accent,
  );

  static TextStyle get floorPlanTableLabel => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textLight,
  );

  static TextStyle get floorPlanTableLabelOnAccent => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static TextStyle get floorPlanTableLabelMuted => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static TextStyle get floorPlanSeatBadge => AppFonts.ui(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textLight80,
  );

  static TextStyle get floorPlanSeatBadgeOnAccent => AppFonts.ui(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get floorPlanSeatBadgeMuted => AppFonts.ui(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  static TextStyle get floorPlanMapHint => AppFonts.ui(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get tableSeatCount => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textPrimary,
  );

  static TextStyle get tableStatusChip => AppFonts.ui(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static TextStyle get tableDescription => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle get confirmReservationButton => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static TextStyle get confirmationTitle => AppFonts.heading(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textLight,
  );

  static TextStyle get confirmationReference => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textLight80,
  );

  static TextStyle get confirmationDetailLabel => AppFonts.ui(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  static TextStyle get confirmationDetailValue => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle get conciergeTitle => AppFonts.heading(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get conciergeStatus => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.online,
  );

  static TextStyle get conciergeMessage => AppFonts.ui(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static TextStyle get conciergeAction => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static TextStyle get conciergeInput => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get occasionTitle => AppFonts.heading(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get occasionLabel => AppFonts.ui(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get detailsHeroTitle => AppFonts.heading(
    color: AppColors.textLight,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    height: 1.1,
  );

  static TextStyle get detailsHeroRating => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
    letterSpacing: 0.4,
  );

  static TextStyle get detailsHeroLocation => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight80,
  );

  static TextStyle get detailsAboutBody => AppFonts.ui(
    color: AppColors.textSecondary,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.2,
  );

  static TextStyle get detailsAmenityText => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get detailsSectionLabel => AppFonts.heading(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: AppColors.accent,
  );

  static TextStyle get detailsHoursDay => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get detailsHoursTime => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get detailsContactPhone => AppFonts.ui(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static TextStyle get detailsMenuTitle => AppFonts.heading(
    color: AppColors.textPrimary,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  static TextStyle get detailsMenuItemName => AppFonts.heading(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get detailsMenuItemDescription => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get detailsMenuItemPrice => AppFonts.ui(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  static TextStyle get detailsLocationNote => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle appBarTitle(BuildContext context) {
    return AppFonts.heading(
      textStyle: Theme.of(context).textTheme.titleLarge,
      fontSize: 40,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle buttonLabel(BuildContext context) {
    return AppFonts.ui(
      textStyle: Theme.of(context).textTheme.labelLarge,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle listSectionTitle(BuildContext context) {
    return AppFonts.heading(textStyle: Theme.of(context).textTheme.titleMedium);
  }

  static TextStyle get headerLogo => AppFonts.heading(
    color: AppColors.primary,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: 3,
    height: 1,
  );

  static TextStyle get notificationsTitle => AppFonts.heading(
    color: AppColors.primary,
    fontSize: AppDimensions.notificationsTitleFontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: AppDimensions.notificationsTitleLetterSpacing,
    height: 1,
  );

  static TextStyle get splashTitle => AppFonts.heading(
    color: AppColors.primaryDark,
    fontSize: 58,
    fontWeight: FontWeight.w700,
    letterSpacing: 10,
    height: 1,
    shadows: const [Shadow(color: AppColors.accent, blurRadius: 24)],
  );

  static TextStyle get splashBrandMark => AppFonts.heading(
    color: AppColors.primaryDark,
    fontSize: AppDimensions.splashBrandFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: AppDimensions.splashBrandLetterSpacing,
    height: 1,
  );

  static TextStyle get splashBrandGlyph => AppFonts.heading(
    color: AppColors.primaryDark,
    fontSize: AppDimensions.splashBrandFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1,
  );

  static TextStyle get languageSwitchBrand => AppFonts.heading(
    color: AppColors.primary,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 6,
    height: 1,
  );

  static TextStyle get languageSwitchTitle => AppFonts.heading(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get languageSwitchSubtitle => AppFonts.ui(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get logo => AppFonts.heading(
    color: AppColors.textLight,
    fontSize: 35,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
  );

  static TextStyle get welcomeHeroTitle => AppFonts.heading(
    color: AppColors.accent,
    fontSize: AppDimensions.welcomeTitleFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: AppDimensions.welcomeTitleLetterSpacing,
    height: 1,
    shadows: const [
      Shadow(
        color: AppColors.primaryDark75,
        blurRadius: 8,
        offset: Offset(0, 1),
      ),
    ],
  );

  static TextStyle get welcomeButton => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.9,
  );

  static TextStyle get restaurantCardActionButton => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.2,
  );

  static TextStyle get onboardingWelcomeSubtitle => AppFonts.heading(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 4.0,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingWelcomeBrand => AppFonts.heading(
    color: AppColors.primaryDark,
    fontSize: AppDimensions.onboardingWelcomeBrandSize,
    fontWeight: FontWeight.w700,
    letterSpacing: AppDimensions.onboardingWelcomeLetterSpacing,
    height: 1,
  );

  static TextStyle get onboardingSwipeHint => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingSectionTitle => AppFonts.heading(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingSectionHint => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingPartyChip => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  static TextStyle get onboardingDateWeekday => AppFonts.ui(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingDateNumber => AppFonts.ui(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingDateLabel => AppFonts.ui(
    fontSize: 8,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.primaryDark,
  );

  static TextStyle get onboardingInviteLabel => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  static TextStyle get onboardingBookHeadline => AppFonts.heading(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingBookHint => AppFonts.ui(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingConfirmedTitle => AppFonts.heading(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textLight,
  );

  static TextStyle get onboardingConfirmedMessage => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textLight80,
  );

  static TextStyle get onboardingInfoSectionTitle => AppFonts.heading(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingInfoLabel => AppFonts.ui(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingInfoValue => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingCodeField => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingActionButton =>
      AppFonts.ui(fontSize: 12, fontWeight: FontWeight.w700);

  static TextStyle get onboardingMiniCardTitle => AppFonts.heading(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingMiniCardSubtitle => AppFonts.ui(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingRewardsHeader => AppFonts.heading(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingRewardsTier => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.primaryDark,
  );

  static TextStyle get onboardingRewardsPoints => AppFonts.ui(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingRewardsProgressLabel => AppFonts.ui(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.accent,
  );

  static TextStyle get onboardingRewardsProgressHint => AppFonts.ui(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingRewardsStatValue => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingRewardsStatLabel => AppFonts.ui(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingRewardsSectionTitle => AppFonts.heading(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.accent,
  );

  static TextStyle get onboardingRewardsOfferTitle => AppFonts.heading(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingRewardsOfferMeta => AppFonts.ui(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get onboardingRewardsNeedMore => AppFonts.ui(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.warning,
  );

  static TextStyle get onboardingRewardsChip =>
      AppFonts.ui(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.2);

  static TextStyle get onboardingRewardsBadge => AppFonts.ui(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static TextStyle get onboardingRewardsBenefit => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get onboardingDinemateUserBubble => AppFonts.ui(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textLight,
  );

  static TextStyle get onboardingDinemateHeaderTitle => AppFonts.heading(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static TextStyle get onboardingDinemateHeaderStatus => AppFonts.ui(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
  );

  static TextStyle get favoriteCuisinesTitle => AppFonts.heading(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get favoriteCuisinesSubtitle => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static TextStyle get favoriteCuisineChip =>
      AppFonts.ui(fontSize: 14, fontWeight: FontWeight.w600);

  static TextStyle get favoriteCuisinesSkip => AppFonts.ui(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static TextStyle get onboardingGetStarted => AppFonts.ui(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
}
