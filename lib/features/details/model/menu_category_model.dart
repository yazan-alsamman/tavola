import '../../../core/network/api_exception.dart';
import 'menu_item_model.dart';

/// Menu category with nested items (`GET .../menus/default` tree).
class MenuCategoryModel {
  const MenuCategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.displayOrder = 0,
    this.items = const <MenuItemModel>[],
  });

  final String id;
  final String name;
  final String description;
  final int displayOrder;
  final List<MenuItemModel> items;

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    final String name = ApiException.coerceString(json['name']);
    final Object? itemsRaw = json['items'];
    final List<(int, MenuItemModel)> ranked = <(int, MenuItemModel)>[];
    if (itemsRaw is List) {
      for (final dynamic item in itemsRaw) {
        if (item is! Map) {
          continue;
        }
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final MenuItemModel model = MenuItemModel.fromJson(
          map,
          categoryName: name,
        );
        if (model.name.isNotEmpty) {
          ranked.add((_readOrder(map['displayOrder']), model));
        }
      }
    }
    ranked.sort((a, b) => a.$1.compareTo(b.$1));
    return MenuCategoryModel(
      id: ApiException.coerceString(json['id'] ?? json['categoryId']),
      name: name,
      description: ApiException.coerceString(json['description']),
      displayOrder: _readOrder(json['displayOrder']),
      items: List<MenuItemModel>.unmodifiable(
        ranked.map((e) => e.$2).toList(growable: false),
      ),
    );
  }

  static int _readOrder(Object? raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim()) ?? 0;
    }
    return 0;
  }
}
