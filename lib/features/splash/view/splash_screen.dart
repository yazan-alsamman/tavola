import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_images.dart';
import '../widgets/splash_tavola_mark.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const AssetImage _lavenderAsset =
      AssetImage(AppImages.splashLavender);

  late final AnimationController _introController;
  late final AnimationController _drawController;
  late final CurvedAnimation _introCurve;
  late final CurvedAnimation _drawCurve;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _drawStartTimer;
  bool _didPrecacheLavender = false;

  @override
  void initState() {
    super.initState();

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
    _drawCurve = CurvedAnimation(
      parent: _drawController,
      curve: Curves.linear,
    );

    _fadeAnimation = Tween<double>(
      begin: AppDimensions.splashInitialOpacity,
      end: 1,
    ).animate(_introCurve);
    _scaleAnimation =
        Tween<double>(begin: AppDimensions.splashInitialScale, end: 1)
            .animate(_introCurve);

    _introController.forward();
    _drawStartTimer = Timer(AppDimensions.splashBrandDrawDelay, () {
      if (!mounted) {
        return;
      }
      _drawController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheLavender) {
      return;
    }
    _didPrecacheLavender = true;
    // Catch decode/path races so Hot Restart never surfaces an uncaught async error.
    unawaited(
      precacheImage(_lavenderAsset, context).catchError((Object _) {}),
    );
  }

  Widget _buildLavenderImage() {
    return Image(
      image: _lavenderAsset,
      width: AppDimensions.splashLavenderWidth,
      height: AppDimensions.splashLavenderHeight,
      fit: BoxFit.contain,
      // Pin the stem tip (bottom-left of the art) to the transform pivot.
      alignment: const Alignment(
        AppDimensions.splashLavenderPivotX,
        1,
      ),
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.local_florist_rounded,
        color: AppColors.accent,
        size: AppDimensions.smallIconSize,
      ),
    );
  }

  @override
  void dispose() {
    _drawStartTimer?.cancel();
    _drawStartTimer = null;
    // Drop any in-flight lavender decode tied to this splash instance.
    PaintingBinding.instance.imageCache.evict(_lavenderAsset);
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
    final double maxBrandWidth = MediaQuery.sizeOf(context).width *
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
                    lavenderImage: _buildLavenderImage(),
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
