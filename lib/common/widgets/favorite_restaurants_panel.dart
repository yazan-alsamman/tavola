import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../features/home/model/restaurant_model.dart';
import 'restaurant_card.dart';

class FavoriteRestaurantsPanel extends StatelessWidget {
  const FavoriteRestaurantsPanel({
    super.key,
    required this.restaurants,
    required this.favoriteValues,
    required this.onFavoritePressed,
    this.onRestaurantTap,
  });

  final List<RestaurantModel> restaurants;
  final List<bool> favoriteValues;
  final ValueChanged<String> onFavoritePressed;
  final ValueChanged<RestaurantModel>? onRestaurantTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
              size: AppDimensions.settingsIconSize,
            ),
            SizedBox(width: AppDimensions.smallSpacing),
            Text(
              AppStrings.favoriteDiningSelections,
              style: AppTextStyles.settingsHeader,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.smallSpacing),
        ...List.generate(restaurants.length, (index) {
          final restaurant = restaurants[index];

          return RestaurantCard(
            restaurant: restaurant,
            isFavorite: favoriteValues[index],
            onFavoritePressed: () => onFavoritePressed(restaurant.id),
            onTap: onRestaurantTap == null
                ? null
                : () => onRestaurantTap!(restaurant),
          );
        }),
      ],
    );
  }
}
