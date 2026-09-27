import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../model/restaurant_table_model.dart';
import '../model/table_shape.dart';
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

  bool get _bookable => table.isSelectable;

  bool get _highlightSelection => isSelected && _bookable;

  @override
  Widget build(BuildContext context) {
    final bool isCleaning = table.status == TableStatus.cleaning;
    final double rotationRadians = ((table.rotation ?? 0) * math.pi) / 180;
    final TableShape? shape = table.tableShape;
    final bool isCircle = shape == TableShape.circle;
    final double bodyWidth = isCircle ? math.min(width, height) : width;
    final double bodyHeight = isCircle ? math.min(width, height) : height;
    final double chairDepth = math.max(
      AppDimensions.tinySpacing * 2,
      math.min(bodyWidth, bodyHeight) * 0.16,
    );
    final double chairWidth = chairDepth * 1.35;
    final double gap = AppDimensions.tinySpacing;
    final List<_SeatMark> seats = _seatMarks(
      shape: shape,
      width: bodyWidth,
      height: bodyHeight,
      count: table.seatCount,
      orbit: gap + chairDepth / 2,
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Transform.rotate(
            angle: rotationRadians,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                for (final _SeatMark seat in seats)
                  Positioned(
                    key: ValueKey<String>(
                      'floor-plan-seat-${table.tableId}-${seat.index}',
                    ),
                    left: bodyWidth / 2 + seat.center.dx - chairWidth / 2,
                    top: bodyHeight / 2 + seat.center.dy - chairDepth / 2,
                    child: Transform.rotate(
                      angle: seat.facing,
                      child: _ChairMark(
                        width: chairWidth,
                        depth: chairDepth,
                        color: table.presentedChairColor,
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: AppDimensions.hoverDuration,
                  curve: Curves.easeOutCubic,
                  width: bodyWidth,
                  height: bodyHeight,
                  padding: const EdgeInsets.all(AppDimensions.tinySpacing),
                  decoration: BoxDecoration(
                    color: _highlightSelection
                        ? AppColors.primaryDark
                        : _backgroundColor,
                    borderRadius: _borderRadius(shape, bodyWidth, bodyHeight),
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
                          painter: _DashedShapePainter(
                            color: AppColors.border,
                            strokeWidth: AppDimensions.dashedBorderStrokeWidth,
                            borderRadius: _borderRadius(
                              shape,
                              bodyWidth,
                              bodyHeight,
                            ),
                          ),
                          child: Center(child: _tableContent),
                        )
                      : Center(child: _tableContent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _tableContent {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(table.tableNumber, style: _labelStyle),
    );
  }

  TextStyle get _labelStyle {
    if (_highlightSelection) {
      return table.presentedLabelStyle.copyWith(color: AppColors.textLight);
    }
    return table.presentedLabelStyle;
  }

  BorderRadius _borderRadius(
    TableShape? shape,
    double bodyWidth,
    double bodyHeight,
  ) {
    switch (shape) {
      case TableShape.circle:
      case TableShape.oval:
        return BorderRadius.all(
          Radius.elliptical(bodyWidth / 2, bodyHeight / 2),
        );
      case TableShape.square:
      case TableShape.rectangle:
      case null:
        return BorderRadius.circular(AppDimensions.floorPlanTableRadius);
    }
  }

  Color get _backgroundColor => table.presentedTableColor;

  Color get _borderColor => table.presentedBorderColor;
}

class _ChairMark extends StatelessWidget {
  const _ChairMark({
    required this.width,
    required this.depth,
    required this.color,
  });

  final double width;
  final double depth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double back = math.max(
      AppDimensions.tinySpacing * 0.75,
      depth * 0.28,
    );
    return SizedBox(
      width: width,
      height: depth,
      child: Column(
        children: [
          Container(
            width: width * 0.72,
            height: back,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(back),
            ),
          ),
          SizedBox(height: math.max(1, AppDimensions.tinySpacing * 0.25)),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(depth * 0.35),
                border: Border.all(
                  color: color,
                  width: AppDimensions.cardBorderWidth,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryDark10,
                    blurRadius: AppDimensions.tinySpacing,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatMark {
  const _SeatMark({
    required this.index,
    required this.center,
    required this.facing,
  });

  final int index;
  final Offset center;
  final double facing;
}

List<_SeatMark> _seatMarks({
  required TableShape? shape,
  required double width,
  required double height,
  required int count,
  required double orbit,
}) {
  if (count <= 0 || width <= 0 || height <= 0) {
    return const <_SeatMark>[];
  }
  if (shape == TableShape.circle) {
    return _aroundEllipse(
      count: count,
      radiusX: width / 2 + orbit,
      radiusY: width / 2 + orbit,
    );
  }
  if (shape == TableShape.oval) {
    return _aroundEllipse(
      count: count,
      radiusX: width / 2 + orbit,
      radiusY: height / 2 + orbit,
    );
  }
  return _aroundRectangle(
    count: count,
    width: width,
    height: height,
    orbit: orbit,
  );
}

List<_SeatMark> _aroundEllipse({
  required int count,
  required double radiusX,
  required double radiusY,
}) {
  return List<_SeatMark>.generate(count, (int index) {
    final double angle = -math.pi / 2 + index * 2 * math.pi / count;
    return _SeatMark(
      index: index,
      center: Offset(radiusX * math.cos(angle), radiusY * math.sin(angle)),
      facing: angle + math.pi / 2,
    );
  });
}

List<_SeatMark> _aroundRectangle({
  required int count,
  required double width,
  required double height,
  required double orbit,
}) {
  final List<int> perSide = _splitByLength(count, <double>[
    width,
    height,
    width,
    height,
  ]);
  final List<_SeatMark> seats = <_SeatMark>[];
  void addSide(int sideCount, Offset Function(double t) center, double facing) {
    for (int i = 0; i < sideCount; i++) {
      final double t = (i + 1) / (sideCount + 1);
      seats.add(
        _SeatMark(index: seats.length, center: center(t), facing: facing),
      );
    }
  }

  addSide(
    perSide[0],
    (double t) => Offset(-width / 2 + width * t, -height / 2 - orbit),
    0,
  );
  addSide(
    perSide[1],
    (double t) => Offset(width / 2 + orbit, -height / 2 + height * t),
    math.pi / 2,
  );
  addSide(
    perSide[2],
    (double t) => Offset(width / 2 - width * t, height / 2 + orbit),
    math.pi,
  );
  addSide(
    perSide[3],
    (double t) => Offset(-width / 2 - orbit, height / 2 - height * t),
    -math.pi / 2,
  );
  return seats;
}

List<int> _splitByLength(int count, List<double> lengths) {
  final double total = lengths.fold<double>(0, (double sum, double value) {
    return sum + math.max(value, 0);
  });
  if (count <= 0 || total <= 0) {
    return List<int>.filled(lengths.length, 0);
  }
  final List<double> raw = <double>[
    for (final double length in lengths) count * math.max(length, 0) / total,
  ];
  final List<int> counts = <int>[for (final double value in raw) value.floor()];
  int assigned = counts.fold<int>(0, (int sum, int value) => sum + value);
  final List<double> remainders = <double>[
    for (int i = 0; i < raw.length; i++) raw[i] - counts[i],
  ];
  while (assigned < count) {
    int best = 0;
    for (int i = 1; i < remainders.length; i++) {
      if (remainders[i] > remainders[best]) {
        best = i;
      }
    }
    counts[best] = counts[best] + 1;
    remainders[best] = -1;
    assigned++;
  }
  return counts;
}

class _DashedShapePainter extends CustomPainter {
  const _DashedShapePainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = borderRadius.toRRect(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
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
  bool shouldRepaint(covariant _DashedShapePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}
