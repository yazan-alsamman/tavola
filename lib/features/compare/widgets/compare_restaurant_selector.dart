import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/model/restaurant_model.dart';
import 'compare_frosted_shell.dart';

/// Compact frosted selector tile for restaurant A or B.
class CompareRestaurantSelector extends StatelessWidget {
  const CompareRestaurantSelector({
    super.key,
    required this.label,
    required this.restaurant,
    required this.onTap,
    this.onClear,
    this.isLoading = false,
  });

  final String label;
  final RestaurantModel? restaurant;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final RestaurantModel? selected = restaurant;
    final bool hasSelection = selected != null;

    return HoverableButton(
      child: CompareFrostedShell(
        padding: const EdgeInsets.all(AppDimensions.smallSpacing),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(
              AppDimensions.compareCardRadius,
            ),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(
                      alpha: AppDimensions.reservationHistoryGlassSurfaceAlpha,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.smallSpacing,
                    ),
                    border: Border.all(
                      color: AppColors.primaryDark.withValues(
                        alpha: AppDimensions.reservationHistoryBorderAlpha,
                      ),
                      width: AppDimensions.cardBorderWidth,
                    ),
                  ),
                  child: SizedBox.square(
                    dimension: AppDimensions.compareSelectorIconSize,
                    child: Icon(
                      hasSelection ? Symbols.storefront : Symbols.add,
                      color: AppColors.primaryDark,
                      size: AppDimensions.smallIconSize,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.smallSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: AppTextStyles.compareEyebrow,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        hasSelection
                            ? selected.name
                            : AppStrings.compareSelectRestaurant,
                        style: AppTextStyles.compareCardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox.square(
                    dimension: AppDimensions.smallIconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
                    ),
                  )
                else if (hasSelection && onClear != null)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Symbols.close),
                    color: AppColors.primaryDark,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: AppDimensions.compareSelectorIconSize,
                      minHeight: AppDimensions.compareSelectorIconSize,
                    ),
                  )
                else
                  const Icon(
                    Symbols.expand_more,
                    color: AppColors.primaryDark,
                    size: AppDimensions.smallIconSize,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
