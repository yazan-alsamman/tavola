import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';

/// Public Discovery offer (`GET /discovery/restaurants/:id/offers` item).
class RestaurantOfferModel {
  const RestaurantOfferModel({
    required this.offerId,
    required this.restaurantId,
    required this.title,
    required this.description,
    this.type = '',
    this.discountType = '',
    this.discountValue,
    this.status = '',
    this.startsAt,
    this.endsAt,
  });

  final String offerId;
  final String restaurantId;
  final String title;
  final String description;
  final String type;
  final String discountType;
  final double? discountValue;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;

  bool get isPublished =>
      status.trim().toLowerCase() ==
      AppStrings.offerStatusPublished.toLowerCase();

  factory RestaurantOfferModel.fromJson(Map<String, dynamic> json) {
    return RestaurantOfferModel(
      offerId: ApiException.coerceString(json['offerId'] ?? json['id']),
      restaurantId: ApiException.coerceString(json['restaurantId']),
      title: ApiException.coerceString(json['title']),
      description: ApiException.coerceString(json['description']),
      type: ApiException.coerceString(json['type']),
      discountType: ApiException.coerceString(json['discountType']),
      discountValue: _readDouble(json['discountValue']),
      status: ApiException.coerceString(json['status']),
      startsAt: _parseDate(json['startsAt']),
      endsAt: _parseDate(json['endsAt']),
    );
  }

  static double? _readDouble(Object? raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      return double.tryParse(raw.trim());
    }
    return null;
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw.trim());
  }
}
