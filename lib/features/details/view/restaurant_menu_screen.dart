import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/circle_back_button.dart';
import '../../../common/widgets/tavola_refresh.dart';
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
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              AppStrings.menu,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.detailsMenuTitle,
                            ),
                            if (controller.restaurant.name.trim().isNotEmpty)
                              Text(
                                controller.restaurant.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.compactRestaurantTitle
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.circleBackButtonSize),
                    ],
                  ),
                ),
                Expanded(child: _buildBody(controller)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(RestaurantMenuController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
        ),
      );
    }

    final String? error = controller.error;
    if (error != null && controller.menuItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error, style: AppTextStyles.body, textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.regularSpacing),
            TextButton(
              onPressed: controller.retry,
              child: Text(AppStrings.retry),
            ),
          ],
        ),
      );
    }

    return TavolaRefresh(
      onRefresh: controller.reloadMenu,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: DetailsMenuSection(
          menuItems: controller.menuItems,
          categories: controller.categories,
          menuTitle: controller.menu?.name,
          showHeading: false,
        ),
      ),
    );
  }
}
