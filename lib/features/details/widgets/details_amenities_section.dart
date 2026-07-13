import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class DetailsAmenitiesSection extends StatelessWidget {
  const DetailsAmenitiesSection({super.key, required this.amenities});

  final List<String> amenities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.amenities, style: AppTextStyles.detailsSectionLabel),
        const SizedBox(height: AppDimensions.regularSpacing),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: amenities.map(_buildAmenityChip).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityChip(String amenity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.compactSpacing),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.detailsAmenityMinHeight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.compactHorizontalPadding,
          vertical: AppDimensions.compactVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(
            AppDimensions.detailsAmenityRadius,
          ),
        ),
        child: Text(amenity, style: AppTextStyles.detailsAmenityText),
      ),
    );
  }
}
