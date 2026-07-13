import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class HoverableCard extends StatefulWidget {
  const HoverableCard({
    super.key,
    required this.child,
    this.borderRadius = AppDimensions.cardRadius,
  });

  final Widget child;
  final double borderRadius;

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isActive => _isHovered || _isPressed;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed
        ? AppDimensions.cardPressedScale
        : _isHovered
        ? AppDimensions.hoverScale
        : 1.0;

    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedSlide(
          offset: _isActive
              ? const Offset(0, AppDimensions.cardHoverSlideY)
              : Offset.zero,
          duration: AppDimensions.hoverDuration,
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: scale,
            duration: AppDimensions.hoverDuration,
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: AppDimensions.hoverDuration,
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: _isActive
                    ? [
                        BoxShadow(
                          color: AppColors.accent,
                          blurRadius: AppDimensions.shadowBlur,
                          offset: const Offset(0, AppDimensions.shadowOffsetY),
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
