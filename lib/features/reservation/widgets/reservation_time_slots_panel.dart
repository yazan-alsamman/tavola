import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
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
      child: Obx(() {
        if (controller.isLoadingSlots.value ||
            controller.isResolvingBranch.value) {
          return const SizedBox(
            width: double.infinity,
            height: AppDimensions.reservationChoiceHeight,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
              ),
            ),
          );
        }

        final String? error = controller.slotsError.value;
        if (error != null && error.isNotEmpty) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.selectRestaurantSubtitle,
                ),
                const SizedBox(height: AppDimensions.smallSpacing),
                TextButton(
                  onPressed: controller.loadAvailabilitySlots,
                  child: Text(
                    AppStrings.retry,
                    style: AppTextStyles.authLinkEmphasis,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.timeSlots.isEmpty) {
          return SizedBox(
            width: double.infinity,
            child: Text(
              AppStrings.reservationSlotsEmpty,
              textAlign: TextAlign.center,
              style: AppTextStyles.selectRestaurantSubtitle,
            ),
          );
        }

        return SizedBox(
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
        );
      }),
    );
  }
}
