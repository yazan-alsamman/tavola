import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../controller/select_table_controller.dart';
import '../model/restaurant_table_model.dart';
import '../model/table_status.dart';
import '../model/table_status_theme.dart';

class FloorPlanTable extends StatelessWidget {
  const FloorPlanTable({
    super.key,
    required this.table,
    required this.isSelected,
    required this.onTap,
    this.size = AppDimensions.floorPlanTableSize,
  });

  final RestaurantTableModel table;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;

  Widget get _tableContent {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _label,
          if (table.isCategoryExample) ...[
            const SizedBox(height: AppDimensions.tinySpacing),
            Text(
              SelectTableController.seatCountText(table.seatCount),
              style: _seatStyle,
            ),
          ],
        ],
      ),
    );
  }

  TextStyle get _seatStyle => table.status.seatBadgeStyle;

  @override
  Widget build(BuildContext context) {
    final bool isCleaning = table.status == TableStatus.cleaning;
    final BorderRadius radius = BorderRadius.circular(
      AppDimensions.floorPlanTableRadius,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDimensions.hoverDuration,
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        padding: const EdgeInsets.all(AppDimensions.tinySpacing),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: radius,
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : _borderColor,
            width: isSelected
                ? AppDimensions.occasionSelectedBorderWidth
                : isCleaning
                ? AppDimensions.dashedBorderStrokeWidth
                : AppDimensions.cardBorderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryDark22
                  : AppColors.primaryDark10,
              blurRadius: isSelected
                  ? AppDimensions.floorPlanSelectedShadowBlur
                  : AppDimensions.floorPlanIdleShadowBlur,
              offset: const Offset(0, AppDimensions.tinySpacing),
            ),
          ],
        ),
        child: isCleaning
            ? CustomPaint(
                painter: _DashedRectPainter(
                  color: AppColors.border,
                  strokeWidth: AppDimensions.dashedBorderStrokeWidth,
                  borderRadius: AppDimensions.floorPlanTableRadius,
                ),
                child: Center(child: _tableContent),
              )
            : Center(child: _tableContent),
      ),
    );
  }

  Color get _backgroundColor => table.status.tableBackgroundColor;

  Color get _borderColor => table.status.tableBorderColor;

  Widget get _label => Text(table.label, style: table.status.tableLabelStyle);
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      const double dashLength = AppDimensions.dashedBorderDashLength;
      const double gapLength = AppDimensions.dashedBorderGapLength;
      while (distance < metric.length) {
        final double nextDashEnd = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, nextDashEnd.clamp(0, metric.length)),
          paint,
        );
        distance = nextDashEnd + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
