import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../splash/splash_assets.dart';

/// Branded Welcome → Login / Guest bridge — Tavola look without Splash paint cost.
///
/// Soft cream field, lavender + TAVOLA wordmark, accent spinner.
class WelcomeBridgeScaffold extends StatelessWidget {
  const WelcomeBridgeScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final double brandMaxWidth =
        MediaQuery.sizeOf(context).width *
        AppDimensions.welcomeTransitionMarkMaxWidthFactor;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, AppDimensions.splashGradientCenterY),
            radius: AppDimensions.splashGradientRadius,
            colors: <Color>[AppColors.surface, AppColors.scaffold],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: brandMaxWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: SplashAssets.isLavenderReady
                        ? SplashAssets.lavenderProvider
                        : const AssetImage(AppImages.splashLavender),
                    width: AppDimensions.welcomeTransitionLavenderWidth,
                    height: AppDimensions.welcomeTransitionLavenderHeight,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return Icon(
                            Symbols.local_florist,
                            color: AppColors.primary,
                            size: AppDimensions.settingsIconSize,
                          );
                        },
                  ),
                  const SizedBox(height: AppDimensions.regularSpacing),
                  Text(
                    AppStrings.splashTitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: AppTextStyles.authBrandMark.copyWith(
                      color: AppColors.primary,
                      fontSize: AppDimensions.welcomeTransitionBrandFontSize,
                      letterSpacing:
                          AppDimensions.welcomeTransitionBrandLetterSpacing,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  const SizedBox(
                    width: AppDimensions.welcomeTransitionIndicatorSize,
                    height: AppDimensions.welcomeTransitionIndicatorSize,
                    child: CircularProgressIndicator(
                      strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
