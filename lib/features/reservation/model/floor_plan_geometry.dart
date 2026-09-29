import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import 'floor_plan_area_model.dart';
import 'restaurant_table_model.dart';

/// Backend/Dashboard coordinate system:
/// origin top-left, X right, Y down, unit = stored CSS pixels.
///
/// Zoom is a render-only [Matrix4]. It never mutates table geometry.
class FloorPlanGeometry {
  const FloorPlanGeometry._();

  /// Axis-aligned size of [contentBounds]. Does not move API coordinates.
  static Size canvasSize(List<RestaurantTableModel> tables) {
    final Rect? bounds = contentBounds(tables);
    if (bounds == null) {
      return Size.zero;
    }
    return Size(bounds.width, bounds.height);
  }

  /// Union of rotated table extents, including the chair orbit.
  /// The minimum is the real geometry, not (0, 0).
  static Rect? contentBounds(List<RestaurantTableModel> tables) {
    Rect? bounds;
    for (final RestaurantTableModel table in tables) {
      bounds = _include(bounds, occupiedBounds(table));
    }
    return bounds;
  }

  /// Occupied extent of the tables that belong to [area].
  /// Falls back to an explicit API box only when the area has no tables.
  static Rect? areaCluster(
    FloorPlanAreaModel area,
    List<RestaurantTableModel> tables,
  ) {
    Rect? bounds;
    for (final RestaurantTableModel table in tables) {
      if (table.floorPlanAreaId != area.id) {
        continue;
      }
      bounds = _include(bounds, occupiedBounds(table));
    }
    if (bounds != null || !area.hasExplicitBounds) {
      return bounds;
    }
    return Rect.fromLTWH(
      area.positionX!,
      area.positionY!,
      area.width!,
      area.height!,
    );
  }

  /// Grows [cluster] so the measured label fits around it.
  /// [sideApi], [topBandApi], and [minWidthApi] are label measurements
  /// converted by the current render scale. API fields are not written.
  static Rect encloseCluster({
    required Rect cluster,
    required double sideApi,
    required double topBandApi,
    required double minWidthApi,
  }) {
    final double side = sideApi > 0 ? sideApi : 0;
    final double band = topBandApi > 0 ? topBandApi : 0;
    double left = cluster.left - side;
    double right = cluster.right + side;
    final double width = right - left;
    if (minWidthApi > width) {
      final double extra = (minWidthApi - width) / 2;
      left -= extra;
      right += extra;
    }
    return Rect.fromLTRB(
      left,
      cluster.top - side - band,
      right,
      cluster.bottom + side,
    );
  }

  static Rect? _include(Rect? bounds, Rect? rect) {
    if (rect == null || rect.width <= 0 || rect.height <= 0) {
      return bounds;
    }
    return bounds == null ? rect : bounds.expandToInclude(rect);
  }

  /// API rectangle expanded by the chair orbit, then rotated about its center.
  /// The stored position, size, and rotation are not changed.
  static Rect? occupiedBounds(RestaurantTableModel table) {
    final Rect? rect = tableRect(table);
    if (rect == null) {
      return null;
    }
    final double reach =
        math.min(rect.width, rect.height) *
        AppDimensions.floorPlanSeatOrbitFraction;
    final Rect padded = Rect.fromLTRB(
      rect.left - reach,
      rect.top - reach,
      rect.right + reach,
      rect.bottom + reach,
    );
    return _rotatedAabb(padded, table.rotation ?? 0);
  }

  static Rect _rotatedAabb(Rect rect, double degrees) {
    final double turns = degrees / 360;
    if (turns == turns.roundToDouble()) {
      return rect;
    }
    final double radians = degrees * math.pi / 180;
    final double cosR = math.cos(radians);
    final double sinR = math.sin(radians);
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    for (final Offset corner in <Offset>[
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ]) {
      final double dx = corner.dx - cx;
      final double dy = corner.dy - cy;
      final double x = cx + dx * cosR - dy * sinR;
      final double y = cy + dx * sinR + dy * cosR;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Area box from the API.
  ///
  /// When the payload includes `positionX`/`positionY`/`width`/`height`, that
  /// box is used unchanged. Otherwise the area fills the API coordinate space
  /// of its tables: tables in the same vertical band share that band, and the
  /// gaps between bands come from those table coordinates.
  static Rect? areaRect(
    FloorPlanAreaModel area,
    List<RestaurantTableModel> tables, {
    List<FloorPlanAreaModel> areas = const <FloorPlanAreaModel>[],
  }) {
    if (area.hasExplicitBounds) {
      return Rect.fromLTWH(
        area.positionX!,
        area.positionY!,
        area.width!,
        area.height!,
      );
    }

    final List<FloorPlanAreaModel> known =
        areas.any((FloorPlanAreaModel item) => item.id == area.id)
        ? areas
        : <FloorPlanAreaModel>[...areas, area];
    final Map<String, Rect> seeds = _tableSeeds(known, tables);
    final Rect? seed = seeds[area.id];
    if (seed == null) {
      return null;
    }

    final List<_AreaBand> bands = _verticalBands(seeds);
    final int bandIndex = bands.indexWhere(
      (_AreaBand band) => band.seeds.containsKey(area.id),
    );
    if (bandIndex < 0) {
      return seed;
    }

    final double maxX = _contentMax(tables, axisIsX: true);
    final double maxY = _contentMax(tables, axisIsX: false);
    final _AreaBand band = bands[bandIndex];
    final double top = bandIndex == 0
        ? 0
        : (bands[bandIndex - 1].bounds.bottom + band.bounds.top) / 2;
    final double bottom = bandIndex == bands.length - 1
        ? maxY
        : (band.bounds.bottom + bands[bandIndex + 1].bounds.top) / 2;

    final List<MapEntry<String, Rect>> row =
        band.seeds.entries.toList(growable: false)..sort(
          (MapEntry<String, Rect> a, MapEntry<String, Rect> b) =>
              a.value.left.compareTo(b.value.left),
        );
    final int column = row.indexWhere(
      (MapEntry<String, Rect> entry) => entry.key == area.id,
    );
    if (column < 0) {
      return seed;
    }
    final double left = column == 0
        ? 0
        : (row[column - 1].value.right + row[column].value.left) / 2;
    final double right = column == row.length - 1
        ? maxX
        : (row[column].value.right + row[column + 1].value.left) / 2;

    final Rect expanded = Rect.fromLTRB(left, top, right, bottom);
    if (!expanded.contains(seed.center)) {
      return seed;
    }
    return expanded;
  }

  static Map<String, Rect> _tableSeeds(
    List<FloorPlanAreaModel> areas,
    List<RestaurantTableModel> tables,
  ) {
    final Set<String> explicit = <String>{
      for (final FloorPlanAreaModel area in areas)
        if (area.hasExplicitBounds) area.id,
    };
    final Map<String, Rect> seeds = <String, Rect>{};
    for (final RestaurantTableModel table in tables) {
      final String? areaId = table.floorPlanAreaId;
      if (areaId == null || explicit.contains(areaId)) {
        continue;
      }
      final Rect? rect = tableRect(table);
      if (rect == null) {
        continue;
      }
      final Rect? current = seeds[areaId];
      seeds[areaId] = current == null ? rect : current.expandToInclude(rect);
    }
    return seeds;
  }

  static double _contentMax(
    List<RestaurantTableModel> tables, {
    required bool axisIsX,
  }) {
    double maxValue = 0;
    for (final RestaurantTableModel table in tables) {
      final Rect? rect = tableRect(table);
      if (rect == null) {
        continue;
      }
      maxValue = math.max(maxValue, axisIsX ? rect.right : rect.bottom);
    }
    return maxValue;
  }

  static List<_AreaBand> _verticalBands(Map<String, Rect> seeds) {
    final List<MapEntry<String, Rect>> ordered =
        seeds.entries.toList(growable: false)..sort(
          (MapEntry<String, Rect> a, MapEntry<String, Rect> b) =>
              a.value.top.compareTo(b.value.top),
        );
    final List<_AreaBand> bands = <_AreaBand>[];
    for (final MapEntry<String, Rect> entry in ordered) {
      _AreaBand? matched;
      for (final _AreaBand band in bands) {
        if (band.bounds.top < entry.value.bottom &&
            entry.value.top < band.bounds.bottom) {
          matched = band;
          break;
        }
      }
      if (matched == null) {
        bands.add(_AreaBand({entry.key: entry.value}, entry.value));
        continue;
      }
      matched.seeds[entry.key] = entry.value;
      matched.bounds = matched.bounds.expandToInclude(entry.value);
    }
    bands.sort(
      (_AreaBand a, _AreaBand b) => a.bounds.top.compareTo(b.bounds.top),
    );
    return bands;
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
  ///
  /// [canvas] is treated as a box whose top-left is (0, 0). Prefer
  /// [frameContent] when the geometry's minimum is not the origin.
  static Matrix4 fitToViewport({required Size viewport, required Size canvas}) {
    final FloorPlanFrame frame = frameContent(
      viewport: viewport,
      content: Rect.fromLTWH(0, 0, canvas.width, canvas.height),
    );
    return Matrix4.identity()
      ..translateByDouble(frame.dx, frame.dy, 0, 1)
      ..scaleByDouble(frame.scale, frame.scale, 1, 1);
  }

  /// Uniform scale and translation from API space into [viewport].
  ///
  /// The inset is a fraction of the shorter viewport edge, so the same
  /// geometry stays inside a phone, a tablet, portrait, and landscape.
  static FloorPlanFrame frameContent({
    required Size viewport,
    required Rect content,
    double? inset,
  }) {
    if (viewport.width <= 0 ||
        viewport.height <= 0 ||
        content.width <= 0 ||
        content.height <= 0) {
      return FloorPlanFrame.identity;
    }

    final double resolvedInset =
        inset ??
        math.min(viewport.width, viewport.height) *
            AppDimensions.floorPlanViewportInsetFraction;
    final double innerWidth = viewport.width - resolvedInset * 2;
    final double innerHeight = viewport.height - resolvedInset * 2;
    if (innerWidth <= 0 || innerHeight <= 0) {
      return FloorPlanFrame.identity;
    }

    final double scale = math.min(
      innerWidth / content.width,
      innerHeight / content.height,
    );
    final double usedWidth = content.width * scale;
    final double usedHeight = content.height * scale;
    return FloorPlanFrame(
      scale: scale,
      dx: (viewport.width - usedWidth) / 2 - content.left * scale,
      dy: (viewport.height - usedHeight) / 2 - content.top * scale,
    );
  }
}

/// Presentation-only map from API coordinates into the floor-plan viewport.
class FloorPlanFrame {
  const FloorPlanFrame({
    required this.scale,
    required this.dx,
    required this.dy,
  });

  static const FloorPlanFrame identity = FloorPlanFrame(
    scale: 1,
    dx: 0,
    dy: 0,
  );

  final double scale;
  final double dx;
  final double dy;

  double x(double apiX) => apiX * scale + dx;

  double y(double apiY) => apiY * scale + dy;

  double length(double apiLength) => apiLength * scale;
}

class _AreaBand {
  _AreaBand(this.seeds, this.bounds);

  final Map<String, Rect> seeds;
  Rect bounds;
}
