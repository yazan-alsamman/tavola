import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class ShiningRestaurantMarker extends StatefulWidget {
  const ShiningRestaurantMarker({
    super.key,
    required this.restaurantName,
    required this.onTap,
  });

  final String restaurantName;
  final VoidCallback onTap;

  @override
  State<ShiningRestaurantMarker> createState() =>
      _ShiningRestaurantMarkerState();
}

class _ShiningRestaurantMarkerState extends State<ShiningRestaurantMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDimensions.mapMarkerShineDuration,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: AppDimensions.mapMarkerMinScale,
      end: AppDimensions.mapMarkerMaxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(
      begin: AppDimensions.mapMarkerMinGlow,
      end: AppDimensions.mapMarkerMaxGlow,
    ).animate(_controller);
    _opacityAnimation = Tween<double>(
      begin: AppDimensions.mapMarkerMinGlowOpacity,
      end: AppDimensions.mapMarkerMaxGlowOpacity,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.restaurantName,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: _opacityAnimation.value,
                      ),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: AppDimensions.tinySpacing,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: Container(
            width: AppDimensions.mapMarkerCoreSize,
            height: AppDimensions.mapMarkerCoreSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textLight,
                width: AppDimensions.cardBorderWidth,
              ),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.textLight,
              size: AppDimensions.mapMarkerIconSize,
            ),
          ),
        ),
      ),
    );
  }
}
