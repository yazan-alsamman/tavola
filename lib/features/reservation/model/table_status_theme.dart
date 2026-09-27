import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import 'restaurant_table_model.dart';
import 'table_status.dart';

/// Visual state for a table that is operationally available but not bookable
/// for the selected window. Map, legend, and the status under the plan share it.
class SlotUnavailablePresentation {
  const SlotUnavailablePresentation._();

  static Color get tableColor => AppColors.surfaceAlt;
  static Color get borderColor => AppColors.border;
  static Color get chairColor => AppColors.disabled;
  static Color get badgeColor => AppColors.surfaceAlt;
  static Color get foregroundColor => AppColors.textPrimary;
  static String get label => AppStrings.tableUnavailable;
  static TextStyle get labelStyle => AppTextStyles.floorPlanTableLabelOnLight;
}

extension RestaurantTableStatusPresentation on RestaurantTableModel {
  /// Operational `available` plus a closed booking window.
  bool get isSlotUnavailable =>
      status == TableStatus.available && isAvailableForWindow == false;

  String get presentedStatusLabel =>
      isSlotUnavailable ? SlotUnavailablePresentation.label : status.label;

  Color get presentedTableColor => isSlotUnavailable
      ? SlotUnavailablePresentation.tableColor
      : status.tableBackgroundColor;

  Color get presentedBorderColor => isSlotUnavailable
      ? SlotUnavailablePresentation.borderColor
      : status.tableBorderColor;

  Color get presentedChairColor => isSlotUnavailable
      ? SlotUnavailablePresentation.chairColor
      : status.chairColor;

  Color get presentedBadgeColor => isSlotUnavailable
      ? SlotUnavailablePresentation.badgeColor
      : status.badgeColor;

  Color get presentedForegroundColor => isSlotUnavailable
      ? SlotUnavailablePresentation.foregroundColor
      : status.foregroundColor;

  TextStyle get presentedLabelStyle => isSlotUnavailable
      ? SlotUnavailablePresentation.labelStyle
      : status.tableLabelStyle;
}

extension TableStatusTheme on TableStatus {
  String get label {
    switch (this) {
      case TableStatus.available:
        return AppStrings.tableAvailable;
      case TableStatus.occupied:
        return AppStrings.tableOccupied;
      case TableStatus.cleaning:
        return AppStrings.tableCleaning;
      case TableStatus.disabled:
        return AppStrings.tableDisabled;
    }
  }

  Color get badgeColor {
    switch (this) {
      case TableStatus.available:
        return AppColors.primaryDark;
      case TableStatus.occupied:
        return AppColors.accent;
      case TableStatus.cleaning:
        return AppColors.surfaceAlt;
      case TableStatus.disabled:
        return AppColors.disabled;
    }
  }

  Color get foregroundColor {
    switch (this) {
      case TableStatus.available:
        return AppColors.textLight;
      case TableStatus.occupied:
        return AppColors.textPrimary;
      case TableStatus.cleaning:
        return AppColors.textSecondary;
      case TableStatus.disabled:
        return AppColors.textSecondary;
    }
  }

  Color get tableBackgroundColor {
    switch (this) {
      case TableStatus.available:
        return AppColors.primaryDark;
      case TableStatus.occupied:
        return AppColors.accent;
      case TableStatus.cleaning:
        return AppColors.surface;
      case TableStatus.disabled:
        return AppColors.disabled;
    }
  }

  Color get tableBorderColor {
    switch (this) {
      case TableStatus.available:
        return AppColors.primaryDark;
      case TableStatus.occupied:
        return AppColors.accent;
      case TableStatus.cleaning:
        return AppColors.border;
      case TableStatus.disabled:
        return AppColors.border;
    }
  }

  Color get chairColor {
    switch (this) {
      case TableStatus.available:
        return AppColors.primaryDark;
      case TableStatus.occupied:
        return AppColors.accent;
      case TableStatus.cleaning:
        return AppColors.border;
      case TableStatus.disabled:
        return AppColors.disabled;
    }
  }

  TextStyle get tableLabelStyle {
    switch (this) {
      case TableStatus.available:
        return AppTextStyles.floorPlanTableLabel;
      case TableStatus.occupied:
        return AppTextStyles.floorPlanTableLabelOnAccent;
      case TableStatus.cleaning:
        return AppTextStyles.floorPlanTableLabelMuted;
      case TableStatus.disabled:
        return AppTextStyles.floorPlanTableLabelMuted;
    }
  }

  TextStyle get seatBadgeStyle {
    switch (this) {
      case TableStatus.available:
        return AppTextStyles.floorPlanSeatBadge;
      case TableStatus.occupied:
        return AppTextStyles.floorPlanSeatBadgeOnAccent;
      case TableStatus.cleaning:
        return AppTextStyles.floorPlanSeatBadgeMuted;
      case TableStatus.disabled:
        return AppTextStyles.floorPlanSeatBadgeMuted;
    }
  }
}
