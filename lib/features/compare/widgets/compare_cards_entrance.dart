import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

/// Synchronized top-to-bottom entrance for both compare cards.
///
/// Plays once per [animationKey]. Remounts with the same key jump to the end
/// so loading-driven rebuilds never replay the motion.
class CompareCardsEntrance extends StatefulWidget {
  const CompareCardsEntrance({
    super.key,
    required this.animationKey,
    required this.cardA,
    required this.cardB,
  });

  final String animationKey;
  final Widget cardA;
  final Widget cardB;

  /// Clears the completed-key guard so the next pair can animate again.
  static void resetCompletedKey() {
    _CompareCardsEntranceState._lastCompletedKey = null;
  }

  @override
  State<CompareCardsEntrance> createState() => _CompareCardsEntranceState();
}

class _CompareCardsEntranceState extends State<CompareCardsEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expand;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  /// Survives State remounts for the same pair within this session.
  static String? _lastCompletedKey;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDimensions.compareCardsEntranceDuration,
    );
    _bindCurves();
    _startOrRestore();
  }

  void _bindCurves() {
    _expand = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _slide =
        Tween<Offset>(
          begin: const Offset(0, -AppDimensions.compareCardEntranceSlideY),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ),
        );
  }

  void _startOrRestore() {
    if (_lastCompletedKey == widget.animationKey) {
      _controller.value = 1;
      return;
    }
    _controller.forward().whenComplete(() {
      if (mounted && widget.animationKey.isNotEmpty) {
        _lastCompletedKey = widget.animationKey;
      }
    });
  }

  @override
  void didUpdateWidget(covariant CompareCardsEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationKey == widget.animationKey) {
      return;
    }
    if (_lastCompletedKey == widget.animationKey) {
      _controller.value = 1;
      return;
    }
    _controller.forward(from: 0).whenComplete(() {
      if (mounted && widget.animationKey.isNotEmpty) {
        _lastCompletedKey = widget.animationKey;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _expand.value.clamp(0.0, 1.0),
            child: FadeTransition(
              opacity: _opacity,
              child: SlideTransition(
                position: _slide,
                child: child,
              ),
            ),
          ),
        );
      },
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: widget.cardA),
          const SizedBox(width: AppDimensions.compareColumnGap),
          Expanded(child: widget.cardB),
        ],
      ),
    );
  }
}
