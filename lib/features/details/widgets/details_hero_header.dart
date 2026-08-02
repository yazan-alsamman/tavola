import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/circle_back_button.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../common/widgets/app_safe_image.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/model/restaurant_model.dart';
import '../model/restaurant_detail_model.dart';

class DetailsHeroHeader extends StatelessWidget {
  const DetailsHeroHeader({
    super.key,
    required this.restaurant,
    required this.detail,
    required this.ratingLabel,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  final RestaurantModel restaurant;
  final RestaurantDetailModel detail;
  final String ratingLabel;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final String heroImage = restaurant.imageUrl.trim().isNotEmpty
        ? restaurant.imageUrl
        : (detail.galleryImageUrls.isNotEmpty
              ? detail.galleryImageUrls.first
              : '');

    return SizedBox(
      height: AppDimensions.detailsHeroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppSafeImage(path: heroImage, fit: BoxFit.cover),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: AppDimensions.detailsHeroOverlayHeight,
            // Gradient-only fade — BackdropFilter blur on a full-bleed hero
            // forces expensive first-frame raster work during route transition.
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.primaryDark22,
                    AppColors.primaryDark75,
                  ],
                  stops: [
                    AppDimensions.detailsHeroFadeStart,
                    AppDimensions.detailsHeroFadeMid,
                    1.0,
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.transparent,
                    AppColors.primaryDark22,
                    AppColors.primaryDark75,
                    AppColors.primaryDark,
                  ],
                  stops: [
                    0.0,
                    AppDimensions.detailsHeroFadeMid,
                    AppDimensions.detailsHeroFadeEnd,
                    0.85,
                    1.0,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppDimensions.pagePadding,
                AppDimensions.sectionSpacing,
                AppDimensions.pagePadding,
                AppDimensions.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(restaurant.name, style: AppTextStyles.detailsHeroTitle),
                  const SizedBox(height: AppDimensions.compactSpacing),
                  Text(ratingLabel, style: AppTextStyles.detailsHeroRating),
                  const SizedBox(height: AppDimensions.tinySpacing),
                  Text(
                    detail.locationBlurb,
                    style: AppTextStyles.detailsHeroLocation,
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            top: AppDimensions.pagePadding,
            start: AppDimensions.pagePadding,
            child: SafeArea(
              child: CircleBackButton(
                onPressed: Get.back,
                onDarkBackground: true,
              ),
            ),
          ),
          PositionedDirectional(
            top: AppDimensions.pagePadding,
            end: AppDimensions.pagePadding,
            child: SafeArea(
              child: SizedBox(
                width: AppDimensions.circleBackButtonSize,
                height: AppDimensions.circleBackButtonSize,
                child: HoverableButton(
                  child: Material(
                    color: AppColors.surface75,
                    shape: const CircleBorder(),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onFavoritePressed,
                      child: Center(
                        child: Icon(
                          Symbols.favorite,
                          fill: isFavorite ? 1 : 0,
                          color: isFavorite
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
