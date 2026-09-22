import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/features/reservation/model/restaurant_table_model.dart';
import 'package:tavla/features/reservation/model/table_status.dart';

import 'floor_plan_test_fixtures.dart';

void main() {
  test('maps Backend geometry and keeps tableId distinct from tableNumber', () {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(liveT5Json);

    expect(table.tableId, 'efd1304e-dfb5-45a8-9bc7-631321451a5d');
    expect(table.id, table.tableId);
    expect(table.tableNumber, 'T5');
    expect(table.label, 'T5');
    expect(table.tableId, isNot(table.tableNumber));
    expect(table.seatCount, 6);
    expect(table.positionX, 592);
    expect(table.positionY, 368);
    expect(table.width, 128);
    expect(table.height, 72);
    expect(table.rotation, 0);
    expect(table.shape, 'Rectangle');
    expect(table.hasExplicitStatus, isFalse);
    expect(table.status, TableStatus.available);
    expect(table.isAvailableForWindow, isNull);
    expect(table.hasRenderableGeometry, isTrue);
  });

  test('maps multiple live tables with distinct geometry and shapes', () {
    final RestaurantTableModel t1 = RestaurantTableModel.fromJson(liveT1Json);
    final RestaurantTableModel t3 = RestaurantTableModel.fromJson(liveT3Json);

    expect(t1.positionX, 464);
    expect(t1.positionY, 80);
    expect(t1.width, 160);
    expect(t1.height, 80);
    expect(t1.isRound, isFalse);
    expect(t3.positionX, 256);
    expect(t3.positionY, 320);
    expect(t3.shape, 'Round');
    expect(t3.isRound, isTrue);
  });

  test('does not invent geometry when Backend omits it', () {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(
      <String, dynamic>{'tableId': 'abc', 'tableNumber': 'T9', 'capacity': 2},
    );

    expect(table.positionX, isNull);
    expect(table.positionY, isNull);
    expect(table.width, isNull);
    expect(table.height, isNull);
    expect(table.rotation, isNull);
    expect(table.shape, isNull);
    expect(table.hasRenderableGeometry, isFalse);
  });

  test('isAvailable does not become Table.status', () {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(
      <String, dynamic>{
        'tableId': 'abc',
        'tableNumber': 'T9',
        'isAvailable': false,
      },
    );

    expect(table.status, TableStatus.available);
    expect(table.hasExplicitStatus, isFalse);
    expect(table.isAvailableForWindow, isFalse);
    expect(table.isSelectable, isFalse);
  });

  test('maps operational statuses without Reserved', () {
    expect(
      TableStatus.values.map((TableStatus status) => status.name),
      isNot(contains('reserved')),
    );
    expect(
      TableStatus.values,
      <TableStatus>[
        TableStatus.available,
        TableStatus.occupied,
        TableStatus.cleaning,
        TableStatus.disabled,
      ],
    );

    expect(
      RestaurantTableModel.fromJson(<String, dynamic>{
        'tableId': '1',
        'status': 'Occupied',
      }).status,
      TableStatus.occupied,
    );
    expect(
      RestaurantTableModel.fromJson(<String, dynamic>{
        'tableId': '1',
        'status': 'Cleaning',
      }).status,
      TableStatus.cleaning,
    );
    expect(
      RestaurantTableModel.fromJson(<String, dynamic>{
        'tableId': '1',
        'status': 'Disabled',
      }).status,
      TableStatus.disabled,
    );
    expect(
      RestaurantTableModel.fromJson(<String, dynamic>{
        'tableId': '1',
        'status': 'reserved',
      }).status,
      TableStatus.disabled,
    );
  });

  test('updated Dashboard geometry remaps without leftover coordinates', () {
    final RestaurantTableModel before = RestaurantTableModel.fromJson(
      liveT5Json,
    );
    final RestaurantTableModel after = RestaurantTableModel.fromJson(
      <String, dynamic>{...liveT5Json, 'positionX': 700, 'positionY': 300},
    );

    expect(before.positionX, 592);
    expect(before.positionY, 368);
    expect(after.positionX, 700);
    expect(after.positionY, 300);
    expect(after.width, before.width);
    expect(after.height, before.height);
    expect(after.rotation, before.rotation);
    expect(after.shape, before.shape);
    expect(after.tableId, before.tableId);
    expect(after.tableNumber, 'T5');
  });

  test('overlayAvailability keeps floor-plan geometry and uses tableId', () {
    final RestaurantTableModel floor = RestaurantTableModel.fromJson(liveT5Json);
    final RestaurantTableModel availability = RestaurantTableModel.fromJson(
      <String, dynamic>{
        'tableId': liveT5Json['tableId'],
        'tableNumber': 'T5',
        'isAvailable': false,
        'positionX': 0,
        'positionY': 0,
      },
    );

    final List<RestaurantTableModel> merged =
        RestaurantTableModel.overlayAvailability(
          floorPlan: <RestaurantTableModel>[floor],
          availability: <RestaurantTableModel>[availability],
        );

    expect(merged, hasLength(1));
    expect(merged.single.positionX, 592);
    expect(merged.single.positionY, 368);
    expect(merged.single.width, 128);
    expect(merged.single.height, 72);
    expect(merged.single.isAvailableForWindow, isFalse);
    expect(merged.single.status, TableStatus.available);
    expect(merged.single.isSelectable, isFalse);
  });

  test('overlayWith preserves geometry when get-by-id omits it', () {
    final RestaurantTableModel floor = RestaurantTableModel.fromJson(liveT5Json);
    final RestaurantTableModel fresh = RestaurantTableModel.fromJson(
      <String, dynamic>{
        'tableId': liveT5Json['tableId'],
        'tableNumber': 'T5',
        'status': 'Occupied',
        'capacity': 6,
      },
    );

    final RestaurantTableModel merged = floor.overlayWith(fresh);
    expect(merged.positionX, 592);
    expect(merged.positionY, 368);
    expect(merged.width, 128);
    expect(merged.height, 72);
    expect(merged.rotation, 0);
    expect(merged.shape, 'Rectangle');
    expect(merged.status, TableStatus.occupied);
    expect(merged.hasExplicitStatus, isTrue);
  });
}
