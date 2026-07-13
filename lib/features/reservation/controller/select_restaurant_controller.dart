import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/restaurant_model.dart';
import 'reservation_controller.dart';

class SelectRestaurantController extends GetxController {
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;

  final HomeController homeController = Get.find<HomeController>();

  List<RestaurantModel> get restaurants => homeController.restaurants;

  bool isFavorite(String id) => homeController.isFavorite(id);

  void toggleFavorite(String id) => homeController.toggleFavorite(id);

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
