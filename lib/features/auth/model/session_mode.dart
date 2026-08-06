import '../../../core/constants/app_strings.dart';

/// Persisted entry mode restored by Splash after process death / reboot.
enum SessionMode {
  none,
  guest,
  authenticated;

  String get storageValue {
    switch (this) {
      case SessionMode.none:
        return AppStrings.sessionModeNoneValue;
      case SessionMode.guest:
        return AppStrings.sessionModeGuestValue;
      case SessionMode.authenticated:
        return AppStrings.sessionModeAuthenticatedValue;
    }
  }

  static SessionMode fromStorage(String? raw) {
    final String value = raw?.trim() ?? '';
    if (value == AppStrings.sessionModeGuestValue) {
      return SessionMode.guest;
    }
    if (value == AppStrings.sessionModeAuthenticatedValue) {
      return SessionMode.authenticated;
    }
    return SessionMode.none;
  }
}
