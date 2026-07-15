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
    this.showBottomMargin = true,
    this.compact = false,
  });

  final RestaurantModel restaurant;
  final List<(String, String)> details;
  final bool showBottomMargin;
  final bool compact;

  static const List<IconData> _detailIcons = [
    Icons.calendar_today,
    Icons.access_time,
    Icons.person,
  ];

  double get _cardHeight => compact
      ? AppDimensions.onboardingReservationCardHeight
      : AppDimensions.reservationCardHeight;

  double get _imageWidth => compact
      ? AppDimensions.onboardingReservationImageWidth
      : AppDimensions.reservationImageWidth;

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      child: Container(
        height: _cardHeight,
        margin: showBottomMargin
            ? const EdgeInsets.only(bottom: AppDimensions.sectionSpacing)
            : EdgeInsets.zero,
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
              width: _imageWidth,
              height: double.infinity,
              child: restaurant.imageUrl.isNetworkImage
                  ? Image.network(restaurant.imageUrl, fit: BoxFit.cover)
                  : Image.asset(restaurant.imageUrl, fit: BoxFit.cover),
            ),
            Expanded(
              child: Container(
                color: AppColors.surface,
                padding: EdgeInsets.all(
                  compact
                      ? AppDimensions.compactSpacing
                      : AppDimensions.contentPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.reservationTitle,
                    ),
                    SizedBox(
                      height: compact
                          ? AppDimensions.compactSpacing
                          : AppDimensions.regularSpacing,
                    ),
                    Row(
                      children: List.generate(
                        details.length,
                        (index) => Expanded(
                          child: _ReservationInfoItem(
                            icon: _detailIcons[index],
                            label: details[index].$1,
                            value: details[index].$2,
                            compact: compact,
                          ),
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
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: compact
              ? AppDimensions.smallIconSize
              : AppDimensions.mediumIconSize,
        ),
        SizedBox(
          height: compact
              ? AppDimensions.tinySpacing
              : AppDimensions.compactSpacing,
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.label,
        ),
        const SizedBox(height: AppDimensions.tinySpacing),
        Text(
          value,
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: compact ? 12 : null,
          ),
        ),
      ],
    );
  }
}
