import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/table_status.dart';
import 'table_status_dot.dart';

class TableStatusLegend extends StatelessWidget {
  const TableStatusLegend({super.key, this.overlay = false});

  final bool overlay;

  static List<_LegendItem> get _items => [
        _LegendItem(
          status: TableStatus.available,
          label: AppStrings.tableAvailable,
        ),
        _LegendItem(
          status: TableStatus.reserved,
          label: AppStrings.tableReserved,
        ),
        _LegendItem(
          status: TableStatus.cleaning,
          label: AppStrings.tableCleaning,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final Widget legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (overlay)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.compactSpacing),
            child: Text(
              AppStrings.tableStatus,
              style: AppTextStyles.reservationSectionLabel,
            ),
          ),
        ...List.generate(_items.length, (index) {
          final _LegendItem item = _items[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  index == _items.length - 1 ? 0 : AppDimensions.compactSpacing,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableStatusDot(status: item.status),
                const SizedBox(width: AppDimensions.smallSpacing),
                Text(item.label, style: AppTextStyles.tableStatusLegendLabel),
              ],
            ),
          );
        }),
      ],
    );

    if (!overlay) {
      return legend;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.compactHorizontalPadding,
        vertical: AppDimensions.compactVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface75,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryDark10,
            blurRadius: AppDimensions.floorPlanIdleShadowBlur,
            offset: Offset(0, AppDimensions.tinySpacing),
          ),
        ],
      ),
      child: legend,
    );
  }
}

class _LegendItem {
  const _LegendItem({required this.status, required this.label});

  final TableStatus status;
  final String label;
}
