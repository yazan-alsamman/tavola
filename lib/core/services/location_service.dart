import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../constants/app_dimensions.dart';
import '../../features/location/model/location_permission_state.dart';
import '../../features/location/model/user_location_model.dart';

/// Talks only to the device location provider (geolocator).
///
/// No UI, GetX, or API calls — controllers own state; repositories own HTTP.
class LocationService {
  /// Whether the platform location services (GPS) are enabled.
  Future<bool> isServiceEnabled() {
    return Geolocator.isLocationServiceEnabled().timeout(
      AppDimensions.locationServiceCheckTimeout,
    );
  }

  /// Reads the current permission without prompting the user.
  Future<LocationPermissionState> checkPermission() async {
    final bool enabled = await isServiceEnabled();
    if (!enabled) {
      return LocationPermissionState.serviceDisabled;
    }
    final LocationPermission permission = await Geolocator.checkPermission()
        .timeout(AppDimensions.locationServiceCheckTimeout);
    return _mapPermission(permission);
  }

  /// Explicitly requests permission. Never call without a user-driven action
  /// unless permission was already granted and only a refresh is needed.
  Future<LocationPermissionState> requestPermission() async {
    final bool enabled = await isServiceEnabled();
    if (!enabled) {
      return LocationPermissionState.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission().timeout(
      AppDimensions.locationServiceCheckTimeout,
    );
    // Prompt whenever the OS has not granted access yet. `unableToDetermine`
    // (and first-ask `denied`) must still call requestPermission — otherwise
    // Enable appears to do nothing.
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission().timeout(
        AppDimensions.locationRequestTimeout,
      );
    }
    return _mapPermission(permission);
  }

  /// Fetches the current coordinates. Caller must ensure permission is granted.
  Future<UserLocationModel> getCurrentLocation() async {
    final bool enabled = await isServiceEnabled();
    if (!enabled) {
      return const UserLocationModel(
        permissionStatus: LocationPermissionState.serviceDisabled,
        isServiceEnabled: false,
      );
    }

    final LocationPermissionState permission = await checkPermission();
    if (permission != LocationPermissionState.granted) {
      return UserLocationModel(
        permissionStatus: permission,
        isServiceEnabled: true,
      );
    }

    // LocationSettings.timeLimit is not reliable on every iOS build — also
    // apply a Dart ceiling so Stage-7 Home location cannot hang forever.
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppDimensions.locationDistanceFilterMeters,
        timeLimit: AppDimensions.locationRequestTimeout,
      ),
    ).timeout(AppDimensions.locationRequestTimeout);

    return UserLocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      permissionStatus: LocationPermissionState.granted,
      isServiceEnabled: true,
    );
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  LocationPermissionState _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionState.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionState.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionState.granted;
      case LocationPermission.unableToDetermine:
        return LocationPermissionState.unknown;
    }
  }
}
