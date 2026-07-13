import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';

class HoverableButton extends StatefulWidget {
  const HoverableButton({super.key, required this.child});

  final Widget child;

  @override
  State<HoverableButton> createState() => _HoverableButtonState();
}

class _HoverableButtonState extends State<HoverableButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed
        ? AppDimensions.buttonPressedScale
        : _isHovered
        ? AppDimensions.buttonHoverScale
        : 1.0;

    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedSlide(
          offset: _isHovered
              ? const Offset(0, AppDimensions.buttonHoverSlideY)
              : Offset.zero,
          duration: AppDimensions.hoverDuration,
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: scale,
            duration: AppDimensions.hoverDuration,
            curve: Curves.easeOutBack,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
