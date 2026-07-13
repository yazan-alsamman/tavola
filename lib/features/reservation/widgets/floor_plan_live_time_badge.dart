import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/select_table_controller.dart';

class FloorPlanLiveTimeBadge extends StatefulWidget {
  const FloorPlanLiveTimeBadge({super.key});

  @override
  State<FloorPlanLiveTimeBadge> createState() => _FloorPlanLiveTimeBadgeState();
}

class _FloorPlanLiveTimeBadgeState extends State<FloorPlanLiveTimeBadge> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(AppDimensions.floorPlanLiveTimeUpdateInterval, (_) {
      if (!mounted) {
        return;
      }

      setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.compactHorizontalPadding,
        vertical: AppDimensions.compactVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface75,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryDark10,
            blurRadius: AppDimensions.floorPlanIdleShadowBlur,
            offset: Offset(0, AppDimensions.tinySpacing),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _LiveStatusDot(),
          const SizedBox(width: AppDimensions.smallSpacing),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.floorPlanNowTime,
                style: AppTextStyles.floorPlanLiveLabel,
              ),
              const SizedBox(height: AppDimensions.tinySpacing),
              Text(
                SelectTableController.formatCurrentTime(_currentTime),
                style: AppTextStyles.floorPlanLiveTime,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveStatusDot extends StatefulWidget {
  const _LiveStatusDot();

  @override
  State<_LiveStatusDot> createState() => _LiveStatusDotState();
}

class _LiveStatusDotState extends State<_LiveStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDimensions.floorPlanLiveDotPulseDuration,
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(
      begin: AppDimensions.floorPlanLiveDotMinOpacity,
      end: AppDimensions.floorPlanLiveDotMaxOpacity,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.online.withValues(alpha: _opacityAnimation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.online.withValues(
                  alpha: _opacityAnimation.value * 0.35,
                ),
                blurRadius: AppDimensions.floorPlanLiveDotGlowBlur,
              ),
            ],
          ),
          child: const SizedBox.square(
            dimension: AppDimensions.floorPlanLiveDotSize,
          ),
        );
      },
    );
  }
}
