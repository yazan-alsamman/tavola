import 'location_permission_state.dart';

/// Snapshot of the user's location readiness for recommendations.
class UserLocationModel {
  const UserLocationModel({
    this.latitude,
    this.longitude,
    required this.permissionStatus,
    required this.isServiceEnabled,
  });

  final double? latitude;
  final double? longitude;
  final LocationPermissionState permissionStatus;
  final bool isServiceEnabled;

  static const UserLocationModel initial = UserLocationModel(
    permissionStatus: LocationPermissionState.unknown,
    isServiceEnabled: false,
  );

  bool get hasCoordinates => latitude != null && longitude != null;

  /// Ready for nearby restaurant recommendation / search queries.
  bool get canProvideRecommendations =>
      hasCoordinates &&
      isServiceEnabled &&
      permissionStatus == LocationPermissionState.granted;

  UserLocationModel copyWith({
    double? latitude,
    double? longitude,
    LocationPermissionState? permissionStatus,
    bool? isServiceEnabled,
    bool clearCoordinates = false,
  }) {
    return UserLocationModel(
      latitude: clearCoordinates ? null : (latitude ?? this.latitude),
      longitude: clearCoordinates ? null : (longitude ?? this.longitude),
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
    );
  }
}
