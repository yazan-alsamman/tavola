import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/favorite_cuisines_controller.dart';
import 'package:material_symbols_icons/symbols.dart';

class FavoriteCuisinesScreen extends StatelessWidget {
  const FavoriteCuisinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoriteCuisinesController controller =
        Get.find<FavoriteCuisinesController>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.favoriteCuisinesMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.pagePadding),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: AppDimensions.favoriteCuisinesIconCircleSize,
                    height: AppDimensions.favoriteCuisinesIconCircleSize,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Symbols.restaurant_menu,
                      size: AppDimensions.favoriteCuisinesIconSize,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  Text(
                    AppStrings.favoriteCuisinesTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.favoriteCuisinesTitle,
                  ),
                  const SizedBox(height: AppDimensions.regularSpacing),
                  Text(
                    AppStrings.favoriteCuisinesSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.favoriteCuisinesSubtitle,
                  ),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  Expanded(
                    flex: 8,
                    child: Obx(() {
                      if (controller.isLoadingCuisineCategories.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final String? error =
                          controller.cuisineCategoriesError.value;
                      if (error != null) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                error,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.favoriteCuisinesSubtitle,
                              ),
                              const SizedBox(
                                height: AppDimensions.regularSpacing,
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
                          ),
                        );
                      }

                      if (controller.cuisineOptions.isEmpty) {
                        return Center(
                          child: Text(
                            AppStrings.cuisineCategoriesEmpty,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.favoriteCuisinesSubtitle,
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppDimensions.favoriteCuisinesChipSpacing,
                          runSpacing: AppDimensions.favoriteCuisinesChipSpacing,
                          children: controller.cuisineOptions.map((cuisine) {
                            final String name = cuisine.name;
                            final bool selected = controller.isSelected(name);
                            return GestureDetector(
                              onTap: () => controller.toggleCuisine(name),
                              child: AnimatedContainer(
                                duration: AppDimensions.hoverDuration,
                                curve: Curves.easeOutCubic,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions
                                      .favoriteCuisinesChipHorizontalPadding,
                                  vertical: AppDimensions
                                      .favoriteCuisinesChipVerticalPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryDark
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.pillRadius,
                                  ),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primaryDark
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  AppStrings.localizeUiLabel(
                                    name,
                                    alternate: cuisine.slug,
                                  ),
                                  style: AppTextStyles.favoriteCuisineChip
                                      .copyWith(
                                        color: selected
                                            ? AppColors.textLight
                                            : AppColors.textPrimary,
                                      ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  Obx(() {
                    final bool hasSelection = controller.hasSelection;
                    return SizedBox(
                      width: double.infinity,
                      child: HoverableButton(
                        child: ElevatedButton(
                          onPressed: hasSelection
                              ? controller.confirm
                              : controller.skipForNow,
                          style: AppButtonStyles.filledHover(
                            ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: AppColors.textLight,
                              textStyle: AppTextStyles.favoriteCuisinesSkip,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.buttonVerticalPadding,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.pillRadius,
                                ),
                              ),
                            ),
                            idleBackground: AppColors.primaryDark,
                          ),
                          child: Text(
                            hasSelection
                                ? AppStrings.favoriteCuisinesConfirm
                                : AppStrings.favoriteCuisinesSkip,
                            style: AppTextStyles.favoriteCuisinesSkip,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppDimensions.smallSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
