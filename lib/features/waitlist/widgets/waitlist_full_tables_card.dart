import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';

/// Simple customer panel when the floor has no available tables.
class WaitlistFullTablesCard extends StatelessWidget {
  const WaitlistFullTablesCard({
    super.key,
    required this.isJoined,
    required this.isBusy,
    required this.onJoin,
    required this.onCancel,
  });

  final bool isJoined;
  final bool isBusy;
  final VoidCallback onJoin;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Symbols.hourglass_top,
                  color: AppColors.primaryDark,
                  size: AppDimensions.mediumIconSize,
                ),
                const SizedBox(width: AppDimensions.regularSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.waitlistTablesFullTitle,
                        style: AppTextStyles.settingsItemTitle,
                      ),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        isJoined
                            ? AppStrings.waitlistJoinedBody
                            : AppStrings.waitlistTablesFullBody,
                        style: AppTextStyles.settingsItemBody,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.regularSpacing),
            HoverableButton(
              child: ElevatedButton(
                onPressed: isBusy ? null : (isJoined ? onCancel : onJoin),
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
                  idleForeground: AppColors.textLight,
                ),
                child: isBusy
                    ? const SizedBox(
                        width: AppDimensions.mediumIconSize,
                        height: AppDimensions.mediumIconSize,
                        child: CircularProgressIndicator(
                          strokeWidth:
                              AppDimensions.progressIndicatorStrokeWidth,
                          color: AppColors.textLight,
                        ),
                      )
                    : Text(
                        isJoined
                            ? AppStrings.waitlistCancel
                            : AppStrings.waitlistJoin,
                        style: AppTextStyles.confirmReservationButton.copyWith(
                          color: AppColors.textLight,
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
