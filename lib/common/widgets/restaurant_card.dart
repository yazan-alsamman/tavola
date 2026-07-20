import 'package:flutter/material.dart';

import 'app_safe_image.dart';
import 'hoverable_card.dart';
import 'hoverable_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../features/home/model/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.isFavorite,
    required this.onFavoritePressed,
    this.onTap,
    this.compact = false,
  });

  final RestaurantModel restaurant;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double imageHeight = compact
        ? AppDimensions.compactRestaurantImageHeight
        : AppDimensions.imageHeight;
    final double contentPadding = compact
        ? AppDimensions.compactRestaurantContentPadding
        : AppDimensions.contentPadding;
    final double badgePaddingHorizontal = compact
        ? AppDimensions.compactBadgePaddingHorizontal
        : AppDimensions.badgePaddingHorizontal;
    final double badgePaddingVertical = compact
        ? AppDimensions.compactBadgePaddingVertical
        : AppDimensions.badgePaddingVertical;
    final double favoriteButtonSize = compact
        ? AppDimensions.compactFavoriteButtonSize
        : AppDimensions.iconButtonSize;
    final int descriptionMaxLines = compact ? 1 : 2;
    final TextStyle titleStyle = compact
        ? AppTextStyles.compactRestaurantTitle
        : AppTextStyles.title.copyWith(color: AppColors.textPrimary);

    return HoverableCard(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDimensions.hoverDuration,
          curve: Curves.easeOut,
          margin: compact
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(
                  vertical: AppDimensions.tinySpacing,
                ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: AppColors.border,
              width: AppDimensions.cardBorderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: AnimatedScale(
              scale: 1,
              duration: AppDimensions.hoverDuration,
              curve: Curves.easeOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: imageHeight,
                        width: double.infinity,
                        child: AppSafeImage(
                          path: restaurant.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      PositionedDirectional(
                        start: contentPadding,
                        top: contentPadding,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: badgePaddingHorizontal,
                            vertical: badgePaddingVertical,
                          ),
                          decoration: BoxDecoration(
                            color: restaurant.isAvailable
                                ? AppColors.primary
                                : AppColors.surfaceAlt90,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.pillRadius,
                            ),
                          ),
                          child: Text(
                            restaurant.availabilityLabel,
                            style: AppTextStyles.label.copyWith(
                              color: restaurant.isAvailable
                                  ? AppColors.textLight
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        end: contentPadding,
                        top: contentPadding,
                        child: SizedBox(
                          width: favoriteButtonSize,
                          height: favoriteButtonSize,
                          child: HoverableButton(
                            child: Material(
                              color: AppColors.surface75,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: onFavoritePressed,
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  size: compact
                                      ? AppDimensions.compactFavoriteIconSize
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.name,
                                style: titleStyle,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.primary,
                              size: AppDimensions.smallIconSize,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.compactSpacing),
                        Text(
                          restaurant.location,
                          style: compact
                              ? AppTextStyles.compactRestaurantBody
                              : AppTextStyles.body,
                        ),
                        const SizedBox(height: AppDimensions.smallSpacing),
                        Text(
                          restaurant.description,
                          maxLines: descriptionMaxLines,
                          overflow: TextOverflow.ellipsis,
                          style: compact
                              ? AppTextStyles.compactRestaurantBody
                              : AppTextStyles.body,
                        ),
                        SizedBox(
                          height: compact
                              ? AppDimensions.smallSpacing
                              : AppDimensions.regularSpacing,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.restaurant_menu,
                              color: AppColors.primary,
                              size: AppDimensions.smallIconSize,
                            ),
                            const SizedBox(width: AppDimensions.compactSpacing),
                            Expanded(
                              child: Text(
                                restaurant.cuisine,
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (!compact) ...[
                          const SizedBox(height: AppDimensions.smallSpacing),
                          Text(
                            AppStrings.viewAll,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
