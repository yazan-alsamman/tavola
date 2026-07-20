import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/favorite_cuisines_controller.dart';

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
                      Icons.restaurant_menu_rounded,
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
                    child: SingleChildScrollView(
                      child: Obx(() {
                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppDimensions.favoriteCuisinesChipSpacing,
                          runSpacing:
                              AppDimensions.favoriteCuisinesChipSpacing,
                          children: AppStrings.favoriteCuisineOptions.map((
                            String cuisine,
                          ) {
                            final bool selected =
                                controller.isSelected(cuisine);
                            return GestureDetector(
                              onTap: () => controller.toggleCuisine(cuisine),
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
                                  cuisine,
                                  style:
                                      AppTextStyles.favoriteCuisineChip
                                          .copyWith(
                                    color: selected
                                        ? AppColors.textLight
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),
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
