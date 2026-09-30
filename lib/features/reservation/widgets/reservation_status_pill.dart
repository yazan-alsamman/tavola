import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Static capsule for a reservation status that already has a display color.
///
/// Width follows the label. There is no ring, spinner, or repeating motion.
class ReservationStatusPill extends StatelessWidget {
  const ReservationStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.textStyle,
  });

  final String label;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: AppDimensions.reservationStatusPillFillAlpha,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        border: Border.all(
          color: color.withValues(
            alpha: AppDimensions.reservationStatusPillBorderAlpha,
          ),
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.regularSpacing,
          vertical: AppDimensions.compactSpacing,
        ),
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          style: (textStyle ?? AppTextStyles.body).copyWith(color: color),
        ),
      ),
    );
  }
}
