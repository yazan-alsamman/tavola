import '../../../core/network/api_exception.dart';
import '../../../core/utils/media_url_resolver.dart';

/// Customer reservation DTO from create/cancel/reschedule and
/// `GET /reservations/my*` (enriched list + flat detail).
class CustomerReservationModel {
  const CustomerReservationModel({
    required this.reservationId,
    required this.status,
    this.restaurantId = '',
    this.restaurantName = '',
    this.branchId = '',
    this.branchName = '',
    this.tableId = '',
    this.guests = 0,
    this.reservationStartTime,
    this.reservationEndTime,
    this.notes,
    this.imageUrl = '',
  });

  final String reservationId;
  final String status;
  final String restaurantId;
  final String restaurantName;
  final String branchId;
  final String branchName;
  final String tableId;
  final int guests;
  final DateTime? reservationStartTime;
  final DateTime? reservationEndTime;
  final String? notes;
  final String imageUrl;

  /// Pending / Approved (case-insensitive; API uses PascalCase).
  bool get isActive {
    final String normalized = status.trim().toLowerCase();
    return normalized == 'pending' || normalized == 'approved';
  }

  CustomerReservationModel copyWith({
    String? reservationId,
    String? status,
    String? restaurantId,
    String? restaurantName,
    String? branchId,
    String? branchName,
    String? tableId,
    int? guests,
    DateTime? reservationStartTime,
    DateTime? reservationEndTime,
    String? notes,
    String? imageUrl,
  }) {
    return CustomerReservationModel(
      reservationId: reservationId ?? this.reservationId,
      status: status ?? this.status,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      tableId: tableId ?? this.tableId,
      guests: guests ?? this.guests,
      reservationStartTime: reservationStartTime ?? this.reservationStartTime,
      reservationEndTime: reservationEndTime ?? this.reservationEndTime,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Parses create/cancel/reschedule, enriched `/my*` list items, and detail.
  factory CustomerReservationModel.fromJson(
    Map<String, dynamic> json, {
    String restaurantName = '',
    String imageUrl = '',
  }) {
    final String parsedName = ApiException.coerceString(
      json['restaurantName'],
    );
    final String parsedImage = MediaUrlResolver.resolve(
      json['restaurantImage'] ??
          json['imageUrl'] ??
          json['coverImageUrl'] ??
          json['coverImageId'] ??
          json['logoId'],
    );
    final Object? tableRaw = json['table'];
    String tableId = ApiException.coerceString(json['tableId']);
    if (tableId.isEmpty && tableRaw is Map) {
      tableId = ApiException.coerceString(
        Map<String, dynamic>.from(tableRaw)['tableId'] ??
            Map<String, dynamic>.from(tableRaw)['id'],
      );
    }

    final int guests =
        _readInt(json['partySize']) ??
        _readInt(json['guests']) ??
        0;

    final String notesRaw = ApiException.coerceString(
      json['specialRequest'] ?? json['notes'],
    );

    return CustomerReservationModel(
      reservationId: ApiException.coerceString(
        json['reservationId'] ?? json['id'],
      ),
      status: ApiException.coerceString(json['status']),
      restaurantId: ApiException.coerceString(json['restaurantId']),
      restaurantName: parsedName.isNotEmpty ? parsedName : restaurantName,
      branchId: ApiException.coerceString(json['branchId']),
      branchName: ApiException.coerceString(json['branchName']),
      tableId: tableId,
      guests: guests,
      reservationStartTime: _parseDate(json['reservationStartTime']),
      reservationEndTime: _parseDate(json['reservationEndTime']),
      notes: notesRaw.isEmpty ? null : notesRaw,
      imageUrl: parsedImage.isNotEmpty ? parsedImage : imageUrl,
    );
  }

  static int? _readInt(Object? raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim());
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
