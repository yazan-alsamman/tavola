import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_button_styles.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.cormorantGaramond().fontFamily,
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
      style: AppButtonStyles.filledHover(const ButtonStyle()),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppButtonStyles.outlinedHover(const ButtonStyle()),
    ),
    textButtonTheme: TextButtonThemeData(
      style: AppButtonStyles.textHover(const ButtonStyle()),
    ),
    dividerColor: AppColors.divider,
  );
}
