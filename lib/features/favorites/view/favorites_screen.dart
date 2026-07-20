import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/favorite_restaurants_panel.dart';
import '../../../core/constants/app_dimensions.dart';
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
