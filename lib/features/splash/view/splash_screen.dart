import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../controller/splash_controller.dart';
import '../splash_assets.dart';
import '../widgets/splash_tavola_mark.dart';
import 'package:material_symbols_icons/symbols.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _drawController;
  late final CurvedAnimation _introCurve;
  late final CurvedAnimation _drawCurve;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _drawStartTimer;
  late final Widget _lavenderImage;

  @override
  void initState() {
    super.initState();

    // Resolve controller put in `main()` / Binding before first paint.
    Get.find<SplashController>();

    _lavenderImage = SplashAssets.lavenderImage != null
        ? RawImage(
            image: SplashAssets.lavenderImage,
            width: AppDimensions.splashLavenderWidth,
            height: AppDimensions.splashLavenderHeight,
            fit: BoxFit.contain,
            alignment: const Alignment(AppDimensions.splashLavenderPivotX, 1),
            filterQuality: FilterQuality.medium,
          )
        : Image(
            image: SplashAssets.lavenderProvider,
            width: AppDimensions.splashLavenderWidth,
            height: AppDimensions.splashLavenderHeight,
            fit: BoxFit.contain,
            alignment: const Alignment(AppDimensions.splashLavenderPivotX, 1),
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return Icon(
                    Symbols.local_florist,
                    color: AppColors.accent,
                    size: AppDimensions.smallIconSize,
                  );
                },
          );

    _introController = AnimationController(
      vsync: this,
      duration: AppDimensions.splashIntroDuration,
    );
    _drawController = AnimationController(
      vsync: this,
      duration: AppDimensions.splashBrandDrawDuration,
    );

    _introCurve = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _drawCurve = CurvedAnimation(parent: _drawController, curve: Curves.linear);

    _fadeAnimation = Tween<double>(
      begin: AppDimensions.splashInitialOpacity,
      end: 1,
    ).animate(_introCurve);
    _scaleAnimation = Tween<double>(
      begin: AppDimensions.splashInitialScale,
      end: 1,
    ).animate(_introCurve);

    _introController.forward();
    _drawStartTimer = Timer(AppDimensions.splashBrandDrawDelay, () {
      if (!mounted) {
        return;
      }
      _drawController.forward();
    });
  }

  @override
  void dispose() {
    _drawStartTimer?.cancel();
    _drawStartTimer = null;
    _introController.stop();
    _drawController.stop();
    _introCurve.dispose();
    _drawCurve.dispose();
    _introController.dispose();
    _drawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxBrandWidth =
        MediaQuery.sizeOf(context).width *
        AppDimensions.splashBrandMaxWidthFactor;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, AppDimensions.splashGradientCenterY),
            radius: AppDimensions.splashGradientRadius,
            colors: [AppColors.surface, AppColors.scaffold],
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              alignment: Alignment.center,
              scale: _scaleAnimation,
              child: SizedBox(
                width: maxBrandWidth,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  child: SplashTavolaMark(
                    drawProgress: _drawCurve,
                    lavenderImage: _lavenderImage,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
