class ReservationConfirmationModel {
  const ReservationConfirmationModel({
    required this.restaurantName,
    required this.guestsLabel,
    required this.dateLabel,
    required this.tableLabel,
    required this.referenceCode,
  });

  final String restaurantName;
  final String guestsLabel;
  final String dateLabel;
  final String tableLabel;
  final String referenceCode;
}
