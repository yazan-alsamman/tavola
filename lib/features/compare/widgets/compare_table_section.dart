import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/compare_row_model.dart';

/// Comparison table — rows only for fields that have real data.
class CompareTableSection extends StatelessWidget {
  const CompareTableSection({
    super.key,
    required this.rows,
    required this.labelA,
    required this.labelB,
  });

  final List<CompareRowModel> rows;
  final String labelA;
  final String labelB;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Text(
        AppStrings.compareNoComparableFields,
        style: AppTextStyles.compareSubtitle,
        textAlign: TextAlign.center,
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: AppColors.surfaceAlt,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.regularSpacing,
              vertical: AppDimensions.smallSpacing,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    AppStrings.compareFieldLabel,
                    style: AppTextStyles.compareTableHeader,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    labelA,
                    style: AppTextStyles.compareTableHeader,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    labelB,
                    style: AppTextStyles.compareTableHeader,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          ...rows.map((CompareRowModel row) => _CompareTableRow(row: row)),
        ],
      ),
    );
  }
}

class _CompareTableRow extends StatelessWidget {
  const _CompareTableRow({required this.row});

  final CompareRowModel row;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.regularSpacing,
        vertical: AppDimensions.regularSpacing,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(row.label, style: AppTextStyles.compareTableLabel),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.valueA,
              style: AppTextStyles.compareTableValue,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.valueB,
              style: AppTextStyles.compareTableValue,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
