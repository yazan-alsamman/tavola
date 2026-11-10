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
import '../model/review_model.dart';
import 'review_star_rating.dart';

/// What the guest submits from [WriteReviewSheet].
class ReviewDraft {
  const ReviewDraft({
    required this.axes,
    required this.comment,
    required this.privateNote,
    this.imagePath,
  });

  final ReviewAxesModel axes;
  final String comment;
  final String privateNote;
  final String? imagePath;
}

/// Compose sheet → `POST /reviews` (+ optional image upload), or
/// `PUT /reviews/:id` when the restaurant reopened the review.
///
/// The guest rates service, place and food separately (backend ADR-045),
/// each with an optional comment, plus an overall comment and a private
/// note only the restaurant sees.
///
/// Keyboard inset is already applied by `Get.bottomSheet` — do not pad again.
class WriteReviewSheet extends StatefulWidget {
  const WriteReviewSheet({
    super.key,
    required this.restaurantName,
    required this.onSubmit,
    required this.onPickImage,
    this.initialReview,
    this.isRerate = false,
  });

  final String restaurantName;

  /// Pre-fills the form when rating again.
  final ReviewModel? initialReview;

  /// Re-rating keeps the review's photos, so the photo picker is hidden.
  final bool isRerate;
  final Future<String?> Function() onPickImage;
  final Future<bool> Function(ReviewDraft draft) onSubmit;

  static Future<void> open({
    required String restaurantName,
    required Future<bool> Function(ReviewDraft draft) onSubmit,
    required Future<String?> Function() onPickImage,
    ReviewModel? initialReview,
    bool isRerate = false,
  }) {
    return Get.bottomSheet<void>(
      WriteReviewSheet(
        restaurantName: restaurantName,
        onSubmit: onSubmit,
        onPickImage: onPickImage,
        initialReview: initialReview,
        isRerate: isRerate,
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      enableDrag: true,
    );
  }

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _AxisDraft {
  _AxisDraft(this.label, ReviewAxisModel? initial)
    : rating = initial?.rating ?? 0,
      comment = TextEditingController(text: initial?.comment ?? '');

  final String label;
  int rating;
  final TextEditingController comment;

  ReviewAxisModel toModel() =>
      ReviewAxisModel(rating: rating, comment: comment.text);
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  late final _AxisDraft _service;
  late final _AxisDraft _place;
  late final _AxisDraft _food;
  late final TextEditingController _commentController;
  late final TextEditingController _privateNoteController;
  String? _imagePath;
  bool _submitting = false;

  List<_AxisDraft> get _axes => <_AxisDraft>[_service, _place, _food];

  @override
  void initState() {
    super.initState();
    final ReviewModel? initial = widget.initialReview;
    final ReviewAxesModel? axes = initial?.axes;
    // A single-rating review being rated again starts every axis at its stars.
    final ReviewAxisModel? fallback =
        initial != null && axes == null && initial.rating > 0
        ? ReviewAxisModel(rating: initial.rating)
        : null;
    _service = _AxisDraft(
      AppStrings.reviewAxisService,
      axes?.service ?? fallback,
    );
    _place = _AxisDraft(AppStrings.reviewAxisPlace, axes?.place ?? fallback);
    _food = _AxisDraft(AppStrings.reviewAxisFood, axes?.food ?? fallback);
    _commentController = TextEditingController(text: initial?.comment ?? '');
    _privateNoteController = TextEditingController();
  }

  @override
  void dispose() {
    for (final _AxisDraft axis in _axes) {
      axis.comment.dispose();
    }
    _commentController.dispose();
    _privateNoteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    if (_axes.any(
      (_AxisDraft axis) => axis.rating < AppDimensions.reviewMinRating,
    )) {
      Get.snackbar(AppStrings.rateYourVisit, AppStrings.reviewAxesHint);
      return;
    }
    setState(() => _submitting = true);
    final bool ok = await widget.onSubmit(
      ReviewDraft(
        axes: ReviewAxesModel(
          service: _service.toModel(),
          place: _place.toModel(),
          food: _food.toModel(),
        ),
        comment: _commentController.text,
        privateNote: _privateNoteController.text,
        imagePath: _imagePath,
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (ok) {
      Get.back<void>();
    }
  }

  static InputDecoration _decoration(String hint) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.reservationHistoryMeta,
      filled: true,
      fillColor: AppColors.surfaceAlt,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primaryDark),
      ),
      contentPadding: const EdgeInsets.all(AppDimensions.regularSpacing),
    );
  }

  Widget _buildAxis(_AxisDraft axis) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.regularSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  axis.label,
                  style: AppTextStyles.reservationHistoryTitle,
                ),
              ),
              ReviewStarRating(
                rating: axis.rating,
                size: AppDimensions.reviewAxisStarSize,
                onChanged: _submitting
                    ? null
                    : (int value) => setState(() => axis.rating = value),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          TextField(
            controller: axis.comment,
            enabled: !_submitting,
            maxLines: 2,
            minLines: 1,
            maxLength: AppDimensions.reviewAxisCommentMaxLength,
            buildCounter: _hideCounter,
            textInputAction: TextInputAction.newline,
            scrollPadding: EdgeInsets.zero,
            style: AppTextStyles.reservationReviewComment,
            decoration: _decoration(AppStrings.reviewAxisCommentHint),
          ),
        ],
      ),
    );
  }

  static Widget? _hideCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) => null;

  @override
  Widget build(BuildContext context) {
    final double maxHeight =
        MediaQuery.sizeOf(context).height *
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
                  widget.isRerate
                      ? AppStrings.rateAgain
                      : AppStrings.writeAReview,
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
                  AppStrings.reviewAxesHint.toUpperCase(),
                  style: AppTextStyles.reservationReviewEyebrow,
                ),
                const SizedBox(height: AppDimensions.regularSpacing),
                ..._axes.map(_buildAxis),
                const SizedBox(height: AppDimensions.smallSpacing),
                TextField(
                  controller: _commentController,
                  enabled: !_submitting,
                  maxLines: 4,
                  maxLength: AppDimensions.reviewCommentMaxLength,
                  textInputAction: TextInputAction.newline,
                  // Avoid ensureVisible yanking the sheet when the keyboard opens.
                  scrollPadding: EdgeInsets.zero,
                  style: AppTextStyles.reservationReviewComment,
                  decoration: _decoration(AppStrings.reviewCommentHint),
                ),
                const SizedBox(height: AppDimensions.regularSpacing),
                Text(
                  AppStrings.reviewPrivateNote.toUpperCase(),
                  style: AppTextStyles.reservationReviewEyebrow,
                ),
                const SizedBox(height: AppDimensions.smallSpacing),
                TextField(
                  controller: _privateNoteController,
                  enabled: !_submitting,
                  maxLines: 3,
                  minLines: 2,
                  maxLength: AppDimensions.reviewPrivateNoteMaxLength,
                  buildCounter: _hideCounter,
                  textInputAction: TextInputAction.newline,
                  scrollPadding: EdgeInsets.zero,
                  style: AppTextStyles.reservationReviewComment,
                  decoration: _decoration(AppStrings.reviewPrivateNoteHint),
                ),
                if (!widget.isRerate) ...[
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
                            width:
                                AppDimensions.reservationReviewPhotoThumbSize,
                            height:
                                AppDimensions.reservationReviewPhotoThumbSize,
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
                                  final String? path = await widget
                                      .onPickImage();
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
                              side: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                                strokeWidth:
                                    AppDimensions.progressIndicatorStrokeWidth,
                                color: AppColors.textLight,
                              ),
                            )
                          : Text(
                              widget.isRerate
                                  ? AppStrings.rateAgain
                                  : AppStrings.submitReview,
                            ),
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
