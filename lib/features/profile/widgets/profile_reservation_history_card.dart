import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../common/widgets/app_safe_image.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/reservation_history_item_model.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Premium frosted history card — accent-led glass veiled with primaryDark.
class ProfileReservationHistoryCard extends StatelessWidget {
  const ProfileReservationHistoryCard({super.key, required this.item});

  final ReservationHistoryItemModel item;

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.regularSpacing),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(
                alpha: AppDimensions.reservationHistoryCardElevationOpacity,
              ),
              blurRadius: AppDimensions.reservationHistoryCardElevationBlur,
              offset: const Offset(
                0,
                AppDimensions.reservationHistoryCardElevationY,
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        AppColors.secondaryLight,
                        AppColors.accent,
                        AppColors.secondary,
                        AppColors.accent,
                      ],
                      stops: [0.0, 0.35, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: -AppDimensions.reservationHistoryOrbSize * 0.45,
                end: -AppDimensions.reservationHistoryOrbSize * 0.28,
                child: const _BlurOrb(
                  size: AppDimensions.reservationHistoryOrbSize * 1.2,
                  color: AppColors.accent,
                  alpha: AppDimensions.reservationHistoryAccentOrbAlpha,
                ),
              ),
              PositionedDirectional(
                bottom: -AppDimensions.reservationHistoryOrbSize * 0.5,
                start: -AppDimensions.reservationHistoryOrbSize * 0.35,
                child: const _BlurOrb(
                  size: AppDimensions.reservationHistoryOrbSize,
                  color: AppColors.primaryDark,
                  alpha: AppDimensions.reservationHistoryPrimaryOrbAlpha,
                ),
              ),
              PositionedDirectional(
                top: AppDimensions.contentPadding,
                start: AppDimensions.reservationHistoryOrbSize * 0.55,
                child: const _BlurOrb(
                  size: AppDimensions.reservationHistoryOrbSize * 0.55,
                  color: AppColors.surface,
                  alpha: AppDimensions.reservationHistorySoftOrbAlpha,
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppDimensions.reservationHistoryCardBlurSigma,
                  sigmaY: AppDimensions.reservationHistoryCardBlurSigma,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.contentPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        AppColors.surface.withValues(
                          alpha:
                              AppDimensions.reservationHistoryGlassSurfaceAlpha,
                        ),
                        AppColors.accent.withValues(
                          alpha:
                              AppDimensions.reservationHistoryGlassAccentAlpha,
                        ),
                        AppColors.primaryDark.withValues(
                          alpha:
                              AppDimensions.reservationHistoryGlassPrimaryAlpha,
                        ),
                      ],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                    border: Border.all(
                      color: AppColors.primaryDark.withValues(
                        alpha: AppDimensions.reservationHistoryBorderAlpha,
                      ),
                      width: AppDimensions.cardBorderWidth,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RestaurantThumbnail(imageUrl: item.imageUrl),
                      const SizedBox(width: AppDimensions.regularSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.restaurantName,
                                    style:
                                        AppTextStyles.reservationHistoryTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  width: AppDimensions.smallSpacing,
                                ),
                                _StatusChip(
                                  label: item.status.trim().isNotEmpty
                                      ? item.status
                                      : AppStrings.reservationHistoryCompleted,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: AppDimensions.regularSpacing,
                            ),
                            Container(
                              height: AppDimensions.cardBorderWidth,
                              width: double.infinity,
                              color: AppColors.primaryDark.withValues(
                                alpha:
                                    AppDimensions.reservationHistoryBorderAlpha,
                              ),
                            ),
                            const SizedBox(
                              height: AppDimensions.regularSpacing,
                            ),
                            _MetaRow(
                              icon: Symbols.calendar_today,
                              label: item.date,
                            ),
                            const SizedBox(
                              height: AppDimensions.compactSpacing,
                            ),
                            _MetaRow(icon: Symbols.schedule, label: item.time),
                            const SizedBox(
                              height: AppDimensions.compactSpacing,
                            ),
                            _MetaRow(
                              icon: Symbols.group,
                              label:
                                  '${AppStrings.guests}${AppStrings.restaurantSummarySeparator}${item.guests}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantThumbnail extends StatelessWidget {
  const _RestaurantThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.reservationHistoryImageSize,
      height: AppDimensions.reservationHistoryImageSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppDimensions.reservationHistoryImageRadius,
        ),
        border: Border.all(
          color: AppColors.primaryDark.withValues(
            alpha: AppDimensions.reservationHistoryBorderAlpha,
          ),
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: AppDimensions.shadowOpacity,
            ),
            blurRadius: AppDimensions.smallSpacing,
            offset: const Offset(0, AppDimensions.tinySpacing),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
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
              width: AppDimensions.reservationHistoryImageSize,
              height: AppDimensions.reservationHistoryImageSize,
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
        vertical: AppDimensions.tinySpacing,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(
          alpha: AppDimensions.reservationHistoryStatusFillAlpha,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.reservationHistoryStatus,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.reservationHistoryMetaIconSize,
          color: AppColors.primaryDark,
        ),
        const SizedBox(width: AppDimensions.compactSpacing),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.reservationHistoryMeta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    required this.size,
    required this.color,
    required this.alpha,
  });

  final double size;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: AppDimensions.reservationHistoryCardBlurSigma,
        sigmaY: AppDimensions.reservationHistoryCardBlurSigma,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: alpha),
        ),
      ),
    );
  }
}
