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

  /// Versioned customer REST API base (`{{baseUrl}}` from Postman).
  /// Override at build time with `--dart-define=API_BASE_URL=...`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.tavola.business/api/v1',
  );

  /// Unversioned API root for health probes.
  static const String apiRootUrl = String.fromEnvironment(
    'API_ROOT_URL',
    defaultValue: 'https://api.tavola.business/api',
  );

  /// Customer Discovery (Postman folder "Discovery") — public, cross-tenant.
  static const String discoveryRestaurantsPath = '/discovery/restaurants';

  /// Public nearby Discovery (`GET /discovery/restaurants/nearby`).
  static const String discoveryRestaurantsNearbyPath =
      '$discoveryRestaurantsPath/nearby';

  static String discoveryRestaurantPath(String restaurantId) =>
      '$discoveryRestaurantsPath/$restaurantId';

  static String discoveryBranchesPath(String restaurantId) =>
      '${discoveryRestaurantPath(restaurantId)}/branches';

  static String discoveryBranchPath(String restaurantId, String branchId) =>
      '${discoveryBranchesPath(restaurantId)}/$branchId';

  static String discoveryFloorPlanPath(String restaurantId, String branchId) =>
      '${discoveryBranchPath(restaurantId, branchId)}/floor-plan';

  /// Public offers for a restaurant (`GET .../offers`).
  static String discoveryOffersPath(String restaurantId) =>
      '${discoveryRestaurantPath(restaurantId)}/offers';

  /// Customer reservations (Postman folder **Reservations**).
  static const String reservationsPath = '/reservations';
  static const String reservationsAvailabilityPath =
      '$reservationsPath/availability';
  static const String reservationsMyPath = '$reservationsPath/my';
  static const String reservationsMyUpcomingPath = '$reservationsMyPath/upcoming';
  static const String reservationsMyHistoryPath = '$reservationsMyPath/history';

  static String reservationsMyDetailPath(String reservationId) =>
      '$reservationsMyPath/${reservationId.trim()}';

  static String reservationsCancelPath(String reservationId) =>
      '$reservationsPath/${reservationId.trim()}/cancel';

  static String reservationsReschedulePath(String reservationId) =>
      '$reservationsPath/${reservationId.trim()}/reschedule';

  /// Public restaurant menus (Postman folder **Menu**).
  static String restaurantMenusPath(String restaurantId) =>
      '/restaurants/${restaurantId.trim()}/menus';

  static String restaurantDefaultMenuPath(String restaurantId) =>
      '${restaurantMenusPath(restaurantId)}/default';

  static String restaurantMenuPath(String restaurantId, String menuId) =>
      '${restaurantMenusPath(restaurantId)}/${menuId.trim()}';

  /// Restaurant-level weekly hours (`GET /restaurants/:id/working-hours`).
  /// Admin/org default schedule — customer Details uses [branchWorkingHoursPath].
  static String restaurantWorkingHoursPath(String restaurantId) =>
      '/restaurants/${restaurantId.trim()}/working-hours';

  /// Branch weekly hours override
  /// (`GET /restaurants/:restaurantId/branches/:branchId/working-hours`).
  /// Used for Details Hours + restaurant card hours (primary branch).
  static String branchWorkingHoursPath({
    required String restaurantId,
    required String branchId,
  }) =>
      '/restaurants/${restaurantId.trim()}/branches/${branchId.trim()}/working-hours';

  /// Authenticated session management (Postman folder **Auth**).
  static const String authLogoutPath = '/auth/logout';
  static const String authLogoutAllPath = '/auth/logout-all';
  static const String authSessionsPath = '/auth/sessions';
  static const String authChangePasswordPath = '/auth/change-password';

  static String authSessionPath(String sessionId) =>
      '$authSessionsPath/${sessionId.trim()}';

  /// Customer messaging (Postman folder **13 - Messaging**).
  static const String conversationsPath = '/conversations';

  static String conversationPath(String conversationId) =>
      '$conversationsPath/${conversationId.trim()}';

  static String conversationMessagesPath(String conversationId) =>
      '${conversationPath(conversationId)}/messages';

  static String conversationReadPath(String conversationId) =>
      '${conversationPath(conversationId)}/read';

  static String conversationClosePath(String conversationId) =>
      '${conversationPath(conversationId)}/close';

  /// Cursor page size for conversations / messages (`CursorPaginationQueryDto`).
  static const String conversationsLimitQueryKey = 'limit';

  /// Opaque cursor for conversations / messages (`CursorPaginationQueryDto`).
  static const String conversationsCursorQueryKey = 'cursor';

  /// Customer reviews (Postman folder **10 - Reviews** + `GET /users/me/reviews`).
  static const String reviewsPath = '/reviews';
  static const String myReviewsPath = '/users/me/reviews';
  static const String reviewsPageQueryKey = 'page';
  static const String reviewsPageSizeQueryKey = 'pageSize';

  static String restaurantReviewsPath(String restaurantId) =>
      '/restaurants/${restaurantId.trim()}/reviews';

  static String reviewPath(String reviewId) =>
      '$reviewsPath/${reviewId.trim()}';

  static String reviewImagesPath(String reviewId) =>
      '${reviewPath(reviewId)}/images';

  static String reviewImagePath(String reviewId, String reviewImageId) =>
      '${reviewImagesPath(reviewId)}/${reviewImageId.trim()}';

  static const String healthPath = '/health';
  static const String healthLivenessPath = '/health/liveness';
  static const String healthReadinessPath = '/health/readiness';

  /// Query parameter keys for location-aware restaurant recommendations.
  static const String latitudeQueryKey = 'latitude';
  static const String longitudeQueryKey = 'longitude';

  /// `GET /discovery/restaurants/nearby` query keys (NearbyRestaurantsQueryDto).
  static const String nearbyLatitudeQueryKey = 'lat';
  static const String nearbyLongitudeQueryKey = 'lng';
  static const String nearbyRadiusKmQueryKey = 'radiusKm';
}
