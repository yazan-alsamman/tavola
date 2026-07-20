import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../../home/repository/restaurant_repository.dart';
import 'reservation_controller.dart';

class SelectRestaurantController extends GetxController {
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;

  final RestaurantRepository _restaurantRepository =
      Get.find<RestaurantRepository>();
  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();

  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _favoritesRepository.ensureInitializedSync();
    reloadLocalizedData();
  }

  void reloadLocalizedData() {
    restaurants.assignAll(_restaurantRepository.getRestaurants());
  }

  bool isFavorite(String id) {
    return _favoritesRepository.favoriteStates[id] ?? false;
  }

  void toggleFavorite(String id) => _favoritesRepository.toggleFavorite(id);

  void selectRestaurant(RestaurantModel restaurant) {
    if (!restaurant.isAvailable) {
      Get.snackbar(
        AppStrings.selectYourRestaurant,
        AppStrings.selectRestaurantUnavailable,
      );
      return;
    }

    if (Get.isRegistered<ReservationController>()) {
      Get.delete<ReservationController>(force: true);
    }

    Get.toNamed(AppRoutes.reservation, arguments: restaurant.name);
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(
      index,
      currentIndex: bookingNavigationIndex,
    );
  }

  static void open() {
    Get.offNamed(AppRoutes.selectRestaurant);
  }
}
