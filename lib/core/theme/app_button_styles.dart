import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppButtonStyles {
  static ButtonStyle filledHover(
    ButtonStyle baseStyle, {
    Color idleBackground = AppColors.primary,
    Color idleForeground = AppColors.textLight,
  }) {
    return baseStyle.copyWith(
      animationDuration: AppDimensions.hoverDuration,
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.disabled;
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.primaryDark;
          }
          return idleBackground;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textSecondary;
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.textLight;
          }
          return idleForeground;
        },
      ),
    );
  }

  static ButtonStyle outlinedHover(ButtonStyle baseStyle) {
    return baseStyle.copyWith(
      animationDuration: AppDimensions.hoverDuration,
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? AppColors.primaryDark
            : AppColors.transparent,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? AppColors.textLight
            : AppColors.primary,
      ),
    );
  }

  static ButtonStyle textHover(ButtonStyle baseStyle) {
    return baseStyle.copyWith(
      animationDuration: AppDimensions.hoverDuration,
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? AppColors.primaryDark
            : AppColors.transparent,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? AppColors.textLight
            : AppColors.primary,
      ),
    );
  }
}
