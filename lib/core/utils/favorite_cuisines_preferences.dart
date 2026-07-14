import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';

class FavoriteCuisinesPreferences {
  FavoriteCuisinesPreferences._();

  static Future<bool> isCompleted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppStrings.favoriteCuisinesCompletedKey) ?? false;
  }

  static Future<void> markCompleted({
    List<String> selectedCuisines = const [],
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.favoriteCuisinesCompletedKey, true);
    await prefs.setStringList(
      AppStrings.favoriteCuisinesSelectedKey,
      selectedCuisines,
    );
  }
}
