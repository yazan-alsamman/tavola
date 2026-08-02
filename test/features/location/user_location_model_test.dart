import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';

void main() {
  group('UserLocationModel', () {
    test('initial has no coordinates and unknown permission', () {
      expect(UserLocationModel.initial.hasCoordinates, isFalse);
      expect(
        UserLocationModel.initial.permissionStatus,
        LocationPermissionState.unknown,
      );
      expect(UserLocationModel.initial.canProvideRecommendations, isFalse);
    });

    test('canProvideRecommendations requires granted coords and service', () {
      const UserLocationModel ready = UserLocationModel(
        latitude: 25.2048,
        longitude: 55.2708,
        permissionStatus: LocationPermissionState.granted,
        isServiceEnabled: true,
      );
      expect(ready.canProvideRecommendations, isTrue);

      const UserLocationModel denied = UserLocationModel(
        latitude: 25.2048,
        longitude: 55.2708,
        permissionStatus: LocationPermissionState.denied,
        isServiceEnabled: true,
      );
      expect(denied.canProvideRecommendations, isFalse);
    });

    test('copyWith clearCoordinates removes lat/lng', () {
      const UserLocationModel source = UserLocationModel(
        latitude: 1,
        longitude: 2,
        permissionStatus: LocationPermissionState.granted,
        isServiceEnabled: true,
      );
      final UserLocationModel cleared = source.copyWith(clearCoordinates: true);
      expect(cleared.hasCoordinates, isFalse);
      expect(cleared.permissionStatus, LocationPermissionState.granted);
    });
  });
}
