import 'package:get/get.dart';

import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../details/controller/details_controller.dart';
import '../../home/model/restaurant_model.dart';
import '../../home/repository/restaurant_repository.dart';
import '../repository/favorites_repository.dart';

/// Favorites feature only: favorite list and favorite toggles for this screen.
class FavoritesController extends GetxController {
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

  List<RestaurantModel> get favoriteRestaurants {
    return _favoritesRepository.defaultFavoriteRestaurants(restaurants);
  }

  bool isFavorite(String id) {
    return _favoritesRepository.favoriteStates[id] ?? false;
  }

  void toggleFavorite(String id) {
    _favoritesRepository.toggleFavorite(id);
  }

  void openDetails(RestaurantModel restaurant) {
    DetailsController.open(restaurant);
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(
      index,
      currentIndex: BottomNavNavigation.homeIndex,
    );
  }
}
