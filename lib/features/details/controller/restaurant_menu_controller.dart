import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_dependency.dart';
import '../../home/model/restaurant_model.dart';
import '../model/menu_category_model.dart';
import '../model/menu_item_model.dart';
import '../model/restaurant_menu_model.dart';
import '../repository/menu_repository.dart';
import '../repository/restaurant_details_repository.dart';

class RestaurantMenuController extends GetxController {
  static const String menuUpdateId = 'restaurant_menu';

  RestaurantMenuController({
    RestaurantDetailsRepository? detailsRepository,
    MenuRepository? menuRepository,
  }) : _detailsRepository =
           detailsRepository ?? Get.find<RestaurantDetailsRepository>(),
       _menuRepository = menuRepository ?? Get.find<MenuRepository>();

  final RestaurantDetailsRepository _detailsRepository;
  final MenuRepository _menuRepository;

  RestaurantModel? _restaurant;
  RestaurantMenuModel? _menu;
  List<MenuCategoryModel> _categories = const <MenuCategoryModel>[];
  List<MenuItemModel> _menuItems = const <MenuItemModel>[];
  bool _isLoading = false;
  String? _error;

  RestaurantModel get restaurant =>
      _restaurant ?? _detailsRepository.emptyRestaurant();

  RestaurantMenuModel? get menu => _menu;

  List<MenuCategoryModel> get categories => _categories;

  List<MenuItemModel> get menuItems => _menuItems;

  bool get isLoading => _isLoading;

  String? get error => _error;

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

  Future<void> loadMenu(RestaurantModel restaurant) async {
    _restaurant = restaurant;
    _error = null;
    _menu = null;
    _categories = const <MenuCategoryModel>[];
    _menuItems = const <MenuItemModel>[];
    update([menuUpdateId]);

    final String restaurantId = restaurant.id.trim();
    if (restaurantId.isEmpty) {
      _error = AppStrings.invalidRestaurantPayload;
      update([menuUpdateId]);
      return;
    }

    _isLoading = true;
    update([menuUpdateId]);
    try {
      final RestaurantMenuModel loaded = await _menuRepository
          .resolveMenuForRestaurant(restaurantId);
      if (isClosed) {
        return;
      }
      _menu = loaded;
      _categories = loaded.categories;
      _menuItems = loaded.flatItems;
      if (_menuItems.isEmpty) {
        _error = AppStrings.menuEmpty;
      }
    } on ApiException catch (error) {
      if (!isClosed) {
        _error = error.message;
      }
    } catch (_) {
      if (!isClosed) {
        _error = AppStrings.menuLoadFailed;
      }
    } finally {
      if (!isClosed) {
        _isLoading = false;
        update([menuUpdateId]);
      }
    }
  }

  void retry() {
    final RestaurantModel? current = _restaurant;
    if (current != null) {
      loadMenu(current);
    }
  }

  void goBack() => Get.back();

  static void open(RestaurantModel restaurant) {
    AppDependency.ensureMenuRepository();
    // Binding creates a fresh controller that loads from route arguments.
    AppNavigation.pushOnce(AppRoutes.restaurantMenu, arguments: restaurant);
  }
}
