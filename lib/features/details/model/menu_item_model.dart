import '../../../core/network/api_exception.dart';

/// Single menu item for Details / Menu UI (from public menu tree).
class MenuItemModel {
  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.categoryName = '',
  });

  final String id;
  final String name;
  final String description;
  final String price;
  final String categoryName;

  factory MenuItemModel.fromJson(
    Map<String, dynamic> json, {
    String categoryName = '',
  }) {
    return MenuItemModel(
      id: ApiException.coerceString(json['id'] ?? json['itemId']),
      name: ApiException.coerceString(json['name']),
      description: ApiException.coerceString(json['description']),
      price: formatMenuPrice(json['price'], json['currency']),
      categoryName: categoryName,
    );
  }

  static String formatMenuPrice(Object? priceRaw, Object? currencyRaw) {
    final String currency = ApiException.coerceString(currencyRaw);
    String amount = '';
    if (priceRaw is num) {
      amount = priceRaw % 1 == 0
          ? priceRaw.toInt().toString()
          : priceRaw.toStringAsFixed(2);
    } else {
      amount = ApiException.coerceString(priceRaw);
    }
    if (amount.isEmpty) {
      return '';
    }
    if (currency.isEmpty) {
      return amount;
    }
    return '$currency$amount';
  }
}
