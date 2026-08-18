import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../model/menu_category_model.dart';
import '../model/menu_item_model.dart';
import '../model/restaurant_menu_model.dart';

/// Public restaurant menu APIs (Postman folder **Menu**).
///
/// - `GET /restaurants/:restaurantId/menus`
/// - `GET /restaurants/:restaurantId/menus/default`
/// - `GET /restaurants/:restaurantId/menus/:menuId`
/// - `GET /restaurants/:restaurantId/menus/:menuId/categories/:categoryId`
/// - `GET /restaurants/:restaurantId/menus/:menuId/categories/:categoryId/items/:itemId`
class MenuRepository {
  MenuRepository(this._apiClient);

  final ApiClient _apiClient;

  /// `GET /restaurants/:id/menus` — summary list (no nested tree).
  Future<List<RestaurantMenuModel>> listMenus(String restaurantId) async {
    final String id = restaurantId.trim();
    if (id.isEmpty) {
      throw ApiException(message: AppStrings.invalidRestaurantPayload);
    }
    final ApiResponse<List<RestaurantMenuModel>> response = await _apiClient
        .get<List<RestaurantMenuModel>>(
          AppUrls.restaurantMenusPath(id),
          options: ApiClient.skipAuthOptions(),
          parseData: _parseMenuSummaries,
        );
    return response.data;
  }

  /// `GET /restaurants/:id/menus/default` — full nested tree.
  Future<RestaurantMenuModel> getDefaultMenu(String restaurantId) async {
    final String id = restaurantId.trim();
    if (id.isEmpty) {
      throw ApiException(message: AppStrings.invalidRestaurantPayload);
    }
    final ApiResponse<RestaurantMenuModel> response = await _apiClient
        .get<RestaurantMenuModel>(
          AppUrls.restaurantDefaultMenuPath(id),
          options: ApiClient.skipAuthOptions(),
          parseData: _parseMenuTree,
        );
    return response.data;
  }

  /// `GET /restaurants/:id/menus/:menuId` — full nested tree.
  Future<RestaurantMenuModel> getMenuById({
    required String restaurantId,
    required String menuId,
  }) async {
    final String rid = restaurantId.trim();
    final String mid = menuId.trim();
    if (rid.isEmpty || mid.isEmpty) {
      throw ApiException(message: AppStrings.invalidMenuPayload);
    }
    final ApiResponse<RestaurantMenuModel> response = await _apiClient
        .get<RestaurantMenuModel>(
          AppUrls.restaurantMenuPath(rid, mid),
          options: ApiClient.skipAuthOptions(),
          parseData: _parseMenuTree,
        );
    return response.data;
  }

  /// `GET /restaurants/:id/menus/:menuId/categories/:categoryId`.
  Future<MenuCategoryModel> getCategoryById({
    required String restaurantId,
    required String menuId,
    required String categoryId,
  }) async {
    final String rid = restaurantId.trim();
    final String mid = menuId.trim();
    final String cid = categoryId.trim();
    if (rid.isEmpty || mid.isEmpty || cid.isEmpty) {
      throw ApiException(message: AppStrings.invalidMenuPayload);
    }
    final ApiResponse<MenuCategoryModel> response = await _apiClient
        .get<MenuCategoryModel>(
          AppUrls.restaurantMenuCategoryPath(
            restaurantId: rid,
            menuId: mid,
            categoryId: cid,
          ),
          options: ApiClient.skipAuthOptions(),
          parseData: _parseCategory,
        );
    return response.data;
  }

  /// `GET /restaurants/:id/menus/:menuId/categories/:categoryId/items/:itemId`.
  Future<MenuItemModel> getItemById({
    required String restaurantId,
    required String menuId,
    required String categoryId,
    required String itemId,
  }) async {
    final String rid = restaurantId.trim();
    final String mid = menuId.trim();
    final String cid = categoryId.trim();
    final String iid = itemId.trim();
    if (rid.isEmpty || mid.isEmpty || cid.isEmpty || iid.isEmpty) {
      throw ApiException(message: AppStrings.invalidMenuPayload);
    }
    final ApiResponse<MenuItemModel> response = await _apiClient
        .get<MenuItemModel>(
          AppUrls.restaurantMenuItemPath(
            restaurantId: rid,
            menuId: mid,
            categoryId: cid,
            itemId: iid,
          ),
          options: ApiClient.skipAuthOptions(),
          parseData: _parseItem,
        );
    return response.data;
  }

  /// Prefer default menu; if missing, list menus and fetch the default/first.
  Future<RestaurantMenuModel> resolveMenuForRestaurant(
    String restaurantId,
  ) async {
    try {
      return await getDefaultMenu(restaurantId);
    } on ApiException catch (error) {
      if (!error.isNotFound) {
        rethrow;
      }
    }
    final List<RestaurantMenuModel> menus = await listMenus(restaurantId);
    if (menus.isEmpty) {
      throw ApiException(message: AppStrings.menuEmpty);
    }
    RestaurantMenuModel summary = menus.first;
    for (final RestaurantMenuModel item in menus) {
      if (item.isDefault) {
        summary = item;
        break;
      }
    }
    if (summary.id.isEmpty) {
      throw ApiException(message: AppStrings.invalidMenuPayload);
    }
    return getMenuById(restaurantId: restaurantId, menuId: summary.id);
  }

  static RestaurantMenuModel _parseMenuTree(Object? raw) {
    if (raw is Map) {
      final RestaurantMenuModel menu = RestaurantMenuModel.fromJson(
        Map<String, dynamic>.from(raw),
      );
      if (menu.id.isNotEmpty || menu.categories.isNotEmpty) {
        return menu;
      }
    }
    throw ApiException(message: AppStrings.invalidMenuPayload);
  }

  static List<RestaurantMenuModel> _parseMenuSummaries(Object? raw) {
    final List<dynamic> items;
    if (raw is List) {
      items = raw;
    } else if (raw is Map) {
      final Object? nested = raw['items'] ?? raw['menus'];
      items = nested is List ? nested : const <dynamic>[];
    } else {
      items = const <dynamic>[];
    }
    final List<RestaurantMenuModel> parsed = <RestaurantMenuModel>[];
    for (final dynamic item in items) {
      if (item is! Map) {
        continue;
      }
      final RestaurantMenuModel menu = RestaurantMenuModel.fromSummaryJson(
        Map<String, dynamic>.from(item),
      );
      if (menu.id.isNotEmpty) {
        parsed.add(menu);
      }
    }
    return parsed;
  }

  static MenuCategoryModel _parseCategory(Object? raw) {
    if (raw is! Map) {
      throw ApiException(message: AppStrings.invalidMenuPayload);
    }
    final MenuCategoryModel category = MenuCategoryModel.fromJson(
      Map<String, dynamic>.from(raw),
    );
    if (category.id.isEmpty && category.name.isEmpty) {
      throw ApiException(message: AppStrings.invalidMenuPayload);
    }
    return category;
  }

  static MenuItemModel _parseItem(Object? raw) {
    if (raw is! Map) {
      throw ApiException(message: AppStrings.invalidMenuPayload);
    }
    final MenuItemModel item = MenuItemModel.fromJson(Map<String, dynamic>.from(raw));
    if (item.id.isEmpty && item.name.isEmpty) {
      throw ApiException(message: AppStrings.invalidMenuPayload);
    }
    return item;
  }
}
