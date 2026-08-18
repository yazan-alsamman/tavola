import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/app_ltr_text.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../model/opening_hours_day_model.dart';

class DetailsInfoBox extends StatelessWidget {
  const DetailsInfoBox({
    super.key,
    required this.openingHours,
    this.onComparePressed,
  });

  final List<OpeningHoursDayModel> openingHours;
  final VoidCallback? onComparePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.contentPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hours card always stays visible inside restaurant details —
          // never hide the section when the API is still loading / fails.
          Text(AppStrings.hours, style: AppTextStyles.detailsSectionLabel),
          const SizedBox(height: AppDimensions.regularSpacing),
          if (openingHours.isEmpty)
            Text(
              AppStrings.hoursUnavailable,
              style: AppTextStyles.detailsHoursTime,
            )
          else
            ...openingHours.map(
              (OpeningHoursDayModel day) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.compactSpacing,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        day.day,
                        style: AppTextStyles.detailsHoursDay,
                      ),
                    ),
                    AppLtrText(
                      day.hours,
                      style: AppTextStyles.detailsHoursTime,
                    ),
                  ],
                ),
              ),
            ),
          if (onComparePressed != null) ...[
            const SizedBox(height: AppDimensions.sectionSpacing),
            const Divider(
              color: AppColors.border,
              height: AppDimensions.dividerHeight,
            ),
            const SizedBox(height: AppDimensions.sectionSpacing),
            SizedBox(
              width: double.infinity,
              child: HoverableButton(
                child: OutlinedButton.icon(
                  onPressed: onComparePressed,
                  icon: const Icon(
                    Symbols.compare_arrows,
                    size: AppDimensions.mediumIconSize,
                  ),
                  label: Text(
                    AppStrings.compareWithAnotherRestaurant,
                    style: AppTextStyles.restaurantCardActionButton,
                  ),
                  style: AppButtonStyles.outlinedHover(
                    OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(
                        color: AppColors.primaryDark,
                        width: AppDimensions.restaurantCardActionBorderWidth,
                      ),
                      textStyle: AppTextStyles.restaurantCardActionButton,
                      minimumSize: const Size(
                        0,
                        AppDimensions.restaurantCardActionMinHeight,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal:
                            AppDimensions.restaurantCardActionHorizontalPadding,
                        vertical:
                            AppDimensions.restaurantCardActionVerticalPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.restaurantCardActionRadius,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
