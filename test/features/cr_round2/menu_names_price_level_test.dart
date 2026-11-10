import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tavla/common/widgets/price_level_stars.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/features/branches/model/branch_model.dart';
import 'package:tavla/features/details/model/menu_item_model.dart';
import 'package:tavla/features/details/widgets/details_menu_section.dart';

void main() {
  group('MenuItemModel names', () {
    final MenuItemModel both = MenuItemModel.fromJson(<String, dynamic>{
      'id': 'i1',
      'name': 'شاورما',
      'nameAr': 'شاورما',
      'nameEn': 'Shawarma',
      'price': 10,
    });
    final MenuItemModel legacy = MenuItemModel.fromJson(<String, dynamic>{
      'id': 'i2',
      'name': 'Old item',
      'price': 5,
    });
    final MenuItemModel englishOnly = MenuItemModel.fromJson(<String, dynamic>{
      'id': 'i3',
      'name': 'Fries',
      'nameAr': null,
      'nameEn': 'Fries',
    });

    test('picks the app language and offers the other as secondary', () {
      expect(both.displayName(arabic: true), 'شاورما');
      expect(both.secondaryName(arabic: true), 'Shawarma');
      expect(both.displayName(arabic: false), 'Shawarma');
      expect(both.secondaryName(arabic: false), 'شاورما');
    });

    test('falls back to the other name, then to name', () {
      expect(englishOnly.displayName(arabic: true), 'Fries');
      expect(englishOnly.secondaryName(arabic: true), isEmpty);
      expect(legacy.displayName(arabic: true), 'Old item');
      expect(legacy.secondaryName(arabic: false), isEmpty);
    });

    testWidgets('menu section shows both names in Arabic', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DetailsMenuSection(menuItems: <MenuItemModel>[both]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('شاورما'), findsOneWidget);
      expect(find.text('Shawarma'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('branch reads its price level and ignores missing values', () {
    expect(
      BranchModel.fromJson(<String, dynamic>{
        'branchId': 'b1',
        'priceLevel': 3,
      }).priceLevel,
      3,
    );
    expect(
      BranchModel.fromJson(<String, dynamic>{
        'branchId': 'b1',
        'priceLevel': null,
      }).priceLevel,
      isNull,
    );
    expect(
      BranchModel.fromJson(<String, dynamic>{'branchId': 'b1'}).priceLevel,
      isNull,
    );
  });

  testWidgets('price level stars fill the level out of four', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const Scaffold(body: PriceLevelStars(level: 3)),
      ),
    );

    final List<Icon> icons = tester
        .widgetList<Icon>(find.byType(Icon))
        .toList();
    expect(icons, hasLength(4));
    expect(icons.where((Icon icon) => icon.fill == 1), hasLength(3));
    expect(find.bySemanticsLabel('Price level 3 of 4'), findsOneWidget);
  });

  testWidgets('no price level renders nothing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PriceLevelStars(level: null))),
    );
    expect(find.byType(Icon), findsNothing);
  });
}
