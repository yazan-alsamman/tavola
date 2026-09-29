import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/app_safe_image.dart';
import '../../../core/constants/app_colors.dart';
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
    this.showHeading = true,
  });

  final List<MenuItemModel> menuItems;
  final List<MenuCategoryModel> categories;
  final String? menuTitle;

  /// The Restaurant Menu screen already titles the page. Details keeps the heading.
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final String title = (menuTitle ?? '').trim();
    final List<Widget> children = <Widget>[
      if (showHeading || title.isNotEmpty)
        Text(
          title.isNotEmpty ? title : AppStrings.leMenu,
          style: showHeading
              ? AppTextStyles.detailsMenuTitle
              : AppTextStyles.sectionTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      if (showHeading || title.isNotEmpty)
        const SizedBox(height: AppDimensions.sectionSpacing),
    ];

    if (categories.isNotEmpty) {
      children.addAll(categories.map(_buildCategory));
    } else {
      children.addAll(menuItems.map(_buildItem));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildCategory(MenuCategoryModel category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (category.imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              child: SizedBox(
                height: AppDimensions.detailsMenuCategoryImageHeight,
                width: double.infinity,
                child: AppSafeImage(path: category.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: AppDimensions.regularSpacing),
          ],
          _MenuGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: AppTextStyles.sectionTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category.description.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.tinySpacing),
                    Text(
                      category.description,
                      style: AppTextStyles.detailsMenuItemDescription,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.regularSpacing),
          ...category.items.map(_buildItem),
        ],
      ),
    );
  }

  Widget _buildItem(MenuItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.regularSpacing),
      child: _MenuGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.compactHorizontalPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMenuImage(item),
              const SizedBox(width: AppDimensions.regularSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.isFeatured) ...[
                      const _FeaturedBadge(),
                      const SizedBox(height: AppDimensions.smallSpacing),
                    ],
                    Text(
                      item.name,
                      style: AppTextStyles.detailsMenuItemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        item.description,
                        style: AppTextStyles.detailsMenuItemDescription,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (item.price.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.smallSpacing),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _MenuPriceChip(price: item.price),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuImage(MenuItemModel item) {
    final BorderRadius radius = BorderRadius.circular(
      AppDimensions.detailsAmenityRadius,
    );
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: AppDimensions.detailsMenuItemImageSize,
        height: AppDimensions.detailsMenuItemImageSize,
        child: item.imageUrl.isNotEmpty
            ? AppSafeImage(path: item.imageUrl, fit: BoxFit.cover)
            : DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      AppColors.secondaryLight,
                      AppColors.accent,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Symbols.restaurant,
                    color: AppColors.textLight,
                    size: AppDimensions.mediumIconSize,
                    fill: 1,
                  ),
                ),
              ),
      ),
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.selectedBg,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.compactBadgePaddingHorizontal,
          vertical: AppDimensions.compactBadgePaddingVertical,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Symbols.star,
              size: AppDimensions.smallIconSize,
              color: AppColors.primary,
              fill: 1,
            ),
            const SizedBox(width: AppDimensions.tinySpacing),
            Text(
              AppStrings.menuFeatured,
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuGlassCard extends StatelessWidget {
  const _MenuGlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppDimensions.cardRadius);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.shadowBlur,
          sigmaY: AppDimensions.shadowBlur,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.surface75,
                AppColors.surfaceAlt90,
              ],
            ),
            borderRadius: radius,
            border: Border.all(
              color: AppColors.border,
              width: AppDimensions.cardBorderWidth,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryDark10,
                blurRadius: AppDimensions.shadowBlur,
                offset: Offset(0, AppDimensions.shadowOffsetY),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MenuPriceChip extends StatelessWidget {
  const _MenuPriceChip({required this.price});

  final String price;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.badgePaddingHorizontal,
          vertical: AppDimensions.compactBadgePaddingVertical,
        ),
        child: Text(price, style: AppTextStyles.detailsMenuItemPrice),
      ),
    );
  }
}
