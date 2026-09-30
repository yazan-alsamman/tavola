import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../model/reservation_status.dart';

/// Display colors for reservation statuses already returned by the backend.
///
/// Pending, Accepted, and Rejected use existing [AppColors]. Other statuses
/// keep their current presentation.
abstract final class ReservationStatusColors {
  static Color? forStoredStatus(String raw) {
    switch (ReservationStatusApi.parse(raw)) {
      case ReservationStatus.pending:
        return AppColors.primaryDark;
      case ReservationStatus.approved:
        return AppColors.online;
      case ReservationStatus.rejected:
        return AppColors.warning;
      case ReservationStatus.cancelled:
      case ReservationStatus.completed:
      case ReservationStatus.expired:
      case ReservationStatus.noShow:
      case ReservationStatus.unknown:
        return null;
    }
  }

  static Color? forCustomerLabel(String? label) {
    if (label == null) {
      return null;
    }
    final String value = label.trim();
    if (value.isEmpty) {
      return null;
    }
    if (value == AppStrings.reservationStatusPending) {
      return AppColors.primaryDark;
    }
    if (value == AppStrings.reservationStatusAccepted) {
      return AppColors.online;
    }
    if (value == AppStrings.reservationStatusRejected) {
      return AppColors.warning;
    }
    return null;
  }
}
