import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../reviews/model/review_model.dart';
import '../model/reservation_history_item_model.dart';
import 'profile_reservation_history_card.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfileReservationHistoryPanel extends StatelessWidget {
  const ProfileReservationHistoryPanel({
    super.key,
    required this.items,
    required this.reviewForReservation,
    required this.onWriteReview,
    required this.onDeleteReview,
    this.isReviewBusy = false,
  });

  final List<ReservationHistoryItemModel> items;
  final ReviewModel? Function(String reservationId) reviewForReservation;
  final void Function(ReservationHistoryItemModel item) onWriteReview;
  final void Function(ReservationHistoryItemModel item) onDeleteReview;
  final bool isReviewBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.regularSpacing),
          child: Row(
            children: [
              Container(
                width:
                    AppDimensions.settingsIconSize + AppDimensions.smallSpacing,
                height:
                    AppDimensions.settingsIconSize + AppDimensions.smallSpacing,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(
                    alpha: AppDimensions.reservationHistoryHeaderIconFillAlpha,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.exploreBannerIconRadius,
                  ),
                ),
                child: const Icon(
                  Symbols.history,
                  color: AppColors.primaryDark,
                  size: AppDimensions.settingsIconSize,
                ),
              ),
              const SizedBox(width: AppDimensions.regularSpacing),
              Expanded(
                child: Text(
                  AppStrings.reservationHistory,
                  style: AppTextStyles.settingsHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        ...items.map(
          (ReservationHistoryItemModel item) => ProfileReservationHistoryCard(
            item: item,
            existingReview: reviewForReservation(item.reservationId),
            onWriteReview: () => onWriteReview(item),
            onDeleteReview: () => onDeleteReview(item),
            isReviewBusy: isReviewBusy,
          ),
        ),
      ],
    );
  }
}
