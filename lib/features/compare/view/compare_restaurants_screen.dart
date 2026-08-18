import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/circle_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/compare_controller.dart';
import '../widgets/compare_cards_entrance.dart';
import '../widgets/compare_frosted_shell.dart';
import '../widgets/compare_restaurant_card.dart';
import '../widgets/compare_restaurant_selector.dart';

class CompareRestaurantsScreen extends GetView<CompareController> {
  const CompareRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.secondaryLight,
              AppColors.scaffold,
              AppColors.surfaceAlt,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppDimensions.smallSpacing,
                  AppDimensions.tinySpacing,
                  AppDimensions.pagePadding,
                  0,
                ),
                child: Row(
                  children: [
                    CircleBackButton(onPressed: controller.goBack),
                    const SizedBox(width: AppDimensions.smallSpacing),
                    Expanded(
                      child: Text(
                        AppStrings.compareRestaurants,
                        style: AppTextStyles.compareTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final bool loadingCatalog = controller.isLoadingCatalog.value;
                  final bool comparing = controller.isComparing.value;
                  final String? catalogError = controller.catalogError.value;
                  final String? compareError = controller.compareError.value;

                  return RefreshIndicator(
                    onRefresh: () async {
                      await controller.loadCatalog(forceRefresh: true);
                      if (controller.hasBothSides) {
                        await controller.refreshComparison();
                      }
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(AppDimensions.pagePadding),
                      children: [
                        Text(
                          AppStrings.compareRestaurantsSubtitle,
                          style: AppTextStyles.compareSubtitle,
                        ),
                        const SizedBox(height: AppDimensions.regularSpacing),
                        // Visual order: Restaurant A on the right, B on the left.
                        Row(
                          textDirection: TextDirection.rtl,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CompareRestaurantSelector(
                                label: AppStrings.compareSideAShort,
                                restaurant: controller.restaurantA.value,
                                isLoading: controller.isLoadingSideA.value,
                                onTap: () =>
                                    controller.openPicker(CompareSide.a),
                                onClear: controller.restaurantA.value == null
                                    ? null
                                    : () => controller.clearSide(CompareSide.a),
                              ),
                            ),
                            const SizedBox(
                              width: AppDimensions.compareColumnGap,
                            ),
                            Expanded(
                              child: CompareRestaurantSelector(
                                label: AppStrings.compareSideBShort,
                                restaurant: controller.restaurantB.value,
                                isLoading: controller.isLoadingSideB.value,
                                onTap: () =>
                                    controller.openPicker(CompareSide.b),
                                onClear: controller.restaurantB.value == null
                                    ? null
                                    : () => controller.clearSide(CompareSide.b),
                              ),
                            ),
                          ],
                        ),
                        // Fixed-height progress slot — avoids remounting cards
                        // when loading toggles (which replayed the entrance).
                        SizedBox(
                          height:
                              AppDimensions.regularSpacing +
                              AppDimensions.progressIndicatorStrokeWidth,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Opacity(
                              opacity: (loadingCatalog || comparing) ? 1 : 0,
                              child: const LinearProgressIndicator(
                                minHeight:
                                    AppDimensions.progressIndicatorStrokeWidth,
                              ),
                            ),
                          ),
                        ),
                        if (catalogError != null &&
                            controller.catalog.isEmpty) ...[
                          const SizedBox(height: AppDimensions.regularSpacing),
                          CompareFrostedShell(
                            padding: const EdgeInsets.all(
                              AppDimensions.regularSpacing,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  catalogError,
                                  style: AppTextStyles.compareError,
                                ),
                                TextButton(
                                  onPressed: () => controller.loadCatalog(
                                    forceRefresh: true,
                                  ),
                                  child: Text(AppStrings.retry),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppDimensions.sectionSpacing),
                        if (!controller.hasBothSides)
                          CompareFrostedShell(
                            padding: const EdgeInsets.all(
                              AppDimensions.sectionSpacing,
                            ),
                            child: Text(
                              AppStrings.compareSelectBothPrompt,
                              style: AppTextStyles.compareSubtitle,
                              textAlign: TextAlign.center,
                            ),
                          )
                        else ...[
                          Builder(
                            builder: (BuildContext context) {
                              final String pairKey =
                                  '${controller.restaurantA.value?.id ?? ''}_'
                                  '${controller.restaurantB.value?.id ?? ''}';
                              return CompareCardsEntrance(
                                key: ValueKey<String>(
                                  'compare-entrance-$pairKey',
                                ),
                                animationKey: pairKey,
                                cardA: CompareRestaurantCard(
                                  sideLabel: AppStrings.compareSideA,
                                  snapshot: controller.snapshotA,
                                  isLoading: controller.isLoadingSideA.value,
                                  error: controller.sideAError.value,
                                  onRetry: () =>
                                      controller.retrySide(CompareSide.a),
                                  onViewDetails: () =>
                                      controller.openDetails(CompareSide.a),
                                ),
                                cardB: CompareRestaurantCard(
                                  sideLabel: AppStrings.compareSideB,
                                  snapshot: controller.snapshotB,
                                  isLoading: controller.isLoadingSideB.value,
                                  error: controller.sideBError.value,
                                  onRetry: () =>
                                      controller.retrySide(CompareSide.b),
                                  onViewDetails: () =>
                                      controller.openDetails(CompareSide.b),
                                ),
                              );
                            },
                          ),
                          if (compareError != null) ...[
                            const SizedBox(
                              height: AppDimensions.regularSpacing,
                            ),
                            CompareFrostedShell(
                              padding: const EdgeInsets.all(
                                AppDimensions.regularSpacing,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    compareError,
                                    style: AppTextStyles.compareError,
                                  ),
                                  TextButton(
                                    onPressed: controller.refreshComparison,
                                    child: Text(AppStrings.retry),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                        SizedBox(
                          height:
                              MediaQuery.paddingOf(context).bottom +
                              AppDimensions.pagePadding,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
