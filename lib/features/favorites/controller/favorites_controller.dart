import 'package:get/get.dart';

import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../details/controller/details_controller.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/restaurant_model.dart';

class FavoritesController extends GetxController {
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;

  final HomeController homeController = Get.find<HomeController>();

  List<RestaurantModel> get favoriteRestaurants {
    return homeController.defaultFavoriteRestaurants;
  }

  bool isFavorite(String id) => homeController.isFavorite(id);

  void toggleFavorite(String id) {
    homeController.toggleFavorite(id);
  }

  void openDetails(RestaurantModel restaurant) {
    DetailsController.open(restaurant);
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(
      index,
      currentIndex: homeNavigationIndex,
    );
  }
}
