import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/core/constants/app_images.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';
import 'package:tavla/features/profile/widgets/profile_reservation_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'ProfileReservationCard lays out under unbounded height (onboarding)',
    (WidgetTester tester) async {
      // Mirrors onboarding confirmation: SizeTransition / Column(min) pass
      // unbounded max height — previously crashed with infinite height.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfileReservationCard(
                    restaurant: RestaurantModel(
                      id: AppStrings.restaurantIdTwo,
                      name: AppStrings.otakoSushi,
                      cuisine: AppStrings.sushi,
                      occasion: AppStrings.dinner,
                      description: AppStrings.otakoDescription,
                      imageUrl: AppImages.r3,
                      location: AppStrings.marinaBay,
                      availabilityLabel: AppStrings.openNow,
                      isAvailable: true,
                    ),
                    details: <(String, String)>[
                      (AppStrings.date, 'Fri 24'),
                      (AppStrings.time, '7:30 PM'),
                      (AppStrings.guests, '2'),
                    ],
                    showBottomMargin: false,
                    compact: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ProfileReservationCard), findsOneWidget);
      expect(find.text(AppStrings.otakoSushi), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
