import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../home/model/restaurant_model.dart';
import '../model/menu_item_model.dart';
import '../repository/restaurant_details_repository.dart';

class RestaurantMenuController extends GetxController {
  static const String menuUpdateId = 'restaurant_menu';

  final RestaurantDetailsRepository _detailsRepository =
      Get.find<RestaurantDetailsRepository>();

  RestaurantModel? _restaurant;
  List<MenuItemModel> _menuItems = const <MenuItemModel>[];

  RestaurantModel get restaurant =>
      _restaurant ?? _detailsRepository.emptyRestaurant();

  List<MenuItemModel> get menuItems => _menuItems;

  @override
  void onReady() {
    super.onReady();
    _loadFromRouteArguments();
  }

  void _loadFromRouteArguments() {
    final Object? args = Get.arguments;
    if (args is RestaurantModel) {
      loadMenu(args);
      return;
    }

    loadMenu(_detailsRepository.emptyRestaurant());
  }

  void loadMenu(RestaurantModel restaurant) {
    _restaurant = restaurant;
    // No menu API in Postman — show empty list from details payload.
    _menuItems = _detailsRepository.getMenuItems(restaurant.id);
    update([menuUpdateId]);
  }

  void goBack() => Get.back();

  static void open(RestaurantModel restaurant) {
    if (Get.isRegistered<RestaurantMenuController>()) {
      Get.find<RestaurantMenuController>().loadMenu(restaurant);
    }

    AppNavigation.pushOnce(AppRoutes.restaurantMenu, arguments: restaurant);
  }
}
