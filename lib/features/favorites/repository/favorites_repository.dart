import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../home/model/restaurant_model.dart';
import '../../users/repository/users_repository.dart';

/// Owns favorite state for the app. Controllers request toggles/reads only.
///
/// Synced from `GET/POST/DELETE /users/me/favorites`.
class FavoritesRepository extends GetxService {
  FavoritesRepository({UsersRepository? usersRepository})
    : _usersRepository = usersRepository ?? Get.find<UsersRepository>();

  final UsersRepository _usersRepository;

  final RxMap<String, bool> favoriteStates = <String, bool>{}.obs;
  final RxList<RestaurantModel> favoriteSummaries = <RestaurantModel>[].obs;

  /// Bumped on every favorite change so `Obx` can track updates reliably
  /// even when cards are built inside `ListView.builder`.
  final RxInt favoritesRevision = 0.obs;

  bool _initialized = false;
  final RxBool isSyncing = false.obs;
  final RxnString syncError = RxnString();

  /// Clears in-memory favorite state when session ends (logout/guest).
  void clearSessionState() {
    favoriteStates.clear();
    favoriteSummaries.clear();
    syncError.value = null;
    isSyncing.value = false;
    _initialized = false;
    _notifyFavoriteListeners();
  }

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    // Guests have no session — skip auth-only favorites to avoid 401 storms
    // that can stall Home after "Continue as guest".
    if (Get.isRegistered<GuestModeReader>() &&
        Get.find<GuestModeReader>().isAnonymousGuest) {
      // Guest sessions must not lock initialization: once the user signs in
      // in the same app lifecycle we need to sync favorites immediately.
      _initialized = false;
      return;
    }
    if (Get.isRegistered<AuthTokenReader>()) {
      final String? access = await Get.find<AuthTokenReader>()
          .readAccessToken();
      if (access == null || access.trim().isEmpty) {
        // Access token may still be hydrating from secure storage on startup.
        // Keep this false so later calls can retry and populate favorites.
        _initialized = false;
        return;
      }
    }
    await syncFavoritesFromApi();
  }

  /// Synchronous no-op seed; prefer [ensureInitialized] / [syncFavoritesFromApi].
  void ensureInitializedSync() {
    // Kept for existing controller call sites; API sync happens async.
  }

  Future<void> syncFavoritesFromApi() async {
    isSyncing.value = true;
    syncError.value = null;
    try {
      final List<RestaurantModel> items = await _usersRepository
          .fetchFavoriteRestaurants();
      favoriteSummaries.assignAll(items);
      favoriteStates
        ..clear()
        ..addEntries(
          items.map(
            (RestaurantModel item) => MapEntry<String, bool>(item.id, true),
          ),
        );
      _notifyFavoriteListeners();
      _initialized = true;
    } on ApiException catch (error) {
      syncError.value = error.message;
      // Auth failures are often transient around startup hydration/login race.
      // Do not lock initialization so a later call can retry and recover.
      _initialized = !error.isUnauthorized;
    } catch (_) {
      _initialized = true;
    } finally {
      isSyncing.value = false;
    }
  }

  bool isFavorite(String id) => favoriteStates[id] ?? false;

  /// Call inside `Obx` builders so favorite heart UI rebuilds on toggle.
  int watchFavorites() => favoritesRevision.value;

  /// Toggle via `POST/DELETE /users/me/favorites/:restaurantId`.
  ///
  /// Optional [preview] keeps Home/Profile card data when the favorites list
  /// does not yet contain that restaurant (add path).
  Future<void> toggleFavorite(String id, {RestaurantModel? preview}) async {
    if (id.trim().isEmpty) {
      return;
    }
    // Controllers must call AuthSessionController.requireSignIn first.
    // Repository only skips API work when no Bearer token is present.
    if (!await _hasAccessToken()) {
      return;
    }

    final bool currentlyFavorite = isFavorite(id);
    favoriteStates[id] = !currentlyFavorite;
    if (currentlyFavorite) {
      favoriteSummaries.removeWhere((RestaurantModel item) => item.id == id);
    } else if (preview != null && preview.id == id) {
      _upsertSummary(preview);
    }
    _notifyFavoriteListeners();

    try {
      if (currentlyFavorite) {
        await _usersRepository.removeFavoriteRestaurant(id);
      } else {
        await _usersRepository.addFavoriteRestaurant(id);
        // Refresh summaries so Profile matches FavoriteListItemResponseDto.
        await syncFavoritesFromApi();
      }
    } catch (_) {
      favoriteStates[id] = currentlyFavorite;
      if (currentlyFavorite) {
        if (preview != null) {
          _upsertSummary(preview);
        }
      } else {
        favoriteSummaries.removeWhere((RestaurantModel item) => item.id == id);
      }
      _notifyFavoriteListeners();
      rethrow;
    }
  }

  /// Favorites for Profile / Favorites screens from `GET /users/me/favorites`.
  List<RestaurantModel> listedFavoriteRestaurants() {
    watchFavorites();
    return favoriteSummaries
        .where((RestaurantModel item) => isFavorite(item.id))
        .toList(growable: false);
  }

  List<RestaurantModel> favoriteRestaurants(List<RestaurantModel> restaurants) {
    watchFavorites();
    final List<RestaurantModel> fromApi = listedFavoriteRestaurants();
    if (fromApi.isNotEmpty || favoriteStates.values.every((bool v) => !v)) {
      // Prefer API summaries; fall back to catalog merge when summaries empty
      // but local favorite ids still exist (e.g. mid-toggle).
      if (fromApi.isNotEmpty) {
        return fromApi;
      }
    }

    final Map<String, RestaurantModel> byId = <String, RestaurantModel>{
      for (final RestaurantModel restaurant in restaurants)
        restaurant.id: restaurant,
      for (final RestaurantModel restaurant in favoriteSummaries)
        restaurant.id: restaurant,
    };
    final List<RestaurantModel> result = <RestaurantModel>[];
    for (final MapEntry<String, bool> entry in favoriteStates.entries) {
      if (!entry.value) {
        continue;
      }
      final RestaurantModel? restaurant = byId[entry.key];
      if (restaurant != null) {
        result.add(restaurant);
      }
    }
    return result;
  }

  /// Alias used by older call sites.
  List<RestaurantModel> defaultFavoriteRestaurants(
    List<RestaurantModel> restaurants,
  ) {
    return favoriteRestaurants(restaurants);
  }

  void _upsertSummary(RestaurantModel restaurant) {
    final int index = favoriteSummaries.indexWhere(
      (RestaurantModel item) => item.id == restaurant.id,
    );
    if (index >= 0) {
      favoriteSummaries[index] = restaurant;
    } else {
      favoriteSummaries.insert(0, restaurant);
    }
  }

  void _notifyFavoriteListeners() {
    favoriteStates.refresh();
    favoriteSummaries.refresh();
    favoritesRevision.value++;
  }

  Future<bool> _hasAccessToken() async {
    if (!Get.isRegistered<AuthTokenReader>()) {
      return false;
    }
    final String? access = await Get.find<AuthTokenReader>().readAccessToken();
    return access != null && access.trim().isNotEmpty;
  }
}
