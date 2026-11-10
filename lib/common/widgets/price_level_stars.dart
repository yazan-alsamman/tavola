import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';

/// A branch's price level (1–4, backend ADR-046) as filled stars.
/// Renders nothing when the branch has no level yet.
class PriceLevelStars extends StatelessWidget {
  const PriceLevelStars({
    super.key,
    required this.level,
    this.size = AppDimensions.priceLevelStarSize,
    this.filledColor = AppColors.primaryDark,
    this.emptyColor = AppColors.border,
  });

  final int? level;
  final double size;
  final Color filledColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    final int? value = level;
    if (value == null || value < 1) {
      return const SizedBox.shrink();
    }
    final int clamped = value.clamp(1, AppDimensions.priceLevelMax);
    return Semantics(
      label: AppStrings.priceLevelOutOf(clamped),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(AppDimensions.priceLevelMax, (int i) {
          final bool filled = i < clamped;
          return Icon(
            Symbols.star,
            fill: filled ? 1 : 0,
            size: size,
            color: filled ? filledColor : emptyColor,
          );
        }),
      ),
    );
  }
}
