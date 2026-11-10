import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';

/// Public Discovery offer (`GET /discovery/restaurants/:id/offers` item).
class RestaurantOfferModel {
  const RestaurantOfferModel({
    required this.offerId,
    required this.restaurantId,
    required this.title,
    required this.description,
    this.imageUrl = '',
    this.type = '',
    this.discountType = '',
    this.discountValue,
    this.status = '',
    this.startsAt,
    this.endsAt,
    this.daysOfWeek = const <int>[],
    this.startTime,
    this.endTime,
    this.minPartySize,
    this.branchIds = const <String>[],
    this.oncePerCustomer = false,
    this.bookingCap,
  });

  final String offerId;
  final String restaurantId;
  final String title;
  final String description;
  final String imageUrl;
  final String type;
  final String discountType;
  final double? discountValue;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;

  /// Booking conditions (backend ADR-047). Empty lists and nulls mean
  /// "no restriction". Days use the backend numbering: 0 = Sunday … 6 = Saturday.
  final List<int> daysOfWeek;

  /// `HH:mm`, branch-local. Both set or both null.
  final String? startTime;
  final String? endTime;
  final int? minPartySize;

  /// Empty = every branch of the restaurant.
  final List<String> branchIds;
  final bool oncePerCustomer;

  /// Total bookings the offer accepts; null = unlimited.
  final int? bookingCap;

  bool get hasDayLimit => daysOfWeek.isNotEmpty && daysOfWeek.length < 7;

  bool get hasHourLimit => startTime != null && endTime != null;

  /// Whether a booking at [branchId] can count toward this offer.
  bool coversBranch(String branchId) =>
      branchIds.isEmpty || branchIds.contains(branchId.trim());

  bool get isPublished =>
      status.trim().toLowerCase() ==
      AppStrings.offerStatusPublished.toLowerCase();

  factory RestaurantOfferModel.fromJson(Map<String, dynamic> json) {
    return RestaurantOfferModel(
      offerId: ApiException.coerceString(json['offerId'] ?? json['id']),
      restaurantId: ApiException.coerceString(json['restaurantId']),
      title: ApiException.coerceString(json['title']),
      description: ApiException.coerceString(json['description']),
      imageUrl: ApiException.coerceString(
        json['imageUrl'] ??
            json['image'] ??
            json['coverImageUrl'] ??
            json['mediaUrl'],
      ),
      type: ApiException.coerceString(json['type']),
      discountType: ApiException.coerceString(json['discountType']),
      discountValue: _readDouble(json['discountValue']),
      status: ApiException.coerceString(json['status']),
      startsAt: _parseDate(json['startsAt']),
      endsAt: _parseDate(json['endsAt']),
      daysOfWeek: _readDays(json['daysOfWeek']),
      startTime: _readClock(json['startTime']),
      endTime: _readClock(json['endTime']),
      minPartySize: _readPositiveInt(json['minPartySize']),
      branchIds: _readStrings(json['branchIds']),
      oncePerCustomer: json['oncePerCustomer'] == true,
      bookingCap: _readPositiveInt(json['bookingCap']),
    );
  }

  static List<int> _readDays(Object? raw) {
    if (raw is! List) {
      return const <int>[];
    }
    final Set<int> days = <int>{};
    for (final Object? entry in raw) {
      final int? day = entry is num ? entry.toInt() : int.tryParse('$entry');
      if (day != null && day >= 0 && day <= 6) {
        days.add(day);
      }
    }
    return List<int>.unmodifiable(days.toList()..sort());
  }

  static String? _readClock(Object? raw) {
    final String value = ApiException.coerceString(raw).trim();
    final RegExpMatch? match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) {
      return null;
    }
    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }

  static int? _readPositiveInt(Object? raw) {
    final int? value = raw is num ? raw.toInt() : int.tryParse('${raw ?? ''}');
    return value != null && value > 0 ? value : null;
  }

  static List<String> _readStrings(Object? raw) {
    if (raw is! List) {
      return const <String>[];
    }
    return List<String>.unmodifiable(<String>[
      for (final Object? entry in raw)
        if (ApiException.coerceString(entry).trim().isNotEmpty)
          ApiException.coerceString(entry).trim(),
    ]);
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
