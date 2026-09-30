import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/reservation/model/reservation_status.dart';

void main() {
  test('parses API reservation statuses and labels Approved as Accepted', () {
    expect(
      ReservationStatusApi.parse(AppStrings.apiReservationStatusPending),
      ReservationStatus.pending,
    );
    expect(
      ReservationStatusApi.parse(AppStrings.apiReservationStatusApproved),
      ReservationStatus.approved,
    );
    expect(
      ReservationStatusApi.parse(AppStrings.apiReservationStatusRejected),
      ReservationStatus.rejected,
    );
    expect(
      ReservationStatusApi.customerLabel(
        AppStrings.apiReservationStatusPending,
      ),
      AppStrings.reservationStatusPending,
    );
    expect(
      ReservationStatusApi.customerLabel(
        AppStrings.apiReservationStatusApproved,
      ),
      AppStrings.reservationStatusAccepted,
    );
    expect(
      ReservationStatusApi.customerLabel(
        AppStrings.apiReservationStatusRejected,
      ),
      AppStrings.reservationStatusRejected,
    );
    expect(ReservationStatusApi.parse(''), ReservationStatus.unknown);
    expect(
      ReservationStatusApi.customerLabel('not-a-status'),
      AppStrings.reservationStatusUnknown,
    );
    expect(
      ReservationStatusApi.isOpen(AppStrings.apiReservationStatusPending),
      isTrue,
    );
    expect(
      ReservationStatusApi.isOpen(AppStrings.apiReservationStatusRejected),
      isFalse,
    );
  });
}
