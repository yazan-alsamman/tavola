import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/model/restaurant_model.dart';
import '../controller/concierge_controller.dart';

/// Restaurant picker sheet for `POST /conversations`.
class ConciergeStartConversationSheet {
  ConciergeStartConversationSheet._();

  static Future<void> open(
    ConciergeController controller, {
    String? excludeRestaurantId,
  }) async {
    final List<RestaurantModel> restaurants;
    try {
      restaurants = await controller.loadRestaurantsForNewChat(
        excludeRestaurantId: excludeRestaurantId,
      );
    } catch (_) {
      Get.snackbar(AppStrings.chat, AppStrings.conversationStartFailed);
      return;
    }
    if (controller.requiresSignIn.value) {
      return;
    }
    if (restaurants.isEmpty) {
      Get.snackbar(AppStrings.chat, AppStrings.restaurantsEmpty);
      return;
    }

    await Get.bottomSheet<void>(
      SafeArea(
        child: Material(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.cardRadius),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(Get.context!).size.height *
                  AppDimensions.conversationsPickerMaxHeightFactor,
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
                  AppStrings.conversationsChooseRestaurant,
                  style: AppTextStyles.conciergeTitle,
                ),
                const SizedBox(height: AppDimensions.tinySpacing),
                Text(
                  AppStrings.conversationsChatAnotherRestaurant,
                  style: AppTextStyles.conciergeStatus.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                Expanded(
                  child: ListView.separated(
                    itemCount: restaurants.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimensions.smallSpacing),
                    itemBuilder: (BuildContext context, int index) {
                      final RestaurantModel restaurant = restaurants[index];
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
                          title: Text(
                            restaurant.name,
                            style: AppTextStyles.conciergeMessage.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: restaurant.cuisine.isEmpty
                              ? null
                              : Text(
                                  AppStrings.localizeUiLabel(
                                    restaurant.cuisine,
                                  ),
                                  style: AppTextStyles.conciergeStatus.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.primary,
                          ),
                          onTap: () {
                            Get.back<void>();
                            controller.startConversationWithRestaurant(
                              restaurant,
                            );
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
