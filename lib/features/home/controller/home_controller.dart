import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_dependency.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../details/controller/details_controller.dart';
import '../../details/controller/restaurant_menu_controller.dart';
import '../../details/repository/restaurant_details_repository.dart';
import '../../discovery/model/restaurant_offer_model.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../location/controller/user_location_controller.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../../reservation/controller/select_restaurant_controller.dart';
import '../../reservation/model/reservation_route_args.dart';
import '../../taxonomy/model/cuisine_category_model.dart';
import '../../taxonomy/model/occasion_category_model.dart';
import '../../taxonomy/repository/taxonomy_repository.dart';
import '../home_progressive_init.dart';
import '../model/restaurant_model.dart';

/// Home feature only: catalog, filters, occasions, and home UI actions.
///
/// Stage 0 (first frame) creates this controller with taxonomy + discovery
/// cache hydrate. Remaining shell work is one band per frame via
/// [HomeProgressiveInit].
class HomeController extends GetxController {
  final TaxonomyRepository _taxonomyRepository = Get.find<TaxonomyRepository>();
  final DiscoveryRepository _discoveryRepository =
      Get.find<DiscoveryRepository>();

  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxList<CuisineCategoryModel> cuisineCategories =
      <CuisineCategoryModel>[].obs;
  final RxList<String> restaurantFilters = <String>[].obs;
  final RxList<String> occasionCategories = <String>[].obs;
  final RxList<OccasionCategoryModel> occasionCategoryItems =
      <OccasionCategoryModel>[].obs;
  final RxInt selectedFilterIndex = 0.obs;
  final RxnString selectedOccasion = RxnString();

  /// Start true so the first frame shows lightweight skeletons when caches miss.
  final RxBool isLoadingCuisineCategories = true.obs;
  final RxnString cuisineCategoriesError = RxnString();
  final RxBool isLoadingOccasionCategories = true.obs;
  final RxnString occasionCategoriesError = RxnString();
  final RxBool isLoadingRestaurants = true.obs;
  final RxnString restaurantsError = RxnString();
  final RxString searchQuery = ''.obs;

  /// Featured Home promo from nearby/catalog + `GET .../offers`.
  final Rxn<RestaurantOfferModel> featuredOffer = Rxn<RestaurantOfferModel>();
  final Rxn<RestaurantModel> featuredOfferRestaurant = Rxn<RestaurantModel>();
  final RxBool isLoadingSpecialOffer = false.obs;
  final RxnString specialOfferError = RxnString();
  bool _specialOfferLoadInFlight = false;

  /// Owns the Home search field so keyboard / MediaQuery rebuilds cannot
  /// recreate an uncontrolled [TextField] and drop focus mid-typing.
  final TextEditingController searchController = TextEditingController();

  /// Progressive init band: 0 = first frame only, [HomeProgressiveInit.stageComplete] = done.
  final RxInt progressiveStage = 0.obs;

  /// Chrome rebuild milestones — flip once so AppBar/location Obx do not
  /// rebuild on every progressive band (was 8 rebuilds per Login→Home).
  final RxBool shellProfileReady = false.obs;
  final RxBool shellNotificationsReady = false.obs;
  final RxBool shellLocationReady = false.obs;

  bool _postFrameLoadsStarted = false;
  bool _progressiveInitCancelled = false;
  HomeProgressiveInit? _progressiveInit;

  /// Test/perf: true after the post-frame progressive kickoff has been scheduled.
  bool get didSchedulePostFrameLoads => _postFrameLoadsStarted;

  /// Test-only: stop progressive bands so unit tests can drive loads explicitly.
  @visibleForTesting
  void cancelProgressiveInit() {
    _progressiveInitCancelled = true;
    _progressiveInit?.cancel();
  }

  FavoritesRepository? get _favoritesOrNull =>
      Get.isRegistered<FavoritesRepository>()
      ? Get.find<FavoritesRepository>()
      : null;

  @override
  void onInit() {
    final Stopwatch stopwatch = Stopwatch()..start();
    super.onInit();
    // Sync only: seed from warm taxonomy cache so the first paint can skip
    // empty→loading→data flicker when Welcome/Login already prefetched.
    _hydrateFromCaches();
    _log('onInit (sync hydrate)', stopwatch);

    // Progressive stages start after the first Home frame is committed.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (isClosed || _postFrameLoadsStarted || _progressiveInitCancelled) {
        return;
      }
      _postFrameLoadsStarted = true;
      final Stopwatch loadWatch = Stopwatch()..start();
      _progressiveInit = HomeProgressiveInit(this)..startAfterFirstFrame();
      _log('post-frame progressive kickoff', loadWatch);
    });
  }

  @override
  void onClose() {
    _progressiveInit?.cancel();
    _progressiveInit = null;
    searchController.dispose();
    super.onClose();
  }

  void markProgressiveStage(int stage) {
    if (isClosed) {
      return;
    }
    if (stage > progressiveStage.value) {
      progressiveStage.value = stage;
    }
    if (stage >= 4) {
      shellProfileReady.value = true;
    }
    if (stage >= 7) {
      shellNotificationsReady.value = true;
    }
    if (stage >= 8) {
      shellLocationReady.value = true;
    }
  }

  void _hydrateFromCaches() {
    final List<CuisineCategoryModel>? cuisines =
        _taxonomyRepository.cachedCuisineCategories;
    if (cuisines != null) {
      cuisineCategories.assignAll(cuisines);
      _applyCuisineFilterLabels();
      isLoadingCuisineCategories.value = false;
    }

    final List<OccasionCategoryModel>? occasions =
        _taxonomyRepository.cachedOccasionCategories;
    if (occasions != null) {
      occasionCategoryItems.assignAll(occasions);
      occasionCategories.assignAll(
        occasions.map((OccasionCategoryModel item) => item.name).toList(),
      );
      isLoadingOccasionCategories.value = false;
    }

    // Discovery list cache when Splash / Welcome already prefetched.
    final List<RestaurantModel>? cachedRestaurants =
        _discoveryRepository.cachedRestaurants;
    if (cachedRestaurants != null) {
      restaurants.assignAll(cachedRestaurants);
      restaurantsError.value = null;
      _restaurantsErrorKind = null;
      isLoadingRestaurants.value = false;
    } else {
      restaurants.clear();
      isLoadingRestaurants.value = true;
    }
  }

  void reloadLocalizedData() {
    if (isClosed) {
      return;
    }
    _applyCuisineFilterLabels();
    cuisineCategories.refresh();
    restaurantFilters.refresh();
    occasionCategoryItems.refresh();
    occasionCategories.refresh();
    // Re-bake availability labels that were translated at parse time.
    if (restaurants.isNotEmpty) {
      restaurants.assignAll(<RestaurantModel>[
        for (final RestaurantModel item in restaurants)
          item.copyWith(
            availabilityLabel: item.isAvailable
                ? AppStrings.openNow
                : AppStrings.hoursClosed,
          ),
      ]);
    } else {
      restaurants.refresh();
    }
    _relocalizeKnownListErrors();
  }

  void _relocalizeKnownListErrors() {
    _applyLocalizedError(restaurantsError, _restaurantsErrorKind);
    _applyLocalizedError(cuisineCategoriesError, _cuisineErrorKind);
    _applyLocalizedError(occasionCategoriesError, _occasionErrorKind);
  }

  _HomeListErrorKind? _restaurantsErrorKind;
  _HomeListErrorKind? _cuisineErrorKind;
  _HomeListErrorKind? _occasionErrorKind;

  static void _applyLocalizedError(
    RxnString target,
    _HomeListErrorKind? kind,
  ) {
    if (kind == null || target.value == null) {
      return;
    }
    switch (kind) {
      case _HomeListErrorKind.empty:
        target.value = AppStrings.restaurantsEmpty;
        return;
      case _HomeListErrorKind.timeout:
        target.value = AppStrings.networkTimeoutError;
        return;
      case _HomeListErrorKind.unexpected:
        target.value = AppStrings.networkUnexpectedError;
        return;
      case _HomeListErrorKind.api:
        return;
    }
  }

  void _setRestaurantsError(_HomeListErrorKind kind, String message) {
    _restaurantsErrorKind = kind;
    restaurantsError.value = message;
  }

  void _setCuisineError(_HomeListErrorKind kind, String message) {
    _cuisineErrorKind = kind;
    cuisineCategoriesError.value = message;
  }

  void _setOccasionError(_HomeListErrorKind kind, String message) {
    _occasionErrorKind = kind;
    occasionCategoriesError.value = message;
  }

  /// `GET /discovery/restaurants` — customer catalog.
  Future<void> loadRestaurants() async {
    final bool showSpinner = restaurants.isEmpty;
    if (showSpinner) {
      isLoadingRestaurants.value = true;
    }
    restaurantsError.value = null;
    _restaurantsErrorKind = null;
    try {
      final List<RestaurantModel> items = await _discoveryRepository
          .listRestaurants(forceRefresh: true)
          .timeout(AppDimensions.homeCatalogLoadTimeout);
      restaurants.assignAll(items);
      if (items.isEmpty) {
        _setRestaurantsError(
          _HomeListErrorKind.empty,
          AppStrings.restaurantsEmpty,
        );
      } else {
        unawaited(_enrichRestaurantHoursLabels());
      }
      _logCatalog('restaurants ok', items.length);
    } on TimeoutException {
      _logCatalog('restaurants timeout', 0);
      if (restaurants.isEmpty) {
        _setRestaurantsError(
          _HomeListErrorKind.timeout,
          AppStrings.networkTimeoutError,
        );
      }
    } on ApiException catch (error) {
      _logCatalog('restaurants api: ${error.message}', 0);
      if (restaurants.isEmpty) {
        _setRestaurantsError(_HomeListErrorKind.api, error.message);
      }
    } catch (error) {
      _logCatalog('restaurants unexpected: $error', 0);
      if (restaurants.isEmpty) {
        _setRestaurantsError(
          _HomeListErrorKind.unexpected,
          AppStrings.networkUnexpectedError,
        );
      }
    } finally {
      isLoadingRestaurants.value = false;
    }
  }

  /// Fills [RestaurantModel.hoursLabel] from primary-branch working-hours.
  Future<void> _enrichRestaurantHoursLabels() async {
    if (isClosed || restaurants.isEmpty) {
      return;
    }
    AppDependency.ensureRestaurantDetailsRepository();
    if (!Get.isRegistered<RestaurantDetailsRepository>()) {
      return;
    }
    final RestaurantDetailsRepository details =
        Get.find<RestaurantDetailsRepository>();
    final List<RestaurantModel> snapshot = restaurants.toList(growable: false);
    final List<RestaurantModel> enriched = await Future.wait(
      snapshot.map((RestaurantModel restaurant) async {
        if (restaurant.hoursLabel.trim().isNotEmpty) {
          return restaurant;
        }
        try {
          final String label = await details
              .fetchTodayHoursLabel(restaurant.id)
              .timeout(AppDimensions.homeCatalogLoadTimeout);
          if (label.trim().isEmpty) {
            return restaurant;
          }
          return restaurant.copyWith(hoursLabel: label);
        } catch (_) {
          return restaurant;
        }
      }),
    );
    if (isClosed) {
      return;
    }
    restaurants.assignAll(enriched);
  }

  Future<void> loadCuisineCategories() async {
    final bool showSpinner = cuisineCategories.isEmpty;
    if (showSpinner) {
      isLoadingCuisineCategories.value = true;
    }
    cuisineCategoriesError.value = null;
    _cuisineErrorKind = null;
    try {
      final List<CuisineCategoryModel> items = await _taxonomyRepository
          .fetchCuisineCategories()
          .timeout(AppDimensions.homeCatalogLoadTimeout);
      cuisineCategories.assignAll(items);
      _applyCuisineFilterLabels();
      if (selectedFilterIndex.value >= restaurantFilters.length) {
        selectedFilterIndex.value = 0;
      }
      _logCatalog('cuisine ok', items.length);
    } on TimeoutException {
      _logCatalog('cuisine timeout', 0);
      if (cuisineCategories.isEmpty) {
        restaurantFilters.clear();
        _setCuisineError(
          _HomeListErrorKind.timeout,
          AppStrings.networkTimeoutError,
        );
      }
    } on ApiException catch (error) {
      _logCatalog('cuisine api: ${error.message}', 0);
      if (cuisineCategories.isEmpty) {
        restaurantFilters.clear();
        _setCuisineError(_HomeListErrorKind.api, error.message);
      }
    } catch (error) {
      _logCatalog('cuisine unexpected: $error', 0);
      if (cuisineCategories.isEmpty) {
        restaurantFilters.clear();
        _setCuisineError(
          _HomeListErrorKind.unexpected,
          AppStrings.networkUnexpectedError,
        );
      }
    } finally {
      isLoadingCuisineCategories.value = false;
    }
  }

  Future<void> loadOccasionCategories() async {
    final bool showSpinner = occasionCategoryItems.isEmpty;
    if (showSpinner) {
      isLoadingOccasionCategories.value = true;
    }
    occasionCategoriesError.value = null;
    _occasionErrorKind = null;
    try {
      final List<OccasionCategoryModel> items = await _taxonomyRepository
          .fetchOccasionCategories()
          .timeout(AppDimensions.homeCatalogLoadTimeout);
      occasionCategoryItems.assignAll(items);
      occasionCategories.assignAll(
        items.map((OccasionCategoryModel item) => item.name).toList(),
      );
      final String? selected = selectedOccasion.value;
      if (selected != null && !occasionCategories.contains(selected)) {
        selectedOccasion.value = null;
      }
      _logCatalog('occasion ok', items.length);
    } on TimeoutException {
      _logCatalog('occasion timeout', 0);
      if (occasionCategoryItems.isEmpty) {
        occasionCategories.clear();
        _setOccasionError(
          _HomeListErrorKind.timeout,
          AppStrings.networkTimeoutError,
        );
      }
    } on ApiException catch (error) {
      _logCatalog('occasion api: ${error.message}', 0);
      if (occasionCategoryItems.isEmpty) {
        occasionCategories.clear();
        _setOccasionError(_HomeListErrorKind.api, error.message);
      }
    } catch (error) {
      _logCatalog('occasion unexpected: $error', 0);
      if (occasionCategoryItems.isEmpty) {
        occasionCategories.clear();
        _setOccasionError(
          _HomeListErrorKind.unexpected,
          AppStrings.networkUnexpectedError,
        );
      }
    } finally {
      isLoadingOccasionCategories.value = false;
    }
  }

  static void _logCatalog(String label, int count) {
    if (kDebugMode) {
      debugPrint('[HomeCatalog] $label (count=$count)');
    }
  }

  void _applyCuisineFilterLabels() {
    restaurantFilters.assignAll(<String>[
      AppStrings.allRestaurantsKey,
      ...cuisineCategories.map((CuisineCategoryModel item) => item.name),
    ]);
  }

  void selectFilter(int index) {
    if (index < 0 || index >= restaurantFilters.length) {
      return;
    }
    selectedFilterIndex.value = index;
  }

  void selectOccasion(String occasion) {
    // Tap again to clear — users must not be forced to keep an occasion.
    if (selectedOccasion.value == occasion) {
      selectedOccasion.value = null;
      return;
    }
    selectedOccasion.value = occasion;
  }

  void updateSearch(String value) {
    if (searchQuery.value == value) {
      return;
    }
    searchQuery.value = value;
  }

  List<RestaurantModel> get filteredRestaurants {
    Iterable<RestaurantModel> items = restaurants;
    final int filterIndex = selectedFilterIndex.value;
    if (filterIndex > 0 && filterIndex < restaurantFilters.length) {
      final String cuisine = restaurantFilters[filterIndex];
      items = items.where(
        (RestaurantModel restaurant) => _matchesCuisine(restaurant, cuisine),
      );
    }

    final String? occasion = selectedOccasion.value?.trim();
    if (occasion != null && occasion.isNotEmpty) {
      items = items.where(
        (RestaurantModel restaurant) => _matchesOccasion(restaurant, occasion),
      );
    }

    final String query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      items = items.where(
        (RestaurantModel restaurant) =>
            restaurant.name.toLowerCase().contains(query) ||
            restaurant.cuisine.toLowerCase().contains(query) ||
            restaurant.location.toLowerCase().contains(query),
      );
    }
    return items.toList(growable: false);
  }

  bool isFavorite(String id) {
    return _favoritesOrNull?.isFavorite(id) ?? false;
  }

  int watchFavorites() => _favoritesOrNull?.watchFavorites() ?? 0;

  Future<void> toggleFavorite(String id) async {
    if (!await AuthSessionController.requireSignInIfRegistered()) {
      return;
    }
    try {
      AppDependency.ensureFavoritesRepository();
      final FavoritesRepository favorites = Get.find<FavoritesRepository>();
      RestaurantModel? preview;
      for (final RestaurantModel item in restaurants) {
        if (item.id == id) {
          preview = item;
          break;
        }
      }
      await favorites.toggleFavorite(id, preview: preview);
    } catch (_) {
      Get.snackbar(AppStrings.favorites, AppStrings.networkUnexpectedError);
    }
  }

  void openReservation() {
    SelectRestaurantController.open();
  }

  /// Book the restaurant behind the featured Discovery offer.
  void openFeaturedOfferReservation() {
    final RestaurantModel? restaurant = featuredOfferRestaurant.value;
    if (restaurant == null || restaurant.id.trim().isEmpty) {
      SelectRestaurantController.open();
      return;
    }
    if (Get.isRegistered<ReservationController>()) {
      Get.delete<ReservationController>(force: true);
    }
    AppDependency.ensureReservationFlowDependencies();
    AppNavigation.pushOnce(
      AppRoutes.reservation,
      arguments: ReservationRouteArgs(
        restaurantId: restaurant.id,
        restaurantName: restaurant.name.isNotEmpty
            ? restaurant.name
            : AppStrings.specialOffer,
      ),
    );
  }

  /// Loads one published offer for the Home Special Offer card.
  ///
  /// Prefers `GET /discovery/restaurants/nearby` + offers; falls back to catalog
  /// restaurants with `hasActiveOffer` (or probes catalog when the flag is absent).
  Future<void> loadSpecialOfferPromo() async {
    if (isClosed || _specialOfferLoadInFlight) {
      return;
    }
    _specialOfferLoadInFlight = true;
    isLoadingSpecialOffer.value = true;
    specialOfferError.value = null;
    try {
      if (Get.isRegistered<UserLocationController>()) {
        try {
          await Get.find<UserLocationController>()
              .refreshStatus()
              .timeout(AppDimensions.homeCatalogLoadTimeout);
        } catch (_) {
          // Location is optional; catalog fallback still applies.
        }
      }

      final List<RestaurantModel> nearbyCandidates =
          await _loadNearbyOfferCandidates();
      final RestaurantOfferModel? fromNearby = await _firstPublishedOffer(
        nearbyCandidates,
      );
      if (fromNearby != null) {
        return;
      }

      List<RestaurantModel> catalog = restaurants.toList(growable: false);
      if (catalog.isEmpty) {
        try {
          catalog = await _discoveryRepository
              .listRestaurants()
              .timeout(AppDimensions.homeCatalogLoadTimeout);
        } catch (_) {
          catalog = const <RestaurantModel>[];
        }
      }

      final List<RestaurantModel> flagged = catalog
          .where((RestaurantModel item) => item.hasActiveOffer)
          .toList(growable: false);
      final RestaurantOfferModel? fromFlagged = await _firstPublishedOffer(
        flagged.isNotEmpty ? flagged : catalog,
      );
      if (fromFlagged != null) {
        return;
      }

      featuredOffer.value = null;
      featuredOfferRestaurant.value = null;
      specialOfferError.value = AppStrings.offersEmpty;
    } on ApiException catch (error) {
      if (featuredOffer.value == null) {
        specialOfferError.value = error.message;
      }
    } catch (_) {
      if (featuredOffer.value == null) {
        specialOfferError.value = AppStrings.offersLoadFailed;
      }
    } finally {
      _specialOfferLoadInFlight = false;
      if (!isClosed) {
        isLoadingSpecialOffer.value = false;
      }
    }
  }

  Future<List<RestaurantModel>> _loadNearbyOfferCandidates() async {
    if (!Get.isRegistered<UserLocationController>()) {
      return const <RestaurantModel>[];
    }
    final UserLocationController location = Get.find<UserLocationController>();
    final double? latitude = location.latitude;
    final double? longitude = location.longitude;
    if (!location.canProvideRecommendations ||
        latitude == null ||
        longitude == null) {
      return const <RestaurantModel>[];
    }
    try {
      final List<RestaurantModel> nearby = await _discoveryRepository
          .listNearbyRestaurants(latitude: latitude, longitude: longitude)
          .timeout(AppDimensions.homeCatalogLoadTimeout);
      final List<RestaurantModel> flagged = nearby
          .where((RestaurantModel item) => item.hasActiveOffer)
          .toList(growable: false);
      return flagged.isNotEmpty ? flagged : nearby;
    } catch (_) {
      return const <RestaurantModel>[];
    }
  }

  Future<RestaurantOfferModel?> _firstPublishedOffer(
    List<RestaurantModel> candidates,
  ) async {
    final int limit = AppDimensions.homeOfferCandidateProbeLimit;
    for (final RestaurantModel restaurant in candidates.take(limit)) {
      if (restaurant.id.trim().isEmpty) {
        continue;
      }
      try {
        final List<RestaurantOfferModel> offers = await _discoveryRepository
            .listOffers(restaurant.id)
            .timeout(AppDimensions.homeCatalogLoadTimeout);
        for (final RestaurantOfferModel offer in offers) {
          if (!offer.isPublished && offer.status.trim().isNotEmpty) {
            continue;
          }
          if (offer.title.trim().isEmpty && offer.description.trim().isEmpty) {
            continue;
          }
          if (isClosed) {
            return null;
          }
          featuredOffer.value = offer;
          featuredOfferRestaurant.value = restaurant;
          specialOfferError.value = null;
          return offer;
        }
      } catch (_) {
        // Try the next restaurant.
      }
    }
    return null;
  }

  void openDetails(RestaurantModel restaurant) {
    DetailsController.open(restaurant);
  }

  void openMenu(RestaurantModel restaurant) {
    RestaurantMenuController.open(restaurant);
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(
      index,
      currentIndex: BottomNavNavigation.homeIndex,
    );
  }

  static bool _matchesCuisine(RestaurantModel restaurant, String cuisine) {
    final String needle = cuisine.toLowerCase();
    if (restaurant.cuisine.toLowerCase() == needle) {
      return true;
    }
    return restaurant.cuisineTags.any(
      (String tag) => tag.toLowerCase() == needle,
    );
  }

  static bool _matchesOccasion(RestaurantModel restaurant, String occasion) {
    final String needle = occasion.toLowerCase();
    if (restaurant.occasion.toLowerCase() == needle) {
      return true;
    }
    if (restaurant.occasionTags.any(
      (String tag) => tag.toLowerCase() == needle,
    )) {
      return true;
    }
    return restaurant.description.toLowerCase().contains(needle);
  }

  static void _log(String label, Stopwatch stopwatch) {
    if (kDebugMode) {
      debugPrint('[HomePerf] $label: ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}

enum _HomeListErrorKind { empty, timeout, unexpected, api }
