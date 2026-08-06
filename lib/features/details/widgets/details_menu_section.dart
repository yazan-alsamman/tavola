import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/menu_category_model.dart';
import '../model/menu_item_model.dart';

class DetailsMenuSection extends StatelessWidget {
  const DetailsMenuSection({
    super.key,
    required this.menuItems,
    this.categories = const <MenuCategoryModel>[],
    this.menuTitle,
  });

  final List<MenuItemModel> menuItems;
  final List<MenuCategoryModel> categories;
  final String? menuTitle;

  @override
  Widget build(BuildContext context) {
    final String title = (menuTitle ?? '').trim().isNotEmpty
        ? menuTitle!.trim()
        : AppStrings.leMenu;

    if (categories.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.detailsMenuTitle),
          const SizedBox(height: AppDimensions.regularSpacing),
          ...categories.map(_buildCategory),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.detailsMenuTitle),
        const SizedBox(height: AppDimensions.regularSpacing),
        ...menuItems.map(_buildItem),
      ],
    );
  }

  Widget _buildCategory(MenuCategoryModel category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.name, style: AppTextStyles.sectionTitle),
          if (category.description.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.tinySpacing),
            Text(
              category.description,
              style: AppTextStyles.detailsMenuItemDescription,
            ),
          ],
          const SizedBox(height: AppDimensions.regularSpacing),
          ...category.items.map(_buildItem),
        ],
      ),
    );
  }

  Widget _buildItem(MenuItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.regularSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.detailsMenuItemName),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.tinySpacing),
                  Text(
                    item.description,
                    style: AppTextStyles.detailsMenuItemDescription,
                  ),
                ],
              ],
            ),
          ),
          if (item.price.isNotEmpty) ...[
            const SizedBox(width: AppDimensions.regularSpacing),
            SizedBox(
              width: AppDimensions.detailsMenuPriceMinWidth,
              child: Text(
                item.price,
                textAlign: TextAlign.end,
                style: AppTextStyles.detailsMenuItemPrice,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
