import '../../../core/constants/app_strings.dart';
import '../../reservation/model/floor_plan_area_model.dart';
import '../../reservation/model/restaurant_table_model.dart';

/// Active floor plan + tables from
/// `GET /discovery/restaurants/:id/branches/:branchId/floor-plan`.
class DiscoveryFloorPlanModel {
  const DiscoveryFloorPlanModel({
    required this.floorPlanId,
    required this.branchId,
    required this.name,
    required this.isActive,
    required this.tables,
    this.areas = const <FloorPlanAreaModel>[],
  });

  final String floorPlanId;
  final String branchId;
  final String name;
  final bool isActive;
  final List<RestaurantTableModel> tables;
  final List<FloorPlanAreaModel> areas;

  static DiscoveryFloorPlanModel fromJsonRaw(Object? raw) {
    if (raw is! Map) {
      throw StateError(AppStrings.tablesNoFloorPlanAvailable);
    }
    final Map<String, dynamic> root = Map<String, dynamic>.from(raw);
    final Object? floorPlanRaw = root['floorPlan'];
    if (floorPlanRaw is! Map) {
      throw StateError(AppStrings.tablesNoFloorPlanAvailable);
    }
    final Map<String, dynamic> floorPlan = Map<String, dynamic>.from(
      floorPlanRaw,
    );

    final List<FloorPlanAreaModel> areas = <FloorPlanAreaModel>[];
    final Object? areasRaw = root['areas'];
    if (areasRaw is List) {
      for (final dynamic item in areasRaw) {
        if (item is! Map) {
          continue;
        }
        final FloorPlanAreaModel? area = FloorPlanAreaModel.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (area != null) {
          areas.add(area);
        }
      }
      areas.sort(
        (FloorPlanAreaModel a, FloorPlanAreaModel b) =>
            a.sortOrder.compareTo(b.sortOrder),
      );
    }

    final Object? tablesRaw = root['tables'];
    final List<RestaurantTableModel> tables = <RestaurantTableModel>[];
    if (tablesRaw is List) {
      for (final dynamic item in tablesRaw) {
        if (item is! Map) {
          continue;
        }
        try {
          final RestaurantTableModel table = RestaurantTableModel.fromJson(
            Map<String, dynamic>.from(item),
          );
          if (table.id.isNotEmpty) {
            tables.add(table);
          }
        } catch (_) {
          // Skip malformed table rows.
        }
      }
    }

    final String floorPlanId =
        (floorPlan['floorPlanId'] as String?)?.trim() ??
        (floorPlan['id'] as String?)?.trim() ??
        '';
    if (floorPlanId.isEmpty) {
      throw StateError(AppStrings.tablesNoFloorPlanAvailable);
    }

    return DiscoveryFloorPlanModel(
      floorPlanId: floorPlanId,
      branchId: (floorPlan['branchId'] as String?)?.trim() ?? '',
      name: (floorPlan['name'] as String?)?.trim() ?? '',
      isActive: floorPlan['isActive'] == true,
      tables: List<RestaurantTableModel>.unmodifiable(tables),
      areas: List<FloorPlanAreaModel>.unmodifiable(areas),
    );
  }
}
