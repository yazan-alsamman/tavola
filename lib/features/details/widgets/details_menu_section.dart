import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/menu_item_model.dart';

class DetailsMenuSection extends StatelessWidget {
  const DetailsMenuSection({super.key, required this.menuItems});

  final List<MenuItemModel> menuItems;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.leMenu, style: AppTextStyles.detailsMenuTitle),
        const SizedBox(height: AppDimensions.regularSpacing),
        ...menuItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.regularSpacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTextStyles.detailsMenuItemName),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        item.description,
                        style: AppTextStyles.detailsMenuItemDescription,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.regularSpacing),
                SizedBox(
                  width: AppDimensions.detailsMenuPriceMinWidth,
                  child: Text(
                    item.price,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.detailsMenuItemPrice,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
