import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Short in-map notice shown when a floor-plan table cannot be selected.
class FloorPlanUnavailableNotice extends StatefulWidget {
  const FloorPlanUnavailableNotice({
    super.key,
    required this.message,
    this.onDismissed,
  });

  final String message;
  final VoidCallback? onDismissed;

  @override
  State<FloorPlanUnavailableNotice> createState() =>
      _FloorPlanUnavailableNoticeState();
}

class _FloorPlanUnavailableNoticeState extends State<FloorPlanUnavailableNotice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  Timer? _hold;
  Timer? _remove;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: AppDimensions.hoverDuration,
    );
    final CurvedAnimation curved = CurvedAnimation(
      parent: _motion,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fade = curved;
    _slide = Tween<Offset>(
      begin: const Offset(
        0,
        AppDimensions.floorPlanUnavailableNoticeEnterSlide,
      ),
      end: Offset.zero,
    ).animate(curved);
    _scale = Tween<double>(
      begin: AppDimensions.floorPlanUnavailableNoticeEnterScale,
      end: 1,
    ).animate(curved);
    _motion.forward();
    _hold = Timer(AppDimensions.floorPlanUnavailableNoticeDuration, _leave);
    _remove = Timer(
      AppDimensions.floorPlanUnavailableNoticeDuration +
          AppDimensions.hoverDuration,
      _finish,
    );
  }

  void _leave() {
    if (!mounted) {
      return;
    }
    _motion.reverse();
  }

  void _finish() {
    if (!mounted) {
      return;
    }
    widget.onDismissed?.call();
  }

  @override
  void dispose() {
    _hold?.cancel();
    _remove?.cancel();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(
                color: AppColors.border,
                width: AppDimensions.cardBorderWidth,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primaryDark.withValues(
                    alpha: AppDimensions.shadowOpacity,
                  ),
                  blurRadius: AppDimensions.floorPlanIdleShadowBlur,
                  offset: const Offset(0, AppDimensions.shadowOffsetY),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.contentPadding,
                vertical: AppDimensions.regularSpacing,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(
                        alpha: AppDimensions.successToastIconCircleAlpha,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border,
                        width: AppDimensions.cardBorderWidth,
                      ),
                    ),
                    child: SizedBox.square(
                      dimension: AppDimensions.successToastIconCircleSize,
                      child: Icon(
                        Symbols.event_busy,
                        color: AppColors.warning,
                        size: AppDimensions.successToastIconSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.regularSpacing),
                  Flexible(
                    child: Text(
                      widget.message,
                      key: const ValueKey<String>(
                        'floor-plan-unavailable-notice',
                      ),
                      style: AppTextStyles.confirmationDetailValue,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
