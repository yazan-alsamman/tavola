import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/restaurant_card.dart';
import '../../../common/widgets/search_bar.dart';
import '../../../common/widgets/section_title.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../../core/utils/app_dependency.dart';
import '../controller/home_controller.dart';
import '../model/restaurant_model.dart';
import '../widgets/browse_by_occasion_section.dart';
import '../widgets/home_special_offer_card.dart';
import '../../location/widgets/user_location_status_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _restaurantsSectionKey = GlobalKey();
  bool _isOccasionScrollInFlight = false;
  bool _hasPendingOccasionScroll = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToRestaurantsSection() async {
    if (_isOccasionScrollInFlight) {
      _hasPendingOccasionScroll = true;
      return;
    }

    _isOccasionScrollInFlight = true;
    try {
      do {
        _hasPendingOccasionScroll = false;
        // Wait for filter-driven list relayout before calculating offset.
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) {
          return;
        }
        await _animateToRestaurantsSectionIfNeeded();
      } while (_hasPendingOccasionScroll && mounted);
    } finally {
      _isOccasionScrollInFlight = false;
    }
  }

  Future<void> _animateToRestaurantsSectionIfNeeded() async {
    if (!_scrollController.hasClients) {
      return;
    }
    final BuildContext? context = _restaurantsSectionKey.currentContext;
    if (context == null) {
      return;
    }
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }
    final RenderAbstractViewport? viewport =
        RenderAbstractViewport.maybeOf(renderObject);
    if (viewport == null) {
      return;
    }
    final RevealedOffset reveal = viewport.getOffsetToReveal(renderObject, 0.0);
    final double targetOffset =
        (reveal.offset - AppDimensions.homeOccasionScrollTopInset).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
    final double delta = (targetOffset - _scrollController.offset).abs();
    if (delta < AppDimensions.homeOccasionScrollMinDelta) {
      return;
    }
    await _scrollController.animateTo(
      targetOffset,
      duration: AppDimensions.homeOccasionScrollDuration,
      curve: Curves.easeInOutCubic,
    );
  }

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
              controller: _scrollController,
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
                  HomeSpecialOfferCard(controller: controller),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  KeyedSubtree(
                    key: _restaurantsSectionKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                  ),
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
                      onSelected: (String occasion) {
                        controller.selectOccasion(occasion);
                        _scrollToRestaurantsSection();
                      },
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
