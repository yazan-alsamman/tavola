import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../branches/model/branch_model.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../model/menu_item_model.dart';
import '../model/opening_hours_day_model.dart';
import '../model/restaurant_detail_model.dart';
import 'working_hours_mapper.dart';

/// Restaurant details for the Details screen via customer Discovery APIs.
///
/// Uses `GET /discovery/restaurants/:id` + branches for location/phone, and
/// `GET /restaurants/:restaurantId/branches/:branchId/working-hours` (primary
/// branch) for the Hours card — not restaurant-level working-hours.
/// Never calls admin PATCH/tenant-write APIs.
/// Menu items load via [MenuRepository] on the Menu screen.
class RestaurantDetailsRepository {
  RestaurantDetailsRepository(this._discovery, this._apiClient);

  final DiscoveryRepository _discovery;
  final ApiClient _apiClient;

  final Map<String, RestaurantDetailModel> _detailsById =
      <String, RestaurantDetailModel>{};

  /// Cache key: `restaurantId|branchId`.
  final Map<String, Object?> _branchWorkingHoursRawByKey = <String, Object?>{};

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
    final Object? workingHoursRaw = primary == null
        ? null
        : await fetchBranchWorkingHoursRaw(
            restaurantId: id,
            branchId: primary.id,
          );
    final List<OpeningHoursDayModel> openingHours = workingHoursRaw == null
        ? const <OpeningHoursDayModel>[]
        : WorkingHoursMapper.weekFromPayload(
            workingHoursRaw,
            dayLabel: AppStrings.workingHoursDayLabel,
            closedLabel: AppStrings.hoursClosed,
          );
    final bool hasWorkingHours = workingHoursRaw != null;
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
      phone: primary?.phone ?? '',
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

  /// `GET /restaurants/:restaurantId/branches/:branchId/working-hours`.
  ///
  /// Returns `null` when the call fails — Details still shows the Hours card
  /// (with an unavailable placeholder) instead of hiding the section.
  /// Failures are not cached so guest→login / retry can load hours again.
  Future<Object?> fetchBranchWorkingHoursRaw({
    required String restaurantId,
    required String branchId,
  }) async {
    final String restaurant = restaurantId.trim();
    final String branch = branchId.trim();
    if (restaurant.isEmpty || branch.isEmpty) {
      return null;
    }
    final String cacheKey = _hoursCacheKey(restaurant, branch);
    if (_branchWorkingHoursRawByKey.containsKey(cacheKey)) {
      return _branchWorkingHoursRawByKey[cacheKey];
    }
    // Skip the round-trip when there is no Bearer (Guest / logged-out).
    if (!await _hasAccessToken()) {
      return null;
    }
    try {
      final ApiResponse<Object?> response = await _apiClient.get<Object?>(
        AppUrls.branchWorkingHoursPath(
          restaurantId: restaurant,
          branchId: branch,
        ),
        parseData: (Object? raw) => raw,
      );
      _branchWorkingHoursRawByKey[cacheKey] = response.data;
      return response.data;
    } catch (_) {
      // Never cache failures — a later authenticated visit must retry.
      return null;
    }
  }

  /// Drops working-hours memory cache (e.g. after sign-in from Guest).
  void clearWorkingHoursCache() {
    _branchWorkingHoursRawByKey.clear();
  }

  /// Today's hours label for restaurant cards (`hoursLabel`) via primary branch.
  Future<String> fetchTodayHoursLabel(String restaurantId) async {
    final String id = restaurantId.trim();
    if (id.isEmpty) {
      return '';
    }
    List<BranchModel> branches = const <BranchModel>[];
    try {
      branches = await _discovery.listBranches(id);
    } on ApiException {
      return '';
    }
    if (branches.isEmpty) {
      return '';
    }
    final Object? raw = await fetchBranchWorkingHoursRaw(
      restaurantId: id,
      branchId: branches.first.id,
    );
    if (raw == null) {
      return '';
    }
    return WorkingHoursMapper.todayHoursLabel(
      raw,
      closedLabel: AppStrings.hoursClosed,
    );
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

  Future<bool> _hasAccessToken() => AuthAccessGuard.hasAccessToken();

  static String _hoursCacheKey(String restaurantId, String branchId) =>
      '$restaurantId|$branchId';

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
