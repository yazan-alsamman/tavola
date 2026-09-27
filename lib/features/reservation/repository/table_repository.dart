import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../branches/model/branch_model.dart';
import '../../branches/repository/branch_repository.dart';
import '../../discovery/model/discovery_floor_plan_model.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../model/floor_plan_area_model.dart';
import '../model/restaurant_table_model.dart';

/// Table / floor-plan reads for Select Table via Discovery.
///
/// Floor topology: `GET /discovery/restaurants/:id/branches/:branchId/floor-plan`.
/// Direct `GET /tables/:id` remains available for single-table reads.
class TableRepository {
  TableRepository(
    this._apiClient,
    this._branchRepository, {
    DiscoveryRepository? discoveryRepository,
  }) : _discovery = discoveryRepository;

  final ApiClient _apiClient;
  final BranchRepository _branchRepository;
  final DiscoveryRepository? _discovery;

  List<RestaurantTableModel> _cachedTables = const <RestaurantTableModel>[];
  List<FloorPlanAreaModel> _cachedAreas = const <FloorPlanAreaModel>[];

  List<RestaurantTableModel> getFloorPlan() {
    return List<RestaurantTableModel>.unmodifiable(_cachedTables);
  }

  List<FloorPlanAreaModel> getFloorPlanAreas() {
    return List<FloorPlanAreaModel>.unmodifiable(_cachedAreas);
  }

  void _rememberFloorPlan(DiscoveryFloorPlanModel? floorPlan) {
    if (floorPlan == null) {
      _cachedTables = const <RestaurantTableModel>[];
      _cachedAreas = const <FloorPlanAreaModel>[];
      return;
    }
    _cachedTables = List<RestaurantTableModel>.unmodifiable(floorPlan.tables);
    _cachedAreas = List<FloorPlanAreaModel>.unmodifiable(floorPlan.areas);
  }

  String getConfirmationReferenceCode() {
    return AppStrings.onboardingPreviewReferenceLabel;
  }

  Future<String> fetchConfirmationReferenceCode() async {
    return getConfirmationReferenceCode();
  }

  /// Loads tables for [restaurantId] via primary branch + discovery floor plan.
  Future<List<RestaurantTableModel>> fetchFloorPlan({
    String? restaurantId,
  }) async {
    final String id = restaurantId?.trim() ?? '';
    if (id.isEmpty) {
      _rememberFloorPlan(null);
      return _cachedTables;
    }

    final BranchModel? branch = await _branchRepository.resolvePrimaryBranch(
      id,
    );
    if (branch == null || branch.id.isEmpty) {
      _rememberFloorPlan(null);
      throw StateError(AppStrings.tablesNoBranchAvailable);
    }

    final DiscoveryRepository? discovery = _discovery;
    if (discovery == null) {
      _rememberFloorPlan(null);
      return _cachedTables;
    }

    final DiscoveryFloorPlanModel floorPlan = await discovery
        .getActiveFloorPlan(restaurantId: id, branchId: branch.id);
    _rememberFloorPlan(floorPlan);
    return _cachedTables;
  }

  Future<List<RestaurantTableModel>> listTablesByBranch({
    required String restaurantId,
    required String branchId,
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
  }) async {
    final DiscoveryRepository? discovery = _discovery;
    if (discovery == null) {
      throw StateError(AppStrings.tablesNoFloorPlanAvailable);
    }
    final DiscoveryFloorPlanModel floorPlan = await discovery
        .getActiveFloorPlan(restaurantId: restaurantId, branchId: branchId);
    return floorPlan.tables;
  }

  Future<RestaurantTableModel> fetchTableById(String tableId) async {
    final String id = tableId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidTablePayload);
    }
    final ApiResponse<RestaurantTableModel> response = await _apiClient
        .get<RestaurantTableModel>(
          AppUrls.tablePath(id),
          parseData: _parseTable,
        );
    return response.data;
  }

  Future<List<RestaurantTableModel>> fetchTablesByFloorPlan({
    required String restaurantId,
    required String branchId,
    required String floorPlanId,
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
  }) {
    return listTablesByBranch(
      restaurantId: restaurantId,
      branchId: branchId,
      page: page,
      limit: limit,
    );
  }

  Future<String> resolveActiveFloorPlanId({
    required String restaurantId,
    required String branchId,
  }) async {
    final DiscoveryRepository? discovery = _discovery;
    if (discovery == null) {
      throw StateError(AppStrings.tablesNoFloorPlanAvailable);
    }
    final DiscoveryFloorPlanModel floorPlan = await discovery
        .getActiveFloorPlan(restaurantId: restaurantId, branchId: branchId);
    return floorPlan.floorPlanId;
  }

  static RestaurantTableModel _parseTable(Object? raw) {
    if (raw is! Map) {
      throw StateError(AppStrings.invalidTablePayload);
    }
    final RestaurantTableModel table = RestaurantTableModel.fromJson(
      Map<String, dynamic>.from(raw),
    );
    if (table.id.isEmpty) {
      throw StateError(AppStrings.invalidTablePayload);
    }
    return table;
  }
}
