import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/features/reservation/model/floor_plan_geometry.dart';
import 'package:tavla/features/reservation/model/restaurant_table_model.dart';

import 'floor_plan_test_fixtures.dart';

void main() {
  test('tableRect uses Backend positionX/Y/width/height unchanged', () {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(liveT5Json);
    final Rect? rect = FloorPlanGeometry.tableRect(table);

    expect(rect, isNotNull);
    expect(rect!.left, 592);
    expect(rect.top, 368);
    expect(rect.width, 128);
    expect(rect.height, 72);
  });

  test('canvas origin stays top-left and includes every table extent', () {
    final List<RestaurantTableModel> tables = <RestaurantTableModel>[
      RestaurantTableModel.fromJson(liveT1Json),
      RestaurantTableModel.fromJson(liveT5Json),
      RestaurantTableModel.fromJson(<String, dynamic>{
        'tableId': 'baae8733-eb46-4be7-860f-ff30a5d0ffa8',
        'tableNumber': 'T2',
        'positionX': 832,
        'positionY': 176,
        'width': 128,
        'height': 72,
      }),
    ];

    final Size canvas = FloorPlanGeometry.canvasSize(tables);
    expect(canvas.width, greaterThan(832 + 128));
    expect(canvas.height, greaterThan(368 + 72));
    expect(
      FloorPlanGeometry.tableRect(tables[0])!.left,
      464,
      reason: 'T1 X is not remapped to the canvas bounding box',
    );
  });

  test('missing geometry is not invented', () {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(
      <String, dynamic>{'tableId': 'x', 'tableNumber': 'T0'},
    );
    expect(FloorPlanGeometry.tableRect(table), isNull);
  });

  test('zoom matrix does not mutate stored geometry', () {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(liveT5Json);
    final Matrix4 zoomed = Matrix4.identity()..scaleByDouble(1.5, 1.5, 1, 1);
    expect(zoomed.getMaxScaleOnAxis(), 1.5);
    expect(table.positionX, 592);
    expect(table.positionY, 368);
    expect(table.width, 128);
    expect(table.height, 72);
    expect(table.rotation, 0);
    expect(FloorPlanGeometry.tableRect(table)!.left, 592);
    expect(FloorPlanGeometry.tableRect(table)!.top, 368);
  });

  test('fit-to-viewport is a render transform only', () {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(liveT5Json);
    final Size canvas = FloorPlanGeometry.canvasSize(<RestaurantTableModel>[
      table,
    ]);
    final Matrix4 fitted = FloorPlanGeometry.fitToViewport(
      viewport: const Size(390, 460),
      canvas: canvas,
    );

    expect(fitted.storage[0], isNot(1));
    expect(table.positionX, 592);
    expect(table.positionY, 368);
    expect(table.width, 128);
    expect(table.height, 72);
    expect(FloorPlanGeometry.tableRect(table)!.left, table.positionX);
    expect(FloorPlanGeometry.tableRect(table)!.top, table.positionY);
  });

  test('Dashboard geometry change moves the rendered rect', () {
    final Rect before = FloorPlanGeometry.tableRect(
      RestaurantTableModel.fromJson(liveT5Json),
    )!;
    final Rect after = FloorPlanGeometry.tableRect(
      RestaurantTableModel.fromJson(<String, dynamic>{
        ...liveT5Json,
        'positionX': 700,
        'positionY': 300,
      }),
    )!;

    expect(before.left, 592);
    expect(before.top, 368);
    expect(after.left, 700);
    expect(after.top, 300);
  });
}
