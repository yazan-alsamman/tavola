import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_button_styles.dart';
import 'hoverable_button.dart';

/// Left-aligned Reservation / Menu actions under a restaurant photo.
class RestaurantCardActionButtons extends StatelessWidget {
  const RestaurantCardActionButtons({
    super.key,
    required this.onReservationPressed,
    required this.onMenuPressed,
  });

  final VoidCallback onReservationPressed;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HoverableButton(
            child: ElevatedButton(
              onPressed: onReservationPressed,
              style: AppButtonStyles.filledHover(
                ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.textLight,
                  textStyle: AppTextStyles.restaurantCardActionButton,
                  minimumSize: const Size(
                    0,
                    AppDimensions.restaurantCardActionMinHeight,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal:
                        AppDimensions.restaurantCardActionHorizontalPadding,
                    vertical: AppDimensions.restaurantCardActionVerticalPadding,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.restaurantCardActionRadius,
                    ),
                  ),
                ),
                idleBackground: AppColors.primaryDark,
              ),
              child: Text(
                AppStrings.reservation,
                style: AppTextStyles.restaurantCardActionButton,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.restaurantCardActionGap),
          HoverableButton(
            child: OutlinedButton(
              onPressed: onMenuPressed,
              style: AppButtonStyles.outlinedHover(
                OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(
                    color: AppColors.primary,
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
                    vertical: AppDimensions.restaurantCardActionVerticalPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.restaurantCardActionRadius,
                    ),
                  ),
                ),
              ),
              child: Text(
                AppStrings.menu,
                style: AppTextStyles.restaurantCardActionButton,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
