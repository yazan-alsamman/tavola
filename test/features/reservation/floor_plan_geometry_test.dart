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

  test('content bounds use the real minimum and do not rewrite API geometry', () {
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

    final Rect bounds = FloorPlanGeometry.contentBounds(tables)!;
    expect(bounds.left, lessThan(464));
    expect(bounds.right, greaterThan(832 + 128));
    expect(bounds.bottom, greaterThan(368 + 72));
    expect(bounds.left, isNot(0));
    expect(
      FloorPlanGeometry.tableRect(tables[0])!.left,
      464,
      reason: 'T1 X is not remapped to the canvas bounding box',
    );
    expect(tables[0].positionX, 464);
  });

  test('rotated geometry stays inside the viewport without changing API values', () {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(
      <String, dynamic>{
        'tableId': 'rotated',
        'tableNumber': 'T9',
        'positionX': -40,
        'positionY': 800,
        'width': 200,
        'height': 40,
        'rotation': 45,
      },
    );
    const Size viewport = Size(390, 520);
    final Rect bounds = FloorPlanGeometry.contentBounds(
      <RestaurantTableModel>[table],
    )!;
    final FloorPlanFrame frame = FloorPlanGeometry.frameContent(
      viewport: viewport,
      content: bounds,
    );
    final Rect occupied = FloorPlanGeometry.occupiedBounds(table)!;

    expect(table.positionX, -40);
    expect(table.positionY, 800);
    expect(table.width, 200);
    expect(table.height, 40);
    expect(table.rotation, 45);
    expect(occupied.height, greaterThan(table.height!));
    expect(occupied, isNot(FloorPlanGeometry.tableRect(table)));
    expect(frame.scale, greaterThan(0));
    expect(frame.x(occupied.left), greaterThanOrEqualTo(0));
    expect(frame.y(occupied.top), greaterThanOrEqualTo(0));
    expect(frame.x(occupied.right), lessThanOrEqualTo(viewport.width));
    expect(frame.y(occupied.bottom), lessThanOrEqualTo(viewport.height));
    expect(
      (frame.x(occupied.right) - frame.x(occupied.left)) / occupied.width,
      closeTo(frame.scale, 0.0001),
    );
  });

  test('distant tables keep one uniform scale inside a small viewport', () {
    final List<RestaurantTableModel> tables = <RestaurantTableModel>[
      RestaurantTableModel.fromJson(<String, dynamic>{
        'tableId': 'near',
        'tableNumber': 'A',
        'positionX': 20,
        'positionY': 20,
        'width': 40,
        'height': 40,
      }),
      RestaurantTableModel.fromJson(<String, dynamic>{
        'tableId': 'far',
        'tableNumber': 'B',
        'positionX': 4000,
        'positionY': 20,
        'width': 80,
        'height': 30,
      }),
    ];
    const Size viewport = Size(320, 180);
    final FloorPlanFrame frame = FloorPlanGeometry.frameContent(
      viewport: viewport,
      content: FloorPlanGeometry.contentBounds(tables)!,
    );
    final Rect first = FloorPlanGeometry.occupiedBounds(tables[0])!;
    final Rect second = FloorPlanGeometry.occupiedBounds(tables[1])!;

    expect(frame.length(80) / 80, frame.scale);
    expect(frame.length(40) / 40, frame.scale);
    expect(frame.x(first.left), greaterThanOrEqualTo(0));
    expect(frame.x(second.right), lessThanOrEqualTo(viewport.width));
    expect(frame.y(first.top), greaterThanOrEqualTo(0));
    expect(frame.y(second.bottom), lessThanOrEqualTo(viewport.height));
    expect(tables[1].positionX, 4000);
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

  test('area chrome wraps member tables and the measured label', () {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(
      <String, dynamic>{
        'tableId': 't-hall',
        'tableNumber': 'T6',
        'floorPlanAreaId': 'hall',
        'positionX': 500,
        'positionY': 240,
        'width': 80,
        'height': 40,
      },
    );
    const FloorPlanAreaModel area = FloorPlanAreaModel(
      id: 'hall',
      name: 'Main Hall',
      sortOrder: 0,
      positionX: 0,
      positionY: 0,
      width: 2000,
      height: 2000,
    );
    final Rect cluster = FloorPlanGeometry.areaCluster(
      area,
      <RestaurantTableModel>[table],
    )!;
    final Rect wrapped = FloorPlanGeometry.encloseCluster(
      cluster: cluster,
      sideApi: 12,
      topBandApi: 18,
      minWidthApi: 90,
    );

    expect(table.positionX, 500);
    expect(table.positionY, 240);
    expect(area.positionX, 0);
    expect(area.width, 2000);
    expect(cluster.left, greaterThan(400));
    expect(wrapped.top, lessThan(cluster.top));
    expect(wrapped.left, lessThanOrEqualTo(cluster.left));
    expect(wrapped.right, greaterThanOrEqualTo(cluster.right));
    expect(wrapped.bottom, greaterThanOrEqualTo(cluster.bottom));
    expect(wrapped.width, greaterThanOrEqualTo(90));
    expect(wrapped.contains(cluster.center), isTrue);
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
