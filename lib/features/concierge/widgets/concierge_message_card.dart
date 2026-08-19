import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class ConciergeMessageCard extends StatelessWidget {
  const ConciergeMessageCard({
    super.key,
    required this.message,
    this.isFromCustomer = false,
    this.maxWidth,
    this.compact = false,
  });

  final String message;
  final bool isFromCustomer;
  final double? maxWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final BorderRadiusGeometry radius = BorderRadiusDirectional.only(
      topStart: const Radius.circular(AppDimensions.conciergeBubbleRadius),
      topEnd: const Radius.circular(AppDimensions.conciergeBubbleRadius),
      bottomStart: Radius.circular(
        isFromCustomer
            ? AppDimensions.conciergeBubbleRadius
            : AppDimensions.conciergeBubbleTailRadius,
      ),
      bottomEnd: Radius.circular(
        isFromCustomer
            ? AppDimensions.conciergeBubbleTailRadius
            : AppDimensions.conciergeBubbleRadius,
      ),
    );

    return Align(
      alignment: isFromCustomer
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth:
              maxWidth ??
              MediaQuery.sizeOf(context).width *
                  AppDimensions.conciergeMessageWidthFactor,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isFromCustomer ? AppColors.primary : AppColors.surfaceAlt,
            borderRadius: radius,
            border: isFromCustomer
                ? null
                : Border.all(
                    color: AppColors.border,
                    width: AppDimensions.cardBorderWidth,
                  ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact
                  ? AppDimensions.compactSpacing
                  : AppDimensions.contentPadding,
              vertical: compact
                  ? AppDimensions.compactSpacing
                  : AppDimensions.regularSpacing,
            ),
            child: Text(
              message,
              maxLines: compact ? 3 : null,
              overflow: compact ? TextOverflow.ellipsis : TextOverflow.visible,
              style: AppTextStyles.conciergeMessage.copyWith(
                fontSize: compact
                    ? AppDimensions.onboardingMessagingBubbleFontSize
                    : null,
                color: isFromCustomer
                    ? AppColors.textLight
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
