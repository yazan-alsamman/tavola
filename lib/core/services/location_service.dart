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

  /// Asks the OS for permission when it is still `denied` or undetermined.
  ///
  /// Does not prompt for `deniedForever`. Callers must not invoke this on
  /// every launch after the user has already answered.
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

    final Position? position = await _positionWithin(
      AppDimensions.locationFixTimeout,
    );
    if (position == null) {
      return const UserLocationModel(
        permissionStatus: LocationPermissionState.granted,
        isServiceEnabled: true,
      );
    }

    return UserLocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      permissionStatus: LocationPermissionState.granted,
      isServiceEnabled: true,
    );
  }

  /// Last known fix or a medium-accuracy reading, whichever arrives first.
  ///
  /// High-accuracy [Geolocator.getCurrentPosition] can sit on "Finding your
  /// location" until the map screen. This budget keeps Home to two seconds.
  Future<Position?> _positionWithin(Duration budget) {
    final Completer<Position?> completer = Completer<Position?>();
    final Timer timer = Timer(budget, () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });
    completer.future.whenComplete(timer.cancel);

    unawaited(_offerLastKnown(completer));
    unawaited(_offerCurrent(completer, budget));
    return completer.future;
  }

  Future<void> _offerLastKnown(Completer<Position?> completer) async {
    try {
      final Position? last = await Geolocator.getLastKnownPosition();
      if (last != null && !completer.isCompleted) {
        completer.complete(last);
      }
    } catch (_) {
      // A fresh reading can still win the same budget.
    }
  }

  Future<void> _offerCurrent(
    Completer<Position?> completer,
    Duration budget,
  ) async {
    try {
      final Position current = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: budget,
        ),
      );
      if (!completer.isCompleted) {
        completer.complete(current);
      }
    } catch (_) {
      // Timeout or a platform denial: the budget timer ends the wait.
    }
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
