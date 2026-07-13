import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class WelcomeTitleShine extends StatefulWidget {
  const WelcomeTitleShine({super.key});

  @override
  State<WelcomeTitleShine> createState() => _WelcomeTitleShineState();
}

class _WelcomeTitleShineState extends State<WelcomeTitleShine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: AppDimensions.welcomeShineDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shineController,
      builder: (context, child) {
        final double angle = _shineController.value * math.pi * 2;

        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment(
                -AppDimensions.welcomeShineBandExtent,
                0,
              ),
              end: Alignment(
                AppDimensions.welcomeShineBandExtent,
                0,
              ),
              colors: const [
                AppColors.accent,
                AppColors.accent,
                AppColors.textLight,
                AppColors.textLight,
                AppColors.textLight,
                AppColors.accent,
                AppColors.accent,
              ],
              stops: AppDimensions.welcomeShineStops,
              transform: GradientRotation(angle),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          AppStrings.splashTitle,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: AppTextStyles.welcomeHeroTitle,
        ),
      ),
    );
  }
}
