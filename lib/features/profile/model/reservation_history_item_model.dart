class ReservationHistoryItemModel {
  const ReservationHistoryItemModel({
    required this.restaurantId,
    required this.restaurantName,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.guests,
    required this.status,
  });

  final String restaurantId;
  final String restaurantName;
  final String imageUrl;
  final String date;
  final String time;
  final String guests;
  final String status;
}
