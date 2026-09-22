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
      child: Text(table.tableNumber, style: _labelStyle),
    );
  }

  TextStyle get _labelStyle {
    if (_highlightSelection) {
      return table.status.tableLabelStyle.copyWith(color: AppColors.textLight);
    }
    return table.status.tableLabelStyle;
  }

  bool get _highlightSelection =>
      isSelected && table.status == TableStatus.available;

  @override
  Widget build(BuildContext context) {
    final bool isCleaning = table.status == TableStatus.cleaning;
    final BorderRadius radius = table.isRound
        ? BorderRadius.circular(math.max(width, height))
        : BorderRadius.circular(AppDimensions.floorPlanTableRadius);
    final double rotationRadians = ((table.rotation ?? 0) * math.pi) / 180;
    final double chairSize = math.min(
      AppDimensions.floorPlanChairSize,
      math.min(width, height) * 0.16,
    );
    final double inset = math.max(
      chairSize + AppDimensions.tinySpacing,
      math.min(width, height) * 0.18,
    );

    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: rotationRadians,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: _TableChairsPainter(
                  isRound: table.isRound,
                  seatCount: math.max(table.seatCount, 2),
                  chairSize: chairSize,
                  fill: _highlightSelection
                      ? AppColors.primaryDark
                      : table.status.chairColor,
                  border: _highlightSelection
                      ? AppColors.primaryDark
                      : _borderColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(inset),
                child: AnimatedContainer(
                  duration: AppDimensions.hoverDuration,
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(AppDimensions.tinySpacing),
                  decoration: BoxDecoration(
                    color: _highlightSelection
                        ? AppColors.primaryDark
                        : _backgroundColor,
                    borderRadius: radius,
                    border: Border.all(
                      color: _highlightSelection
                          ? AppColors.primaryDark
                          : _borderColor,
                      width: _highlightSelection
                          ? AppDimensions.occasionSelectedBorderWidth
                          : isCleaning
                          ? AppDimensions.dashedBorderStrokeWidth
                          : AppDimensions.cardBorderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _highlightSelection
                            ? AppColors.primaryDark22
                            : AppColors.primaryDark10,
                        blurRadius: _highlightSelection
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
            ],
          ),
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

class _TableChairsPainter extends CustomPainter {
  const _TableChairsPainter({
    required this.isRound,
    required this.seatCount,
    required this.chairSize,
    required this.fill,
    required this.border,
  });

  final bool isRound;
  final int seatCount;
  final double chairSize;
  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppDimensions.cardBorderWidth;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radiusX = math.max(0, size.width / 2 - chairSize / 2);
    final double radiusY = math.max(0, size.height / 2 - chairSize / 2);

    for (int i = 0; i < seatCount; i++) {
      final Offset chairCenter;
      if (isRound) {
        final double angle = (i / seatCount) * math.pi * 2 - math.pi / 2;
        chairCenter = Offset(
          center.dx + math.cos(angle) * radiusX,
          center.dy + math.sin(angle) * radiusY,
        );
      } else {
        chairCenter = _rectChairCenter(size, i, seatCount);
      }

      canvas.drawCircle(chairCenter, chairSize / 2, fillPaint);
      canvas.drawCircle(chairCenter, chairSize / 2, strokePaint);
    }
  }

  Offset _rectChairCenter(Size size, int index, int count) {
    final List<Offset> slots = <Offset>[];
    final int perSide = math.max(1, (count / 4).ceil());
    for (int i = 0; i < perSide && slots.length < count; i++) {
      final double t = (i + 1) / (perSide + 1);
      slots.add(Offset(size.width * t, chairSize / 2));
    }
    for (int i = 0; i < perSide && slots.length < count; i++) {
      final double t = (i + 1) / (perSide + 1);
      slots.add(Offset(size.width - chairSize / 2, size.height * t));
    }
    for (int i = 0; i < perSide && slots.length < count; i++) {
      final double t = (i + 1) / (perSide + 1);
      slots.add(Offset(size.width * (1 - t), size.height - chairSize / 2));
    }
    for (int i = 0; i < perSide && slots.length < count; i++) {
      final double t = (i + 1) / (perSide + 1);
      slots.add(Offset(chairSize / 2, size.height * (1 - t)));
    }
    return slots[index.clamp(0, slots.length - 1)];
  }

  @override
  bool shouldRepaint(covariant _TableChairsPainter oldDelegate) {
    return oldDelegate.isRound != isRound ||
        oldDelegate.seatCount != seatCount ||
        oldDelegate.chairSize != chairSize ||
        oldDelegate.fill != fill ||
        oldDelegate.border != border;
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
