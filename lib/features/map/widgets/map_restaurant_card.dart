import 'package:flutter/material.dart';

import '../../../common/widgets/app_safe_image.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../home/model/restaurant_model.dart';
import 'package:material_symbols_icons/symbols.dart';

class MapRestaurantCard extends StatelessWidget {
  const MapRestaurantCard({
    super.key,
    required this.restaurant,
    required this.isSaved,
    required this.onSave,
    required this.onReserve,
    required this.onViewDetails,
  });

  final RestaurantModel restaurant;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onReserve;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      child: Material(
        color: AppColors.surface,
        elevation: AppDimensions.hoverElevation,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: AppDimensions.mapCardImageHeight,
              width: double.infinity,
              child: AppSafeImage(path: restaurant.imageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(restaurant.name, style: AppTextStyles.title),
                            const SizedBox(height: AppDimensions.tinySpacing),
                            Text(
                              '${AppStrings.localizeUiLabel(restaurant.cuisine)}'
                              '${AppStrings.restaurantSummarySeparator}'
                              '${restaurant.location}',
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                      HoverableButton(
                        child: TextButton.icon(
                          onPressed: onSave,
                          icon: Icon(
                            Symbols.bookmark,
                            fill: isSaved ? 1 : 0,
                            size: AppDimensions.mapCardSaveIconSize,
                          ),
                          label: Text(
                            isSaved ? AppStrings.saved : AppStrings.save,
                            style: AppTextStyles.label,
                          ),
                          style: AppButtonStyles.textHover(
                            TextButton.styleFrom(
                              textStyle: AppTextStyles.label,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.regularSpacing),
                  Row(
                    children: [
                      Expanded(
                        child: HoverableButton(
                          child: ElevatedButton(
                            onPressed: onReserve,
                            style: AppButtonStyles.filledHover(
                              ElevatedButton.styleFrom(
                                textStyle: AppTextStyles.authPrimaryButton,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppDimensions.buttonVerticalPadding,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.cardRadius,
                                  ),
                                ),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppStrings.reserveTable,
                                style: AppTextStyles.authPrimaryButton,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.smallSpacing),
                      Expanded(
                        child: HoverableButton(
                          child: OutlinedButton(
                            onPressed: onViewDetails,
                            style: AppButtonStyles.outlinedHover(
                              OutlinedButton.styleFrom(
                                textStyle: AppTextStyles.authPrimaryButton,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppDimensions.buttonVerticalPadding,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.cardRadius,
                                  ),
                                ),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppStrings.viewDetails,
                                style: AppTextStyles.authPrimaryButton,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
