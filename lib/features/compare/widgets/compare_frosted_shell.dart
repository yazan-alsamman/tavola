import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Soft frosted glass shell matching Last Reservations history cards.
class CompareFrostedShell extends StatelessWidget {
  const CompareFrostedShell({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? AppDimensions.compareCardRadius;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: AppDimensions.reservationHistoryCardElevationOpacity,
            ),
            blurRadius: AppDimensions.reservationHistoryCardElevationBlur,
            offset: const Offset(
              0,
              AppDimensions.reservationHistoryCardElevationY,
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      AppColors.secondaryLight,
                      AppColors.accent,
                      AppColors.secondary,
                      AppColors.accent,
                    ],
                    stops: [0.0, 0.35, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: -AppDimensions.compareOrbSize * 0.4,
              end: -AppDimensions.compareOrbSize * 0.25,
              child: const _BlurOrb(
                size: AppDimensions.compareOrbSize,
                color: AppColors.accent,
                alpha: AppDimensions.reservationHistoryAccentOrbAlpha,
              ),
            ),
            PositionedDirectional(
              bottom: -AppDimensions.compareOrbSize * 0.45,
              start: -AppDimensions.compareOrbSize * 0.3,
              child: const _BlurOrb(
                size: AppDimensions.compareOrbSize * 0.85,
                color: AppColors.primaryDark,
                alpha: AppDimensions.reservationHistoryPrimaryOrbAlpha,
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppDimensions.reservationHistoryCardBlurSigma,
                sigmaY: AppDimensions.reservationHistoryCardBlurSigma,
              ),
              child: Container(
                width: double.infinity,
                padding:
                    padding ??
                    const EdgeInsets.all(AppDimensions.regularSpacing),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      AppColors.surface.withValues(
                        alpha:
                            AppDimensions.reservationHistoryGlassSurfaceAlpha,
                      ),
                      AppColors.accent.withValues(
                        alpha: AppDimensions.reservationHistoryGlassAccentAlpha,
                      ),
                      AppColors.primaryDark.withValues(
                        alpha:
                            AppDimensions.reservationHistoryGlassPrimaryAlpha,
                      ),
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                  border: Border.all(
                    color: AppColors.primaryDark.withValues(
                      alpha: AppDimensions.reservationHistoryBorderAlpha,
                    ),
                    width: AppDimensions.cardBorderWidth,
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    required this.size,
    required this.color,
    required this.alpha,
  });

  final double size;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: AppDimensions.reservationHistoryCardBlurSigma,
        sigmaY: AppDimensions.reservationHistoryCardBlurSigma,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: alpha),
        ),
      ),
    );
  }
}
