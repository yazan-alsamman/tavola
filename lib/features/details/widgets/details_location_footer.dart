import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:material_symbols_icons/symbols.dart';

class DetailsLocationFooter extends StatelessWidget {
  const DetailsLocationFooter({super.key, required this.locationNote});

  final String locationNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.contentPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Symbols.location_on,
            color: AppColors.primaryDark,
            size: AppDimensions.detailsLocationIconSize,
          ),
          const SizedBox(width: AppDimensions.regularSpacing),
          Expanded(
            child: Text(locationNote, style: AppTextStyles.detailsLocationNote),
          ),
        ],
      ),
    );
  }
}
