import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../controller/reservation_controller.dart';
import 'reservation_choice_chip.dart';
import 'reservation_section_container.dart';

class ReservationDurationPanel extends StatelessWidget {
  const ReservationDurationPanel({super.key, required this.controller});

  final ReservationController controller;

  @override
  Widget build(BuildContext context) {
    return ReservationSectionContainer(
      label: AppStrings.experienceDuration,
      child: Obx(
        () => Row(
          children: List.generate(
            controller.durationOptions.length,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == controller.durationOptions.length - 1
                      ? 0
                      : AppDimensions.smallSpacing,
                ),
                child: ReservationChoiceChip(
                  label: controller.durationOptions[index],
                  isSelected: controller.selectedDurationIndex.value == index,
                  onTap: () => controller.selectDuration(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
