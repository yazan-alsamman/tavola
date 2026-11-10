import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../reviews/model/review_model.dart';
import '../../reviews/widgets/review_star_rating.dart';

/// Review CTA / summary embedded in the reservation history card.
class ProfileReservationReviewSection extends StatelessWidget {
  const ProfileReservationReviewSection({
    super.key,
    required this.existingReview,
    required this.onWriteReview,
    required this.onDeleteReview,
    this.onRerateReview,
    this.isBusy = false,
  });

  final ReviewModel? existingReview;
  final VoidCallback onWriteReview;
  final VoidCallback onDeleteReview;

  /// Shown only while the restaurant has the review open for re-rating.
  final VoidCallback? onRerateReview;
  final bool isBusy;

  static List<Widget> _axisRows(ReviewAxesModel axes) {
    final List<(String, ReviewAxisModel)> rows = <(String, ReviewAxisModel)>[
      (AppStrings.reviewAxisService, axes.service),
      (AppStrings.reviewAxisPlace, axes.place),
      (AppStrings.reviewAxisFood, axes.food),
    ];
    return <Widget>[
      for (final (String label, ReviewAxisModel axis) in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.tinySpacing),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.reservationReviewComment,
                ),
              ),
              ReviewStarRating(rating: axis.rating, enabled: false),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ReviewModel? review = existingReview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimensions.regularSpacing),
        Container(
          height: AppDimensions.cardBorderWidth,
          width: double.infinity,
          color: AppColors.primaryDark.withValues(
            alpha: AppDimensions.reservationHistoryBorderAlpha,
          ),
        ),
        const SizedBox(height: AppDimensions.regularSpacing),
        if (review != null) ...[
          Text(
            AppStrings.yourReview.toUpperCase(),
            style: AppTextStyles.reservationReviewEyebrow,
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          if (review.axes == null)
            ReviewStarRating(rating: review.rating, enabled: false)
          else
            ..._axisRows(review.axes!),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.smallSpacing),
            Text(
              review.comment.trim(),
              style: AppTextStyles.reservationReviewComment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (review.openForRerating && onRerateReview != null) ...[
            const SizedBox(height: AppDimensions.regularSpacing),
            Text(
              AppStrings.reviewReopenedNotice,
              style: AppTextStyles.reservationReviewComment,
            ),
            const SizedBox(height: AppDimensions.smallSpacing),
            HoverableButton(
              child: FilledButton.icon(
                onPressed: isBusy ? null : onRerateReview,
                icon: const Icon(
                  Symbols.star,
                  size: AppDimensions.smallIconSize,
                  fill: 1,
                ),
                label: Text(AppStrings.rateAgain),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.textLight,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.smallSpacing),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: HoverableButton(
              child: TextButton.icon(
                onPressed: isBusy ? null : onDeleteReview,
                icon: const Icon(
                  Symbols.delete,
                  size: AppDimensions.smallIconSize,
                ),
                label: Text(
                  AppStrings.removeReview,
                  style: AppTextStyles.reservationReviewAction.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
        ] else ...[
          Text(
            AppStrings.rateYourVisit.toUpperCase(),
            style: AppTextStyles.reservationReviewEyebrow,
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          HoverableButton(
            child: Material(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
              child: InkWell(
                onTap: isBusy ? null : onWriteReview,
                borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.regularSpacing,
                    vertical: AppDimensions.regularSpacing,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.star,
                        size: AppDimensions.mediumIconSize,
                        color: AppColors.textLight,
                        fill: 1,
                      ),
                      const SizedBox(width: AppDimensions.smallSpacing),
                      Expanded(
                        child: Text(
                          AppStrings.writeAReview,
                          style: AppTextStyles.reservationReviewAction.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                      const Icon(
                        Symbols.chevron_right,
                        size: AppDimensions.mediumIconSize,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
