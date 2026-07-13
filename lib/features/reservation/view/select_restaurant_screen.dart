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
              const Text(
                AppStrings.selectYourRestaurant,
                textAlign: TextAlign.center,
                style: AppTextStyles.selectRestaurantTitle,
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              const Text(
                AppStrings.selectYourRestaurantSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.selectRestaurantSubtitle,
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              Obx(
                () => ListView.separated(
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
                ),
              ),
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
