/// App-level location permission / service states.
///
/// Maps provider-specific permission values into a single domain enum so
/// controllers and UI never depend on the location package types.
enum LocationPermissionState {
  /// Permission has not been checked yet.
  unknown,

  /// Device location services (GPS) are turned off.
  serviceDisabled,

  /// User has not been asked, or soft-denied once (can ask again).
  denied,

  /// User permanently denied; must open app settings.
  deniedForever,

  /// Platform restricted (e.g. parental controls on iOS).
  restricted,

  /// Permission granted — coordinates may be fetched.
  granted,
}
