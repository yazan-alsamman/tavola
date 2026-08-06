import '../../../core/network/api_exception.dart';
import 'menu_category_model.dart';
import 'menu_item_model.dart';

/// Full nested menu (`GET /restaurants/:id/menus/default` or `/:menuId`).
class RestaurantMenuModel {
  const RestaurantMenuModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.isDefault = false,
    this.active = true,
    this.categories = const <MenuCategoryModel>[],
  });

  final String id;
  final String restaurantId;
  final String name;
  final bool isDefault;
  final bool active;
  final List<MenuCategoryModel> categories;

  List<MenuItemModel> get flatItems {
    final List<MenuItemModel> items = <MenuItemModel>[];
    for (final MenuCategoryModel category in categories) {
      items.addAll(category.items);
    }
    return items;
  }

  factory RestaurantMenuModel.fromJson(Map<String, dynamic> json) {
    final Object? categoriesRaw = json['categories'];
    final List<MenuCategoryModel> categories = <MenuCategoryModel>[];
    if (categoriesRaw is List) {
      for (final dynamic item in categoriesRaw) {
        if (item is! Map) {
          continue;
        }
        final MenuCategoryModel category = MenuCategoryModel.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (category.id.isNotEmpty || category.name.isNotEmpty) {
          categories.add(category);
        }
      }
    }
    categories.sort(
      (MenuCategoryModel a, MenuCategoryModel b) =>
          a.displayOrder.compareTo(b.displayOrder),
    );
    return RestaurantMenuModel(
      id: ApiException.coerceString(json['id'] ?? json['menuId']),
      restaurantId: ApiException.coerceString(json['restaurantId']),
      name: ApiException.coerceString(json['name']),
      isDefault: json['isDefault'] == true,
      active: json['active'] != false,
      categories: List<MenuCategoryModel>.unmodifiable(categories),
    );
  }

  /// Summary row from `GET /restaurants/:id/menus` (no categories).
  factory RestaurantMenuModel.fromSummaryJson(Map<String, dynamic> json) {
    return RestaurantMenuModel(
      id: ApiException.coerceString(json['id'] ?? json['menuId']),
      restaurantId: ApiException.coerceString(json['restaurantId']),
      name: ApiException.coerceString(json['name']),
      isDefault: json['isDefault'] == true,
      active: json['active'] != false,
    );
  }
}
