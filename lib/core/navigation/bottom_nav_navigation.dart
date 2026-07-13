import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../features/reservation/controller/select_restaurant_controller.dart';

class BottomNavNavigation {
  static const int homeIndex = 0;
  static const int mapIndex = 1;
  static const int bookingIndex = 2;
  static const int chatIndex = 3;
  static const int profileIndex = 4;

  static void handle(int index, {required int currentIndex}) {
    if (index == currentIndex) {
      return;
    }

    if (index == homeIndex) {
      Get.offNamed(AppRoutes.home);
      return;
    }

    if (index == mapIndex) {
      Get.toNamed(AppRoutes.map);
      return;
    }

    if (index == bookingIndex) {
      SelectRestaurantController.open();
      return;
    }

    if (index == chatIndex) {
      Get.toNamed(AppRoutes.concierge);
      return;
    }

    if (index == profileIndex) {
      Get.offNamed(AppRoutes.profile);
    }
  }
}
