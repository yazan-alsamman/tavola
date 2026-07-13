import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/image_source.dart';
import '../../home/model/restaurant_model.dart';

class ProfileReservationCard extends StatelessWidget {
  const ProfileReservationCard({
    super.key,
    required this.restaurant,
    required this.details,
  });

  final RestaurantModel restaurant;
  final List<(String, String)> details;

  static const List<IconData> _detailIcons = [
    Icons.calendar_today,
    Icons.access_time,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      child: Container(
        height: AppDimensions.reservationCardHeight,
        margin: const EdgeInsets.only(bottom: AppDimensions.sectionSpacing),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: AppColors.border,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: AppDimensions.reservationImageWidth,
              height: double.infinity,
              child: restaurant.imageUrl.isNetworkImage
                  ? Image.network(restaurant.imageUrl, fit: BoxFit.cover)
                  : Image.asset(restaurant.imageUrl, fit: BoxFit.cover),
            ),
            Expanded(
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppDimensions.contentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      restaurant.name,
                      style: AppTextStyles.reservationTitle,
                    ),
                    const SizedBox(height: AppDimensions.regularSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        details.length,
                        (index) => _ReservationInfoItem(
                          icon: _detailIcons[index],
                          label: details[index].$1,
                          value: details[index].$2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationInfoItem extends StatelessWidget {
  const _ReservationInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: AppDimensions.mediumIconSize,
        ),
        const SizedBox(height: AppDimensions.compactSpacing),
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppDimensions.tinySpacing),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
