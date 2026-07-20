import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../model/restaurant_table_model.dart';
import '../model/table_status.dart';

/// Provides floor-plan tables and confirmation reference data.
class TableRepository {
  Future<List<RestaurantTableModel>> fetchFloorPlan() async {
    return getFloorPlan();
  }

  Future<String> fetchConfirmationReferenceCode() async {
    return getConfirmationReferenceCode();
  }

  List<RestaurantTableModel> getFloorPlan() {
    return List<RestaurantTableModel>.unmodifiable(_floorPlanTables);
  }

  String getConfirmationReferenceCode() {
    return AppStrings.confirmationReferenceCode;
  }

  static List<RestaurantTableModel> get _floorPlanTables => [
    RestaurantTableModel(
      id: AppStrings.tableIdW1,
      label: AppStrings.tableLabelW1,
      seatCount: 12,
      status: TableStatus.available,
      mapX: 228,
      mapY: 62,
      mapSize: AppDimensions.floorPlanLargeTableSize,
      description: AppStrings.availableTableDescription,
      isWindowSeat: true,
      isCategoryExample: true,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdR3,
      label: AppStrings.tableLabelR3,
      seatCount: 8,
      status: TableStatus.reserved,
      mapX: 234,
      mapY: 188,
      description: AppStrings.reservedTableNote,
      isCategoryExample: true,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdC2,
      label: AppStrings.tableLabelC2,
      seatCount: 6,
      status: TableStatus.cleaning,
      mapX: 234,
      mapY: 322,
      description: AppStrings.cleaningTableNote,
      isCategoryExample: true,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdA2,
      label: AppStrings.tableLabelA2,
      seatCount: 4,
      status: TableStatus.available,
      mapX: 158,
      mapY: 168,
      description: AppStrings.tableDescriptionA2,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdV5,
      label: AppStrings.tableLabelV5,
      seatCount: 2,
      status: TableStatus.available,
      mapX: 158,
      mapY: 252,
      description: AppStrings.tableDescriptionV5,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdB4,
      label: AppStrings.tableLabelB4,
      seatCount: 6,
      status: TableStatus.reserved,
      mapX: 348,
      mapY: 168,
      description: AppStrings.tableDescriptionB4,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdP6,
      label: AppStrings.tableLabelP6,
      seatCount: 10,
      status: TableStatus.available,
      mapX: 348,
      mapY: 252,
      description: AppStrings.tableDescriptionP6,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdM8,
      label: AppStrings.tableLabelM8,
      seatCount: 8,
      status: TableStatus.reserved,
      mapX: 448,
      mapY: 210,
      description: AppStrings.tableDescriptionM8,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdT7,
      label: AppStrings.tableLabelT7,
      seatCount: 4,
      status: TableStatus.cleaning,
      mapX: 448,
      mapY: 322,
      description: AppStrings.tableDescriptionT7,
    ),
  ];
}
