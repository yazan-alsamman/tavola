import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class ReservationChoiceChip extends StatelessWidget {
  const ReservationChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverableButton(
      child: Material(
        color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
          child: Container(
            height: AppDimensions.reservationChoiceHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.compactHorizontalPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: AppDimensions.cardBorderWidth,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.reservationChoiceLabel.copyWith(
                color: isSelected ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
