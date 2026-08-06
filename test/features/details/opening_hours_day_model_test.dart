import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/details/model/opening_hours_day_model.dart';
import 'package:tavla/features/details/repository/working_hours_mapper.dart';

void main() {
  test('weekFromPayload maps API dayOfWeek 0=Sunday entries', () {
    final List<OpeningHoursDayModel> week = WorkingHoursMapper.weekFromPayload(
      <String, dynamic>{
        'entries': <dynamic>[
          <String, dynamic>{
            'dayOfWeek': 0,
            'openingTime': '10:00',
            'closingTime': '22:00',
          },
          <String, dynamic>{
            'dayOfWeek': 1,
            'openingTime': '09:00',
            'closingTime': '22:00',
          },
        ],
      },
      dayLabel: AppStrings.workingHoursDayLabel,
      closedLabel: AppStrings.hoursClosed,
    );

    expect(week, hasLength(7));
    expect(week[0].day, AppStrings.daySunday);
    expect(week[0].hours, '10:00 – 22:00');
    expect(week[1].day, AppStrings.dayMonday);
    expect(week[1].hours, '09:00 – 22:00');
    expect(week[2].hours, AppStrings.hoursClosed);
  });

  test('todayHoursLabel uses today dayOfWeek from working-hours payload', () {
    final DateTime sunday = DateTime(2026, 8, 2, 12); // Sunday
    final String label = WorkingHoursMapper.todayHoursLabel(
      <String, dynamic>{
        'entries': <dynamic>[
          <String, dynamic>{
            'dayOfWeek': 0,
            'openingTime': '10:00',
            'closingTime': '22:00',
          },
        ],
      },
      closedLabel: AppStrings.hoursClosed,
      now: sunday,
    );

    expect(label, '10:00 – 22:00');
  });
}
