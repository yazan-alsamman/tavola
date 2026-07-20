import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';

class LocalePreferences {
  LocalePreferences._();

  static Future<Locale?> savedLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(AppStrings.localeLanguageCodeKey);
    if (code == null || code.isEmpty) {
      return null;
    }
    return Locale(code);
  }

  static Future<void> saveLocale(Locale locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.localeLanguageCodeKey, locale.languageCode);
  }
}
