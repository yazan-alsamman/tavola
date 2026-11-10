import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/app_safe_image.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../discovery/model/offer_terms.dart';
import '../../discovery/model/restaurant_offer_model.dart';
import '../controller/home_controller.dart';
import '../model/restaurant_model.dart';

/// Home Special Offer card bound to Discovery nearby + offers APIs.
class HomeSpecialOfferCard extends StatelessWidget {
  const HomeSpecialOfferCard({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final RestaurantOfferModel? offer = controller.featuredOffer.value;
      final RestaurantModel? restaurant =
          controller.featuredOfferRestaurant.value;

      if (offer == null || restaurant == null || !restaurant.hasActiveOffer) {
        return const SizedBox.shrink();
      }

      final String title = offer.title.trim().isNotEmpty
          ? offer.title.trim()
          : AppStrings.specialOffer;
      final String description = offer.description.trim().isNotEmpty
          ? offer.description.trim()
          : AppStrings.specialOfferDescription;
      final String imagePath = offer.imageUrl.trim().isNotEmpty
          ? offer.imageUrl.trim()
          : restaurant.imageUrl.trim();

      return HoverableCard(
        child: SizedBox(
          height: AppDimensions.promoHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppSafeImage(path: imagePath, fit: BoxFit.cover),
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
                      Text(
                        title,
                        style: AppTextStyles.promoTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        _scheduleLine(offer),
                        style: AppTextStyles.promoBody.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.smallSpacing),
                      Flexible(
                        child: Text(
                          description,
                          style: AppTextStyles.promoBody,
                          maxLines: 2,
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
                              onPressed:
                                  controller.openFeaturedOfferReservation,
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
                                style: AppTextStyles.restaurantCardActionButton,
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

  /// "20% off · Sunday, Monday · 18:00 – 22:00" (ADR-047 terms).
  static String _scheduleLine(RestaurantOfferModel offer) {
    return <String>[
      OfferTerms.discountLabel(offer),
      OfferTerms.daysLabel(offer),
      // Keep the clock range left-to-right inside Arabic text.
      if (offer.hasHourLimit)
        '\u2066${OfferTerms.hoursLabel(offer)}\u2069'
      else
        OfferTerms.hoursLabel(offer),
    ].where((String part) => part.isNotEmpty).join(' · ');
  }
}
