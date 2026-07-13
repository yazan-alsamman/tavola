import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/select_table_controller.dart';
import '../model/restaurant_table_model.dart';
import '../model/table_status.dart';
import '../model/table_status_theme.dart';

class RestaurantTableDetailPanel extends StatelessWidget {
  const RestaurantTableDetailPanel({super.key, required this.controller});

  final SelectTableController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showSelectedTableDetails) {
        return const SizedBox.shrink();
      }

      final RestaurantTableModel table = controller.selectedTable!;
      final bool isAvailable = table.status == TableStatus.available;

      return AnimatedSize(
        duration: AppDimensions.hoverDuration,
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.contentPadding,
            0,
            AppDimensions.contentPadding,
            AppDimensions.contentPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                color: AppColors.border,
                height: AppDimensions.dividerHeight,
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              Text(
                AppStrings.selectedTableLabel,
                style: AppTextStyles.reservationSectionLabel,
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              Wrap(
                spacing: AppDimensions.smallSpacing,
                runSpacing: AppDimensions.smallSpacing,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _InfoChip(
                    label: table.label,
                    background: table.status.badgeColor,
                    foreground: table.status.foregroundColor,
                  ),
                  _InfoChip(
                    label: table.status.label,
                    background: AppColors.surfaceAlt,
                    foreground: AppColors.textPrimary,
                    bordered: true,
                  ),
                  Text(
                    SelectTableController.seatsLabel(table.seatCount),
                    style: AppTextStyles.tableSeatCount,
                  ),
                  if (table.isWindowSeat)
                    const _InfoChip(
                      label: AppStrings.windowSeatBadge,
                      background: AppColors.secondaryLight,
                      foreground: AppColors.textPrimary,
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: AppDimensions.tableDescriptionFieldMinHeight,
                ),
                padding: const EdgeInsets.all(AppDimensions.contentPadding),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  border: Border.all(
                    color: isAvailable ? AppColors.primary : AppColors.border,
                    width: AppDimensions.cardBorderWidth,
                  ),
                ),
                child: Text(
                  controller.descriptionFor(table),
                  style: AppTextStyles.tableDescription,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
        horizontal: AppDimensions.compactHorizontalPadding,
        vertical: AppDimensions.compactVerticalPadding,
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
