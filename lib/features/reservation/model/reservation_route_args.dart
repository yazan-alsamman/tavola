class ReservationRouteArgs {
  const ReservationRouteArgs({
    required this.restaurantId,
    required this.restaurantName,
    this.rescheduleReservationId,
    this.guests,
  });

  final String restaurantId;
  final String restaurantName;

  /// When set, confirm calls `POST /reservations/:id/reschedule` instead of create.
  final String? rescheduleReservationId;

  /// Party size already booked. Reschedule keeps this instead of the default.
  final int? guests;
}
