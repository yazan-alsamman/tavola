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
}
