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

  /// Canvas origin stays (0, 0). Size is the axis-aligned extent of API tables
  /// and the dining-area bounds derived from those tables.
  static Size canvasSize(
    List<RestaurantTableModel> tables, {
    List<FloorPlanAreaModel> areas = const <FloorPlanAreaModel>[],
  }) {
    double maxX = 0;
    double maxY = 0;
    void include(Rect? rect) {
      if (rect == null) {
        return;
      }
      maxX = math.max(maxX, rect.right);
      maxY = math.max(maxY, rect.bottom);
    }

    for (final RestaurantTableModel table in tables) {
      include(tableRect(table));
    }
    for (final FloorPlanAreaModel area in areas) {
      include(areaRect(area, tables, areas: areas));
    }
    return Size(
      maxX + AppDimensions.floorPlanCanvasPadding,
      maxY + AppDimensions.floorPlanCanvasPadding,
    );
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
  static Matrix4 fitToViewport({required Size viewport, required Size canvas}) {
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

class _AreaBand {
  _AreaBand(this.seeds, this.bounds);

  final Map<String, Rect> seeds;
  Rect bounds;
}
