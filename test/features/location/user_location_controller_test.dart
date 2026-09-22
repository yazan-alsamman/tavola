import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/features/location/controller/user_location_controller.dart';
import 'package:tavla/features/location/location_prompt_preferences.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
    LocationPromptPreferences.resetForTest();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(Get.reset);

  test('first denied request shows Enable and persist hides it', () async {
    await LocationPromptPreferences.hasRequested();
    final _FakeLocationService service = _FakeLocationService(
      permission: LocationPermissionState.denied,
    );
    final UserLocationController controller = UserLocationController(
      locationService: service,
    );

    await controller.refreshStatus();
    expect(controller.permissionStatus, LocationPermissionState.denied);
    expect(controller.primaryActionLabel, AppStrings.locationEnableAction);
    expect(await LocationPromptPreferences.hasRequested(), isFalse);

    await controller.requestPermissionAndLocate();
    expect(service.requestPermissionCalls, 1);
    expect(await LocationPromptPreferences.hasRequested(), isTrue);
    expect(controller.hasRequestedActivation.value, isTrue);
    expect(controller.permissionStatus, LocationPermissionState.denied);
    expect(controller.primaryActionLabel, isNull);
  });

  test('second launch restores flag and does not show Enable', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppStrings.locationPromptRequestedKey: true,
    });
    expect(await LocationPromptPreferences.hasRequested(), isTrue);

    final _FakeLocationService service = _FakeLocationService(
      permission: LocationPermissionState.denied,
    );
    final UserLocationController controller = UserLocationController(
      locationService: service,
    );

    expect(controller.hasRequestedActivation.value, isTrue);
    await controller.refreshStatus();
    expect(controller.permissionStatus, LocationPermissionState.denied);
    expect(controller.primaryActionLabel, isNull);
    expect(service.requestPermissionCalls, 0);
    expect(controller.location.value.canProvideRecommendations, isFalse);
  });

  test('process-restart cache miss still restores from disk', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final _FakeLocationService service = _FakeLocationService(
      permission: LocationPermissionState.denied,
    );
    final UserLocationController first = UserLocationController(
      locationService: service,
    );
    await first.requestPermissionAndLocate();
    expect(await LocationPromptPreferences.hasRequested(), isTrue);

    LocationPromptPreferences.resetForTest();
    expect(LocationPromptPreferences.cachedOrNull, isNull);
    expect(await LocationPromptPreferences.hasRequested(), isTrue);

    final UserLocationController second = UserLocationController(
      locationService: service,
    );
    expect(second.hasRequestedActivation.value, isTrue);
    await second.refreshStatus();
    expect(second.primaryActionLabel, isNull);
    expect(service.requestPermissionCalls, 1);
  });

  test('granted permission still retrieves coordinates', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppStrings.locationPromptRequestedKey: true,
    });
    await LocationPromptPreferences.hasRequested();
    final _FakeLocationService service = _FakeLocationService(
      permission: LocationPermissionState.granted,
      latitude: 25.2,
      longitude: 55.3,
    );
    final UserLocationController controller = UserLocationController(
      locationService: service,
    );

    await controller.refreshStatus();
    expect(controller.permissionStatus, LocationPermissionState.granted);
    expect(controller.latitude, 25.2);
    expect(controller.longitude, 55.3);
    expect(controller.canProvideRecommendations, isTrue);
    expect(controller.primaryActionLabel, isNull);
    expect(service.requestPermissionCalls, 0);
    expect(service.getCurrentLocationCalls, 1);
  });

  test('refreshStatus does not persist a fake granted flag', () async {
    await LocationPromptPreferences.hasRequested();
    final _FakeLocationService service = _FakeLocationService(
      permission: LocationPermissionState.granted,
      latitude: 1,
      longitude: 2,
    );
    final UserLocationController controller = UserLocationController(
      locationService: service,
    );

    await controller.refreshStatus();
    expect(controller.permissionStatus, LocationPermissionState.granted);
    expect(await LocationPromptPreferences.hasRequested(), isFalse);
  });

  test('denied forever keeps Settings and does not show Enable', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppStrings.locationPromptRequestedKey: true,
    });
    await LocationPromptPreferences.hasRequested();
    final _FakeLocationService service = _FakeLocationService(
      permission: LocationPermissionState.deniedForever,
    );
    final UserLocationController controller = UserLocationController(
      locationService: service,
    );

    await controller.refreshStatus();
    expect(controller.permissionStatus, LocationPermissionState.deniedForever);
    expect(controller.primaryActionLabel, AppStrings.locationOpenSettings);
    expect(controller.statusLabel, AppStrings.locationPermissionDeniedForever);

    await controller.handlePrimaryAction();
    expect(service.openAppSettingsCalls, 1);
    expect(service.requestPermissionCalls, 0);
  });

  test('restricted keeps Settings and does not show Enable', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppStrings.locationPromptRequestedKey: true,
    });
    await LocationPromptPreferences.hasRequested();
    final _FakeLocationService service = _FakeLocationService(
      permission: LocationPermissionState.restricted,
    );
    final UserLocationController controller = UserLocationController(
      locationService: service,
    );

    await controller.refreshStatus();
    expect(controller.permissionStatus, LocationPermissionState.restricted);
    expect(controller.primaryActionLabel, AppStrings.locationOpenSettings);
    await controller.handlePrimaryAction();
    expect(service.openAppSettingsCalls, 1);
  });

  test('location services off comes from the real service check', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppStrings.locationPromptRequestedKey: true,
    });
    await LocationPromptPreferences.hasRequested();
    final _FakeLocationService service = _FakeLocationService(
      serviceEnabled: false,
    );
    final UserLocationController controller = UserLocationController(
      locationService: service,
    );

    await controller.refreshStatus();
    expect(controller.permissionStatus, LocationPermissionState.serviceDisabled);
    expect(controller.location.value.isServiceEnabled, isFalse);
    expect(
      controller.primaryActionLabel,
      AppStrings.locationOpenLocationSettings,
    );
    expect(controller.canProvideRecommendations, isFalse);
    expect(service.checkPermissionCalls, 0);

    await controller.handlePrimaryAction();
    expect(service.openLocationSettingsCalls, 1);
  });
}

class _FakeLocationService extends LocationService {
  _FakeLocationService({
    this.serviceEnabled = true,
    this.permission = LocationPermissionState.denied,
    this.latitude,
    this.longitude,
  });

  final bool serviceEnabled;
  final LocationPermissionState permission;
  final double? latitude;
  final double? longitude;

  int requestPermissionCalls = 0;
  int checkPermissionCalls = 0;
  int getCurrentLocationCalls = 0;
  int openAppSettingsCalls = 0;
  int openLocationSettingsCalls = 0;

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermissionState> checkPermission() async {
    checkPermissionCalls += 1;
    if (!serviceEnabled) {
      return LocationPermissionState.serviceDisabled;
    }
    return permission;
  }

  @override
  Future<LocationPermissionState> requestPermission() async {
    requestPermissionCalls += 1;
    if (!serviceEnabled) {
      return LocationPermissionState.serviceDisabled;
    }
    return permission;
  }

  @override
  Future<UserLocationModel> getCurrentLocation() async {
    getCurrentLocationCalls += 1;
    return UserLocationModel(
      latitude: latitude,
      longitude: longitude,
      permissionStatus: permission,
      isServiceEnabled: serviceEnabled,
    );
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalls += 1;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    openLocationSettingsCalls += 1;
    return true;
  }
}
