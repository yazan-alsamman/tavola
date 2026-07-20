import 'package:flutter/material.dart';

/// Local Cormorant Garamond helpers (bundled in pubspec `fonts:`).
///
/// LOCKED for Hot Restart safety: never route brand typography through the
/// `google_fonts` package (network/isolate loading). Use this API instead.
class AppFonts {
  AppFonts._();

  static const String cormorantGaramondFamily = 'CormorantGaramond';

  static TextStyle cormorantGaramond({
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
    final TextStyle base = textStyle ?? const TextStyle();
    return base.copyWith(
      fontFamily: cormorantGaramondFamily,
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

  static TextTheme cormorantGaramondTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: cormorantGaramond(textStyle: textTheme.displayLarge),
      displayMedium: cormorantGaramond(textStyle: textTheme.displayMedium),
      displaySmall: cormorantGaramond(textStyle: textTheme.displaySmall),
      headlineLarge: cormorantGaramond(textStyle: textTheme.headlineLarge),
      headlineMedium: cormorantGaramond(textStyle: textTheme.headlineMedium),
      headlineSmall: cormorantGaramond(textStyle: textTheme.headlineSmall),
      titleLarge: cormorantGaramond(textStyle: textTheme.titleLarge),
      titleMedium: cormorantGaramond(textStyle: textTheme.titleMedium),
      titleSmall: cormorantGaramond(textStyle: textTheme.titleSmall),
      bodyLarge: cormorantGaramond(textStyle: textTheme.bodyLarge),
      bodyMedium: cormorantGaramond(textStyle: textTheme.bodyMedium),
      bodySmall: cormorantGaramond(textStyle: textTheme.bodySmall),
      labelLarge: cormorantGaramond(textStyle: textTheme.labelLarge),
      labelMedium: cormorantGaramond(textStyle: textTheme.labelMedium),
      labelSmall: cormorantGaramond(textStyle: textTheme.labelSmall),
    );
  }
}
