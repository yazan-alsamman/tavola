import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/circle_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/restaurant_menu_controller.dart';
import '../widgets/details_menu_section.dart';

class RestaurantMenuScreen extends StatelessWidget {
  const RestaurantMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantMenuController>(
      id: RestaurantMenuController.menuUpdateId,
      builder: (RestaurantMenuController controller) {
        return Scaffold(
          backgroundColor: AppColors.scaffold,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppDimensions.pagePadding,
                    AppDimensions.smallSpacing,
                    AppDimensions.pagePadding,
                    AppDimensions.smallSpacing,
                  ),
                  child: Row(
                    children: [
                      CircleBackButton(onPressed: controller.goBack),
                      const SizedBox(width: AppDimensions.smallSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.menu,
                              style: AppTextStyles.detailsMenuTitle,
                            ),
                            Text(
                              controller.restaurant.name,
                              style: AppTextStyles.compactRestaurantTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: AppDimensions.dividerHeight,
                  color: AppColors.border,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.pagePadding),
                    child: DetailsMenuSection(menuItems: controller.menuItems),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
