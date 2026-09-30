class ReservationConfirmationModel {
  const ReservationConfirmationModel({
    required this.restaurantName,
    required this.guestsLabel,
    required this.dateLabel,
    required this.tableLabel,
    required this.referenceCode,
    this.statusLabel,
  });

  final String restaurantName;
  final String guestsLabel;
  final String dateLabel;
  final String tableLabel;
  final String referenceCode;

  /// Customer label from the create/reschedule response. Null for preview.
  final String? statusLabel;
}
