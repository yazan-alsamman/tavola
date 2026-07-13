import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _shineController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: AppDimensions.splashIntroDuration,
    );
    _shineController = AnimationController(
      vsync: this,
      duration: AppDimensions.splashShineDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation =
        Tween<double>(begin: AppDimensions.splashInitialScale, end: 1).animate(
          CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
        );
    _shineAnimation =
        Tween<double>(
          begin: AppDimensions.splashShineStart,
          end: AppDimensions.splashShineEnd,
        ).animate(
          CurvedAnimation(
            parent: _shineController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _introController.forward();
    Future<void>.delayed(AppDimensions.splashShineDelay, () {
      if (mounted) {
        _shineController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, AppDimensions.splashGradientCenterY),
            radius: AppDimensions.splashGradientRadius,
            colors: [AppColors.surface, AppColors.surface],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedBuilder(
                animation: _shineAnimation,
                builder: (context, child) {
                  final position = _shineAnimation.value;

                  return ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment(
                        position - AppDimensions.splashShineWidth,
                        0,
                      ),
                      end: Alignment(
                        position + AppDimensions.splashShineWidth,
                        0,
                      ),
                      colors: const [
                        AppColors.primary,
                        AppColors.primary,
                        AppColors.primary,
                        AppColors.secondary,
                        AppColors.primary,
                        AppColors.primary,
                        AppColors.primary,
                      ],
                      stops: AppDimensions.splashShineStops,
                    ).createShader(bounds),
                    child: child,
                  );
                },
                child: Text(
                  AppStrings.splashTitle,
                  style: AppTextStyles.splashTitle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
