import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_strings.dart';
import 'model/session_mode.dart';

/// SharedPreferences-backed persistence for [SessionMode].
///
/// Lives under the auth feature (owns [SessionMode]). Uses the same
/// SharedPreferences abstraction as [OnboardingPreferences] — not a second
/// storage system. Does not touch Secure Storage tokens.
class SessionModePreferences {
  SessionModePreferences._();

  static Future<SessionMode> read() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return SessionMode.fromStorage(prefs.getString(AppStrings.sessionModeKey));
  }

  static Future<void> write(SessionMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mode == SessionMode.none) {
      await prefs.remove(AppStrings.sessionModeKey);
      return;
    }
    await prefs.setString(AppStrings.sessionModeKey, mode.storageValue);
  }

  static Future<void> clear() => write(SessionMode.none);
}
