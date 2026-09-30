import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/features/reservation/widgets/floor_plan_unavailable_notice.dart';

void main() {
  testWidgets('unavailable notice stays for two seconds then dismisses', (
    WidgetTester tester,
  ) async {
    var dismissed = false;
    const String message = 'This table is currently unavailable.';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: FloorPlanUnavailableNotice(
              message: message,
              onDismissed: () => dismissed = true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('floor-plan-unavailable-notice')),
      findsOneWidget,
    );
    expect(find.text(message), findsOneWidget);
    expect(dismissed, isFalse);

    await tester.pump(
      AppDimensions.floorPlanUnavailableNoticeDuration -
          const Duration(milliseconds: 1),
    );
    expect(find.text(message), findsOneWidget);
    expect(dismissed, isFalse);

    await tester.pump(
      AppDimensions.hoverDuration + const Duration(milliseconds: 1),
    );
    expect(dismissed, isTrue);
  });
}
