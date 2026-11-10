class ReservationRouteArgs {
  const ReservationRouteArgs({
    required this.restaurantId,
    required this.restaurantName,
    this.rescheduleReservationId,
    this.guests,
    this.offerId,
    this.offerTitle,
  });

  final String restaurantId;
  final String restaurantName;

  /// When set, confirm calls `POST /reservations/:id/reschedule` instead of create.
  final String? rescheduleReservationId;

  /// Party size already booked. Reschedule keeps this instead of the default.
  final int? guests;

  /// Set when the customer books from an offer. Sent as `offerId` on create;
  /// the backend keeps it only when the booking meets the offer's terms.
  final String? offerId;
  final String? offerTitle;
}
