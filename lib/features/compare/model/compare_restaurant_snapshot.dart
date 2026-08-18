import '../../../core/constants/app_strings.dart';
import '../../details/model/restaurant_detail_model.dart';
import '../../home/model/restaurant_model.dart';

/// Merged discovery/compare + optional details view-model for one compare side.
class CompareRestaurantSnapshot {
  const CompareRestaurantSnapshot({required this.restaurant, this.detail});

  final RestaurantModel restaurant;
  final RestaurantDetailModel? detail;

  String get id => restaurant.id;

  String get name => restaurant.name.trim();

  String get imageUrl {
    final String fromRestaurant = restaurant.imageUrl.trim();
    if (fromRestaurant.isNotEmpty) {
      return fromRestaurant;
    }
    final List<String> gallery = detail?.galleryImageUrls ?? const <String>[];
    if (gallery.isEmpty) {
      return '';
    }
    return gallery.first.trim();
  }

  String get cuisineLabel {
    final String primary = restaurant.cuisine.trim();
    if (primary.isNotEmpty) {
      return AppStrings.localizeUiLabel(primary);
    }
    if (restaurant.cuisineTags.isEmpty) {
      return '';
    }
    return restaurant.cuisineTags
        .map(AppStrings.localizeUiLabel)
        .where((String tag) => tag.trim().isNotEmpty)
        .join(AppStrings.restaurantSummarySeparator);
  }

  String get occasionLabel {
    final String primary = restaurant.occasion.trim();
    if (primary.isNotEmpty) {
      return AppStrings.localizeUiLabel(primary);
    }
    if (restaurant.occasionTags.isEmpty) {
      return '';
    }
    return restaurant.occasionTags
        .map(AppStrings.localizeUiLabel)
        .where((String tag) => tag.trim().isNotEmpty)
        .join(AppStrings.restaurantSummarySeparator);
  }

  String get locationLabel {
    final String blurb = detail?.locationBlurb.trim() ?? '';
    if (blurb.isNotEmpty) {
      return blurb;
    }
    final String note = detail?.locationNote.trim() ?? '';
    if (note.isNotEmpty) {
      return note;
    }
    return restaurant.location.trim();
  }

  String get ratingLabel {
    final double? average = restaurant.averageRating;
    if (average != null && average > 0) {
      return average.toStringAsFixed(1);
    }
    final String detailRating = detail?.rating.trim() ?? '';
    if (detailRating.isEmpty || detailRating == AppStrings.ratingUnavailable) {
      return '';
    }
    return detailRating;
  }

  String get hoursLabel {
    final String today = detail?.todayHoursLabel.trim() ?? '';
    if (today.isNotEmpty) {
      return today;
    }
    return restaurant.hoursLabel.trim();
  }

  /// Discovery/compare `status` first (API source of truth for compare).
  String get statusLabel {
    final String status = restaurant.status.trim();
    if (status.isNotEmpty) {
      return AppStrings.localizeUiLabel(status);
    }
    if (detail != null && detail!.hasWorkingHours) {
      return detail!.isOpenNow ? AppStrings.openNow : AppStrings.hoursClosed;
    }
    final String availability = restaurant.availabilityLabel.trim();
    if (availability.isNotEmpty) {
      return availability;
    }
    return '';
  }

  String get aboutLabel {
    final String about = detail?.about.trim() ?? '';
    if (about.isNotEmpty && about != AppStrings.restaurantDetailsEmpty) {
      return about;
    }
    return restaurant.description.trim();
  }

  String get amenitiesLabel {
    final List<String> amenities = detail?.amenities ?? const <String>[];
    if (amenities.isEmpty) {
      return '';
    }
    return amenities
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .map(AppStrings.localizeUiLabel)
        .join(AppStrings.restaurantSummarySeparator);
  }

  String get activeOfferLabel =>
      restaurant.hasActiveOffer ? AppStrings.yes : AppStrings.no;

  String get priceLevelLabel {
    final int? level = restaurant.priceLevel;
    if (level == null || level <= 0) {
      return '';
    }
    return AppStrings.priceLevelSymbols(level);
  }

  String get hasMenuLabel =>
      restaurant.hasMenu ? AppStrings.yes : AppStrings.no;
}
