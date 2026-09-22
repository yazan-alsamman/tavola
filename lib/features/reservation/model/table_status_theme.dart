import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import 'table_status.dart';

extension TableStatusTheme on TableStatus {
  String get label {
    switch (this) {
      case TableStatus.available:
        return AppStrings.tableAvailable;
      case TableStatus.occupied:
        return AppStrings.tableOccupied;
      case TableStatus.reserved:
        return AppStrings.tableReserved;
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
      case TableStatus.reserved:
        return AppColors.bronze;
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
      case TableStatus.reserved:
        return AppColors.textLight;
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
      case TableStatus.reserved:
        return AppColors.bronze;
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
      case TableStatus.reserved:
        return AppColors.bronze;
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
      case TableStatus.reserved:
        return AppColors.bronze;
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
      case TableStatus.reserved:
        return AppTextStyles.floorPlanTableLabel;
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
      case TableStatus.reserved:
        return AppTextStyles.floorPlanSeatBadge;
      case TableStatus.cleaning:
        return AppTextStyles.floorPlanSeatBadgeMuted;
      case TableStatus.disabled:
        return AppTextStyles.floorPlanSeatBadgeMuted;
    }
  }
}
