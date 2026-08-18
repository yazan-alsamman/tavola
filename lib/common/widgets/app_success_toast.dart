import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

/// Professional frosted green success banner shown at the top of the screen.
class AppSuccessToast {
  AppSuccessToast._();

  static void show({
    required String title,
    required String message,
  }) {
    void present() {
      if (Get.overlayContext == null && Get.context == null) {
        return;
      }
      Get.closeAllSnackbars();
      Get.rawSnackbar(
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.transparent,
        margin: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.regularSpacing,
          AppDimensions.pagePadding,
          0,
        ),
        padding: EdgeInsets.zero,
        borderRadius: AppDimensions.cardRadius,
        duration: AppDimensions.successToastDuration,
        isDismissible: true,
        dismissDirection: DismissDirection.up,
        overlayBlur: 0,
        messageText: _FrostedSuccessBanner(title: title, message: message),
      );
    }

    if (Get.overlayContext == null && Get.context == null) {
      // Retry once after shell replace when overlay is not ready yet.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(AppDimensions.successToastRevealDelay, present);
      });
      return;
    }
    present();
  }
}

class _FrostedSuccessBanner extends StatelessWidget {
  const _FrostedSuccessBanner({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.successToastBlurSigma,
          sigmaY: AppDimensions.successToastBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[
                AppColors.online.withValues(
                  alpha: AppDimensions.successToastFillAlpha,
                ),
                AppColors.online.withValues(
                  alpha: AppDimensions.successToastFillAlphaStrong,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: AppColors.textLight.withValues(
                alpha: AppDimensions.successToastBorderAlpha,
              ),
              width: AppDimensions.cardBorderWidth,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.online.withValues(
                  alpha: AppDimensions.successToastShadowAlpha,
                ),
                blurRadius: AppDimensions.successToastShadowBlur,
                offset: const Offset(0, AppDimensions.smallSpacing),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.contentPadding,
              vertical: AppDimensions.regularSpacing,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: AppDimensions.successToastIconCircleSize,
                  height: AppDimensions.successToastIconCircleSize,
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withValues(
                      alpha: AppDimensions.successToastIconCircleAlpha,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.check_circle,
                    color: AppColors.textLight,
                    size: AppDimensions.successToastIconSize,
                    fill: 1,
                  ),
                ),
                const SizedBox(width: AppDimensions.regularSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTextStyles.settingsItemTitle.copyWith(
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        message,
                        style: AppTextStyles.settingsItemBody.copyWith(
                          color: AppColors.textLight90,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
