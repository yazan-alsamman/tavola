import 'menu_item_model.dart';
import 'opening_hours_day_model.dart';

class RestaurantDetailModel {
  const RestaurantDetailModel({
    required this.restaurantId,
    required this.rating,
    required this.locationBlurb,
    required this.about,
    required this.amenities,
    required this.openingHours,
    required this.phone,
    required this.menuItems,
    required this.locationNote,
    this.galleryImageUrls = const <String>[],
  });

  final String restaurantId;
  final String rating;
  final String locationBlurb;
  final String about;
  final List<String> amenities;
  final List<OpeningHoursDayModel> openingHours;
  final String phone;
  final List<MenuItemModel> menuItems;
  final String locationNote;
  final List<String> galleryImageUrls;

  RestaurantDetailModel copyWith({
    String? restaurantId,
    String? rating,
    String? locationBlurb,
    String? about,
    List<String>? amenities,
    List<OpeningHoursDayModel>? openingHours,
    String? phone,
    List<MenuItemModel>? menuItems,
    String? locationNote,
    List<String>? galleryImageUrls,
  }) {
    return RestaurantDetailModel(
      restaurantId: restaurantId ?? this.restaurantId,
      rating: rating ?? this.rating,
      locationBlurb: locationBlurb ?? this.locationBlurb,
      about: about ?? this.about,
      amenities: amenities ?? this.amenities,
      openingHours: openingHours ?? this.openingHours,
      phone: phone ?? this.phone,
      menuItems: menuItems ?? this.menuItems,
      locationNote: locationNote ?? this.locationNote,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
    );
  }
}
