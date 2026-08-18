import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../branches/model/branch_model.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../model/menu_item_model.dart';
import '../model/opening_hours_day_model.dart';
import '../model/restaurant_detail_model.dart';
import 'working_hours_mapper.dart';

/// Restaurant details for the Details screen via customer Discovery APIs.
///
/// Uses `GET /discovery/restaurants/:id` (includes public `workingHours`) +
/// branches for location. Never calls admin restaurant/branch working-hours.
/// Menu items load via [MenuRepository] on the Menu screen.
class RestaurantDetailsRepository {
  RestaurantDetailsRepository(this._discovery, ApiClient apiClient)
    : _apiClient = apiClient;

  final DiscoveryRepository _discovery;
  // Retained for constructor/DI compatibility; hours come from discovery.
  // ignore: unused_field
  final ApiClient _apiClient;

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
    final Object? workingHoursRaw = restaurant.workingHours;
    final bool hasWorkingHours = WorkingHoursMapper.hasEntries(workingHoursRaw);
    final List<OpeningHoursDayModel> openingHours = hasWorkingHours
        ? WorkingHoursMapper.weekFromPayload(
            workingHoursRaw,
            dayLabel: AppStrings.workingHoursDayLabel,
            closedLabel: AppStrings.hoursClosed,
          )
        : const <OpeningHoursDayModel>[];
    final String todayHoursLabel = hasWorkingHours
        ? WorkingHoursMapper.todayHoursLabel(
            workingHoursRaw,
            closedLabel: AppStrings.hoursClosed,
          )
        : '';
    final bool isOpenNow = hasWorkingHours
        ? WorkingHoursMapper.isOpenNow(workingHoursRaw)
        : restaurant.isAvailable;

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
      openingHours: openingHours,
      menuItems: const <MenuItemModel>[],
      locationNote: primary?.locationLabel ?? '',
      galleryImageUrls: restaurant.imageUrl.isEmpty
          ? const <String>[]
          : <String>[restaurant.imageUrl],
      todayHoursLabel: todayHoursLabel,
      isOpenNow: isOpenNow,
      hasWorkingHours: hasWorkingHours,
    );
    _detailsById[id] = detail;
    return detail;
  }

  /// Drops cached details so the next visit reloads discovery hours.
  void clearWorkingHoursCache() {
    _detailsById.clear();
  }

  /// Today's hours label from discovery-embedded `workingHours`.
  Future<String> fetchTodayHoursLabel(String restaurantId) async {
    final String id = restaurantId.trim();
    if (id.isEmpty) {
      return '';
    }
    try {
      final RestaurantModel restaurant = await _discovery.getRestaurantById(id);
      if (restaurant.hoursLabel.trim().isNotEmpty) {
        return restaurant.hoursLabel;
      }
      final Object? raw = restaurant.workingHours;
      if (!WorkingHoursMapper.hasEntries(raw)) {
        return '';
      }
      return WorkingHoursMapper.todayHoursLabel(
        raw,
        closedLabel: AppStrings.hoursClosed,
      );
    } catch (_) {
      return '';
    }
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

  /// Cached detail menu rows (usually empty — Menu screen loads live menus).
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
      menuItems: const <MenuItemModel>[],
      locationNote: '',
    );
  }
}
