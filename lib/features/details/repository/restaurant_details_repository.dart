import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../branches/model/branch_model.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../model/menu_item_model.dart';
import '../model/opening_hours_day_model.dart';
import '../model/restaurant_detail_model.dart';

/// Restaurant details for the Details screen via customer Discovery APIs.
///
/// Uses `GET /discovery/restaurants/:id` + branches for location/phone.
/// Never calls admin `/restaurants` tenant APIs. Menu remains empty until a
/// customer menu contract exists in Postman.
class RestaurantDetailsRepository {
  RestaurantDetailsRepository(this._discovery);

  final DiscoveryRepository _discovery;

  final Map<String, RestaurantDetailModel> _detailsById =
      <String, RestaurantDetailModel>{};

  Future<RestaurantDetailModel> fetchDetails(String restaurantId) async {
    final String id = restaurantId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidRestaurantPayload);
    }

    final RestaurantModel restaurant = await _discovery.getRestaurantById(id);
    List<BranchModel> branches = const <BranchModel>[];
    try {
      branches = await _discovery.listBranches(id);
    } on ApiException {
      // Detail can still render from restaurant payload alone.
    }

    final BranchModel? primary = branches.isEmpty ? null : branches.first;
    final double? averageRating = restaurant.averageRating;
    final String rating = averageRating == null
        ? AppStrings.ratingUnavailable
        : averageRating.toStringAsFixed(1);

    final RestaurantDetailModel detail = RestaurantDetailModel(
      restaurantId: restaurant.id,
      rating: rating,
      locationBlurb: primary?.locationLabel.isNotEmpty == true
          ? primary!.locationLabel
          : restaurant.location,
      about: restaurant.description.isNotEmpty
          ? restaurant.description
          : AppStrings.restaurantDetailsEmpty,
      amenities: const <String>[],
      openingHours: const <OpeningHoursDayModel>[],
      phone: primary?.phone ?? '',
      menuItems: const <MenuItemModel>[],
      locationNote: primary?.locationLabel ?? '',
      galleryImageUrls: restaurant.imageUrl.isEmpty
          ? const <String>[]
          : <String>[restaurant.imageUrl],
    );
    _detailsById[id] = detail;
    return detail;
  }

  RestaurantDetailModel getDetails(String restaurantId) {
    final RestaurantDetailModel? cached = _detailsById[restaurantId];
    if (cached != null) {
      return cached;
    }
    return _emptyDetail(restaurantId);
  }

  /// Empty restaurant placeholder — never invents demo catalog data.
  RestaurantModel emptyRestaurant({String id = ''}) => RestaurantModel(
    id: id,
    name: '',
    cuisine: '',
    occasion: '',
    description: '',
    imageUrl: '',
    location: '',
    availabilityLabel: AppStrings.hoursClosed,
    isAvailable: false,
  );

  /// Menu API is absent from Postman — always empty until a menu contract exists.
  List<MenuItemModel> getMenuItems(String restaurantId) {
    return getDetails(restaurantId).menuItems;
  }

  RestaurantDetailModel _emptyDetail(String restaurantId) {
    return RestaurantDetailModel(
      restaurantId: restaurantId,
      rating: AppStrings.ratingUnavailable,
      locationBlurb: '',
      about: AppStrings.restaurantDetailsEmpty,
      amenities: const <String>[],
      openingHours: const <OpeningHoursDayModel>[],
      phone: '',
      menuItems: const <MenuItemModel>[],
      locationNote: '',
    );
  }
}
