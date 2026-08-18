import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/features/reservation/model/reservation_availability_slot_model.dart';

void main() {
  group('ReservationAvailabilitySlotModel.parseList', () {
    final DateTime day = DateTime(2026, 8, 7);

    test('parses items with reservationStartTime', () {
      final List<ReservationAvailabilitySlotModel> slots =
          ReservationAvailabilitySlotModel.parseList(
            <String, dynamic>{
              'items': <Map<String, dynamic>>[
                <String, dynamic>{
                  'reservationStartTime': '2026-08-07T19:30:00.000Z',
                  'reservationEndTime': '2026-08-07T21:00:00.000Z',
                },
                <String, dynamic>{
                  'startTime': '2026-08-07T20:00:00.000Z',
                },
              ],
            },
            day: day,
            labelBuilder: (DateTime start) =>
                '${start.hour}:${start.minute.toString().padLeft(2, '0')}',
          );

      expect(slots, hasLength(2));
      expect(slots.first.startTime.toUtc().hour, 19);
      expect(slots.first.startTime.toUtc().minute, 30);
      expect(slots.first.endTime, isNotNull);
      expect(slots.last.startTime.toUtc().hour, 20);
    });

    test('parses nested windows and availableSlots clock times', () {
      final List<ReservationAvailabilitySlotModel> fromWindows =
          ReservationAvailabilitySlotModel.parseList(
            <String, dynamic>{
              'windows': <Map<String, dynamic>>[
                <String, dynamic>{
                  'windowStart': '2026-08-07T18:00:00Z',
                  'windowEnd': '2026-08-07T19:30:00Z',
                  'label': '6:00 PM',
                },
              ],
            },
            day: day,
          );
      expect(fromWindows, hasLength(1));
      expect(fromWindows.first.label, '6:00 PM');

      final List<ReservationAvailabilitySlotModel> fromClock =
          ReservationAvailabilitySlotModel.parseList(
            <String, dynamic>{
              'availableSlots': <String>['19:30', '08:00 PM'],
            },
            day: day,
            labelBuilder: (DateTime start) =>
                '${start.hour}:${start.minute.toString().padLeft(2, '0')}',
          );
      expect(fromClock, hasLength(2));
      expect(fromClock.first.startTime.hour, 19);
      expect(fromClock.first.startTime.minute, 30);
      expect(fromClock.last.startTime.hour, 20);
      expect(fromClock.last.startTime.minute, 0);
    });

    test('dedupes identical starts and sorts ascending', () {
      final List<ReservationAvailabilitySlotModel> slots =
          ReservationAvailabilitySlotModel.parseList(
            <Map<String, dynamic>>[
              <String, dynamic>{
                'startTime': '2026-08-07T21:00:00Z',
              },
              <String, dynamic>{
                'startTime': '2026-08-07T19:00:00Z',
              },
              <String, dynamic>{
                'startTime': '2026-08-07T19:00:00Z',
              },
            ],
            day: day,
          );

      expect(slots, hasLength(2));
      expect(slots.first.startTime.isBefore(slots.last.startTime), isTrue);
    });
  });
}
