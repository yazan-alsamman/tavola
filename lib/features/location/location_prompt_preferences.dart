import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_strings.dart';

/// SharedPreferences flag: the in-app location activation prompt was handled.
///
/// Same persistence mechanism as [OnboardingPreferences] / [SessionModePreferences].
/// Does not store OS permission or Location Services state.
class LocationPromptPreferences {
  LocationPromptPreferences._();

  static bool? _cached;

  /// Last known disk value for this process, or `null` before the first read.
  static bool? get cachedOrNull => _cached;

  @visibleForTesting
  static void resetForTest() {
    _cached = null;
  }

  static Future<bool> hasRequested() async {
    if (_cached != null) {
      return _cached!;
    }
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _cached = prefs.getBool(AppStrings.locationPromptRequestedKey) ?? false;
      return _cached!;
    } catch (_) {
      return _cached ?? false;
    }
  }

  static Future<void> markRequested() async {
    _cached = true;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppStrings.locationPromptRequestedKey, true);
    } catch (_) {
      // Process memory still records the ask; launch continues if disk fails.
    }
  }
}
