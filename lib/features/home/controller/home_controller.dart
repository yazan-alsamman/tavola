import 'package:get/get.dart';

import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../details/controller/details_controller.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../reservation/controller/select_restaurant_controller.dart';
import '../model/restaurant_model.dart';
import '../repository/restaurant_repository.dart';

/// Home feature only: catalog, filters, occasions, and home UI actions.
class HomeController extends GetxController {
  final RestaurantRepository _restaurantRepository =
      Get.find<RestaurantRepository>();
  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();

  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxList<String> restaurantFilters = <String>[].obs;
  final RxList<String> occasionCategories = <String>[].obs;
  final RxInt selectedFilterIndex = 0.obs;
  final RxnString selectedOccasion = RxnString();

  @override
  void onInit() {
    super.onInit();
    _favoritesRepository.ensureInitializedSync();
    reloadLocalizedData();
  }

  void reloadLocalizedData() {
    restaurants.assignAll(_restaurantRepository.getRestaurants());
    restaurantFilters.assignAll(_restaurantRepository.getFilters());
    occasionCategories.assignAll(
      _restaurantRepository.getOccasionCategories(),
    );
  }

  void selectFilter(int index) {
    if (index < 0 || index >= restaurantFilters.length) {
      return;
    }
    selectedFilterIndex.value = index;
  }

  void selectOccasion(String occasion) {
    selectedOccasion.value = occasion;
  }

  /// Home cards expose favorite hearts; state lives in [FavoritesRepository].
  bool isFavorite(String id) {
    return _favoritesRepository.favoriteStates[id] ?? false;
  }

  void toggleFavorite(String id) {
    _favoritesRepository.toggleFavorite(id);
  }

  void openReservation() {
    SelectRestaurantController.open();
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
