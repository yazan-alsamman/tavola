import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/features/location/controller/user_location_controller.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/location/widgets/user_location_status_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  testWidgets(
    'Enable registers location stack when controller is not ready yet',
    (tester) async {
      final _FakeLocationService locationService = _FakeLocationService();
      // Mimic Home Stage 0–7: chrome paints Enable before Stage 8 registers.
      Get.put<LocationService>(locationService, permanent: true);

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: UserLocationStatusBar())),
      );
      await tester.pump();

      expect(Get.isRegistered<UserLocationController>(), isFalse);
      expect(find.text(AppStrings.locationEnableAction), findsOneWidget);

      await tester.tap(find.text(AppStrings.locationEnableAction));
      await tester.pump();

      expect(Get.isRegistered<UserLocationController>(), isTrue);
      expect(locationService.requestPermissionCalls, 1);
    },
  );

  testWidgets(
    'Enable requests permission when controller is already registered',
    (tester) async {
      final _FakeLocationService locationService = _FakeLocationService();
      Get.put<LocationService>(locationService, permanent: true);
      Get.put<UserLocationController>(
        UserLocationController(locationService: locationService),
        permanent: true,
      );

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: UserLocationStatusBar())),
      );
      // Drain onInit refreshStatus post-frame work.
      await tester.pump();
      await tester.pump();

      locationService.requestPermissionCalls = 0;
      await tester.tap(find.text(AppStrings.locationEnableAction));
      await tester.pump();
      await tester.pump();

      expect(locationService.requestPermissionCalls, greaterThanOrEqualTo(1));
    },
  );
}

class _FakeLocationService extends LocationService {
  int requestPermissionCalls = 0;

  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<LocationPermissionState> checkPermission() async {
    return LocationPermissionState.denied;
  }

  @override
  Future<LocationPermissionState> requestPermission() async {
    requestPermissionCalls += 1;
    return LocationPermissionState.denied;
  }

  @override
  Future<UserLocationModel> getCurrentLocation() async {
    return const UserLocationModel(
      permissionStatus: LocationPermissionState.denied,
      isServiceEnabled: true,
    );
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}
