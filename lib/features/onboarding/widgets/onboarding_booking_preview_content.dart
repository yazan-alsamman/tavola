import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../../reservation/model/restaurant_table_model.dart';
import '../../reservation/model/table_status_theme.dart';
import '../../reservation/widgets/restaurant_floor_map.dart';
import '../controller/onboarding_controller.dart';
import 'onboarding_glass_shell.dart';

/// Compact reservation UI for onboarding — glass shell with readable inner panels.
class OnboardingBookingPreviewContent extends StatelessWidget {
  const OnboardingBookingPreviewContent({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController onboardingController =
        Get.find<OnboardingController>();

    return OnboardingGlassShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingGlassHeader(
            icon: Icons.table_restaurant_rounded,
            title: AppStrings.onboardingSelectTable,
            message: AppStrings.onboardingSelectTableHint,
          ),
          const OnboardingGlassDivider(),
          OnboardingGlassInnerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  AppStrings.floorPlan,
                  style: AppTextStyles.reservationSectionLabel,
                ),
                const SizedBox(height: AppDimensions.compactSpacing),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.onboardingTablePreviewRadius,
                  ),
                  child: SizedBox(
                    height: AppDimensions.onboardingFloorPlanPreviewHeight,
                    width: double.infinity,
                    child: RestaurantFloorMap(
                      controller:
                          onboardingController.previewSelectTableController,
                    ),
                  ),
                ),
                Obx(() {
                  final RestaurantTableModel? table = onboardingController
                      .previewSelectTableController.selectedTable;
                  if (table == null) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimensions.compactSpacing,
                    ),
                    child: _SelectedTableStrip(table: table),
                  );
                }),
              ],
            ),
          ),
          const OnboardingGlassDivider(),
          OnboardingGlassFrostPanel(
            child: Row(
              children: [
                const Expanded(
                  child: OnboardingGlassSectionLabel(
                    text: AppStrings.numberOfDiners,
                  ),
                ),
                Obx(
                  () => _CompactDinerCounter(
                    value: onboardingController
                        .previewReservationController.dinerCount.value,
                    onDecrement: onboardingController
                        .previewReservationController.decrementDiners,
                    onIncrement: onboardingController
                        .previewReservationController.incrementDiners,
                  ),
                ),
              ],
            ),
          ),
          const OnboardingGlassDivider(),
          const _PreviewReserveTableButton(),
        ],
      ),
    );
  }
}

class _PreviewReserveTableButton extends StatelessWidget {
  const _PreviewReserveTableButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.buttonVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        AppStrings.reserveTable.toUpperCase(),
        style: AppTextStyles.confirmReservationButton.copyWith(
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _SelectedTableStrip extends StatelessWidget {
  const _SelectedTableStrip({required this.table});

  final RestaurantTableModel table;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectedTableLabel,
          style: AppTextStyles.onboardingSectionHint,
        ),
        const SizedBox(height: AppDimensions.compactSpacing),
        Wrap(
          spacing: AppDimensions.compactSpacing,
          runSpacing: AppDimensions.compactSpacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusChip(
              label: table.label,
              background: table.status.badgeColor,
              foreground: table.status.foregroundColor,
            ),
            _StatusChip(
              label: table.status.label,
              background: AppColors.surfaceAlt,
              foreground: AppColors.textPrimary,
              bordered: true,
            ),
            if (table.isWindowSeat)
              const _StatusChip(
                label: AppStrings.windowSeatBadge,
                background: AppColors.secondaryLight,
                foreground: AppColors.textPrimary,
              ),
          ],
        ),
      ],
    );
  }
}

class _CompactDinerCounter extends StatelessWidget {
  const _CompactDinerCounter({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = value > ReservationController.minDiners;
    final bool canIncrement = value < ReservationController.maxDiners;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.compactSpacing,
        vertical: AppDimensions.tinySpacing,
      ),
      decoration: BoxDecoration(
        color: AppColors.textLight.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        border: Border.all(
          color: AppColors.textLight.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CounterButton(
            icon: Icons.remove_rounded,
            onPressed: onDecrement,
            isEnabled: canDecrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.smallSpacing,
            ),
            child: Text(
              '$value',
              style: AppTextStyles.reservationCounterValue.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.add_rounded,
            onPressed: onIncrement,
            isEnabled: canIncrement,
          ),
        ],
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
        color: isEnabled
            ? AppColors.accent
            : AppColors.textLight.withValues(alpha: 0.08),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: AppDimensions.onboardingCompactCounterHeight,
            height: AppDimensions.onboardingCompactCounterHeight,
            child: Icon(
              icon,
              color: isEnabled ? AppColors.primaryDark : AppColors.textLight80,
              size: AppDimensions.smallIconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.bordered = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.compactSpacing,
        vertical: AppDimensions.tinySpacing,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        border: bordered
            ? Border.all(
                color: AppColors.border,
                width: AppDimensions.cardBorderWidth,
              )
            : null,
      ),
      child: Text(
        label,
        style: AppTextStyles.tableStatusChip.copyWith(color: foreground),
      ),
    );
  }
}
