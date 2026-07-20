import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class BrowseByOccasionSection extends StatelessWidget {
  const BrowseByOccasionSection({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onSelected;

  static const List<IconData> _icons = [
    Icons.cake_rounded,
    Icons.favorite_rounded,
    Icons.business_center_rounded,
    Icons.groups_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.browseByOccasion,
          style: AppTextStyles.occasionTitle,
        ),
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
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return HoverableCard(
                  borderRadius: AppDimensions.occasionCardRadius,
                  child: Material(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.occasionCardRadius,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onSelected(category),
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
                                _icons[index],
                                color: AppColors.primary,
                                size: AppDimensions.occasionIconSize,
                              ),
                            ),
                            const SizedBox(
                              height: AppDimensions.regularSpacing,
                            ),
                            Text(
                              category,
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
