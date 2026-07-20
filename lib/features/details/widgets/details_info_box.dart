import 'package:flutter/material.dart';

import '../../../common/widgets/app_ltr_text.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/opening_hours_day_model.dart';

class DetailsInfoBox extends StatelessWidget {
  const DetailsInfoBox({
    super.key,
    required this.openingHours,
    required this.phone,
  });

  final List<OpeningHoursDayModel> openingHours;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.contentPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.hours, style: AppTextStyles.detailsSectionLabel),
          const SizedBox(height: AppDimensions.regularSpacing),
          ...openingHours.map(
            (day) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.compactSpacing),
              child: Row(
                children: [
                  Expanded(
                    child: Text(day.day, style: AppTextStyles.detailsHoursDay),
                  ),
                  AppLtrText(day.hours, style: AppTextStyles.detailsHoursTime),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          const Divider(
            color: AppColors.border,
            height: AppDimensions.dividerHeight,
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          Text(AppStrings.contact, style: AppTextStyles.detailsSectionLabel),
          const SizedBox(height: AppDimensions.regularSpacing),
          AppLtrText(phone, style: AppTextStyles.detailsContactPhone),
        ],
      ),
    );
  }
}
