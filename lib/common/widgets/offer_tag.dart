import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

/// Small pill marking an offer: beside a restaurant name, on a booking, or
/// on the booking screen when the customer books from an offer.
class OfferTag extends StatelessWidget {
  const OfferTag({super.key, required this.label, this.onDark = false});

  final String label;

  /// Light-on-dark variant for hero images.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final Color foreground = onDark
        ? AppColors.primaryDark
        : AppColors.textLight;
    final Color background = onDark ? AppColors.accent : AppColors.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.smallSpacing,
        vertical: AppDimensions.tinySpacing,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.local_offer,
            size: AppDimensions.smallIconSize,
            color: foreground,
            fill: 1,
          ),
          const SizedBox(width: AppDimensions.tinySpacing),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
