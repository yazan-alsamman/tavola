import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import 'restaurant_table_model.dart';

/// Backend/Dashboard coordinate system:
/// origin top-left, X right, Y down, unit = stored CSS pixels.
///
/// Zoom is a render-only [Matrix4]. It never mutates table geometry.
class FloorPlanGeometry {
  const FloorPlanGeometry._();

  /// Canvas origin stays (0, 0). Size is the axis-aligned extent of API tables.
  static Size canvasSize(List<RestaurantTableModel> tables) {
    double maxX = 0;
    double maxY = 0;
    for (final RestaurantTableModel table in tables) {
      final Rect? rect = tableRect(table);
      if (rect == null) {
        continue;
      }
      maxX = math.max(maxX, rect.right);
      maxY = math.max(maxY, rect.bottom);
    }
    return Size(
      maxX + AppDimensions.floorPlanCanvasPadding,
      maxY + AppDimensions.floorPlanCanvasPadding,
    );
  }

  static Rect? tableRect(RestaurantTableModel table) {
    if (!table.hasRenderableGeometry) {
      return null;
    }
    return Rect.fromLTWH(
      table.positionX!,
      table.positionY!,
      table.width!,
      table.height!,
    );
  }

  /// Fit-to-viewport scale/translate. Does not change stored X/Y/width/height.
  static Matrix4 fitToViewport({
    required Size viewport,
    required Size canvas,
  }) {
    if (viewport.width <= 0 ||
        viewport.height <= 0 ||
        canvas.width <= 0 ||
        canvas.height <= 0) {
      return Matrix4.identity();
    }

    final double scale = math.min(
      viewport.width / canvas.width,
      viewport.height / canvas.height,
    );
    final double dx = (viewport.width - canvas.width * scale) / 2;
    final double dy = (viewport.height - canvas.height * scale) / 2;
    return Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }
}
