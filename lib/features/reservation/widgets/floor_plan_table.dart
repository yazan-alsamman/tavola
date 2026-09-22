import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../model/restaurant_table_model.dart';
import '../model/table_status.dart';
import '../model/table_status_theme.dart';

class FloorPlanTable extends StatelessWidget {
  const FloorPlanTable({
    super.key,
    required this.table,
    required this.isSelected,
    required this.onTap,
    required this.width,
    required this.height,
  });

  final RestaurantTableModel table;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;
  final double height;

  Widget get _tableContent {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(table.tableNumber, style: table.status.tableLabelStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCleaning = table.status == TableStatus.cleaning;
    final BorderRadius radius = table.isRound
        ? BorderRadius.circular(math.max(width, height))
        : BorderRadius.circular(AppDimensions.floorPlanTableRadius);
    final double rotationRadians =
        ((table.rotation ?? 0) * math.pi) / 180;

    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: rotationRadians,
        child: AnimatedContainer(
          duration: AppDimensions.hoverDuration,
          curve: Curves.easeOutCubic,
          width: width,
          height: height,
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
                    borderRadius: table.isRound
                        ? math.max(width, height)
                        : AppDimensions.floorPlanTableRadius,
                  ),
                  child: Center(child: _tableContent),
                )
              : Center(child: _tableContent),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    if (table.status == TableStatus.available &&
        table.isAvailableForWindow == false) {
      return AppColors.surfaceAlt;
    }
    return table.status.tableBackgroundColor;
  }

  Color get _borderColor {
    if (table.status == TableStatus.available &&
        table.isAvailableForWindow == false) {
      return AppColors.border;
    }
    return table.status.tableBorderColor;
  }
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
