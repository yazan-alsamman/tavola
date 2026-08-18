import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/app_safe_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/media_url_resolver.dart';
import '../../reviews/model/review_model.dart';
import '../../reviews/widgets/review_star_rating.dart';
import '../controller/details_controller.dart';

class DetailsReviewsSection extends StatelessWidget {
  const DetailsReviewsSection({super.key, required this.controller});

  final DetailsController controller;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailsController>(
      id: DetailsController.reviewsUpdateId,
      builder: (DetailsController c) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.restaurantReviews,
              style: AppTextStyles.detailsSectionLabel,
            ),
            const SizedBox(height: AppDimensions.regularSpacing),
            if (c.isLoadingReviews && c.reviews.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.sectionSpacing,
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
                  ),
                ),
              )
            else if (c.reviewsError != null && c.reviews.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    c.reviewsError!,
                    style: AppTextStyles.selectRestaurantSubtitle,
                  ),
                  const SizedBox(height: AppDimensions.smallSpacing),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: c.retryReviews,
                      child: Text(
                        AppStrings.retry,
                        style: AppTextStyles.authLinkEmphasis,
                      ),
                    ),
                  ),
                ],
              )
            else if (c.reviews.isEmpty)
              Text(
                AppStrings.restaurantReviewsEmpty,
                style: AppTextStyles.selectRestaurantSubtitle,
              )
            else ...[
              ...c.reviews.map(
                (ReviewModel review) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.smallSpacing,
                  ),
                  child: _ReviewCard(
                    review: review,
                    excerpt: c.reviewCommentExcerpt(review.comment),
                    dateLabel: c.formatReviewDate(review.createdAt),
                    onTap: () => c.openReviewDetail(review.reviewId),
                  ),
                ),
              ),
              if (c.hasMoreReviews)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: c.isLoadingMoreReviews
                        ? null
                        : c.loadMoreReviews,
                    child: c.isLoadingMoreReviews
                        ? const SizedBox(
                            width: AppDimensions.mediumIconSize,
                            height: AppDimensions.mediumIconSize,
                            child: CircularProgressIndicator(
                              strokeWidth:
                                  AppDimensions.progressIndicatorStrokeWidth,
                            ),
                          )
                        : Text(
                            AppStrings.restaurantReviewsLoadMore,
                            style: AppTextStyles.authLinkEmphasis,
                          ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.excerpt,
    required this.dateLabel,
    required this.onTap,
  });

  final ReviewModel review;
  final String excerpt;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.regularSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ReviewStarRating(
                    rating: review.rating,
                    size: AppDimensions.reservationReviewStarSize,
                    enabled: false,
                  ),
                  const Spacer(),
                  if (dateLabel.isNotEmpty)
                    Text(
                      dateLabel,
                      style: AppTextStyles.reservationHistoryMeta,
                    ),
                ],
              ),
              if (excerpt.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.smallSpacing),
                Text(
                  excerpt,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.detailsAboutBody,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet body for a single public review.
class DetailsReviewDetailSheet extends StatelessWidget {
  const DetailsReviewDetailSheet({super.key, required this.review});

  final ReviewModel review;

  static Future<void> show(ReviewModel review) {
    return Get.bottomSheet<void>(
      DetailsReviewDetailSheet(review: review),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight =
        MediaQuery.sizeOf(context).height *
        AppDimensions.reservationReviewSheetMaxHeightFactor;
    final DetailsController? details = Get.isRegistered<DetailsController>()
        ? Get.find<DetailsController>()
        : null;
    final String dateLabel =
        details?.formatReviewDate(review.createdAt) ?? '';

    return SafeArea(
      child: Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.cardRadius),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: AppDimensions.bottomSheetGrabberWidth,
                    height: AppDimensions.bottomSheetGrabberHeight,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.pillRadius,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.regularSpacing),
                Text(
                  AppStrings.viewReviewDetails,
                  style: AppTextStyles.reservationHistoryTitle,
                ),
                const SizedBox(height: AppDimensions.smallSpacing),
                ReviewStarRating(
                  rating: review.rating,
                  size: AppDimensions.reservationReviewSheetStarSize,
                  enabled: false,
                ),
                if (dateLabel.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.smallSpacing),
                  Text(
                    dateLabel,
                    style: AppTextStyles.reservationHistoryMeta,
                  ),
                ],
                if (review.comment.trim().isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  Text(
                    review.comment.trim(),
                    style: AppTextStyles.detailsAboutBody,
                  ),
                ],
                if (review.images.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  Wrap(
                    spacing: AppDimensions.smallSpacing,
                    runSpacing: AppDimensions.smallSpacing,
                    children: review.images.map((ReviewImageModel image) {
                      final String url = MediaUrlResolver.resolve(image.url);
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                        child: AppSafeImage(
                          path: url,
                          width: AppDimensions.detailsReviewImageSize,
                          height: AppDimensions.detailsReviewImageSize,
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
