import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/model/restaurant_model.dart';

/// Bottom sheet to pick a restaurant for one compare side.
class CompareRestaurantPickerSheet {
  CompareRestaurantPickerSheet._();

  static Future<void> open({
    required List<RestaurantModel> restaurants,
    required ValueChanged<RestaurantModel> onSelected,
    required Future<void> Function() onRetry,
    String? excludeRestaurantId,
    bool isLoading = false,
  }) {
    final String exclude = (excludeRestaurantId ?? '').trim();
    final List<RestaurantModel> options = restaurants
        .where((RestaurantModel item) => item.id.trim() != exclude)
        .toList(growable: false);

    return Get.bottomSheet<void>(
      SafeArea(
        child: Material(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.cardRadius),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.sizeOf(Get.context!).height *
                  AppDimensions.comparePickerMaxHeightFactor,
            ),
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: AppDimensions.bottomSheetGrabberWidth,
                    height: AppDimensions.bottomSheetGrabberHeight,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.pillRadius,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.regularSpacing),
                Text(
                  AppStrings.compareChooseRestaurant,
                  style: AppTextStyles.compareTitle,
                ),
                const SizedBox(height: AppDimensions.tinySpacing),
                Text(
                  AppStrings.compareChooseRestaurantHint,
                  style: AppTextStyles.compareSubtitle,
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                if (isLoading && options.isEmpty)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
                      ),
                    ),
                  )
                else if (options.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.compareCatalogEmpty,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.compareSubtitle,
                          ),
                          const SizedBox(height: AppDimensions.regularSpacing),
                          TextButton(
                            onPressed: () async {
                              await onRetry();
                            },
                            child: Text(AppStrings.retry),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: options.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppDimensions.smallSpacing),
                      itemBuilder: (BuildContext context, int index) {
                        final RestaurantModel restaurant = options[index];
                        return Material(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.cardRadius,
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.cardRadius,
                              ),
                            ),
                            leading: Icon(
                              Symbols.restaurant,
                              color: AppColors.primaryDark,
                              size: AppDimensions.mediumIconSize,
                            ),
                            title: Text(
                              restaurant.name,
                              style: AppTextStyles.compareCardTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: restaurant.cuisine.isEmpty
                                ? null
                                : Text(
                                    AppStrings.localizeUiLabel(
                                      restaurant.cuisine,
                                    ),
                                    style: AppTextStyles.compareSubtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            trailing: const Icon(
                              Symbols.chevron_right,
                              color: AppColors.primaryDark,
                            ),
                            onTap: () {
                              Get.back<void>();
                              onSelected(restaurant);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
    );
  }
}
