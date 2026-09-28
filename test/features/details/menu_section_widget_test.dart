import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/features/details/model/menu_category_model.dart';
import 'package:tavla/features/details/widgets/details_menu_section.dart';

void main() {
  testWidgets('menu section shows only API fields and featured when true', (
    WidgetTester tester,
  ) async {
    final MenuCategoryModel category = MenuCategoryModel.fromJson(
      <String, dynamic>{
        'id': 'c1',
        'name': 'Category A',
        'description': '',
        'imageUrl': null,
        'displayOrder': 1,
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'featured',
            'name': 'Featured dish',
            'description': 'A' * 180,
            'price': 20,
            'currency': 'SR',
            'imageUrl': null,
            'isFeatured': true,
          },
          <String, dynamic>{
            'id': 'plain',
            'name':
                'Plain dish with a long name that must stay inside the card',
            'description': '',
            'price': 38,
            'currency': null,
            'imageUrl': '',
            'isFeatured': false,
          },
          <String, dynamic>{
            'id': 'unset',
            'name': 'Unset featured',
            'description': null,
            'price': null,
            'imageUrl': '/files/not-signed',
            'isFeatured': null,
          },
        ],
      },
    );

    for (final Size size in const <Size>[Size(390, 844), Size(320, 700)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DetailsMenuSection(
                menuItems: category.items,
                categories: <MenuCategoryModel>[category],
                menuTitle: 'Default',
                showHeading: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    }

    expect(find.text('Featured'), findsOneWidget);
    expect(find.text('Category A'), findsOneWidget);
    expect(find.text('Featured dish'), findsOneWidget);
    expect(
      find.text('Plain dish with a long name that must stay inside the card'),
      findsOneWidget,
    );
    expect(find.text('Unset featured'), findsOneWidget);
    expect(find.text('SR20'), findsOneWidget);
    expect(find.text('38'), findsOneWidget);
  });
}
