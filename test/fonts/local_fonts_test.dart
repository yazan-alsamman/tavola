import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/app/theme/app_theme.dart';
import 'package:tavla/core/constants/app_fonts.dart';
import 'package:tavla/core/constants/app_text_styles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const List<String> bundledFontAssets = <String>[
    'assets/fonts/PlayfairDisplay-Regular.ttf',
    'assets/fonts/PlayfairDisplay-Medium.ttf',
    'assets/fonts/PlayfairDisplay-SemiBold.ttf',
    'assets/fonts/PlayfairDisplay-Bold.ttf',
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
    'assets/fonts/Inter-Bold.ttf',
    'assets/fonts/Amiri-Regular.ttf',
    'assets/fonts/Amiri-Bold.ttf',
    'assets/fonts/Cairo-Regular.ttf',
    'assets/fonts/Cairo-Medium.ttf',
    'assets/fonts/Cairo-SemiBold.ttf',
    'assets/fonts/Cairo-Bold.ttf',
    'assets/fonts/MaterialSymbolsOutlined.ttf',
  ];

  group('Local bundled fonts (no google_fonts)', () {
    test('every registered font file exists in the asset bundle', () async {
      for (final String asset in bundledFontAssets) {
        final ByteData data = await rootBundle.load(asset);
        expect(data.lengthInBytes, greaterThan(0), reason: asset);
      }
    });

    test('FontManifest registers all app font families', () async {
      final String manifestJson = await rootBundle.loadString(
        'FontManifest.json',
      );
      final List<dynamic> manifest = json.decode(manifestJson) as List<dynamic>;
      final Set<String> families = manifest
          .map(
            (dynamic entry) =>
                (entry as Map<String, dynamic>)['family'] as String,
          )
          .toSet();

      expect(families, contains(AppFonts.playfairDisplayFamily));
      expect(families, contains(AppFonts.interFamily));
      expect(families, contains(AppFonts.amiriFamily));
      expect(families, contains(AppFonts.cairoFamily));
      expect(families, contains(AppFonts.materialSymbolsOutlinedFamily));
    });

    test('English styles use PlayfairDisplay/Inter local families', () {
      const Locale en = Locale('en');
      expect(
        AppFonts.heading(locale: en).fontFamily,
        AppFonts.playfairDisplayFamily,
      );
      expect(AppFonts.ui(locale: en).fontFamily, AppFonts.interFamily);
      expect(
        AppFonts.familyForLocale(heading: true, locale: en),
        AppFonts.playfairDisplayFamily,
      );
      expect(
        AppFonts.familyForLocale(heading: false, locale: en),
        AppFonts.interFamily,
      );
    });

    test('Arabic styles use Amiri/Cairo local families', () {
      const Locale ar = Locale('ar');
      expect(AppFonts.heading(locale: ar).fontFamily, AppFonts.amiriFamily);
      expect(AppFonts.ui(locale: ar).fontFamily, AppFonts.cairoFamily);
      expect(
        AppFonts.familyForLocale(heading: true, locale: ar),
        AppFonts.amiriFamily,
      );
      expect(
        AppFonts.familyForLocale(heading: false, locale: ar),
        AppFonts.cairoFamily,
      );
    });

    test('theme text styles resolve to local families for both locales', () {
      final ThemeData enTheme = AppTheme.themeFor(const Locale('en'));
      expect(
        enTheme.textTheme.titleLarge?.fontFamily,
        AppFonts.playfairDisplayFamily,
      );
      expect(enTheme.textTheme.bodyMedium?.fontFamily, AppFonts.interFamily);

      final ThemeData arTheme = AppTheme.themeFor(const Locale('ar'));
      expect(arTheme.textTheme.titleLarge?.fontFamily, AppFonts.amiriFamily);
      expect(arTheme.textTheme.bodyMedium?.fontFamily, AppFonts.cairoFamily);
    });

    test('forLocale switches families without google_fonts', () {
      final TextStyle base = AppTextStyles.title;
      expect(
        AppFonts.forLocale(
          base,
          locale: const Locale('ar'),
          heading: true,
        ).fontFamily,
        AppFonts.amiriFamily,
      );
      expect(
        AppFonts.forLocale(
          base,
          locale: const Locale('en'),
          heading: true,
        ).fontFamily,
        AppFonts.playfairDisplayFamily,
      );
    });
  });
}
