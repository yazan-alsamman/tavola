import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../controller/reservation_controller.dart';
import 'reservation_choice_chip.dart';
import 'reservation_section_container.dart';

class ReservationTimeSlotsPanel extends StatelessWidget {
  const ReservationTimeSlotsPanel({super.key, required this.controller});

  final ReservationController controller;

  @override
  Widget build(BuildContext context) {
    return ReservationSectionContainer(
      label: AppStrings.availableTimeSlots,
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: AppDimensions.smallSpacing,
            runSpacing: AppDimensions.smallSpacing,
            children: List.generate(
              controller.timeSlots.length,
              (index) => SizedBox(
                width: AppDimensions.reservationChoiceWidth,
                child: ReservationChoiceChip(
                  label: controller.timeSlots[index],
                  isSelected: controller.selectedTimeSlotIndex.value == index,
                  onTap: () => controller.selectTimeSlot(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
