import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/post_frame_work.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../details/controller/details_controller.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../../location/controller/user_location_controller.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../../reservation/model/reservation_route_args.dart';
import '../model/restaurant_map_location.dart';
import '../repository/restaurant_map_repository.dart';

class RestaurantMapController extends GetxController {
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;

  final RestaurantMapRepository _mapRepository =
      Get.find<RestaurantMapRepository>();
  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();
  final TextEditingController searchController = TextEditingController();
  final Rxn<RestaurantModel> selectedRestaurant = Rxn<RestaurantModel>();
  final RxString searchQuery = ''.obs;
  final RxList<RestaurantMapLocation> restaurantLocations =
      <RestaurantMapLocation>[].obs;
  final RxBool isLoadingLocations = true.obs;
  final RxnString locationsError = RxnString();

  bool _postFrameLoadsStarted = false;

  /// Map camera center — prefers the user location when recommendations-ready.
  double get mapCenterLatitude {
    if (Get.isRegistered<UserLocationController>()) {
      final UserLocationController location =
          Get.find<UserLocationController>();
      final double? latitude = location.latitude;
      if (location.canProvideRecommendations && latitude != null) {
        return latitude;
      }
    }
    return AppDimensions.mapInitialLatitude;
  }

  double get mapCenterLongitude {
    if (Get.isRegistered<UserLocationController>()) {
      final UserLocationController location =
          Get.find<UserLocationController>();
      final double? longitude = location.longitude;
      if (location.canProvideRecommendations && longitude != null) {
        return longitude;
      }
    }
    return AppDimensions.mapInitialLongitude;
  }

  @override
  void onInit() {
    super.onInit();
    // Sync seed only — never start favorites/API on the Binding frame.
    reloadLocalizedData();
    if (restaurantLocations.isNotEmpty) {
      isLoadingLocations.value = false;
    }
    PostFrameWork.schedule(() {
      if (isClosed || _postFrameLoadsStarted) {
        return;
      }
      _postFrameLoadsStarted = true;
      unawaited(_favoritesRepository.ensureInitialized());
      unawaited(loadMapLocations());
    });
  }

  void reloadLocalizedData() {
    if (isClosed) {
      return;
    }
    _applyLocations(_mapRepository.getMapLocations());
  }

  Future<void> loadMapLocations() async {
    isLoadingLocations.value = true;
    locationsError.value = null;

    try {
      final List<RestaurantMapLocation> locations = await _mapRepository
          .fetchMapLocations();
      _applyLocations(locations);
      locationsError.value = null;
      if (locations.isEmpty) {
        locationsError.value = AppStrings.restaurantsEmpty;
      }
    } on ApiException catch (error) {
      locationsError.value = error.message;
    } catch (_) {
      locationsError.value = AppStrings.mapLocationsLoadError;
    } finally {
      isLoadingLocations.value = false;
    }
  }

  void _applyLocations(List<RestaurantMapLocation> locations) {
    final String? selectedId = selectedRestaurant.value?.id;
    restaurantLocations.assignAll(locations);
    if (selectedId == null) {
      return;
    }

    RestaurantModel? matched;
    for (final RestaurantMapLocation location in restaurantLocations) {
      if (location.restaurant.id == selectedId) {
        matched = location.restaurant;
        break;
      }
    }
    selectedRestaurant.value = matched;
  }

  List<RestaurantMapLocation> get filteredLocations {
    // Touch observables so Obx rebuilds reliably.
    final String query = searchQuery.value.trim().toLowerCase();
    final List<RestaurantMapLocation> locations = restaurantLocations.toList(
      growable: false,
    );
    if (query.isEmpty) {
      return locations;
    }

    return locations
        .where((RestaurantMapLocation location) {
          final RestaurantModel restaurant = location.restaurant;
          return restaurant.name.toLowerCase().contains(query) ||
              restaurant.cuisine.toLowerCase().contains(query) ||
              restaurant.location.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void selectRestaurant(RestaurantModel restaurant) {
    selectedRestaurant.value = restaurant;
  }

  void clearSelection() {
    selectedRestaurant.value = null;
  }

  bool isSaved(String restaurantId) {
    _favoritesRepository.watchFavorites();
    return _favoritesRepository.isFavorite(restaurantId);
  }

  Future<void> toggleSaved(String restaurantId) async {
    if (!await AuthSessionController.requireSignInIfRegistered()) {
      return;
    }
    try {
      final RestaurantModel? selected = selectedRestaurant.value;
      final RestaurantModel? preview =
          selected != null && selected.id == restaurantId ? selected : null;
      await _favoritesRepository.toggleFavorite(restaurantId, preview: preview);
    } catch (_) {
      Get.snackbar(AppStrings.favorites, AppStrings.networkUnexpectedError);
    }
  }

  Future<void> reserveTable(RestaurantModel restaurant) async {
    if (Get.isRegistered<AuthSessionController>() &&
        !await Get.find<AuthSessionController>()
            .requireSignInForProtectedAction()) {
      return;
    }
    if (Get.isRegistered<ReservationController>()) {
      Get.delete<ReservationController>(force: true);
    }

    AppNavigation.pushOnce(
      AppRoutes.reservation,
      arguments: ReservationRouteArgs(
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
      ),
    );
  }

  void viewDetails(RestaurantModel restaurant) {
    DetailsController.open(restaurant);
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(index, currentIndex: mapNavigationIndex);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
