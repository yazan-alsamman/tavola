import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/favorite_restaurants_panel.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../controller/favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoritesController controller = Get.find<FavoritesController>();

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Obx(() {
            controller.watchFavorites();

            if (controller.isLoadingFavorites.value) {
              return const SizedBox(
                height: AppDimensions.imageHeight,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
                  ),
                ),
              );
            }

            final String? error = controller.favoritesError.value;
            if (error != null && controller.favoriteRestaurants.isEmpty) {
              return Column(
                children: [
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.selectRestaurantSubtitle,
                  ),
                  const SizedBox(height: AppDimensions.regularSpacing),
                  TextButton(
                    onPressed: controller.loadFavorites,
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

            final restaurants = controller.favoriteRestaurants;
            return FavoriteRestaurantsPanel(
              restaurants: restaurants,
              favoriteValues: restaurants
                  .map((restaurant) => controller.isFavorite(restaurant.id))
                  .toList(),
              onFavoritePressed: controller.toggleFavorite,
              onRestaurantTap: controller.openDetails,
            );
          }),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: BottomNavNavigation.homeIndex,
        onTap: controller.handleBottomNavigation,
      ),
    );
  }
}
