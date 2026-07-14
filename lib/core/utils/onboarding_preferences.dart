import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';

class OnboardingPreferences {
  OnboardingPreferences._();

  static Future<bool> isCompleted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppStrings.onboardingCompletedKey) ?? false;
  }

  static Future<void> markCompleted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.onboardingCompletedKey, true);
  }
}
