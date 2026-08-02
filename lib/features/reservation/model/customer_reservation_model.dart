/// Payload from `POST /reservations` / cancel / reschedule responses
/// (`ReservationResponseDto`) plus booking UI labels.
class CustomerReservationModel {
  const CustomerReservationModel({
    required this.reservationId,
    required this.status,
    this.restaurantId = '',
    this.restaurantName = '',
    this.branchId = '',
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
  final String tableId;
  final int guests;
  final DateTime? reservationStartTime;
  final DateTime? reservationEndTime;
  final String? notes;
  final String imageUrl;

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
      tableId: tableId ?? this.tableId,
      guests: guests ?? this.guests,
      reservationStartTime: reservationStartTime ?? this.reservationStartTime,
      reservationEndTime: reservationEndTime ?? this.reservationEndTime,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory CustomerReservationModel.fromJson(
    Map<String, dynamic> json, {
    String restaurantName = '',
    String imageUrl = '',
  }) {
    return CustomerReservationModel(
      reservationId:
          (json['reservationId'] as String?) ?? (json['id'] as String?) ?? '',
      status: (json['status'] as String?)?.trim() ?? '',
      restaurantId: (json['restaurantId'] as String?)?.trim() ?? '',
      restaurantName: restaurantName,
      branchId: (json['branchId'] as String?)?.trim() ?? '',
      tableId: (json['tableId'] as String?)?.trim() ?? '',
      guests: (json['guests'] as num?)?.toInt() ?? 0,
      reservationStartTime: _parseDate(json['reservationStartTime']),
      reservationEndTime: _parseDate(json['reservationEndTime']),
      notes: (json['notes'] as String?)?.trim(),
      imageUrl: imageUrl,
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw.trim());
  }
}
