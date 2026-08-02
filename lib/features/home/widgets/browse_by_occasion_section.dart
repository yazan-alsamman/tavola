import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../taxonomy/model/occasion_category_model.dart';
import 'package:material_symbols_icons/symbols.dart';

class BrowseByOccasionSection extends StatelessWidget {
  const BrowseByOccasionSection({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<OccasionCategoryModel> categories;
  final String? selectedCategory;
  final ValueChanged<String> onSelected;

  /// Maps icons to `GET /occasion-categories` slugs exactly.
  static IconData _iconFor(OccasionCategoryModel category) {
    switch (category.slug.trim().toLowerCase()) {
      case OccasionCategoryModel.slugDateNight:
        return Symbols.favorite;
      case OccasionCategoryModel.slugBusinessLunch:
        return Symbols.business_center;
      case OccasionCategoryModel.slugFamily:
        return Symbols.family_restroom;
      case OccasionCategoryModel.slugBirthday:
        return Symbols.cake;
      case OccasionCategoryModel.slugGroupGathering:
        return Symbols.group;
      case OccasionCategoryModel.slugCasual:
        return Symbols.restaurant;
      case OccasionCategoryModel.slugFineDining:
        return Symbols.dinner_dining;
      default:
        return Symbols.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.browseByOccasion, style: AppTextStyles.occasionTitle),
        const SizedBox(height: AppDimensions.regularSpacing),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnCount =
                constraints.maxWidth >= AppDimensions.occasionWideBreakpoint
                ? AppDimensions.occasionWideGridColumnCount
                : AppDimensions.occasionGridColumnCount;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                crossAxisSpacing: AppDimensions.occasionGridSpacing,
                mainAxisSpacing: AppDimensions.occasionGridSpacing,
                childAspectRatio: AppDimensions.occasionGridAspectRatio,
              ),
              itemBuilder: (context, index) {
                final OccasionCategoryModel category = categories[index];
                final bool isSelected = selectedCategory == category.name;

                return HoverableCard(
                  borderRadius: AppDimensions.occasionCardRadius,
                  child: Material(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.occasionCardRadius,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onSelected(category.name),
                      child: Container(
                        padding: const EdgeInsets.all(
                          AppDimensions.contentPadding,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.occasionCardRadius,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.accent,
                            width: isSelected
                                ? AppDimensions.occasionSelectedBorderWidth
                                : AppDimensions.cardBorderWidth,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: AppDimensions.occasionIconContainerSize,
                              height: AppDimensions.occasionIconContainerSize,
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconFor(category),
                                color: AppColors.primary,
                                size: AppDimensions.occasionIconSize,
                              ),
                            ),
                            const SizedBox(
                              height: AppDimensions.regularSpacing,
                            ),
                            Text(
                              AppStrings.localizeUiLabel(
                                category.name,
                                alternate: category.slug,
                              ),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.occasionLabel,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
