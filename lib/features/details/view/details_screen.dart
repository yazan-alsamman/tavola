import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/restaurant_card_action_buttons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/details_controller.dart';
import '../widgets/details_about_section.dart';
import '../widgets/details_amenities_section.dart';
import '../widgets/details_hero_header.dart';
import '../widgets/details_info_box.dart';
import '../widgets/details_location_footer.dart';
import '../widgets/details_menu_section.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailsController>(
      id: DetailsController.detailsUpdateId,
      builder: (DetailsController controller) {
        return Scaffold(
          backgroundColor: AppColors.scaffold,
          body: _buildBody(context, controller),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DetailsController controller) {
    if (controller.isLoadingDetails &&
        controller.detail.openingHours.isEmpty &&
        controller.detail.amenities.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
        ),
      );
    }

    final String? detailsError = controller.detailsError;
    if (detailsError != null &&
        controller.detail.openingHours.isEmpty &&
        controller.detail.about == AppStrings.restaurantDetailsEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                detailsError,
                textAlign: TextAlign.center,
                style: AppTextStyles.selectRestaurantSubtitle,
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              TextButton(
                onPressed: controller.retryLoadDetails,
                style: TextButton.styleFrom(
                  textStyle: AppTextStyles.authLinkEmphasis,
                ),
                child: Text(
                  AppStrings.retry,
                  style: AppTextStyles.authLinkEmphasis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            controller.watchFavorites();
            return DetailsHeroHeader(
              restaurant: controller.restaurant,
              detail: controller.detail,
              ratingLabel: controller.ratingLabel(controller.detail.rating),
              isFavorite: controller.isFavorite(controller.restaurant.id),
              onFavoritePressed: controller.toggleFavorite,
            );
          }),
          if (controller.isLoadingDetails)
            const LinearProgressIndicator(
              minHeight: AppDimensions.progressIndicatorStrokeWidth,
            ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppDimensions.pagePadding,
              end: AppDimensions.pagePadding,
              top: AppDimensions.restaurantCardActionTopSpacing,
            ),
            child: RestaurantCardActionButtons(
              onReservationPressed: controller.openReservation,
              onMenuPressed: controller.openMenu,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailsAboutSection(about: controller.detail.about),
                const SizedBox(height: AppDimensions.sectionSpacing),
                DetailsAmenitiesSection(amenities: controller.detail.amenities),
                const SizedBox(height: AppDimensions.sectionSpacing),
                DetailsInfoBox(
                  openingHours: controller.detail.openingHours,
                  phone: controller.detail.phone,
                ),
                if (controller.showMenu) ...[
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  DetailsMenuSection(menuItems: controller.detail.menuItems),
                ],
                const SizedBox(height: AppDimensions.sectionSpacing),
                DetailsLocationFooter(
                  locationNote: controller.detail.locationNote,
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                SizedBox(
                  width: double.infinity,
                  child: HoverableButton(
                    child: ElevatedButton(
                      onPressed: controller.openReservation,
                      style: AppButtonStyles.filledHover(
                        ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.textLight,
                          textStyle: AppTextStyles.confirmReservationButton,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.buttonVerticalPadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                          ),
                        ),
                        idleBackground: AppColors.primaryDark,
                      ),
                      child: Text(
                        AppStrings.reserveTable,
                        style: AppTextStyles.confirmReservationButton,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
