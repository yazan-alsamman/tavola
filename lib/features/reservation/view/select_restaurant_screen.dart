import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/restaurant_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/select_restaurant_controller.dart';

class SelectRestaurantScreen extends StatelessWidget {
  const SelectRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SelectRestaurantController controller =
        Get.find<SelectRestaurantController>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.selectYourRestaurant,
                textAlign: TextAlign.center,
                style: AppTextStyles.selectRestaurantTitle,
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              Text(
                AppStrings.selectYourRestaurantSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.selectRestaurantSubtitle,
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              Obx(() {
                if (controller.isLoadingRestaurants.value) {
                  return const SizedBox(
                    height: AppDimensions.imageHeight,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
                      ),
                    ),
                  );
                }

                final String? restaurantsError =
                    controller.restaurantsError.value;
                if (restaurantsError != null) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurantsError,
                          style: AppTextStyles.selectRestaurantSubtitle,
                        ),
                      ),
                      TextButton(
                        onPressed: controller.loadRestaurants,
                        style: TextButton.styleFrom(
                          textStyle: AppTextStyles.authLinkEmphasis,
                        ),
                        child: Text(
                          AppStrings.retry,
                          style: AppTextStyles.authLinkEmphasis,
                        ),
                      ),
                    ],
                  );
                }

                if (controller.restaurants.isEmpty) {
                  return Text(
                    AppStrings.restaurantsEmpty,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.selectRestaurantSubtitle,
                  );
                }

                // Required: ListView.builder itemBuilder is not tracked by Obx.
                controller.watchFavorites();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.restaurants.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: AppDimensions.bookingRestaurantCardSpacing,
                    );
                  },
                  itemBuilder: (context, index) {
                    final restaurant = controller.restaurants[index];

                    return RestaurantCard(
                      compact: true,
                      restaurant: restaurant,
                      isFavorite: controller.isFavorite(restaurant.id),
                      onFavoritePressed: () =>
                          controller.toggleFavorite(restaurant.id),
                      onTap: () => controller.selectRestaurant(restaurant),
                    );
                  },
                );
              }),
              const SizedBox(height: AppDimensions.sectionSpacing),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: SelectRestaurantController.bookingNavigationIndex,
        onTap: controller.handleBottomNavigation,
      ),
    );
  }
}
