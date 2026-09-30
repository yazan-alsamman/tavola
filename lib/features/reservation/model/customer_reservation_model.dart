import '../../../core/network/api_exception.dart';
import '../../../core/utils/media_url_resolver.dart';
import 'reservation_status.dart';

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

  /// Open bookings are API `Pending` or `Approved` only.
  bool get isActive => ReservationStatusApi.isOpen(status);

  String get customerStatusLabel => ReservationStatusApi.customerLabel(status);

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
    final String parsedName = ApiException.coerceString(json['restaurantName']);
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

    final int guests = partySizeFromJson(json);

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

  /// Booked party size. `guests` is the create/detail field and `partySize`
  /// is the list field. `table.capacity` is how many seats the table has,
  /// and is never the party size.
  static int partySizeFromJson(Map<String, dynamic> json) {
    final int? guests = _positiveInt(json['guests']);
    final int? party = _positiveInt(json['partySize']);
    final int? capacity = _tableCapacity(json['table']);
    if (guests != null && party != null && guests != party) {
      if (capacity != null && party == capacity && guests != capacity) {
        return guests;
      }
      if (capacity != null && guests == capacity && party != capacity) {
        return party;
      }
      return guests;
    }
    return guests ?? party ?? 0;
  }

  /// Keeps the party the customer chose when the response is empty or only
  /// echoes the table's seat count.
  static int partySizeFromReservation({
    required int requested,
    required int returned,
    int? tableCapacity,
  }) {
    if (requested <= 0) {
      return returned > 0 ? returned : 0;
    }
    if (returned <= 0) {
      return requested;
    }
    if (tableCapacity != null &&
        tableCapacity > 0 &&
        returned == tableCapacity &&
        requested != tableCapacity) {
      return requested;
    }
    return returned;
  }

  static int? _tableCapacity(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    return _positiveInt(Map<String, dynamic>.from(raw)['capacity']);
  }

  static int? _positiveInt(Object? raw) {
    final int? value = _readInt(raw);
    if (value == null || value <= 0) {
      return null;
    }
    return value;
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
