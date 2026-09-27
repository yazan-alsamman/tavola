import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/features/discovery/model/discovery_floor_plan_model.dart';
import 'package:tavla/features/reservation/model/floor_plan_area_model.dart';
import 'package:tavla/features/reservation/model/floor_plan_geometry.dart';
import 'package:tavla/features/reservation/model/restaurant_table_model.dart';

import 'floor_plan_test_fixtures.dart';

void main() {
  test('tableRect uses Backend positionX/Y/width/height unchanged', () {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(
      liveT5Json,
    );
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
    final RestaurantTableModel table = RestaurantTableModel.fromJson(
      liveT5Json,
    );
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
    final RestaurantTableModel table = RestaurantTableModel.fromJson(
      liveT5Json,
    );
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

  test('area bounds follow member tables and keep the API name and color', () {
    final DiscoveryFloorPlanModel plan = DiscoveryFloorPlanModel.fromJsonRaw(
      <String, dynamic>{
        'floorPlan': <String, dynamic>{
          'floorPlanId': 'plan-1',
          'branchId': 'branch-1',
          'name': 'Hhh',
        },
        'areas': <Map<String, dynamic>>[
          <String, dynamic>{
            'floorPlanAreaId': 'area-terrace',
            'name': 'التراس',
            'color': '#9D174D',
            'sortOrder': 2,
          },
          <String, dynamic>{
            'floorPlanAreaId': 'area-vip',
            'name': 'غرفة VIP',
            'color': '#6D28D9',
            'sortOrder': 1,
          },
        ],
        'tables': <Map<String, dynamic>>[
          <String, dynamic>{
            'tableId': 't-vip',
            'tableNumber': 'T8',
            'floorPlanAreaId': 'area-vip',
            'positionX': 400,
            'positionY': 80,
            'width': 80,
            'height': 80,
          },
          <String, dynamic>{
            'tableId': 't-terrace',
            'tableNumber': 'T11',
            'floorPlanAreaId': 'area-terrace',
            'positionX': 112,
            'positionY': 528,
            'width': 96,
            'height': 64,
          },
        ],
      },
    );

    expect(plan.areas.first.name, 'غرفة VIP');
    expect(
      FloorPlanAreaModel.translationKeyFor('الصالة الرئيسية'),
      'Main Hall',
    );
    expect(FloorPlanAreaModel.translationKeyFor('غرفة VIP'), 'VIP');
    expect(FloorPlanAreaModel.translationKeyFor('التراس'), 'Terrace');
    expect(FloorPlanAreaModel.translationKeyFor('Terrace'), 'Terrace');
    expect(FloorPlanAreaModel.translationKeyFor('Chef Table'), isNull);
    expect(plan.areas.first.colorValue, const Color(0xFF6D28D9));
    expect(plan.tables.first.floorPlanAreaId, 'area-vip');

    final Rect vip = FloorPlanGeometry.areaRect(
      plan.areas[0],
      plan.tables,
      areas: plan.areas,
    )!;
    final Rect terrace = FloorPlanGeometry.areaRect(
      plan.areas[1],
      plan.tables,
      areas: plan.areas,
    )!;
    expect(vip.overlaps(terrace), isFalse);
    expect(vip.contains(const Offset(440, 120)), isTrue);
    expect(terrace.contains(const Offset(160, 560)), isTrue);
    expect(vip.width, greaterThan(80 + 48));
    expect(terrace.width, greaterThan(96 + 48));
  });

  test('explicit API area bounds are used unchanged', () {
    final DiscoveryFloorPlanModel plan = DiscoveryFloorPlanModel.fromJsonRaw(
      <String, dynamic>{
        'floorPlan': <String, dynamic>{
          'floorPlanId': 'plan-1',
          'branchId': 'branch-1',
          'name': 'Hall',
        },
        'areas': <Map<String, dynamic>>[
          <String, dynamic>{
            'floorPlanAreaId': 'area-vip',
            'name': 'غرفة VIP',
            'color': '#6D28D9',
            'sortOrder': 0,
            'positionX': 10,
            'positionY': 20,
            'width': 300,
            'height': 150,
          },
        ],
        'tables': <Map<String, dynamic>>[
          <String, dynamic>{
            'tableId': 't-vip',
            'tableNumber': 'T8',
            'floorPlanAreaId': 'area-vip',
            'positionX': 40,
            'positionY': 40,
            'width': 80,
            'height': 80,
          },
        ],
      },
    );

    final Rect vip = FloorPlanGeometry.areaRect(
      plan.areas.single,
      plan.tables,
      areas: plan.areas,
    )!;
    expect(vip.left, 10);
    expect(vip.top, 20);
    expect(vip.width, 300);
    expect(vip.height, 150);
  });
}
