import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/circle_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../details/controller/details_controller.dart';
import '../controller/occasion_restaurants_controller.dart';
import '../model/restaurant_model.dart';
import '../widgets/occasion_restaurant_card.dart';
import 'package:material_symbols_icons/symbols.dart';

class OccasionRestaurantsScreen extends StatelessWidget {
  const OccasionRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OccasionRestaurantsController controller =
        Get.find<OccasionRestaurantsController>();
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OccasionHeader(title: controller.title, onBack: Get.back),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.restaurants.isEmpty) {
                  return const _OccasionRestaurantSkeletonGrid();
                }
                final String? error = controller.errorMessage.value;
                if (error != null && controller.restaurants.isEmpty) {
                  return _OccasionMessage(
                    icon: Symbols.error,
                    title: controller.title,
                    message: error,
                    actionLabel: AppStrings.retry,
                    onAction: controller.load,
                  );
                }
                if (controller.restaurants.isEmpty) {
                  return _OccasionMessage(
                    icon: Symbols.restaurant,
                    title: controller.title,
                    message: AppStrings.restaurantsEmpty,
                    actionLabel: AppStrings.retry,
                    onAction: controller.load,
                  );
                }
                return _OccasionRestaurantGrid(
                  restaurants: controller.restaurants.toList(growable: false),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class OccasionRestaurantsTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final double t = Curves.easeOutCubic.transform(
      animation.value.clamp(0.0, 1.0),
    );
    final double scale =
        AppDimensions.occasionRestaurantsEnterScale +
        ((1 - AppDimensions.occasionRestaurantsEnterScale) * t);
    return Opacity(
      opacity: t,
      child: Transform.scale(scale: scale, child: child),
    );
  }
}

class _OccasionHeader extends StatelessWidget {
  const _OccasionHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppDimensions.pagePadding,
        AppDimensions.smallSpacing,
        AppDimensions.pagePadding,
        AppDimensions.smallSpacing,
      ),
      child: Row(
        children: [
          CircleBackButton(onPressed: onBack),
          const SizedBox(width: AppDimensions.regularSpacing),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.occasionTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _OccasionRestaurantGrid extends StatelessWidget {
  const _OccasionRestaurantGrid({required this.restaurants});

  final List<RestaurantModel> restaurants;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns =
            constraints.maxWidth >= AppDimensions.occasionWideBreakpoint
            ? AppDimensions.occasionWideGridColumnCount
            : AppDimensions.occasionGridColumnCount;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePadding,
            AppDimensions.smallSpacing,
            AppDimensions.pagePadding,
            AppDimensions.sectionSpacing,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppDimensions.occasionGridSpacing,
            mainAxisSpacing: AppDimensions.occasionGridSpacing,
            childAspectRatio: AppDimensions.occasionRestaurantGridAspectRatio,
          ),
          itemCount: restaurants.length,
          itemBuilder: (BuildContext context, int index) {
            final RestaurantModel restaurant = restaurants[index];
            return OccasionRestaurantEntrance(
              index: index,
              child: OccasionRestaurantCard(
                restaurant: restaurant,
                onTap: () => DetailsController.open(restaurant),
              ),
            );
          },
        );
      },
    );
  }
}

class _OccasionRestaurantSkeletonGrid extends StatelessWidget {
  const _OccasionRestaurantSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns =
            constraints.maxWidth >= AppDimensions.occasionWideBreakpoint
            ? AppDimensions.occasionWideGridColumnCount
            : AppDimensions.occasionGridColumnCount;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePadding,
            AppDimensions.smallSpacing,
            AppDimensions.pagePadding,
            AppDimensions.sectionSpacing,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppDimensions.occasionGridSpacing,
            mainAxisSpacing: AppDimensions.occasionGridSpacing,
            childAspectRatio: AppDimensions.occasionRestaurantGridAspectRatio,
          ),
          itemCount: AppDimensions.occasionRestaurantSkeletonCount,
          itemBuilder: (BuildContext context, int index) {
            return const _OccasionRestaurantSkeleton();
          },
        );
      },
    );
  }
}

class _OccasionRestaurantSkeleton extends StatelessWidget {
  const _OccasionRestaurantSkeleton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.cardRadius),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(AppDimensions.regularSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(widthFactor: 0.72),
                SizedBox(height: AppDimensions.smallSpacing),
                _SkeletonLine(widthFactor: 0.46),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: AlignmentDirectional.centerStart,
      child: const SizedBox(
        height: AppDimensions.smallSpacing,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.pillRadius),
            ),
          ),
        ),
      ),
    );
  }
}

class _OccasionMessage extends StatelessWidget {
  const _OccasionMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: AppDimensions.occasionIconContainerSize,
          ),
          const SizedBox(height: AppDimensions.regularSpacing),
          if (title.isNotEmpty)
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.occasionTitle,
            ),
          const SizedBox(height: AppDimensions.smallSpacing),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.regularSpacing),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              textStyle: AppTextStyles.authLinkEmphasis,
            ),
            child: Text(actionLabel, style: AppTextStyles.authLinkEmphasis),
          ),
        ],
      ),
    );
  }
}
