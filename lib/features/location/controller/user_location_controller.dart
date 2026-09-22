import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/location_service.dart';
import '../location_prompt_preferences.dart';
import '../model/location_permission_state.dart';
import '../model/user_location_model.dart';

/// Owns user-location state for restaurant recommendations.
///
/// Views bind to observables only — never call [LocationService] from UI.
class UserLocationController extends GetxController {
  UserLocationController({LocationService? locationService})
    : _locationService = locationService ?? Get.find<LocationService>() {
    _hydrateActivationPromptFromCache();
  }

  final LocationService _locationService;

  void _hydrateActivationPromptFromCache() {
    final bool? cached = LocationPromptPreferences.cachedOrNull;
    if (cached == null) {
      return;
    }
    hasRequestedActivation.value = cached;
    activationPromptResolved.value = true;
  }

  final Rx<UserLocationModel> location = UserLocationModel.initial.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool hasRequestedActivation = false.obs;
  final RxBool activationPromptResolved = false.obs;

  bool get hasCoordinates => location.value.hasCoordinates;

  bool get canProvideRecommendations =>
      location.value.canProvideRecommendations;

  double? get latitude => location.value.latitude;

  double? get longitude => location.value.longitude;

  LocationPermissionState get permissionStatus =>
      location.value.permissionStatus;

  @override
  void onInit() {
    super.onInit();
    // Restore the ask-flag first, then read the real OS status. Never request
    // permission here — that stays user-driven via [handlePrimaryAction].
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        unawaited(_bootstrap());
      }
    });
  }

  Future<void> _bootstrap() async {
    await _restoreActivationPromptState();
    if (!isClosed) {
      await refreshStatus();
    }
  }

  Future<void> _restoreActivationPromptState() async {
    hasRequestedActivation.value = await LocationPromptPreferences.hasRequested();
    activationPromptResolved.value = true;
  }

  Future<void> _markActivationRequested() async {
    hasRequestedActivation.value = true;
    activationPromptResolved.value = true;
    await LocationPromptPreferences.markRequested();
  }

  bool get _suppressActivationPrompt {
    if (!activationPromptResolved.value) {
      return true;
    }
    return hasRequestedActivation.value;
  }

  /// Reads service + permission without requesting access or coordinates.
  Future<void> refreshStatus() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final bool enabled = await _locationService.isServiceEnabled();
      if (!enabled) {
        location.value = const UserLocationModel(
          permissionStatus: LocationPermissionState.serviceDisabled,
          isServiceEnabled: false,
        );
        return;
      }

      final LocationPermissionState permission = await _locationService
          .checkPermission();
      if (permission == LocationPermissionState.granted) {
        await _fetchCoordinates();
        return;
      }

      location.value = UserLocationModel(
        permissionStatus: permission,
        isServiceEnabled: true,
      );
    } catch (_) {
      errorMessage.value = AppStrings.locationFetchFailed;
      location.value = location.value.copyWith(
        permissionStatus: LocationPermissionState.unknown,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// User-driven: request permission (if needed) then fetch coordinates.
  Future<void> requestPermissionAndLocate() async {
    await _markActivationRequested();
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final LocationPermissionState permission = await _locationService
          .requestPermission();

      if (permission == LocationPermissionState.serviceDisabled) {
        location.value = const UserLocationModel(
          permissionStatus: LocationPermissionState.serviceDisabled,
          isServiceEnabled: false,
        );
        return;
      }

      if (permission != LocationPermissionState.granted) {
        location.value = UserLocationModel(
          permissionStatus: permission,
          isServiceEnabled: true,
        );
        return;
      }

      await _fetchCoordinates();
    } catch (_) {
      errorMessage.value = AppStrings.locationFetchFailed;
    } finally {
      isLoading.value = false;
    }
  }

  /// Re-fetch coordinates when permission is already granted.
  Future<void> refreshCoordinates() async {
    if (permissionStatus != LocationPermissionState.granted &&
        permissionStatus != LocationPermissionState.unknown) {
      await requestPermissionAndLocate();
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _fetchCoordinates();
    } catch (_) {
      errorMessage.value = AppStrings.locationFetchFailed;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openAppSettings() async {
    await _markActivationRequested();
    await _locationService.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await _markActivationRequested();
    await _locationService.openLocationSettings();
  }

  /// Localized label for the home location chip / status row.
  String get statusLabel {
    if (isLoading.value) {
      return AppStrings.locationLoading;
    }
    final String? error = errorMessage.value;
    if (error != null && error.isNotEmpty) {
      return error;
    }
    switch (location.value.permissionStatus) {
      case LocationPermissionState.granted:
        return location.value.hasCoordinates
            ? AppStrings.locationNearYou
            : AppStrings.locationUnavailable;
      case LocationPermissionState.denied:
        return AppStrings.locationPermissionDenied;
      case LocationPermissionState.deniedForever:
        return AppStrings.locationPermissionDeniedForever;
      case LocationPermissionState.restricted:
        return AppStrings.locationPermissionRestricted;
      case LocationPermissionState.serviceDisabled:
        return AppStrings.locationServiceDisabled;
      case LocationPermissionState.unknown:
        if (!activationPromptResolved.value) {
          return AppStrings.locationLoading;
        }
        if (hasRequestedActivation.value) {
          return AppStrings.locationPermissionDenied;
        }
        return AppStrings.locationEnablePrompt;
    }
  }

  /// Primary action label for the current state (`null` when none).
  String? get primaryActionLabel {
    switch (location.value.permissionStatus) {
      case LocationPermissionState.unknown:
      case LocationPermissionState.denied:
        if (_suppressActivationPrompt) {
          return null;
        }
        return AppStrings.locationEnableAction;
      case LocationPermissionState.deniedForever:
      case LocationPermissionState.restricted:
        return AppStrings.locationOpenSettings;
      case LocationPermissionState.serviceDisabled:
        return AppStrings.locationOpenLocationSettings;
      case LocationPermissionState.granted:
        if (!location.value.hasCoordinates || errorMessage.value != null) {
          return AppStrings.retry;
        }
        return null;
    }
  }

  Future<void> handlePrimaryAction() async {
    switch (location.value.permissionStatus) {
      case LocationPermissionState.unknown:
      case LocationPermissionState.denied:
        await requestPermissionAndLocate();
        return;
      case LocationPermissionState.deniedForever:
      case LocationPermissionState.restricted:
        await openAppSettings();
        return;
      case LocationPermissionState.serviceDisabled:
        await openLocationSettings();
        return;
      case LocationPermissionState.granted:
        await refreshCoordinates();
        return;
    }
  }

  Future<void> _fetchCoordinates() async {
    final UserLocationModel result = await _locationService
        .getCurrentLocation();
    location.value = result;
    if (!result.hasCoordinates &&
        result.permissionStatus == LocationPermissionState.granted) {
      errorMessage.value = AppStrings.locationUnavailable;
    }
  }
}
