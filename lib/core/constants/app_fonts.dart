import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// App typography helpers.
///
/// English:
/// - [playfairDisplay]: brand, headings, restaurant titles, banners, section titles
/// - [inter]: body, buttons, forms, filters, navigation, pricing
///
/// Arabic:
/// - [amiri]: brand logo, main headings, premium identity, luxury section headers
/// - [cairo]: all remaining Arabic UI text
///
/// Prefer [heading] / [ui] so the active locale picks the correct family.
///
/// Families are loaded from `assets/fonts/` via `pubspec.yaml` (no google_fonts).
class AppFonts {
  AppFonts._();

  static bool isArabicLocale([Locale? locale]) {
    final Locale? resolved = locale ?? Get.locale;
    return resolved?.languageCode == 'ar';
  }

  /// Matches `pubspec.yaml` font family keys / Google Fonts API family ids.
  static const String playfairDisplayFamily = 'PlayfairDisplay';
  static const String interFamily = 'Inter';
  static const String amiriFamily = 'Amiri';
  static const String cairoFamily = 'Cairo';
  static const String materialSymbolsOutlinedFamily = 'MaterialSymbolsOutlined';

  static String familyForLocale({required bool heading, Locale? locale}) {
    if (isArabicLocale(locale)) {
      return heading ? amiriFamily : cairoFamily;
    }
    return heading ? playfairDisplayFamily : interFamily;
  }

  static TextStyle playfairDisplay({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return _withFallbacks(
      _style(
        family: playfairDisplayFamily,
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      ),
      fallbacks: const [amiriFamily, cairoFamily],
    );
  }

  static TextStyle inter({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return _withFallbacks(
      _style(
        family: interFamily,
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      ),
      fallbacks: const [cairoFamily, amiriFamily],
    );
  }

  static TextStyle amiri({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return _withFallbacks(
      _style(
        family: amiriFamily,
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      ),
      fallbacks: const [playfairDisplayFamily, interFamily],
    );
  }

  static TextStyle cairo({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return _withFallbacks(
      _style(
        family: cairoFamily,
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      ),
      fallbacks: const [interFamily, playfairDisplayFamily],
    );
  }

  static TextStyle _style({
    required String family,
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return (textStyle ?? const TextStyle()).copyWith(
      fontFamily: family,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  static TextStyle _withFallbacks(
    TextStyle style, {
    required List<String> fallbacks,
  }) {
    return style.copyWith(fontFamilyFallback: fallbacks);
  }

  /// Brand / headings — Playfair (EN) or Amiri (AR).
  static TextStyle heading({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    if (isArabicLocale(locale)) {
      return amiri(
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      );
    }
    return playfairDisplay(
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  /// Body / UI — Inter (EN) or Cairo (AR).
  static TextStyle ui({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    if (isArabicLocale(locale)) {
      return cairo(
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      );
    }
    return inter(
      textStyle: textStyle,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  /// Forces the correct family for [locale] without changing other attributes.
  ///
  /// Use when text must match a target locale before [Get.locale] updates
  /// (e.g. language-switch overlay).
  static TextStyle forLocale(
    TextStyle style, {
    required Locale locale,
    required bool heading,
  }) {
    if (isArabicLocale(locale)) {
      return heading ? amiri(textStyle: style) : cairo(textStyle: style);
    }
    return heading
        ? playfairDisplay(textStyle: style)
        : inter(textStyle: style);
  }

  static TextTheme textTheme([TextTheme? base, Locale? locale]) {
    final TextTheme theme = base ?? ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: heading(textStyle: theme.displayLarge, locale: locale),
      displayMedium: heading(textStyle: theme.displayMedium, locale: locale),
      displaySmall: heading(textStyle: theme.displaySmall, locale: locale),
      headlineLarge: heading(textStyle: theme.headlineLarge, locale: locale),
      headlineMedium: heading(textStyle: theme.headlineMedium, locale: locale),
      headlineSmall: heading(textStyle: theme.headlineSmall, locale: locale),
      titleLarge: heading(textStyle: theme.titleLarge, locale: locale),
      titleMedium: heading(textStyle: theme.titleMedium, locale: locale),
      titleSmall: heading(textStyle: theme.titleSmall, locale: locale),
      bodyLarge: ui(textStyle: theme.bodyLarge, locale: locale),
      bodyMedium: ui(textStyle: theme.bodyMedium, locale: locale),
      bodySmall: ui(textStyle: theme.bodySmall, locale: locale),
      labelLarge: ui(textStyle: theme.labelLarge, locale: locale),
      labelMedium: ui(textStyle: theme.labelMedium, locale: locale),
      labelSmall: ui(textStyle: theme.labelSmall, locale: locale),
    );
  }
}
