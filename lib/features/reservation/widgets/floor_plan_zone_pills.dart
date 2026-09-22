import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class FloorPlanZonePills extends StatelessWidget {
  const FloorPlanZonePills({super.key});

  static List<_ZonePillData> get _zones => [
    _ZonePillData(label: AppStrings.kitchen, color: AppColors.floorPlanKitchen),
    _ZonePillData(label: AppStrings.bar, color: AppColors.floorPlanBar),
    _ZonePillData(
      label: AppStrings.reception,
      color: AppColors.floorPlanReception,
    ),
    _ZonePillData(
      label: AppStrings.entrance,
      color: AppColors.floorPlanEntrance,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.smallSpacing,
      ),
      child: Row(
        children: [
          for (int i = 0; i < _zones.length; i++) ...[
            if (i > 0) const SizedBox(width: AppDimensions.smallSpacing),
            _ZonePill(data: _zones[i]),
          ],
        ],
      ),
    );
  }
}

class _ZonePillData {
  const _ZonePillData({required this.label, required this.color});

  final String label;
  final Color color;
}

class _ZonePill extends StatelessWidget {
  const _ZonePill({required this.data});

  final _ZonePillData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.floorPlanZonePillHeight,
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppDimensions.compactHorizontalPadding,
        0,
        AppDimensions.smallSpacing,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
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
          Text(data.label, style: AppTextStyles.floorPlanZonePillLabel),
          const SizedBox(width: AppDimensions.regularSpacing),
          Container(
            width: AppDimensions.floorPlanZonePillDotSize,
            height: AppDimensions.floorPlanZonePillDotSize,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
