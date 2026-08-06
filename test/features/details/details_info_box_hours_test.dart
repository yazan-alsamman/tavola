import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/features/details/model/opening_hours_day_model.dart';
import 'package:tavla/features/details/widgets/details_info_box.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      home: Scaffold(body: child),
    );
  }

  testWidgets('Hours section stays visible when openingHours is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const DetailsInfoBox(
          openingHours: <OpeningHoursDayModel>[],
          phone: '+1 312 555 0188',
        ),
      ),
    );

    expect(find.text(AppStrings.hours), findsOneWidget);
    expect(find.text(AppStrings.hoursUnavailable), findsOneWidget);
    expect(find.text(AppStrings.contact), findsOneWidget);
  });

  testWidgets('Hours section renders API day rows when present', (tester) async {
    await tester.pumpWidget(
      wrap(
        const DetailsInfoBox(
          openingHours: <OpeningHoursDayModel>[
            OpeningHoursDayModel(day: 'Monday', hours: '09:00 – 22:00'),
          ],
          phone: '+1 312 555 0188',
        ),
      ),
    );

    expect(find.text(AppStrings.hours), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('09:00 – 22:00'), findsOneWidget);
    expect(find.text(AppStrings.hoursUnavailable), findsNothing);
  });
}
