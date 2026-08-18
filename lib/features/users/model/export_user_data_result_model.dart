import '../../../core/network/api_exception.dart';

/// `GET /users/me/export` payload (`ExportUserDataResponseDto`).
class ExportUserDataResultModel {
  const ExportUserDataResultModel({
    required this.exportedAt,
    required this.reservationsTotal,
    required this.reviewsTotal,
    required this.favoritesTotal,
    this.message = '',
  });

  final String exportedAt;
  final int reservationsTotal;
  final int reviewsTotal;
  final int favoritesTotal;
  final String message;

  factory ExportUserDataResultModel.fromJson(
    Map<String, dynamic> json, {
    String message = '',
  }) {
    return ExportUserDataResultModel(
      exportedAt: ApiException.coerceString(json['exportedAt']),
      reservationsTotal: _readTotal(json['reservations']),
      reviewsTotal: _readTotal(json['reviews']),
      favoritesTotal: _readTotal(json['favorites']),
      message: message.trim(),
    );
  }

  static int _readTotal(Object? raw) {
    if (raw is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      final Object? total = map['total'];
      if (total is int) {
        return total;
      }
      if (total is num) {
        return total.toInt();
      }
      if (total is String) {
        return int.tryParse(total.trim()) ?? 0;
      }
      final Object? items = map['items'];
      if (items is List) {
        return items.length;
      }
    }
    return 0;
  }
}
