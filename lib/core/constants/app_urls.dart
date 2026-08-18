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

  /// Optional CDN / object-storage origin for media file IDs.
  /// When empty, IDs resolve to `{apiBaseUrl}/files/{id}`.
  static const String mediaBaseUrl = String.fromEnvironment(
    'MEDIA_BASE_URL',
    defaultValue: '',
  );

  /// Public file download path under the versioned API root.
  static const String mediaFilesPath = '/files';

  static String mediaFilePath(String fileId) =>
      '$mediaFilesPath/${fileId.trim()}';

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

  /// Public side-by-side compare (`POST /discovery/restaurants/compare`).
  static const String discoveryRestaurantsComparePath =
      '$discoveryRestaurantsPath/compare';

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
  static const String reservationsPageQueryKey = 'page';
  static const String reservationsPageSizeQueryKey = 'pageSize';
  static const String reservationsLimitQueryKey = 'limit';
  static const String reservationsMyPath = '$reservationsPath/my';
  static const String reservationsMyUpcomingPath = '$reservationsMyPath/upcoming';
  static const String reservationsMyHistoryPath = '$reservationsMyPath/history';

  static String reservationsDetailPath(String reservationId) =>
      '$reservationsPath/${reservationId.trim()}';

  static String reservationsMyDetailPath(String reservationId) =>
      '$reservationsMyPath/${reservationId.trim()}';

  static String reservationsCancelPath(String reservationId) =>
      '$reservationsPath/${reservationId.trim()}/cancel';

  static String reservationsReschedulePath(String reservationId) =>
      '$reservationsPath/${reservationId.trim()}/reschedule';

  /// Customer waitlist (Postman folder **09 - Waitlist**).
  ///
  /// Customer-allowed: [waitlistPath] (join), [waitlistCancelPath].
  /// Not for this app: `POST /waitlist/:id/promote` — Employee only
  /// (`reservations:waitlist`).
  static const String waitlistPath = '/waitlist';

  static String waitlistCancelPath(String entryId) =>
      '$waitlistPath/${entryId.trim()}/cancel';

  /// Public restaurant menus (Postman folder **Menu**).
  static String restaurantMenusPath(String restaurantId) =>
      '/restaurants/${restaurantId.trim()}/menus';

  static String restaurantDefaultMenuPath(String restaurantId) =>
      '${restaurantMenusPath(restaurantId)}/default';

  static String restaurantMenuPath(String restaurantId, String menuId) =>
      '${restaurantMenusPath(restaurantId)}/${menuId.trim()}';

  static String restaurantMenuCategoryPath({
    required String restaurantId,
    required String menuId,
    required String categoryId,
  }) =>
      '${restaurantMenuPath(restaurantId, menuId)}/categories/${categoryId.trim()}';

  static String restaurantMenuItemPath({
    required String restaurantId,
    required String menuId,
    required String categoryId,
    required String itemId,
  }) =>
      '${restaurantMenuCategoryPath(restaurantId: restaurantId, menuId: menuId, categoryId: categoryId)}/items/${itemId.trim()}';

  /// Authenticated session management (Postman folder **Auth**).
  static const String authRefreshPath = '/auth/refresh';
  static const String authLogoutPath = '/auth/logout';
  static const String authLogoutAllPath = '/auth/logout-all';
  static const String authSessionsPath = '/auth/sessions';
  static const String authChangePasswordPath = '/auth/change-password';

  static String authSessionPath(String sessionId) =>
      '$authSessionsPath/${sessionId.trim()}';

  /// Customer auth (login / register / password-reset) — public `noauth`.
  static const String authCustomerLoginPath = '/auth/customer/login';
  static const String authCustomerRegisterStartPath =
      '/auth/customer/register/start';
  static const String authCustomerRegisterResendPath =
      '/auth/customer/register/resend';
  static const String authCustomerRegisterVerifyPath =
      '/auth/customer/register/verify';
  static const String authCustomerRegisterCompletePath =
      '/auth/customer/register/complete';
  static const String authCustomerPasswordResetStartPath =
      '/auth/customer/password-reset/start';
  static const String authCustomerPasswordResetResendPath =
      '/auth/customer/password-reset/resend';
  static const String authCustomerPasswordResetVerifyPath =
      '/auth/customer/password-reset/verify';
  static const String authCustomerPasswordResetCompletePath =
      '/auth/customer/password-reset/complete';

  /// Users self-service (Postman folder **Users**).
  static const String usersMePath = '/users/me';
  static const String usersMePreferencesPath = '$usersMePath/preferences';
  static const String usersMeAvatarPath = '$usersMePath/avatar';
  static const String usersMeFavoritesPath = '$usersMePath/favorites';
  static const String usersMeExportPath = '$usersMePath/export';
  static const String usersMeCancelDeletionPath =
      '$usersMePath/cancel-deletion';

  static String usersMeFavoritePath(String restaurantId) =>
      '$usersMeFavoritesPath/${restaurantId.trim()}';

  /// Taxonomy (cuisine + occasion categories).
  static const String cuisineCategoriesPath = '/cuisine-categories';
  static const String occasionCategoriesPath = '/occasion-categories';

  /// Customer notifications (Postman folder **Notifications**).
  static const String notificationsPath = '/notifications';
  static const String notificationsUnreadCountPath =
      '$notificationsPath/unread-count';
  static const String notificationsReadAllPath = '$notificationsPath/read-all';
  static const String notificationsIdentityTokenPath =
      '$notificationsPath/identity-token';
  static const String notificationsPageQueryKey = 'page';
  static const String notificationsPageSizeQueryKey = 'pageSize';
  static const String notificationsUnreadQueryKey = 'unread';

  static String notificationReadPath(String notificationId) =>
      '$notificationsPath/${notificationId.trim()}/read';

  /// Single table read (`GET /tables/:tableId`).
  static String tablePath(String tableId) => '/tables/${tableId.trim()}';

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

  /// Conversation list pagination (`GET /conversations?page=&pageSize=`).
  static const String conversationsPageQueryKey = 'page';
  static const String conversationsPageSizeQueryKey = 'pageSize';

  /// Messages page size (`GET /conversations/:id/messages?limit=`).
  static const String conversationsLimitQueryKey = 'limit';

  /// Opaque cursor for messages cursor pagination, if backend returns it.
  static const String conversationsCursorQueryKey = 'cursor';

  /// Customer reviews (Postman folder **10 - Reviews** + `GET /users/me/reviews`).
  static const String reviewsPath = '/reviews';
  static const String myReviewsPath = '/users/me/reviews';
  /// Reviews list pagination in current Postman collection.
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

  /// `SearchRestaurantsQueryDto` / nearby free-text query key.
  static const String discoverySearchQueryKey = 'q';

  /// Discovery list pagination keys on live customer API.
  static const String discoveryPageQueryKey = 'page';
  static const String discoveryLimitQueryKey = 'limit';
  static const String discoveryPageSizeQueryKey = 'pageSize';
}
