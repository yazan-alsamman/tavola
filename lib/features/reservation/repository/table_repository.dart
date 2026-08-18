import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../branches/model/branch_model.dart';
import '../../branches/repository/branch_repository.dart';
import '../../discovery/model/discovery_floor_plan_model.dart';
import '../../discovery/repository/discovery_repository.dart';
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

  List<RestaurantTableModel> getFloorPlan() {
    return List<RestaurantTableModel>.unmodifiable(_cachedTables);
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
      _cachedTables = const <RestaurantTableModel>[];
      return _cachedTables;
    }

    final BranchModel? branch = await _branchRepository.resolvePrimaryBranch(
      id,
    );
    if (branch == null || branch.id.isEmpty) {
      throw StateError(AppStrings.tablesNoBranchAvailable);
    }

    final DiscoveryRepository? discovery = _discovery;
    if (discovery == null) {
      _cachedTables = const <RestaurantTableModel>[];
      return _cachedTables;
    }

    final DiscoveryFloorPlanModel floorPlan = await discovery
        .getActiveFloorPlan(restaurantId: id, branchId: branch.id);
    _cachedTables = List<RestaurantTableModel>.unmodifiable(floorPlan.tables);
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
      return const <RestaurantTableModel>[];
    }
    try {
      final DiscoveryFloorPlanModel floorPlan = await discovery
          .getActiveFloorPlan(restaurantId: restaurantId, branchId: branchId);
      return floorPlan.tables;
    } catch (_) {
      return const <RestaurantTableModel>[];
    }
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
