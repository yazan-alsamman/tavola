import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/app_translations.dart';

/// Ensures every `AppStrings` GetX `.tr` / `.trParams` key has EN + AR entries.
void main() {
  test('every AppStrings .tr key exists in English and Arabic maps', () {
    final String source = File(
      'lib/core/constants/app_strings.dart',
    ).readAsStringSync();
    final RegExp keyPattern = RegExp(r"((?:'[^']*'\s*)+)\.tr(?:Params)?");
    final Set<String> keys = <String>{};
    for (final RegExpMatch match in keyPattern.allMatches(source)) {
      final Iterable<String> parts = RegExp(
        r"'([^']*)'",
      ).allMatches(match.group(1)!).map((RegExpMatch m) => m.group(1)!);
      keys.add(parts.join());
    }

    expect(keys, isNotEmpty);

    final AppTranslations translations = AppTranslations();
    final Map<String, String> en = translations.keys['en']!;
    final Map<String, String> ar = translations.keys['ar']!;

    final List<String> missingEn = <String>[];
    final List<String> missingAr = <String>[];
    for (final String key in keys) {
      if (!en.containsKey(key)) {
        missingEn.add(key);
      }
      if (!ar.containsKey(key)) {
        missingAr.add(key);
      }
    }

    expect(
      missingEn,
      isEmpty,
      reason: 'Missing EN translations: $missingEn',
    );
    expect(
      missingAr,
      isEmpty,
      reason: 'Missing AR translations: $missingAr',
    );
  });

  test('chat open/closed status translates in Arabic', () {
    Get.testMode = true;
    Get.reset();
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('ar');

    expect('Open'.tr, 'مفتوح');
    expect('Closed'.tr, 'مغلق');
    expect('Mark all read'.tr, 'تعليم الكل كمقروء');
    expect('Chat with another restaurant'.tr, 'تحدث مع مطعم آخر');
    expect('No profile available.'.tr, 'لا يوجد ملف شخصي متاح.');
    expect(AppStrings.localizeUiLabel('CANCELLED'), 'ملغى');
    expect(AppStrings.localizeUiLabel('Pending'), 'قيد الانتظار');
    expect(AppStrings.localizeUiLabel('Approved'), 'مقبول');
    expect(AppStrings.localizeUiLabel('Confirmed'), 'مؤكد');

    Get.reset();
  });
}
