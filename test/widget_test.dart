import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/common/widgets/restaurant_card.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_images.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';
import 'package:tavla/main.dart';

void main() {
  testWidgets('App loads with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TavlaApp());

    expect(find.text(AppStrings.splashTitle), findsOneWidget);

    await tester.pump(AppDimensions.splashDisplayDuration);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.home), findsWidgets);
  });

  testWidgets('Restaurant card shows fallback when image URL is invalid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantCard(
            restaurant: RestaurantModel(
              id: '1',
              name: 'Test Restaurant',
              cuisine: 'Italian',
              occasion: 'Dinner',
              description: 'A test restaurant.',
              imageUrl: AppImages.r1,
              location: 'Test City',
              availabilityLabel: 'Open now',
              isAvailable: true,
            ),
            isFavorite: false,
            onFavoritePressed: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });
}
