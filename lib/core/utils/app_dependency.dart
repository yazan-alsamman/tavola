import 'package:get/get.dart';

import '../network/api_client.dart';
import '../services/location_service.dart';
import '../../features/auth/controller/login_controller.dart';
import '../../features/auth/controller/sign_up_controller.dart';
import '../../features/branches/repository/branch_repository.dart';
import '../../features/concierge/repository/conversations_repository.dart';
import '../../features/discovery/repository/discovery_repository.dart';
import '../../features/details/repository/menu_repository.dart';
import '../../features/details/repository/restaurant_details_repository.dart';
import '../../features/favorites/repository/favorites_repository.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/location/controller/user_location_controller.dart';
import '../../features/map/repository/restaurant_map_repository.dart';
import '../../features/notifications/controller/notifications_badge_controller.dart';
import '../../features/notifications/repository/notifications_repository.dart';
import '../../features/notifications/service/push_identity_service.dart';
import '../../features/profile/repository/profile_repository.dart';
import '../../features/reservation/repository/reservation_availability_repository.dart';
import '../../features/reservation/repository/reservation_repository.dart';
import '../../features/reservation/repository/table_repository.dart';
import '../../features/reviews/repository/reviews_repository.dart';
import '../../features/taxonomy/repository/taxonomy_repository.dart';
import '../../features/users/repository/users_repository.dart';
import '../../features/waitlist/repository/waitlist_repository.dart';

/// Safe GetX registration helpers for hot restart / route re-entry.
class AppDependency {
  AppDependency._();

  /// Registers a long-lived app service, replacing any stale Hot Restart leftover.
  static T putPermanent<T extends Object>(T dependency) {
    if (Get.isRegistered<T>()) {
      try {
        Get.delete<T>(force: true);
      } catch (_) {
        // Ignore dispose races during Hot Restart.
      }
    }
    return Get.put<T>(dependency, permanent: true);
  }

  /// Creates [T] once, only if missing. Used for shared repositories and shell
  /// tab controllers (Home / Map / Concierge / Profile) that must survive
  /// shell `offAllNamed` tab switches without being disposed.
  static T putPermanentIfAbsent<T extends Object>(T Function() create) {
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    }
    return Get.put<T>(create(), permanent: true);
  }

  /// Registers a lazy factory once. Instance is created on first [Get.find].
  static void lazyPutIfAbsent<T extends Object>(
    T Function() create, {
    bool fenix = false,
  }) {
    if (Get.isRegistered<T>()) {
      return;
    }
    Get.lazyPut<T>(create, fenix: fenix);
  }

  /// Puts [T] once if missing (non-permanent). Used for SplashController at
  /// cold start so Binding re-entry does not create a duplicate instance.
  static T putIfAbsent<T extends Object>(T Function() create) {
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    }
    return Get.put<T>(create());
  }

  /// Puts a fresh route controller, retiring any live instance safely.
  ///
  /// Never force-deletes here: during `offAllNamed` transitions the outgoing
  /// route is still mounted and its widgets still use the live instance's
  /// resources (TextEditingControllers, FocusNodes) — disposing them now
  /// crashes with "used after being disposed".
  ///
  /// Instead this leans on GetX's late-remove flow:
  /// 1. mark the stale registration dirty so `Get.put` keeps it as
  ///    `lateRemove` instead of reusing it, and
  /// 2. mark the fresh registration dirty too, so the outgoing route's
  ///    cleanup (`delete` on this key) disposes the stale `lateRemove`
  ///    instance and keeps the fresh one alive.
  static T putFresh<T extends Object>(T Function() create) {
    final bool hadStaleInstance = Get.isRegistered<T>();
    if (hadStaleInstance) {
      GetInstance().markAsDirty<T>();
    }
    final T instance = Get.put<T>(create());
    if (hadStaleInstance) {
      GetInstance().markAsDirty<T>();
    }
    return instance;
  }

  // --- Route-scoped shared repositories (created on first needing route) ---

  static void ensureUsersRepository() {
    putPermanentIfAbsent(() => UsersRepository(Get.find<ApiClient>()));
  }

  static void ensureFavoritesRepository() {
    ensureUsersRepository();
    putPermanentIfAbsent(
      () => FavoritesRepository(usersRepository: Get.find<UsersRepository>()),
    );
  }

  static void ensureNotificationsRepository() {
    putPermanentIfAbsent(() => NotificationsRepository(Get.find<ApiClient>()));
  }

  static void ensurePushIdentityService() {
    ensureNotificationsRepository();
    putPermanentIfAbsent(
      () => PushIdentityService(Get.find<NotificationsRepository>()),
    );
  }

  static void ensureReviewsRepository() {
    putPermanentIfAbsent(() => ReviewsRepository(Get.find<ApiClient>()));
  }

  static void ensureConversationsRepository() {
    putPermanentIfAbsent(() => ConversationsRepository(Get.find<ApiClient>()));
  }

  /// Chat / Concierge tab — conversations + discovery for start-chat picker.
  static void ensureConciergeDependencies() {
    ensureConversationsRepository();
    ensureDiscoveryRepository();
  }

  /// App-bar unread badge — permanent, refreshed post-frame on shell entry.
  static void ensureNotificationsBadge() {
    ensureNotificationsRepository();
    putPermanentIfAbsent(
      () => NotificationsBadgeController(Get.find<NotificationsRepository>()),
    );
  }

  static void ensureNotificationsScreenDependencies() {
    ensureNotificationsRepository();
    ensureNotificationsBadge();
  }

  static void ensureWaitlistRepository() {
    putPermanentIfAbsent(() => WaitlistRepository(Get.find<ApiClient>()));
  }

  static void ensureTaxonomyRepository() {
    putPermanentIfAbsent(() => TaxonomyRepository(Get.find<ApiClient>()));
  }

  static void ensureDiscoveryRepository() {
    putPermanentIfAbsent(() => DiscoveryRepository(Get.find<ApiClient>()));
  }

  static void ensureRestaurantDetailsRepository() {
    ensureDiscoveryRepository();
    putPermanentIfAbsent(
      () => RestaurantDetailsRepository(
        Get.find<DiscoveryRepository>(),
        Get.find<ApiClient>(),
      ),
    );
  }

  static void ensureMenuRepository() {
    putPermanentIfAbsent(() => MenuRepository(Get.find<ApiClient>()));
  }

  static void ensureBranchRepository() {
    ensureDiscoveryRepository();
    putPermanentIfAbsent(
      () => BranchRepository(Get.find<DiscoveryRepository>()),
    );
  }

  static void ensureRestaurantMapRepository() {
    ensureDiscoveryRepository();
    putPermanentIfAbsent(
      () => RestaurantMapRepository(Get.find<DiscoveryRepository>()),
    );
  }

  static void ensureReservationRepositories() {
    ensureBranchRepository();
    ensureDiscoveryRepository();
    putPermanentIfAbsent(ReservationAvailabilityRepository.new);
    putPermanentIfAbsent(() => ReservationRepository(Get.find<ApiClient>()));
    putPermanentIfAbsent(
      () => TableRepository(
        Get.find<ApiClient>(),
        Get.find<BranchRepository>(),
        discoveryRepository: Get.find<DiscoveryRepository>(),
      ),
    );
  }

  static void ensureProfileRepository() {
    putPermanentIfAbsent(ProfileRepository.new);
  }

  static void ensureLocationStack() {
    putPermanentIfAbsent(LocationService.new);
    putPermanentIfAbsent(UserLocationController.new);
  }

  /// Home shell: catalog, favorites, taxonomy, location, notifications badge.
  static void ensureHomeDependencies() {
    ensureHomeCatalogDependencies();
    ensureFavoritesRepository();
    ensureLocationStack();
    ensureNotificationsBadge();
  }

  /// Creates Home Stage 0 only: taxonomy + discovery repos + [HomeController].
  ///
  /// Profile, favorites, notifications, and location register later via
  /// [HomeProgressiveInit] (one band per frame after first paint).
  static HomeController ensureHomeController() {
    ensureTaxonomyRepository();
    ensureDiscoveryRepository();
    return putPermanentIfAbsent(HomeController.new);
  }

  /// Catalog-only warm for Welcome/Login idle — skips platform location I/O
  /// and favorites so the first Welcome/Login frame never waits on them.
  static void ensureHomeCatalogDependencies() {
    ensureTaxonomyRepository();
    ensureDiscoveryRepository();
  }

  /// Auth flows that may persist customer identity after sign-in.
  static void ensureAuthFeatureDependencies() {
    ensureUsersRepository();
  }

  /// Login / Sign-up controllers for auth shell entry.
  ///
  /// Must run before [AppNavigation.goShell] to Login when session expiry is
  /// triggered from a Dio interceptor (route Bindings can race the first
  /// [LoginScreen] build and crash with "LoginController not found").
  static void ensureLoginRouteDependencies() {
    // Controllers only — UsersRepository is not required to paint Login.
    putPermanentIfAbsent(LoginController.new);
    putPermanentIfAbsent(SignUpController.new);
  }

  /// Profile tab: history, favorites, users, notifications badge.
  static void ensureProfileDependencies() {
    ensureProfileRepository();
    ensureFavoritesRepository();
    ensureUsersRepository();
    ensureNotificationsBadge();
    ensureReviewsRepository();
    putPermanentIfAbsent(() => ReservationRepository(Get.find<ApiClient>()));
  }

  /// Map tab.
  ///
  /// Does not register [UserLocationController] — that stack starts on Home
  /// Stage 8. Registering it here used to trigger Geolocator on first Map tap
  /// (before Home finished), which crashes macOS without location plist keys.
  static void ensureMapDependencies() {
    ensureRestaurantMapRepository();
    ensureFavoritesRepository();
  }

  /// Favorites tab.
  static void ensureFavoritesScreenDependencies() {
    ensureFavoritesRepository();
  }

  /// Details / menu drill-down.
  static void ensureDetailsDependencies() {
    ensureRestaurantDetailsRepository();
    ensureMenuRepository();
    ensureFavoritesRepository();
    ensureReviewsRepository();
  }

  /// Compare Restaurants — Discovery catalog + details enrichment.
  static void ensureCompareDependencies() {
    ensureDiscoveryRepository();
    ensureRestaurantDetailsRepository();
  }

  /// Reservation booking flow + onboarding previews.
  static void ensureReservationFlowDependencies() {
    ensureReservationRepositories();
    ensureWaitlistRepository();
  }

  /// Select-restaurant uses Discovery catalog + favorites.
  static void ensureSelectRestaurantDependencies() {
    ensureDiscoveryRepository();
    ensureFavoritesRepository();
  }
}
