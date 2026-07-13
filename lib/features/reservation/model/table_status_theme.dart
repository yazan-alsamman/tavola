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
      case TableStatus.reserved:
        return AppStrings.tableReserved;
      case TableStatus.cleaning:
        return AppStrings.tableCleaning;
    }
  }

  Color get badgeColor {
    switch (this) {
      case TableStatus.available:
        return AppColors.primaryDark;
      case TableStatus.reserved:
        return AppColors.accent;
      case TableStatus.cleaning:
        return AppColors.surfaceAlt;
    }
  }

  Color get foregroundColor {
    switch (this) {
      case TableStatus.available:
        return AppColors.textLight;
      case TableStatus.reserved:
        return AppColors.textPrimary;
      case TableStatus.cleaning:
        return AppColors.textSecondary;
    }
  }

  Color get tableBackgroundColor {
    switch (this) {
      case TableStatus.available:
        return AppColors.primaryDark;
      case TableStatus.reserved:
        return AppColors.accent;
      case TableStatus.cleaning:
        return AppColors.surface;
    }
  }

  Color get tableBorderColor {
    switch (this) {
      case TableStatus.available:
        return AppColors.primaryDark;
      case TableStatus.reserved:
        return AppColors.accent;
      case TableStatus.cleaning:
        return AppColors.border;
    }
  }

  TextStyle get tableLabelStyle {
    switch (this) {
      case TableStatus.available:
        return AppTextStyles.floorPlanTableLabel;
      case TableStatus.reserved:
        return AppTextStyles.floorPlanTableLabelOnAccent;
      case TableStatus.cleaning:
        return AppTextStyles.floorPlanTableLabelMuted;
    }
  }

  TextStyle get seatBadgeStyle {
    switch (this) {
      case TableStatus.available:
        return AppTextStyles.floorPlanSeatBadge;
      case TableStatus.reserved:
        return AppTextStyles.floorPlanSeatBadgeOnAccent;
      case TableStatus.cleaning:
        return AppTextStyles.floorPlanSeatBadgeMuted;
    }
  }
}
