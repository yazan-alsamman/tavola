import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/app_safe_image.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../discovery/model/restaurant_offer_model.dart';
import '../controller/home_controller.dart';
import '../home_assets.dart';
import '../model/restaurant_model.dart';

/// Home Special Offer card bound to Discovery nearby + offers APIs.
class HomeSpecialOfferCard extends StatelessWidget {
  const HomeSpecialOfferCard({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool loading = controller.isLoadingSpecialOffer.value;
      final RestaurantOfferModel? offer = controller.featuredOffer.value;
      final RestaurantModel? restaurant =
          controller.featuredOfferRestaurant.value;

      if (!loading && offer == null) {
        return const SizedBox.shrink();
      }

      final String title = offer?.title.trim().isNotEmpty == true
          ? offer!.title.trim()
          : AppStrings.specialOffer;
      final String description = offer?.description.trim().isNotEmpty == true
          ? offer!.description.trim()
          : (loading ? '' : AppStrings.specialOfferDescription);
      final String imagePath = restaurant?.imageUrl.trim().isNotEmpty == true
          ? restaurant!.imageUrl.trim()
          : AppImages.r5;

      return HoverableCard(
        child: SizedBox(
          height: AppDimensions.promoHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppSafeImage(
                  path: imagePath,
                  provider: imagePath == AppImages.r5
                      ? HomeAssets.promoProvider
                      : null,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                      colors: [
                        AppColors.primaryDark75,
                        AppColors.primaryDark22,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.promoTitle),
                      const SizedBox(height: AppDimensions.smallSpacing),
                      Flexible(
                        child: loading && description.isEmpty
                            ? const Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: SizedBox(
                                  width: AppDimensions.iconButtonSize,
                                  height: AppDimensions.iconButtonSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: AppDimensions
                                        .progressIndicatorStrokeWidth,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              )
                            : Text(
                                description,
                                style: AppTextStyles.promoBody,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      const SizedBox(height: AppDimensions.smallSpacing),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: SizedBox(
                          height: AppDimensions.iconButtonSize,
                          child: HoverableButton(
                            child: ElevatedButton(
                              onPressed: offer == null
                                  ? null
                                  : controller.openFeaturedOfferReservation,
                              style: AppButtonStyles.filledHover(
                                ElevatedButton.styleFrom(
                                  textStyle:
                                      AppTextStyles.restaurantCardActionButton,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.contentPadding,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.pillRadius,
                                    ),
                                  ),
                                ),
                              ),
                              child: Text(
                                AppStrings.bookNow,
                                style:
                                    AppTextStyles.restaurantCardActionButton,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
