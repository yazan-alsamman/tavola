import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/app_safe_image.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/compare_restaurant_snapshot.dart';
import 'compare_frosted_shell.dart';

/// Compact frosted compare card — small clipped image + feature list.
class CompareRestaurantCard extends StatelessWidget {
  const CompareRestaurantCard({
    super.key,
    required this.sideLabel,
    required this.snapshot,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.onViewDetails,
  });

  final String sideLabel;
  final CompareRestaurantSnapshot? snapshot;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final CompareRestaurantSnapshot? data = snapshot;

    return CompareFrostedShell(
      padding: const EdgeInsets.all(AppDimensions.compareCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full-width side label — was truncated to "R..." beside ACTIVE chip.
          Text(
            sideLabel,
            style: AppTextStyles.compareEyebrow,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RestaurantThumb(imageUrl: data?.imageUrl ?? ''),
              const SizedBox(width: AppDimensions.regularSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data != null && data.statusLabel.isNotEmpty) ...[
                      _StatusChip(label: data.statusLabel),
                      const SizedBox(height: AppDimensions.compactSpacing),
                    ],
                    Text(
                      data?.name ?? AppStrings.compareWaitingSelection,
                      style: AppTextStyles.compareCardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data != null && data.ratingLabel.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.compactSpacing),
                      Text(
                        '${AppStrings.starSymbol} ${data.ratingLabel}',
                        style: AppTextStyles.compareCardMeta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (isLoading) ...[
            const SizedBox(height: AppDimensions.regularSpacing),
            const LinearProgressIndicator(
              minHeight: AppDimensions.progressIndicatorStrokeWidth,
            ),
          ],
          if (error != null && error!.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.regularSpacing),
            Text(error!, style: AppTextStyles.compareError, maxLines: 3),
            if (onRetry != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(AppStrings.retry),
                ),
              ),
          ],
          if (data != null) ...[
            const SizedBox(height: AppDimensions.regularSpacing),
            Container(
              height: AppDimensions.cardBorderWidth,
              color: AppColors.primaryDark.withValues(
                alpha: AppDimensions.reservationHistoryBorderAlpha,
              ),
            ),
            const SizedBox(height: AppDimensions.regularSpacing),
            ..._featureRows(data).map(
              (_FeatureSpec feature) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.compareFeatureRowSpacing,
                ),
                child: _FeatureRow(feature: feature),
              ),
            ),
            if (onViewDetails != null) ...[
              const SizedBox(height: AppDimensions.smallSpacing),
              Container(
                height: AppDimensions.cardBorderWidth,
                color: AppColors.primaryDark.withValues(
                  alpha: AppDimensions.reservationHistoryBorderAlpha,
                ),
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              _ViewDetailsButton(onPressed: onViewDetails!),
            ],
          ],
        ],
      ),
    );
  }

  List<_FeatureSpec> _featureRows(CompareRestaurantSnapshot data) {
    final List<_FeatureSpec> rows = <_FeatureSpec>[];
    void add(IconData icon, String label, String value) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) {
        return;
      }
      rows.add(_FeatureSpec(icon: icon, label: label, value: trimmed));
    }

    add(Symbols.restaurant, AppStrings.compareFieldCuisine, data.cuisineLabel);
    add(
      Symbols.payments,
      AppStrings.compareFieldPriceLevel,
      data.priceLevelLabel,
    );
    add(Symbols.menu_book, AppStrings.compareFieldHasMenu, data.hasMenuLabel);
    add(
      Symbols.local_offer,
      AppStrings.compareFieldActiveOffer,
      data.activeOfferLabel,
    );
    add(
      Symbols.celebration,
      AppStrings.compareFieldOccasion,
      data.occasionLabel,
    );
    add(
      Symbols.location_on,
      AppStrings.compareFieldLocation,
      data.locationLabel,
    );
    add(Symbols.schedule, AppStrings.compareFieldHours, data.hoursLabel);
    add(Symbols.spa, AppStrings.compareFieldAmenities, data.amenitiesLabel);
    add(Symbols.notes, AppStrings.compareFieldAbout, data.aboutLabel);
    return rows;
  }
}

class _FeatureSpec {
  const _FeatureSpec({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _RestaurantThumb extends StatelessWidget {
  const _RestaurantThumb({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.compareCardImageSize,
      height: AppDimensions.compareCardImageSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppDimensions.compareCardImageRadius,
        ),
        border: Border.all(
          color: AppColors.primaryDark.withValues(
            alpha: AppDimensions.reservationHistoryBorderAlpha,
          ),
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.trim().isEmpty
          ? const ColoredBox(
              color: AppColors.accent,
              child: Icon(
                Symbols.restaurant,
                color: AppColors.primaryDark,
                size: AppDimensions.mediumIconSize,
              ),
            )
          : AppSafeImage(
              path: imageUrl,
              fit: BoxFit.cover,
              width: AppDimensions.compareCardImageSize,
              height: AppDimensions.compareCardImageSize,
              fallbackIcon: Symbols.restaurant,
              fallbackIconSize: AppDimensions.mediumIconSize,
              backgroundColor: AppColors.accent,
              iconColor: AppColors.primaryDark,
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.smallSpacing,
        vertical: AppDimensions.compactSpacing,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(
          alpha: AppDimensions.reservationHistoryStatusFillAlpha,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.compareStatusChip,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});

  final _FeatureSpec feature;

  @override
  Widget build(BuildContext context) {
    final bool isAbout = feature.label == AppStrings.compareFieldAbout;

    return Row(
      crossAxisAlignment: isAbout
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(
          feature.icon,
          size: AppDimensions.compareFeatureIconSize,
          color: AppColors.primaryDark,
        ),
        const SizedBox(width: AppDimensions.smallSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.label.toUpperCase(),
                style: AppTextStyles.compareFeatureLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.tinySpacing),
              Text(
                feature.value,
                style: AppTextStyles.compareFeatureValue,
                maxLines: isAbout ? AppDimensions.compareAboutMaxLines : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ViewDetailsButton extends StatelessWidget {
  const _ViewDetailsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return HoverableButton(
      child: Material(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.regularSpacing,
              vertical: AppDimensions.regularSpacing,
            ),
            child: Row(
              children: [
                const Icon(
                  Symbols.storefront,
                  size: AppDimensions.mediumIconSize,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: AppDimensions.smallSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.viewDetailsViewLine,
                        style: AppTextStyles.compareViewDetailsAction,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        AppStrings.details,
                        style: AppTextStyles.compareViewDetailsAction,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Symbols.chevron_right,
                  size: AppDimensions.mediumIconSize,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
