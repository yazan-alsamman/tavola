import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class DetailsAboutSection extends StatelessWidget {
  const DetailsAboutSection({super.key, required this.about});

  final String about;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.aboutRestaurant, style: AppTextStyles.detailsSectionLabel),
        const SizedBox(height: AppDimensions.regularSpacing),
        Text(about, style: AppTextStyles.detailsAboutBody),
      ],
    );
  }
}
