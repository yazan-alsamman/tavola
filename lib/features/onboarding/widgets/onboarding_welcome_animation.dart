import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingWelcomeAnimation extends StatefulWidget {
  const OnboardingWelcomeAnimation({super.key});

  @override
  State<OnboardingWelcomeAnimation> createState() =>
      _OnboardingWelcomeAnimationState();
}

class _OnboardingWelcomeAnimationState extends State<OnboardingWelcomeAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _brandOpacity;
  late final Animation<double> _brandScale;
  late final Animation<double> _lineWidth;
  late final Animation<double> _orbBreath;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: AppDimensions.onboardingWelcomeDuration,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _subtitleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _brandOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
    );
    _brandScale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutBack),
      ),
    );
    _lineWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _orbBreath = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entranceController,
        _pulseController,
        _shimmerController,
      ]),
      builder: (BuildContext context, Widget? child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _orbBreath.value,
              child: Container(
                width: AppDimensions.onboardingWelcomeOrbSize,
                height: AppDimensions.onboardingWelcomeOrbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.45),
                      AppColors.secondary.withValues(alpha: 0.18),
                      AppColors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: _shimmerController.value * math.pi * 2,
              child: Container(
                width: AppDimensions.onboardingWelcomeOrbSize * 0.72,
                height: AppDimensions.onboardingWelcomeOrbSize * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _subtitleOpacity,
                  child: SlideTransition(
                    position: _subtitleSlide,
                    child: const Text(
                      AppStrings.onboardingWelcomeTo,
                      style: AppTextStyles.onboardingWelcomeSubtitle,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.regularSpacing),
                Opacity(
                  opacity: _brandOpacity.value,
                  child: Transform.scale(
                    scale: _brandScale.value,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        final double shimmer =
                            (_shimmerController.value * 2) - 0.5;
                        return LinearGradient(
                          begin: Alignment(-1 + shimmer, 0),
                          end: Alignment(shimmer, 0),
                          colors: const [
                            AppColors.primaryDark,
                            AppColors.accent,
                            AppColors.primaryDark,
                          ],
                          stops: const [0.35, 0.5, 0.65],
                        ).createShader(bounds);
                      },
                      child: Text(
                        AppStrings.onboardingWelcomeBrand,
                        style: AppTextStyles.onboardingWelcomeBrand,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                FractionallySizedBox(
                  widthFactor: 0.42 * _lineWidth.value,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.pillRadius,
                      ),
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.primaryDark],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
