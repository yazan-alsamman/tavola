import '../../../core/constants/app_strings.dart';

/// Backend `status` on create and `GET /reservations/my*`.
///
/// Customer copy for [ReservationStatus.approved] is Accepted.
/// The stored API value stays [AppStrings.apiReservationStatusApproved].
enum ReservationStatus {
  pending,
  approved,
  rejected,
  cancelled,
  completed,
  expired,
  noShow,
  unknown,
}

abstract final class ReservationStatusApi {
  static ReservationStatus parse(String raw) {
    final String normalized = raw.trim().toLowerCase();
    if (normalized == AppStrings.apiReservationStatusPending.toLowerCase()) {
      return ReservationStatus.pending;
    }
    if (normalized == AppStrings.apiReservationStatusApproved.toLowerCase()) {
      return ReservationStatus.approved;
    }
    if (normalized == AppStrings.apiReservationStatusRejected.toLowerCase()) {
      return ReservationStatus.rejected;
    }
    if (normalized == AppStrings.apiReservationStatusCancelled.toLowerCase()) {
      return ReservationStatus.cancelled;
    }
    if (normalized == AppStrings.apiReservationStatusCompleted.toLowerCase()) {
      return ReservationStatus.completed;
    }
    if (normalized == AppStrings.apiReservationStatusExpired.toLowerCase()) {
      return ReservationStatus.expired;
    }
    if (normalized == AppStrings.apiReservationStatusNoShow.toLowerCase()) {
      return ReservationStatus.noShow;
    }
    return ReservationStatus.unknown;
  }

  static bool isOpen(String raw) {
    final ReservationStatus status = parse(raw);
    return status == ReservationStatus.pending ||
        status == ReservationStatus.approved;
  }

  /// Customer-facing label. Does not rewrite the stored API value.
  static String customerLabel(String raw) {
    switch (parse(raw)) {
      case ReservationStatus.pending:
        return AppStrings.reservationStatusPending;
      case ReservationStatus.approved:
        return AppStrings.reservationStatusAccepted;
      case ReservationStatus.rejected:
        return AppStrings.reservationStatusRejected;
      case ReservationStatus.cancelled:
        return AppStrings.reservationStatusCancelled;
      case ReservationStatus.completed:
        return AppStrings.reservationStatusCompleted;
      case ReservationStatus.expired:
        return AppStrings.reservationStatusExpired;
      case ReservationStatus.noShow:
        return AppStrings.reservationStatusNoShow;
      case ReservationStatus.unknown:
        return AppStrings.reservationStatusUnknown;
    }
  }
}
