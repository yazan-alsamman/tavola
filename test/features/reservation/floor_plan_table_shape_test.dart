import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/core/constants/app_colors.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/features/reservation/model/restaurant_table_model.dart';
import 'package:tavla/features/reservation/model/table_status.dart';
import 'package:tavla/features/reservation/model/table_status_theme.dart';
import 'package:tavla/features/reservation/widgets/floor_plan_table.dart';

void main() {
  const String databaseId = 'efd1304e-dfb5-45a8-9bc7-631321451a5d';

  RestaurantTableModel table({
    required String shape,
    required double width,
    required double height,
    double rotation = 0,
    String tableNumber = 'T5',
    int capacity = 0,
    bool? isAvailable,
    String? status,
  }) {
    return RestaurantTableModel.fromJson(<String, dynamic>{
      'tableId': databaseId,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'shape': shape,
      'positionX': 592,
      'positionY': 368,
      'width': width,
      'height': height,
      'rotation': rotation,
      'isAvailable': ?isAvailable,
      'status': ?status,
    });
  }

  Future<void> pumpTable(
    WidgetTester tester,
    RestaurantTableModel model, {
    bool isSelected = false,
    VoidCallback? onTap,
    bool scaffold = false,
  }) {
    final FloorPlanTable child = FloorPlanTable(
      table: model,
      isSelected: isSelected,
      onTap: onTap ?? () {},
      width: model.width!,
      height: model.height!,
    );
    return tester.pumpWidget(
      MaterialApp(
        home: scaffold
            ? Scaffold(body: Center(child: child))
            : Center(child: child),
      ),
    );
  }

  int seatCount(WidgetTester tester) {
    return tester.widgetList(find.byType(Positioned)).where((Widget widget) {
      final Key? key = widget.key;
      return key is ValueKey<String> &&
          key.value.startsWith('floor-plan-seat-');
    }).length;
  }

  final Finder bodyFinder = find.byType(AnimatedContainer);

  AnimatedContainer bodyOf(WidgetTester tester) {
    return tester.widget<AnimatedContainer>(bodyFinder);
  }

  BorderRadius radiusOf(WidgetTester tester) {
    final BoxDecoration decoration =
        bodyOf(tester).decoration! as BoxDecoration;
    return decoration.borderRadius! as BorderRadius;
  }

  void expectBodySize(WidgetTester tester, double width, double height) {
    expect(tester.getSize(bodyFinder), Size(width, height));
  }

  testWidgets('Circle and Round render a circle that fills an equal box', (
    WidgetTester tester,
  ) async {
    for (final String shape in <String>['Circle', 'Round']) {
      await pumpTable(tester, table(shape: shape, width: 80, height: 80));
      expectBodySize(tester, 80, 80);
      expect(
        radiusOf(tester),
        const BorderRadius.all(Radius.elliptical(40, 40)),
      );
    }
  });

  testWidgets('Oval and Ellipse keep the backend width and height', (
    WidgetTester tester,
  ) async {
    for (final String shape in <String>['Oval', 'Ellipse']) {
      await pumpTable(tester, table(shape: shape, width: 128, height: 72));
      expectBodySize(tester, 128, 72);
      expect(
        radiusOf(tester),
        const BorderRadius.all(Radius.elliptical(64, 36)),
      );
    }
  });

  testWidgets('Rectangle preserves backend width and height', (
    WidgetTester tester,
  ) async {
    await pumpTable(tester, table(shape: 'Rectangle', width: 128, height: 72));
    expectBodySize(tester, 128, 72);
    expect(
      radiusOf(tester),
      BorderRadius.circular(AppDimensions.floorPlanTableRadius),
    );
  });

  testWidgets('Square preserves equal backend dimensions', (
    WidgetTester tester,
  ) async {
    await pumpTable(tester, table(shape: 'Square', width: 96, height: 96));
    expectBodySize(tester, 96, 96);
    expect(
      radiusOf(tester),
      BorderRadius.circular(AppDimensions.floorPlanTableRadius),
    );
  });

  testWidgets('rotation degrees are applied around the table center', (
    WidgetTester tester,
  ) async {
    await pumpTable(
      tester,
      table(shape: 'Rectangle', width: 128, height: 72, rotation: 90),
    );
    final Transform spin = tester.widget<Transform>(
      find.byType(Transform).first,
    );
    expect(spin.alignment, Alignment.center);
    final Matrix4 expected = Matrix4.rotationZ((90.0 * math.pi) / 180);
    for (int i = 0; i < 16; i++) {
      expect(spin.transform.storage[i], closeTo(expected.storage[i], 1e-9));
    }
  });

  testWidgets(
    'shows tableNumber and keeps isAvailable off operational status',
    (WidgetTester tester) async {
      final RestaurantTableModel model = table(
        shape: 'Rectangle',
        width: 128,
        height: 72,
        isAvailable: false,
      );
      expect(model.status, TableStatus.available);
      expect(model.isAvailableForWindow, isFalse);
      expect(model.tableNumber, 'T5');
      expect(model.tableId, databaseId);

      await pumpTable(tester, model);
      expect(find.text('T5'), findsOneWidget);
      expect(find.text(databaseId), findsNothing);
      final BoxDecoration decoration =
          bodyOf(tester).decoration! as BoxDecoration;
      expect(model.isSlotUnavailable, isTrue);
      expect(model.presentedStatusLabel, 'UNAVAILABLE');
      expect(decoration.color, SlotUnavailablePresentation.tableColor);
      expect(
        decoration.color,
        isNot(TableStatus.available.tableBackgroundColor),
      );
      expect(
        (decoration.border! as Border).top.color,
        SlotUnavailablePresentation.borderColor,
      );
    },
  );

  testWidgets('selection highlight does not repaint an occupied table', (
    WidgetTester tester,
  ) async {
    await pumpTable(
      tester,
      table(shape: 'Round', width: 80, height: 80, status: 'occupied'),
      isSelected: true,
    );
    final BoxDecoration decoration =
        bodyOf(tester).decoration! as BoxDecoration;
    expect(decoration.color, TableStatus.occupied.tableBackgroundColor);
    expect(decoration.color, isNot(AppColors.primaryDark));
  });

  testWidgets('places one seat mark per backend capacity', (
    WidgetTester tester,
  ) async {
    for (final int capacity in <int>[2, 4, 6, 8]) {
      await pumpTable(
        tester,
        table(shape: 'Circle', width: 80, height: 80, capacity: capacity),
      );
      expect(seatCount(tester), capacity);
      await pumpTable(
        tester,
        table(shape: 'Rectangle', width: 160, height: 80, capacity: capacity),
      );
      expect(seatCount(tester), capacity);
      await pumpTable(
        tester,
        table(shape: 'Oval', width: 140, height: 70, capacity: capacity),
      );
      expect(seatCount(tester), capacity);
    }
  });

  testWidgets('map color matches the status label for every state', (
    WidgetTester tester,
  ) async {
    for (final String status in <String>[
      'available',
      'occupied',
      'cleaning',
      'disabled',
    ]) {
      final RestaurantTableModel model = table(
        shape: 'Rectangle',
        width: 128,
        height: 72,
        status: status,
        isAvailable: true,
      );
      expect(model.isSlotUnavailable, isFalse);
      expect(model.presentedStatusLabel, model.status.label);
      expect(model.presentedTableColor, model.status.tableBackgroundColor);
      expect(model.presentedBadgeColor, model.status.badgeColor);
      await pumpTable(tester, model);
      final BoxDecoration decoration =
          bodyOf(tester).decoration! as BoxDecoration;
      expect(decoration.color, model.presentedTableColor);
      expect(
        (decoration.border! as Border).top.color,
        model.presentedBorderColor,
      );
    }

    final RestaurantTableModel blocked = table(
      shape: 'Rectangle',
      width: 128,
      height: 72,
      status: 'available',
      isAvailable: false,
    );
    expect(blocked.status, TableStatus.available);
    expect(blocked.presentedStatusLabel, SlotUnavailablePresentation.label);
    expect(blocked.presentedTableColor, SlotUnavailablePresentation.tableColor);
    expect(blocked.presentedBadgeColor, SlotUnavailablePresentation.badgeColor);
    expect(
      blocked.presentedTableColor,
      isNot(TableStatus.available.tableBackgroundColor),
    );
    await pumpTable(tester, blocked, isSelected: true);
    final BoxDecoration blockedDecoration =
        bodyOf(tester).decoration! as BoxDecoration;
    expect(blockedDecoration.color, blocked.presentedTableColor);
    expect(blockedDecoration.color, isNot(AppColors.primaryDark));
  });

  testWidgets('tapping an unavailable table reports the tap for its status', (
    WidgetTester tester,
  ) async {
    var selected = false;
    await pumpTable(
      tester,
      table(shape: 'Rectangle', width: 128, height: 72, isAvailable: false),
      onTap: () => selected = true,
      scaffold: true,
    );
    expect(find.text('UNAVAILABLE'), findsNothing);
    await tester.tap(find.byType(FloorPlanTable));
    await tester.pump();
    expect(selected, isTrue);
    expect(find.text('T5'), findsOneWidget);
  });
}
