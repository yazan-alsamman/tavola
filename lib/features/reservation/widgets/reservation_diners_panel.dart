import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/reservation_controller.dart';
import 'reservation_section_container.dart';

class ReservationDinersPanel extends StatelessWidget {
  const ReservationDinersPanel({super.key, required this.controller});

  final ReservationController controller;

  @override
  Widget build(BuildContext context) {
    return ReservationSectionContainer(
      label: AppStrings.numberOfDiners,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CounterButton(
              icon: Icons.remove_rounded,
              onPressed: controller.decrementDiners,
              isEnabled:
                  controller.dinerCount.value > ReservationController.minDiners,
            ),
            const SizedBox(width: AppDimensions.sectionSpacing),
            Text(
              '${controller.dinerCount.value}',
              style: AppTextStyles.reservationCounterValue,
            ),
            const SizedBox(width: AppDimensions.sectionSpacing),
            _CounterButton(
              icon: Icons.add_rounded,
              onPressed: controller.incrementDiners,
              isEnabled:
                  controller.dinerCount.value < ReservationController.maxDiners,
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.onPressed,
    required this.isEnabled,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return HoverableButton(
      child: Material(
        color: isEnabled ? AppColors.secondary : AppColors.surfaceAlt,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: AppDimensions.reservationCounterButtonSize,
            height: AppDimensions.reservationCounterButtonSize,
            child: Icon(
              icon,
              color: isEnabled ? AppColors.primary : AppColors.disabled,
              size: AppDimensions.reservationCounterIconSize,
            ),
          ),
        ),
      ),
    );
  }
}
