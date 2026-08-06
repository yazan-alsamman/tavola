class ReservationHistoryItemModel {
  const ReservationHistoryItemModel({
    required this.reservationId,
    required this.restaurantId,
    required this.restaurantName,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.guests,
    required this.status,
  });

  final String reservationId;
  final String restaurantId;
  final String restaurantName;
  final String imageUrl;
  final String date;
  final String time;
  final String guests;
  final String status;

  /// Any history row with a reservation id shows the review CTA.
  /// `POST /reviews` still enforces completed reservations server-side.
  bool get canReview => reservationId.trim().isNotEmpty;
}
