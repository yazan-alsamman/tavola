class AppUrls {
  AppUrls._();

  /// Raster basemap tiles (OSM data via CARTO CDN).
  ///
  /// Do not use `tile.openstreetmap.org` in production apps — OSM Foundation
  /// tile policy forbids bulk/app usage, and flutter_map logs a debug warning.
  static const String mapRasterTiles =
      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';

  /// Passed to [TileLayer.userAgentPackageName] (becomes `flutter_map (...)`).
  /// Must identify this app — never `unknown` or `com.example.app`.
  static const String mapUserAgentPackageName = 'com.tavola.restaurant';

  /// Versioned customer REST API base (`{{baseUrl}}` from Postman environment).
  /// Override at build time with `--dart-define=API_BASE_URL=...`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://187.127.76.76:3000/api/v1',
  );

  /// Unversioned API root (`{{apiRoot}}` from Postman) for health probes.
  static const String apiRootUrl = String.fromEnvironment(
    'API_ROOT_URL',
    defaultValue: 'http://187.127.76.76:3000/api',
  );

  /// Customer Discovery (Postman folder "Discovery") — public, cross-tenant.
  static const String discoveryRestaurantsPath = '/discovery/restaurants';

  static String discoveryRestaurantPath(String restaurantId) =>
      '$discoveryRestaurantsPath/$restaurantId';

  static String discoveryBranchesPath(String restaurantId) =>
      '${discoveryRestaurantPath(restaurantId)}/branches';

  static String discoveryBranchPath(String restaurantId, String branchId) =>
      '${discoveryBranchesPath(restaurantId)}/$branchId';

  static String discoveryFloorPlanPath(String restaurantId, String branchId) =>
      '${discoveryBranchPath(restaurantId, branchId)}/floor-plan';

  static const String healthPath = '/health';
  static const String healthLivenessPath = '/health/liveness';
  static const String healthReadinessPath = '/health/readiness';

  /// Query parameter keys for location-aware restaurant recommendations.
  static const String latitudeQueryKey = 'latitude';
  static const String longitudeQueryKey = 'longitude';
}
