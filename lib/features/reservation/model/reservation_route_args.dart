class ReservationRouteArgs {
  const ReservationRouteArgs({
    required this.restaurantId,
    required this.restaurantName,
    this.rescheduleReservationId,
  });

  final String restaurantId;
  final String restaurantName;

  /// When set, confirm calls `POST /reservations/:id/reschedule` instead of create.
  final String? rescheduleReservationId;
}
