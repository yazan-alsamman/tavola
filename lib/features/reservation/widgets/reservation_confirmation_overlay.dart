import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../model/reservation_confirmation_model.dart';
import 'torn_paper_clipper.dart';

class ReservationConfirmationOverlay extends StatelessWidget {
  const ReservationConfirmationOverlay({
    super.key,
    required this.confirmation,
    required this.onDismiss,
  });

  final ReservationConfirmationModel confirmation;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: AppColors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppDimensions.confirmationOverlayBlurSigma,
                sigmaY: AppDimensions.confirmationOverlayBlurSigma,
              ),
              child: const ColoredBox(
                color: AppColors.primaryDark22,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePadding,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.confirmationCardMaxWidth,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.primaryDark10,
                          blurRadius: AppDimensions.shadowBlur,
                          offset: Offset(0, AppDimensions.shadowOffsetY),
                        ),
                      ],
                    ),
                    child: ClipPath(
                      clipper: const TornPaperClipper(),
                      child: ColoredBox(
                        color: AppColors.surface,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ConfirmationHeader(
                              referenceCode: confirmation.referenceCode,
                            ),
                            _ConfirmationDetails(
                              confirmation: confirmation,
                              onDismiss: onDismiss,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationHeader extends StatelessWidget {
  const _ConfirmationHeader({required this.referenceCode});

  final String referenceCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimensions.confirmationHeaderHeight,
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.contentPadding,
        vertical: AppDimensions.sectionSpacing,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppDimensions.confirmationIconContainerSize,
            height: AppDimensions.confirmationIconContainerSize,
            decoration: const BoxDecoration(
              color: AppColors.textLight90,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primaryDark,
              size: AppDimensions.confirmationIconSize,
            ),
          ),
          const SizedBox(height: AppDimensions.regularSpacing),
          const Text(
            AppStrings.confirmed,
            style: AppTextStyles.confirmationTitle,
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          Text(
            '${AppStrings.referencePrefix}$referenceCode',
            style: AppTextStyles.confirmationReference,
          ),
        ],
      ),
    );
  }
}

class _ConfirmationDetails extends StatelessWidget {
  const _ConfirmationDetails({
    required this.confirmation,
    required this.onDismiss,
  });

  final ReservationConfirmationModel confirmation;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.contentPadding,
        AppDimensions.sectionSpacing,
        AppDimensions.contentPadding,
        AppDimensions.confirmationBottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ConfirmationDetailRow(
            label: AppStrings.confirmationRestaurant,
            value: confirmation.restaurantName,
          ),
          const _ConfirmationDivider(),
          _ConfirmationDetailRow(
            label: AppStrings.confirmationGuests,
            value: confirmation.guestsLabel,
          ),
          const _ConfirmationDivider(),
          _ConfirmationDetailRow(
            label: AppStrings.confirmationDate,
            value: confirmation.dateLabel,
          ),
          const _ConfirmationDivider(),
          _ConfirmationDetailRow(
            label: AppStrings.confirmationTable,
            value: confirmation.tableLabel,
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          SizedBox(
            width: double.infinity,
            child: HoverableButton(
              child: ElevatedButton(
                onPressed: onDismiss,
                style: AppButtonStyles.filledHover(
                  ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.textLight,
                    textStyle: AppTextStyles.confirmReservationButton,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.buttonVerticalPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius,
                      ),
                    ),
                  ),
                  idleBackground: AppColors.primaryDark,
                ),
                child: const Text(AppStrings.dismiss),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationDetailRow extends StatelessWidget {
  const _ConfirmationDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.regularSpacing,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: AppDimensions.confirmationLabelFlex,
            child: Text(
              label,
              style: AppTextStyles.confirmationDetailLabel,
            ),
          ),
          const SizedBox(width: AppDimensions.smallSpacing),
          Expanded(
            flex: AppDimensions.confirmationValueFlex,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.confirmationDetailValue,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationDivider extends StatelessWidget {
  const _ConfirmationDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: AppDimensions.dividerHeight,
      thickness: AppDimensions.dividerHeight,
      color: AppColors.border,
    );
  }
}
