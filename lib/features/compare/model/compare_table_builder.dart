import '../../../core/constants/app_strings.dart';
import 'compare_restaurant_snapshot.dart';
import 'compare_row_model.dart';

/// Builds comparison rows from compare/Discovery API fields (+ detail extras).
class CompareTableBuilder {
  CompareTableBuilder._();

  static List<CompareRowModel> build({
    required CompareRestaurantSnapshot? sideA,
    required CompareRestaurantSnapshot? sideB,
  }) {
    if (sideA == null || sideB == null) {
      return const <CompareRowModel>[];
    }

    final List<CompareRowModel> rows = <CompareRowModel>[];
    void add(String label, String valueA, String valueB) {
      final CompareRowModel row = CompareRowModel(
        label: label,
        valueA: valueA.trim(),
        valueB: valueB.trim(),
      );
      if (row.hasAnyValue) {
        rows.add(row);
      }
    }

    // Fields returned by `POST /discovery/restaurants/compare`.
    add(AppStrings.compareFieldRating, sideA.ratingLabel, sideB.ratingLabel);
    add(AppStrings.compareFieldCuisine, sideA.cuisineLabel, sideB.cuisineLabel);
    add(AppStrings.compareFieldStatus, sideA.statusLabel, sideB.statusLabel);
    add(
      AppStrings.compareFieldPriceLevel,
      sideA.priceLevelLabel,
      sideB.priceLevelLabel,
    );
    add(AppStrings.compareFieldHasMenu, sideA.hasMenuLabel, sideB.hasMenuLabel);
    add(
      AppStrings.compareFieldActiveOffer,
      sideA.activeOfferLabel,
      sideB.activeOfferLabel,
    );
    add(AppStrings.compareFieldAbout, sideA.aboutLabel, sideB.aboutLabel);

    // Optional enrichment from Details / branches (not on compare DTO).
    add(
      AppStrings.compareFieldOccasion,
      sideA.occasionLabel,
      sideB.occasionLabel,
    );
    add(
      AppStrings.compareFieldLocation,
      sideA.locationLabel,
      sideB.locationLabel,
    );
    add(AppStrings.compareFieldHours, sideA.hoursLabel, sideB.hoursLabel);
    add(
      AppStrings.compareFieldAmenities,
      sideA.amenitiesLabel,
      sideB.amenitiesLabel,
    );

    return rows;
  }
}
