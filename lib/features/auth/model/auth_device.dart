import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';

/// Resolves `deviceType` for customer login against the API contract:
/// `mobile` | `web` | `tablet` | `unknown`.
class AuthDevice {
  AuthDevice._();

  static String get type {
    if (kIsWeb) {
      return AppStrings.authDeviceTypeWeb;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return AppStrings.authDeviceTypeMobile;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return AppStrings.authDeviceTypeUnknown;
    }
  }

  static String get name => AppStrings.authDeviceName;
}
