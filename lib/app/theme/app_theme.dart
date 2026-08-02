import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/theme/app_button_styles.dart';

class AppTheme {
  static ThemeData get lightTheme => themeFor(const Locale('en'));

  static ThemeData themeFor(Locale locale) {
    final TextTheme appTextTheme = AppFonts.textTheme(null, locale);

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.isArabicLocale(locale)
          ? AppFonts.cairoFamily
          : AppFonts.interFamily,
      textTheme: appTextTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      primaryTextTheme: appTextTheme,
      scaffoldBackgroundColor: AppColors.scaffold,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onPrimary: AppColors.textLight,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: AppColors.surface, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.filledHover(
          ElevatedButton.styleFrom(
            textStyle: AppFonts.ui(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              locale: locale,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlinedHover(
          OutlinedButton.styleFrom(
            textStyle: AppFonts.ui(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              locale: locale,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonStyles.textHover(
          TextButton.styleFrom(
            textStyle: AppFonts.ui(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              locale: locale,
            ),
          ),
        ),
      ),
      dividerColor: AppColors.divider,
    );
  }
}
