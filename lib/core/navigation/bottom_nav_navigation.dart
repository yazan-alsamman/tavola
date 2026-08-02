import '../../app/routes/app_routes.dart';
import '../../features/reservation/controller/select_restaurant_controller.dart';
import 'app_navigation.dart';

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
      AppNavigation.goShell(AppRoutes.home);
      return;
    }

    if (index == mapIndex) {
      AppNavigation.goShell(AppRoutes.map);
      return;
    }

    if (index == bookingIndex) {
      SelectRestaurantController.open();
      return;
    }

    if (index == chatIndex) {
      AppNavigation.goShell(AppRoutes.concierge);
      return;
    }

    if (index == profileIndex) {
      AppNavigation.goShell(AppRoutes.profile);
    }
  }
}
