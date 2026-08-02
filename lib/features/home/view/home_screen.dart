import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/app_safe_image.dart';
import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../common/widgets/restaurant_card.dart';
import '../../../common/widgets/search_bar.dart';
import '../../../common/widgets/section_title.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/utils/app_dependency.dart';
import '../controller/home_controller.dart';
import '../home_assets.dart';
import '../model/restaurant_model.dart';
import '../widgets/browse_by_occasion_section.dart';
import '../../location/widgets/user_location_status_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _filterButton(
    String label, {
    required bool isSelected,
    String? alternate,
  }) {
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
            AppStrings.localizeUiLabel(label, alternate: alternate),
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
    // Prefer a controller already warmed by GuestTransition / Splash prep.
    // Fallback ensure covers authenticated Splash→Home and deep links.
    final HomeController controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : AppDependency.ensureHomeController();
    final LocaleController localeController = Get.find<LocaleController>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppDimensions.headerHeight),
        child: Obx(() {
          // Rebuild AppBar only when profile (Stage 4) or badge (Stage 7) land.
          controller.shellProfileReady.value;
          controller.shellNotificationsReady.value;
          return const CustomAppBar();
        }),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Obx(() {
            // Rebuild localized labels only — not on every progressive band.
            localeController.languageCode.value;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    // Location chrome appears when Stage 8 registers the stack.
                    controller.shellLocationReady.value;
                    return const UserLocationStatusBar();
                  }),
                  const SizedBox(height: AppDimensions.smallSpacing),
                  CustomSearchBar(
                    controller: controller.searchController,
                    hintText: AppStrings.searchHint,
                    onChanged: controller.updateSearch,
                  ),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  Obx(() {
                    if (controller.isLoadingCuisineCategories.value) {
                      return const SizedBox(
                        height: AppDimensions.iconButtonSize,
                        child: Center(
                          child: SizedBox(
                            width: AppDimensions.occasionIconSize,
                            height: AppDimensions.occasionIconSize,
                            child: CircularProgressIndicator(
                              strokeWidth:
                                  AppDimensions.progressIndicatorStrokeWidth,
                            ),
                          ),
                        ),
                      );
                    }

                    final String? cuisineError =
                        controller.cuisineCategoriesError.value;
                    if (cuisineError != null) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              cuisineError,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: controller.loadCuisineCategories,
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

                    if (controller.cuisineCategories.isEmpty ||
                        controller.restaurantFilters.isEmpty) {
                      return Text(
                        AppStrings.cuisineCategoriesEmpty,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      );
                    }

                    final int filterCount = controller.restaurantFilters.length;
                    final int cuisineCount =
                        controller.cuisineCategories.length;
                    // Filters are "All" + cuisine names — never index past cuisines.
                    final int safeCount = filterCount <= cuisineCount + 1
                        ? filterCount
                        : cuisineCount + 1;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          safeCount,
                          (index) => Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: index == safeCount - 1
                                  ? 0
                                  : AppDimensions.smallSpacing,
                            ),
                            child: GestureDetector(
                              onTap: () => controller.selectFilter(index),
                              child: _filterButton(
                                controller.restaurantFilters[index],
                                isSelected:
                                    controller.selectedFilterIndex.value ==
                                    index,
                                alternate:
                                    index == 0 || index - 1 >= cuisineCount
                                    ? null
                                    : controller
                                          .cuisineCategories[index - 1]
                                          .slug,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
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
                            AppSafeImage(
                              path: AppImages.r5,
                              provider: HomeAssets.promoProvider,
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
                              padding: const EdgeInsets.all(
                                AppDimensions.contentPadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.specialOffer,
                                    style: AppTextStyles.promoTitle,
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.smallSpacing,
                                  ),
                                  Flexible(
                                    child: Text(
                                      AppStrings.specialOfferDescription,
                                      style: AppTextStyles.promoBody,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.smallSpacing,
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: SizedBox(
                                      height: AppDimensions.iconButtonSize,
                                      child: HoverableButton(
                                        child: ElevatedButton(
                                          onPressed: controller.openReservation,
                                          style: AppButtonStyles.filledHover(
                                            ElevatedButton.styleFrom(
                                              textStyle: AppTextStyles
                                                  .restaurantCardActionButton,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: AppDimensions
                                                        .contentPadding,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppDimensions.pillRadius,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            AppStrings.bookNow,
                                            style: AppTextStyles
                                                .restaurantCardActionButton,
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
                  ),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  SectionTitle(title: AppStrings.restaurantsNearYou),
                  const SizedBox(height: AppDimensions.smallSpacing),
                  Obx(() {
                    if (controller.isLoadingRestaurants.value) {
                      return const SizedBox(
                        height: AppDimensions.imageHeight,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth:
                                AppDimensions.progressIndicatorStrokeWidth,
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
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textSecondary,
                              ),
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

                    // Required: ListView.builder itemBuilder is not tracked by Obx.
                    controller.watchFavorites();
                    controller.searchQuery.value;
                    controller.selectedFilterIndex.value;
                    controller.selectedOccasion.value;

                    final List<RestaurantModel> visibleRestaurants =
                        controller.filteredRestaurants;

                    if (visibleRestaurants.isEmpty) {
                      return Text(
                        AppStrings.restaurantsEmpty,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visibleRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = visibleRestaurants[index];
                        return RestaurantCard(
                          restaurant: restaurant,
                          isFavorite: controller.isFavorite(restaurant.id),
                          onFavoritePressed: () =>
                              controller.toggleFavorite(restaurant.id),
                          onTap: () => controller.openDetails(restaurant),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  Obx(() {
                    if (controller.isLoadingOccasionCategories.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.browseByOccasion,
                            style: AppTextStyles.occasionTitle,
                          ),
                          const SizedBox(height: AppDimensions.regularSpacing),
                          const SizedBox(
                            height: AppDimensions.iconButtonSize,
                            child: Center(
                              child: SizedBox(
                                width: AppDimensions.occasionIconSize,
                                height: AppDimensions.occasionIconSize,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppDimensions
                                      .progressIndicatorStrokeWidth,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final String? occasionError =
                        controller.occasionCategoriesError.value;
                    if (occasionError != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.browseByOccasion,
                            style: AppTextStyles.occasionTitle,
                          ),
                          const SizedBox(height: AppDimensions.regularSpacing),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  occasionError,
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: controller.loadOccasionCategories,
                                style: TextButton.styleFrom(
                                  textStyle: AppTextStyles.authLinkEmphasis,
                                ),
                                child: Text(
                                  AppStrings.retry,
                                  style: AppTextStyles.authLinkEmphasis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    if (controller.occasionCategories.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.browseByOccasion,
                            style: AppTextStyles.occasionTitle,
                          ),
                          const SizedBox(height: AppDimensions.regularSpacing),
                          Text(
                            AppStrings.occasionCategoriesEmpty,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    }

                    return BrowseByOccasionSection(
                      categories: controller.occasionCategoryItems.toList(),
                      selectedCategory: controller.selectedOccasion.value,
                      onSelected: controller.selectOccasion,
                    );
                  }),
                ],
              ),
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
