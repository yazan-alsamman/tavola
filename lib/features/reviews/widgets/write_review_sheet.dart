import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import 'review_star_rating.dart';

/// Premium compose sheet → `POST /reviews` (+ optional image upload).
///
/// Keyboard inset is already applied by `Get.bottomSheet` — do not pad again.
class WriteReviewSheet extends StatefulWidget {
  const WriteReviewSheet({
    super.key,
    required this.restaurantName,
    required this.onSubmit,
    required this.onPickImage,
    this.initialRating = 0,
  });

  final String restaurantName;
  final int initialRating;
  final Future<String?> Function() onPickImage;
  final Future<bool> Function({
    required int rating,
    required String comment,
    String? imagePath,
  })
  onSubmit;

  static Future<void> open({
    required String restaurantName,
    required Future<bool> Function({
      required int rating,
      required String comment,
      String? imagePath,
    })
    onSubmit,
    required Future<String?> Function() onPickImage,
    int initialRating = 0,
  }) {
    return Get.bottomSheet<void>(
      WriteReviewSheet(
        restaurantName: restaurantName,
        onSubmit: onSubmit,
        onPickImage: onPickImage,
        initialRating: initialRating,
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      enableDrag: true,
    );
  }

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  String? _imagePath;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating.clamp(0, AppDimensions.reviewMaxRating);
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    if (_rating < AppDimensions.reviewMinRating) {
      Get.snackbar(AppStrings.rateYourVisit, AppStrings.invalidReviewRating);
      return;
    }
    setState(() => _submitting = true);
    final bool ok = await widget.onSubmit(
      rating: _rating,
      comment: _commentController.text,
      imagePath: _imagePath,
    );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (ok) {
      Get.back<void>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.sizeOf(context).height *
        AppDimensions.reservationReviewSheetMaxHeightFactor;

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  AppStrings.writeAReview,
                  style: AppTextStyles.reservationHistoryTitle,
                ),
                const SizedBox(height: AppDimensions.tinySpacing),
                Text(
                  widget.restaurantName,
                  style: AppTextStyles.reservationHistoryMeta,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                Text(
                  AppStrings.selectReviewRating.toUpperCase(),
                  style: AppTextStyles.reservationReviewEyebrow,
                ),
                const SizedBox(height: AppDimensions.smallSpacing),
                ReviewStarRating(
                  rating: _rating,
                  size: AppDimensions.reservationReviewSheetStarSize,
                  onChanged: (int value) => setState(() => _rating = value),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: AppDimensions.reviewCommentMaxLength,
                  textInputAction: TextInputAction.newline,
                  // Avoid ensureVisible yanking the sheet when the keyboard opens.
                  scrollPadding: EdgeInsets.zero,
                  style: AppTextStyles.reservationReviewComment,
                  decoration: InputDecoration(
                    hintText: AppStrings.reviewCommentHint,
                    hintStyle: AppTextStyles.reservationHistoryMeta,
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius,
                      ),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius,
                      ),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primaryDark,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(
                      AppDimensions.regularSpacing,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.regularSpacing),
                Text(
                  AppStrings.reviewPhotoOptional.toUpperCase(),
                  style: AppTextStyles.reservationReviewEyebrow,
                ),
                const SizedBox(height: AppDimensions.smallSpacing),
                Row(
                  children: [
                    if (_imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.smallSpacing,
                        ),
                        child: Image.file(
                          File(_imagePath!),
                          width: AppDimensions.reservationReviewPhotoThumbSize,
                          height: AppDimensions.reservationReviewPhotoThumbSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.smallSpacing),
                      IconButton(
                        onPressed: _submitting
                            ? null
                            : () => setState(() => _imagePath = null),
                        icon: const Icon(Symbols.close),
                      ),
                    ],
                    HoverableButton(
                      child: OutlinedButton.icon(
                        onPressed: _submitting
                            ? null
                            : () async {
                                final String? path = await widget.onPickImage();
                                if (!mounted || path == null) {
                                  return;
                                }
                                setState(() => _imagePath = path);
                              },
                        icon: const Icon(Symbols.add_a_photo),
                        label: Text(AppStrings.addReviewPhoto),
                        style: AppButtonStyles.outlinedHover(
                          OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                SizedBox(
                  width: double.infinity,
                  child: HoverableButton(
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: AppButtonStyles.filledHover(
                        FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.textLight,
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: AppDimensions.smallIconSize,
                              height: AppDimensions.smallIconSize,
                              child: CircularProgressIndicator(
                                strokeWidth: AppDimensions
                                    .progressIndicatorStrokeWidth,
                                color: AppColors.textLight,
                              ),
                            )
                          : Text(AppStrings.submitReview),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
