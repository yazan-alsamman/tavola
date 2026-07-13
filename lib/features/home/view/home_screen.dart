import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../common/widgets/restaurant_card.dart';
import '../../../common/widgets/search_bar.dart';
import '../../../common/widgets/section_title.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/home_controller.dart';
import '../widgets/browse_by_occasion_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _filterButton(String label, bool isSelected) {
    return HoverableButton(
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.compactHorizontalPadding,
            vertical: AppDimensions.compactVerticalPadding,
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: AppDimensions.compactSpacing),
                    const Text(
                      AppStrings.nearbyLocation,
                      style: AppTextStyles.locationLabel,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.smallSpacing),
                const CustomSearchBar(hintText: AppStrings.searchHint),
                const SizedBox(height: AppDimensions.sectionSpacing),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(
                    () => Row(
                      children: List.generate(
                        controller.restaurantFilters.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            right:
                                index == controller.restaurantFilters.length - 1
                                ? 0
                                : AppDimensions.smallSpacing,
                          ),
                          child: _filterButton(
                            controller.restaurantFilters[index],
                            controller.selectedFilterIndex.value == index,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                HoverableCard(
                  child: SizedBox(
                    height: AppDimensions.promoHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(AppImages.r5, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColors.primaryDark75,
                                  AppColors.primaryDark22,
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.contentPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppStrings.specialOffer,
                                  style: AppTextStyles.promoTitle,
                                ),
                                const SizedBox(
                                  height: AppDimensions.smallSpacing,
                                ),
                                const Text(
                                  AppStrings.specialOfferDescription,
                                  style: AppTextStyles.promoBody,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                SizedBox(
                                  height: AppDimensions.iconButtonSize,
                                  child: HoverableButton(
                                    child: ElevatedButton(
                                      onPressed: controller.openReservation,
                                      style: AppButtonStyles.filledHover(
                                        ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                AppDimensions.contentPadding,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppDimensions.pillRadius,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: const Text(AppStrings.bookNow),
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
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                const SectionTitle(title: AppStrings.restaurantsNearYou),
                const SizedBox(height: AppDimensions.smallSpacing),
                Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = controller.restaurants[index];
                      return RestaurantCard(
                        restaurant: restaurant,
                        isFavorite: controller.isFavorite(restaurant.id),
                        onFavoritePressed: () =>
                            controller.toggleFavorite(restaurant.id),
                        onTap: () => controller.openDetails(restaurant),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                Obx(
                  () => BrowseByOccasionSection(
                    categories: controller.occasionCategories,
                    selectedCategory: controller.selectedOccasion.value,
                    onSelected: controller.selectOccasion,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: HomeController.homeNavigationIndex,
        onTap: controller.handleBottomNavigation,
      ),
    );
  }
}
