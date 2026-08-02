import '../../../core/network/api_exception.dart';

class CuisineCategoryModel {
  const CuisineCategoryModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String slug;
  final String name;
  final int sortOrder;
  final String? createdAt;
  final String? updatedAt;

  factory CuisineCategoryModel.fromJson(Map<String, dynamic> json) {
    return CuisineCategoryModel(
      id: ApiException.coerceString(json['cuisineCategoryId'] ?? json['id']),
      slug: ApiException.coerceString(json['slug']),
      name: ApiException.coerceString(json['name']),
      sortOrder: ApiException.coerceInt(json['sortOrder']),
      createdAt: ApiException.coerceOptionalString(json['createdAt']),
      updatedAt: ApiException.coerceOptionalString(json['updatedAt']),
    );
  }
}
