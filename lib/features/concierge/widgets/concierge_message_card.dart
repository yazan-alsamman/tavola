import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class ConciergeMessageCard extends StatelessWidget {
  const ConciergeMessageCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: AppDimensions.conciergeMessageWidthFactor,
      child: HoverableCard(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.contentPadding),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: AppColors.border,
              width: AppDimensions.cardBorderWidth,
            ),
          ),
          child: Text(message, style: AppTextStyles.conciergeMessage),
        ),
      ),
    );
  }
}
