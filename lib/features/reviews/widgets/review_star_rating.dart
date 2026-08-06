import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Compact interactive / read-only star row for review rating (1–5).
class ReviewStarRating extends StatelessWidget {
  const ReviewStarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = AppDimensions.reservationReviewStarSize,
    this.enabled = true,
  });

  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(AppDimensions.reviewMaxRating, (int index) {
        final int value = index + 1;
        final bool filled = value <= rating;
        final Widget star = Icon(
          filled ? Symbols.star : Symbols.star,
          fill: filled ? 1 : 0,
          size: size,
          color: filled ? AppColors.primaryDark : AppColors.border,
        );
        if (!enabled || onChanged == null) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(
              end: AppDimensions.tinySpacing,
            ),
            child: star,
          );
        }
        return Padding(
          padding: const EdgeInsetsDirectional.only(
            end: AppDimensions.tinySpacing,
          ),
          child: InkWell(
            onTap: () => onChanged!(value),
            customBorder: const CircleBorder(),
            child: star,
          ),
        );
      }),
    );
  }
}
