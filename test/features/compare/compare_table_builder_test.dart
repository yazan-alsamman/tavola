import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/features/compare/model/compare_restaurant_snapshot.dart';
import 'package:tavla/features/compare/model/compare_row_model.dart';
import 'package:tavla/features/compare/model/compare_table_builder.dart';
import 'package:tavla/features/details/model/menu_item_model.dart';
import 'package:tavla/features/details/model/opening_hours_day_model.dart';
import 'package:tavla/features/details/model/restaurant_detail_model.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en');
  });

  tearDown(Get.reset);

  RestaurantModel restaurant({
    required String id,
    required String name,
    String cuisine = '',
    String location = '',
    double? rating,
    bool offer = false,
    int? priceLevel,
    bool hasMenu = false,
    String status = '',
    String description = '',
  }) {
    return RestaurantModel(
      id: id,
      name: name,
      cuisine: cuisine,
      occasion: '',
      description: description,
      imageUrl: '',
      location: location,
      availabilityLabel: AppStrings.openNow,
      isAvailable: true,
      averageRating: rating,
      hasActiveOffer: offer,
      priceLevel: priceLevel,
      hasMenu: hasMenu,
      status: status,
    );
  }

  test('hides rows when both sides lack values', () {
    final List<CompareRowModel> rows = CompareTableBuilder.build(
      sideA: CompareRestaurantSnapshot(
        restaurant: restaurant(id: 'a', name: 'A'),
      ),
      sideB: CompareRestaurantSnapshot(
        restaurant: restaurant(id: 'b', name: 'B'),
      ),
    );

    expect(
      rows.any(
        (CompareRowModel row) => row.label == AppStrings.compareFieldCuisine,
      ),
      isFalse,
    );
    expect(
      rows.any(
        (CompareRowModel row) => row.label == AppStrings.compareFieldRating,
      ),
      isFalse,
    );
    // Boolean compare-API fields always surface Yes/No.
    expect(
      rows.any(
        (CompareRowModel row) =>
            row.label == AppStrings.compareFieldActiveOffer,
      ),
      isTrue,
    );
    expect(
      rows.any(
        (CompareRowModel row) => row.label == AppStrings.compareFieldHasMenu,
      ),
      isTrue,
    );
  });

  test('maps compare API fields into UI rows', () {
    final List<CompareRowModel> rows = CompareTableBuilder.build(
      sideA: CompareRestaurantSnapshot(
        restaurant: restaurant(
          id: 'a',
          name: 'A',
          cuisine: 'Italian',
          rating: 4.5,
          offer: false,
          priceLevel: 3,
          hasMenu: true,
          status: 'Active',
          description: 'Cozy spot',
        ),
      ),
      sideB: CompareRestaurantSnapshot(
        restaurant: restaurant(
          id: 'b',
          name: 'B',
          cuisine: 'Japanese',
          rating: 4.1,
          offer: true,
          priceLevel: 2,
          hasMenu: false,
          status: 'Active',
          description: 'Sushi bar',
        ),
      ),
    );

    final Map<String, CompareRowModel> byLabel = <String, CompareRowModel>{
      for (final CompareRowModel row in rows) row.label: row,
    };

    expect(byLabel[AppStrings.compareFieldCuisine]!.valueA, isNotEmpty);
    expect(byLabel[AppStrings.compareFieldCuisine]!.valueB, isNotEmpty);
    expect(byLabel[AppStrings.compareFieldRating]!.valueA, '4.5');
    expect(byLabel[AppStrings.compareFieldRating]!.valueB, '4.1');
    expect(byLabel[AppStrings.compareFieldStatus]!.valueA, 'Active');
    expect(byLabel[AppStrings.compareFieldPriceLevel]!.valueA, '\$\$\$');
    expect(byLabel[AppStrings.compareFieldPriceLevel]!.valueB, '\$\$');
    expect(byLabel[AppStrings.compareFieldHasMenu]!.valueA, AppStrings.yes);
    expect(byLabel[AppStrings.compareFieldHasMenu]!.valueB, AppStrings.no);
    expect(
      byLabel[AppStrings.compareFieldActiveOffer]!.valueA,
      AppStrings.no,
    );
    expect(
      byLabel[AppStrings.compareFieldActiveOffer]!.valueB,
      AppStrings.yes,
    );
    expect(byLabel[AppStrings.compareFieldAbout]!.valueA, 'Cozy spot');
  });

  test('includes detail enrichment fields when present', () {
    final List<CompareRowModel> rows = CompareTableBuilder.build(
      sideA: CompareRestaurantSnapshot(
        restaurant: restaurant(
          id: 'a',
          name: 'A',
          cuisine: 'Italian',
          rating: 4.5,
        ),
        detail: const RestaurantDetailModel(
          restaurantId: 'a',
          rating: '4.5',
          locationBlurb: 'Downtown',
          about: 'Cozy spot',
          amenities: <String>[],
          openingHours: <OpeningHoursDayModel>[],
          menuItems: <MenuItemModel>[],
          locationNote: '',
        ),
      ),
      sideB: CompareRestaurantSnapshot(
        restaurant: restaurant(
          id: 'b',
          name: 'B',
          cuisine: 'Japanese',
          offer: true,
        ),
      ),
    );

    final Set<String> labels = rows.map((CompareRowModel r) => r.label).toSet();
    expect(labels, contains(AppStrings.compareFieldLocation));
    expect(labels, isNot(contains(AppStrings.compareFieldAmenities)));
  });

  test('returns empty when either side is missing', () {
    expect(
      CompareTableBuilder.build(
        sideA: CompareRestaurantSnapshot(
          restaurant: restaurant(id: 'a', name: 'A'),
        ),
        sideB: null,
      ),
      isEmpty,
    );
  });
}
