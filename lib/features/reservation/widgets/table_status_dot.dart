import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../model/table_status.dart';

class TableStatusDot extends StatelessWidget {
  const TableStatusDot({
    super.key,
    required this.status,
    this.size = AppDimensions.floorPlanLegendDotSize,
  });

  final TableStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TableStatus.available:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            shape: BoxShape.circle,
          ),
        );
      case TableStatus.reserved:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        );
      case TableStatus.cleaning:
        return CustomPaint(
          size: Size.square(size),
          painter: _DashedCirclePainter(
            color: AppColors.border,
            strokeWidth: AppDimensions.dashedBorderStrokeWidth,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
          ),
        );
    }
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final double radius = size.width / 2;
    const double dashLength = AppDimensions.dashedBorderDashLength;
    const double gapLength = AppDimensions.dashedBorderGapLength;
    const double fullCircle = math.pi * 2;
    final double dashAngle = (dashLength / fullCircle) * fullCircle;
    final double gapAngle = (gapLength / fullCircle) * fullCircle;

    double startAngle = 0;
    while (startAngle < fullCircle) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
      startAngle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
