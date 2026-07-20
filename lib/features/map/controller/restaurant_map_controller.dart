import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../details/controller/details_controller.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../../home/model/restaurant_model.dart';
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
  final TextEditingController searchController = TextEditingController();
  final Rxn<RestaurantModel> selectedRestaurant = Rxn<RestaurantModel>();
  final RxSet<String> savedRestaurantIds = <String>{}.obs;
  final RxString searchQuery = ''.obs;
  final RxList<RestaurantMapLocation> restaurantLocations =
      <RestaurantMapLocation>[].obs;

  @override
  void onInit() {
    super.onInit();
    reloadLocalizedData();
  }

  void reloadLocalizedData() {
    final String? selectedId = selectedRestaurant.value?.id;
    restaurantLocations.assignAll(_mapRepository.getMapLocations());
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
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return restaurantLocations;
    }

    return restaurantLocations.where((location) {
      final restaurant = location.restaurant;
      return restaurant.name.toLowerCase().contains(query) ||
          restaurant.cuisine.toLowerCase().contains(query) ||
          restaurant.location.toLowerCase().contains(query);
    }).toList();
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
    return savedRestaurantIds.contains(restaurantId);
  }

  void toggleSaved(String restaurantId) {
    if (!savedRestaurantIds.remove(restaurantId)) {
      savedRestaurantIds.add(restaurantId);
    }
  }

  void reserveTable(RestaurantModel restaurant) {
    if (Get.isRegistered<ReservationController>()) {
      Get.delete<ReservationController>(force: true);
    }

    Get.toNamed(AppRoutes.reservation, arguments: restaurant.name);
  }

  void viewDetails(RestaurantModel restaurant) {
    DetailsController.open(restaurant);
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(
      index,
      currentIndex: mapNavigationIndex,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
