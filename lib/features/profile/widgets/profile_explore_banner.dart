import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfileExploreBanner extends StatelessWidget {
  const ProfileExploreBanner({super.key, required this.onExplorePressed});

  final VoidCallback onExplorePressed;

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: AppColors.primaryDark22,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppDimensions.exploreBannerIconContainerSize,
                  height: AppDimensions.exploreBannerIconContainerSize,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark10,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.exploreBannerIconRadius,
                    ),
                    border: Border.all(
                      color: AppColors.success,
                      width: AppDimensions.cardBorderWidth,
                    ),
                  ),
                  child: const Icon(
                    Symbols.restaurant_menu,
                    color: AppColors.success,
                    size: AppDimensions.exploreBannerIconSize,
                  ),
                ),
                const SizedBox(width: AppDimensions.regularSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.exploreMoreRestaurants,
                        style: AppTextStyles.exploreBannerTitle,
                      ),
                      const SizedBox(height: AppDimensions.smallSpacing),
                      Text(
                        AppStrings.exploreMoreRestaurantsDescription,
                        style: AppTextStyles.exploreBannerBody,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.regularSpacing),
            SizedBox(
              width: double.infinity,
              child: HoverableButton(
                child: ElevatedButton(
                  onPressed: onExplorePressed,
                  style: AppButtonStyles.filledHover(
                    ElevatedButton.styleFrom(
                      textStyle: AppTextStyles.exploreBannerButton,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.buttonHorizontalPadding,
                        vertical: AppDimensions.buttonVerticalPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                      ),
                    ),
                    idleBackground: AppColors.success,
                    idleForeground: AppColors.primaryDark,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.explore,
                        style: AppTextStyles.exploreBannerButton,
                      ),
                      const SizedBox(width: AppDimensions.smallSpacing),
                      const Icon(
                        Symbols.arrow_forward,
                        size: AppDimensions.mediumIconSize,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
