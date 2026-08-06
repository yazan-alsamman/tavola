import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../branches/model/branch_model.dart';
import '../../home/model/restaurant_model.dart';
import '../model/discovery_floor_plan_model.dart';
import '../model/restaurant_offer_model.dart';

/// Customer Discovery APIs (Postman folder **Discovery**).
///
/// Public (`skipAuth`), cross-tenant Active restaurants only:
/// - `GET /discovery/restaurants`
/// - `GET /discovery/restaurants/nearby`
/// - `GET /discovery/restaurants/:restaurantId`
/// - `GET /discovery/restaurants/:restaurantId/branches`
/// - `GET /discovery/restaurants/:restaurantId/branches/:branchId`
/// - `GET /discovery/restaurants/:restaurantId/branches/:branchId/floor-plan`
/// - `GET /discovery/restaurants/:restaurantId/offers`
///
/// Never calls admin `/restaurants` tenant APIs.
class DiscoveryRepository {
  DiscoveryRepository(this._apiClient);

  final ApiClient _apiClient;

  List<RestaurantModel>? _restaurantsCache;
  final Map<String, RestaurantModel> _restaurantById =
      <String, RestaurantModel>{};
  final Map<String, List<BranchModel>> _branchesByRestaurantId =
      <String, List<BranchModel>>{};
  Future<List<RestaurantModel>>? _listInFlight;

  List<RestaurantModel>? get cachedRestaurants => _restaurantsCache;

  RestaurantModel? cachedRestaurant(String restaurantId) =>
      _restaurantById[restaurantId.trim()];

  List<BranchModel>? cachedBranches(String restaurantId) =>
      _branchesByRestaurantId[restaurantId.trim()];

  /// `GET /discovery/restaurants`
  Future<List<RestaurantModel>> listRestaurants({
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _restaurantsCache != null) {
      return _restaurantsCache!;
    }
    final Future<List<RestaurantModel>>? inFlight = _listInFlight;
    if (inFlight != null && !forceRefresh) {
      return inFlight;
    }

    final Future<List<RestaurantModel>> request = _loadRestaurants(
      page: page,
      limit: limit,
    );
    _listInFlight = request;
    try {
      return await request;
    } finally {
      if (identical(_listInFlight, request)) {
        _listInFlight = null;
      }
    }
  }

  Future<List<RestaurantModel>> _loadRestaurants({
    required int page,
    required int limit,
  }) async {
    final ApiResponse<List<RestaurantModel>> response = await _apiClient
        .get<List<RestaurantModel>>(
          AppUrls.discoveryRestaurantsPath,
          queryParameters: <String, dynamic>{'page': page, 'limit': limit},
          options: ApiClient.skipAuthOptions(),
          parseData: _parseRestaurantItems,
        );
    final List<RestaurantModel> items = List<RestaurantModel>.unmodifiable(
      response.data,
    );
    _restaurantsCache = items;
    for (final RestaurantModel item in items) {
      if (item.id.isNotEmpty) {
        _restaurantById[item.id] = item;
      }
    }
    return items;
  }

  /// `GET /discovery/restaurants/nearby` (`lat`, `lng`, optional `radiusKm`).
  Future<List<RestaurantModel>> listNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = AppDimensions.nearbySearchRadiusKm,
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
  }) async {
    final ApiResponse<List<RestaurantModel>> response = await _apiClient
        .get<List<RestaurantModel>>(
          AppUrls.discoveryRestaurantsNearbyPath,
          queryParameters: <String, dynamic>{
            AppUrls.nearbyLatitudeQueryKey: latitude,
            AppUrls.nearbyLongitudeQueryKey: longitude,
            AppUrls.nearbyRadiusKmQueryKey: radiusKm,
            'page': page,
            'limit': limit,
          },
          options: ApiClient.skipAuthOptions(),
          parseData: _parseRestaurantItems,
        );
    return List<RestaurantModel>.unmodifiable(response.data);
  }

  /// `GET /discovery/restaurants/:restaurantId/offers`
  Future<List<RestaurantOfferModel>> listOffers(String restaurantId) async {
    final String id = restaurantId.trim();
    if (id.isEmpty) {
      return const <RestaurantOfferModel>[];
    }
    final ApiResponse<List<RestaurantOfferModel>> response = await _apiClient
        .get<List<RestaurantOfferModel>>(
          AppUrls.discoveryOffersPath(id),
          options: ApiClient.skipAuthOptions(),
          parseData: _parseOfferItems,
        );
    return List<RestaurantOfferModel>.unmodifiable(response.data);
  }

  /// `GET /discovery/restaurants/:restaurantId`
  Future<RestaurantModel> getRestaurantById(String restaurantId) async {
    final String id = restaurantId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidRestaurantPayload);
    }
    final RestaurantModel? cached = _restaurantById[id];
    if (cached != null) {
      return cached;
    }

    final ApiResponse<RestaurantModel> response = await _apiClient
        .get<RestaurantModel>(
          AppUrls.discoveryRestaurantPath(id),
          options: ApiClient.skipAuthOptions(),
          parseData: _parseRestaurant,
        );
    final RestaurantModel restaurant = response.data;
    if (restaurant.id.isEmpty) {
      throw StateError(AppStrings.invalidRestaurantPayload);
    }
    _restaurantById[restaurant.id] = restaurant;
    return restaurant;
  }

  /// `GET /discovery/restaurants/:restaurantId/branches`
  Future<List<BranchModel>> listBranches(
    String restaurantId, {
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
    bool forceRefresh = false,
  }) async {
    final String id = restaurantId.trim();
    if (id.isEmpty) {
      return const <BranchModel>[];
    }
    if (!forceRefresh) {
      final List<BranchModel>? cached = _branchesByRestaurantId[id];
      if (cached != null) {
        return cached;
      }
    }

    final ApiResponse<List<BranchModel>> response = await _apiClient
        .get<List<BranchModel>>(
          AppUrls.discoveryBranchesPath(id),
          queryParameters: <String, dynamic>{'page': page, 'limit': limit},
          options: ApiClient.skipAuthOptions(),
          parseData: _parseBranchItems,
        );
    final List<BranchModel> items = List<BranchModel>.unmodifiable(
      response.data,
    );
    _branchesByRestaurantId[id] = items;
    return items;
  }

  /// `GET /discovery/restaurants/:restaurantId/branches/:branchId`
  Future<BranchModel> getBranchById({
    required String restaurantId,
    required String branchId,
  }) async {
    final String rid = restaurantId.trim();
    final String bid = branchId.trim();
    if (rid.isEmpty || bid.isEmpty) {
      throw StateError(AppStrings.invalidBranchPayload);
    }

    final ApiResponse<BranchModel> response = await _apiClient.get<BranchModel>(
      AppUrls.discoveryBranchPath(rid, bid),
      options: ApiClient.skipAuthOptions(),
      parseData: _parseBranch,
    );
    final BranchModel branch = response.data;
    if (branch.id.isEmpty) {
      throw StateError(AppStrings.invalidBranchPayload);
    }
    return branch;
  }

  /// First branch for reservation / map (most-recently-created first per API).
  Future<BranchModel?> resolvePrimaryBranch(String restaurantId) async {
    final List<BranchModel> branches = await listBranches(restaurantId);
    if (branches.isEmpty) {
      return null;
    }
    return branches.first;
  }

  /// `GET .../branches/:branchId/floor-plan`
  Future<DiscoveryFloorPlanModel> getActiveFloorPlan({
    required String restaurantId,
    required String branchId,
  }) async {
    final String rid = restaurantId.trim();
    final String bid = branchId.trim();
    if (rid.isEmpty || bid.isEmpty) {
      throw StateError(AppStrings.tablesNoFloorPlanAvailable);
    }

    final ApiResponse<DiscoveryFloorPlanModel> response = await _apiClient
        .get<DiscoveryFloorPlanModel>(
          AppUrls.discoveryFloorPlanPath(rid, bid),
          options: ApiClient.skipAuthOptions(),
          parseData: DiscoveryFloorPlanModel.fromJsonRaw,
        );
    return response.data;
  }

  static List<RestaurantModel> _parseRestaurantItems(Object? raw) {
    final List<dynamic> items = _extractItems(raw);
    final List<RestaurantModel> parsed = <RestaurantModel>[];
    for (final dynamic item in items) {
      if (item is! Map) {
        continue;
      }
      try {
        final RestaurantModel restaurant = RestaurantModel.fromDiscoveryJson(
          Map<String, dynamic>.from(item),
        );
        if (restaurant.id.isNotEmpty) {
          parsed.add(restaurant);
        }
      } catch (_) {
        // Skip malformed rows.
      }
    }
    return parsed;
  }

  static RestaurantModel _parseRestaurant(Object? raw) {
    if (raw is! Map) {
      throw StateError(AppStrings.invalidRestaurantPayload);
    }
    return RestaurantModel.fromDiscoveryJson(Map<String, dynamic>.from(raw));
  }

  static List<BranchModel> _parseBranchItems(Object? raw) {
    final List<dynamic> items = _extractItems(raw);
    final List<BranchModel> parsed = <BranchModel>[];
    for (final dynamic item in items) {
      if (item is! Map) {
        continue;
      }
      try {
        final BranchModel branch = BranchModel.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (branch.id.isNotEmpty) {
          parsed.add(branch);
        }
      } catch (_) {
        // Skip malformed rows.
      }
    }
    return parsed;
  }

  static BranchModel _parseBranch(Object? raw) {
    if (raw is! Map) {
      throw StateError(AppStrings.invalidBranchPayload);
    }
    return BranchModel.fromJson(Map<String, dynamic>.from(raw));
  }

  static List<RestaurantOfferModel> _parseOfferItems(Object? raw) {
    final List<dynamic> items = _extractItems(raw);
    final List<RestaurantOfferModel> parsed = <RestaurantOfferModel>[];
    for (final dynamic item in items) {
      if (item is! Map) {
        continue;
      }
      try {
        final RestaurantOfferModel offer = RestaurantOfferModel.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (offer.offerId.isNotEmpty || offer.title.isNotEmpty) {
          parsed.add(offer);
        }
      } catch (_) {
        // Skip malformed rows.
      }
    }
    return parsed;
  }

  static List<dynamic> _extractItems(Object? raw) {
    if (raw is Map) {
      final Object? items = raw['items'];
      if (items is List) {
        return items;
      }
    }
    if (raw is List) {
      return raw;
    }
    return const <dynamic>[];
  }
}
