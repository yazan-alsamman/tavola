import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/theme/app_button_styles.dart';
import 'hoverable_button.dart';

/// Branded Yes/No confirmation dialog aligned with Tavola visual identity.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.icon = Symbols.help,
  });

  final String title;
  final String? message;
  final IconData icon;

  /// Returns `true` only when the user taps Yes.
  static Future<bool> show({
    required String title,
    String? message,
    IconData icon = Symbols.help,
  }) async {
    final bool? confirmed = await Get.dialog<bool>(
      AppConfirmDialog(title: title, message: message, icon: icon),
      barrierDismissible: true,
      barrierColor: AppColors.primaryDark.withValues(
        alpha: AppDimensions.confirmDialogBarrierAlpha,
      ),
    );
    return confirmed == true;
  }

  static Future<bool> confirmCancelReservation() {
    return show(
      title: AppStrings.areYouSure,
      message: AppStrings.confirmCancelReservationMessage,
      icon: Symbols.event_busy,
    );
  }

  static Future<bool> confirmRescheduleReservation() {
    return show(
      title: AppStrings.areYouSure,
      message: AppStrings.confirmRescheduleReservationMessage,
      icon: Symbols.edit_calendar,
    );
  }

  static Future<bool> confirmLogOut() {
    return show(
      title: AppStrings.areYouSure,
      message: AppStrings.confirmLogOutMessage,
      icon: Symbols.logout,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? body = message?.trim();
    final double maxWidth = MediaQuery.sizeOf(context).width.clamp(
      0,
      AppDimensions.confirmDialogMaxWidth +
          (AppDimensions.confirmDialogHorizontalInset * 2),
    );

    return Dialog(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.confirmDialogHorizontalInset,
        vertical: AppDimensions.pagePadding,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth < AppDimensions.confirmDialogMaxWidth
              ? maxWidth
              : AppDimensions.confirmDialogMaxWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppDimensions.confirmDialogRadius,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(
                  alpha: AppDimensions.confirmDialogElevationOpacity,
                ),
                blurRadius: AppDimensions.confirmDialogElevationBlur,
                offset: const Offset(0, AppDimensions.confirmDialogElevationY),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              AppDimensions.confirmDialogRadius,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: <Color>[
                    AppColors.surface,
                    AppColors.scaffold,
                    AppColors.secondaryLight,
                  ],
                  stops: <double>[0.0, 0.55, 1.0],
                ),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimensions.cardBorderWidth,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDimensions.confirmDialogPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppDimensions.confirmDialogIconContainerSize,
                      height: AppDimensions.confirmDialogIconContainerSize,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(
                          alpha: AppDimensions.confirmDialogIconFillAlpha,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border,
                          width: AppDimensions.cardBorderWidth,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: AppDimensions.confirmDialogIconSize,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sectionSpacing),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.confirmDialogTitle,
                    ),
                    if (body != null && body.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.regularSpacing),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.confirmDialogMessage,
                      ),
                    ],
                    const SizedBox(height: AppDimensions.sectionSpacing),
                    const SizedBox(height: AppDimensions.smallSpacing),
                    Row(
                      children: [
                        Expanded(
                          child: HoverableButton(
                            child: OutlinedButton(
                              onPressed: () => Get.back<bool>(result: false),
                              style: AppButtonStyles.outlinedHover(
                                OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    width: AppDimensions.cardBorderWidth,
                                  ),
                                  minimumSize: const Size(
                                    double.infinity,
                                    AppDimensions.confirmDialogButtonMinHeight,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        AppDimensions.buttonHorizontalPadding,
                                    vertical:
                                        AppDimensions.buttonVerticalPadding,
                                  ),
                                  textStyle: AppTextStyles.confirmDialogButton
                                      .copyWith(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.cardRadius,
                                    ),
                                  ),
                                ),
                              ),
                              child: Text(AppStrings.no),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: AppDimensions.confirmDialogButtonGap,
                        ),
                        Expanded(
                          child: HoverableButton(
                            child: ElevatedButton(
                              onPressed: () => Get.back<bool>(result: true),
                              style: AppButtonStyles.filledHover(
                                ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textLight,
                                  minimumSize: const Size(
                                    double.infinity,
                                    AppDimensions.confirmDialogButtonMinHeight,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        AppDimensions.buttonHorizontalPadding,
                                    vertical:
                                        AppDimensions.buttonVerticalPadding,
                                  ),
                                  textStyle: AppTextStyles.confirmDialogButton,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.cardRadius,
                                    ),
                                  ),
                                ),
                              ),
                              child: Text(AppStrings.yes),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
