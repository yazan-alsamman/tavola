import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/reservation_controller.dart';
import 'reservation_section_container.dart';

class ReservationCalendarPanel extends StatelessWidget {
  const ReservationCalendarPanel({super.key, required this.controller});

  final ReservationController controller;

  @override
  Widget build(BuildContext context) {
    return ReservationSectionContainer(
      label: AppStrings.selectDate,
      child: Obx(
        () => TableCalendar<void>(
          firstDay: DateTime.utc(2026, 1, 1),
          lastDay: DateTime.utc(2027, 12, 31),
          focusedDay: controller.focusedDay.value,
          selectedDayPredicate: (day) =>
              isSameDay(controller.selectedDay.value, day),
          onDaySelected: controller.onDaySelected,
          onPageChanged: controller.onPageChanged,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTextStyles.reservationCalendarHeader,
            leftChevronIcon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.primary,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: AppTextStyles.reservationCalendarWeekday,
            weekendStyle: AppTextStyles.reservationCalendarWeekday,
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: AppTextStyles.reservationCalendarDay,
            weekendTextStyle: AppTextStyles.reservationCalendarDay,
            todayDecoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            todayTextStyle: AppTextStyles.reservationCalendarDay.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: AppTextStyles.reservationCalendarDay.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
