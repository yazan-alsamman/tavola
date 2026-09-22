import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/features/reservation/model/restaurant_table_model.dart';
import 'package:tavla/features/reservation/widgets/restaurant_floor_map.dart';

import 'floor_plan_test_fixtures.dart';

void main() {
  Widget harness({
    required List<RestaurantTableModel> tables,
    required TextDirection textDirection,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: textDirection,
        child: SizedBox(
          width: 1200,
          height: 800,
          child: Stack(
            children: [
              for (final RestaurantTableModel table in tables)
                FloorPlanPlacedTable(
                  table: table,
                  isSelected: false,
                  onTap: () {},
                ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('renders each table at its own API geometry', (tester) async {
    final List<RestaurantTableModel> tables = <RestaurantTableModel>[
      RestaurantTableModel.fromJson(liveT1Json),
      RestaurantTableModel.fromJson(liveT3Json),
      RestaurantTableModel.fromJson(liveT5Json),
    ];

    await tester.pumpWidget(harness(tables: tables, textDirection: TextDirection.ltr));

    final Positioned t1 = tester.widget<Positioned>(
      find.byKey(const ValueKey<String>('floor-plan-position-64367a7e-acbb-4011-afc4-b4dd75393ea9')),
    );
    final Positioned t3 = tester.widget<Positioned>(
      find.byKey(const ValueKey<String>('floor-plan-position-0ad54710-b92c-428f-a4ac-a60bc86c5916')),
    );
    final Positioned t5 = tester.widget<Positioned>(
      find.byKey(const ValueKey<String>('floor-plan-position-efd1304e-dfb5-45a8-9bc7-631321451a5d')),
    );

    expect(t1.left, 464);
    expect(t1.top, 80);
    expect(t3.left, 256);
    expect(t3.top, 320);
    expect(t5.left, 592);
    expect(t5.top, 368);
    expect(find.text('T1'), findsOneWidget);
    expect(find.text('T3'), findsOneWidget);
    expect(find.text('T5'), findsOneWidget);
    expect(find.text('WINDOW'), findsNothing);
    expect(find.text('DINING'), findsNothing);
    expect(find.text('SERVICE'), findsNothing);
    expect(find.text('ENTRANCE'), findsNothing);
  });

  testWidgets('RTL does not mirror floor-plan coordinates', (tester) async {
    final RestaurantTableModel table = RestaurantTableModel.fromJson(liveT5Json);

    await tester.pumpWidget(
      harness(tables: <RestaurantTableModel>[table], textDirection: TextDirection.ltr),
    );
    final Positioned ltr = tester.widget<Positioned>(
      find.byKey(const ValueKey<String>('floor-plan-position-efd1304e-dfb5-45a8-9bc7-631321451a5d')),
    );

    await tester.pumpWidget(
      harness(tables: <RestaurantTableModel>[table], textDirection: TextDirection.rtl),
    );
    final Positioned rtl = tester.widget<Positioned>(
      find.byKey(const ValueKey<String>('floor-plan-position-efd1304e-dfb5-45a8-9bc7-631321451a5d')),
    );

    expect(ltr.left, 592);
    expect(ltr.top, 368);
    expect(rtl.left, 592);
    expect(rtl.top, 368);
    expect(rtl.right, isNull);
  });

  testWidgets('Dashboard coordinate change updates the placed table', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        tables: <RestaurantTableModel>[RestaurantTableModel.fromJson(liveT5Json)],
        textDirection: TextDirection.ltr,
      ),
    );
    expect(
      tester
          .widget<Positioned>(
            find.byKey(
              const ValueKey<String>(
                'floor-plan-position-efd1304e-dfb5-45a8-9bc7-631321451a5d',
              ),
            ),
          )
          .left,
      592,
    );

    await tester.pumpWidget(
      harness(
        tables: <RestaurantTableModel>[
          RestaurantTableModel.fromJson(<String, dynamic>{
            ...liveT5Json,
            'positionX': 700,
            'positionY': 300,
          }),
        ],
        textDirection: TextDirection.ltr,
      ),
    );
    final Positioned moved = tester.widget<Positioned>(
      find.byKey(
        const ValueKey<String>(
          'floor-plan-position-efd1304e-dfb5-45a8-9bc7-631321451a5d',
        ),
      ),
    );
    expect(moved.left, 700);
    expect(moved.top, 300);
  });

  testWidgets('does not place a table when geometry is missing', (tester) async {
    await tester.pumpWidget(
      harness(
        tables: <RestaurantTableModel>[
          RestaurantTableModel.fromJson(<String, dynamic>{
            'tableId': 'missing-geo',
            'tableNumber': 'TX',
          }),
        ],
        textDirection: TextDirection.ltr,
      ),
    );

    expect(find.byKey(const ValueKey<String>('floor-plan-position-missing-geo')), findsNothing);
    expect(find.text('TX'), findsNothing);
  });
}
