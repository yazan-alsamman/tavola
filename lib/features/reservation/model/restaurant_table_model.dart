import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import 'table_status.dart';

class RestaurantTableModel {
  const RestaurantTableModel({
    required this.id,
    required this.label,
    required this.seatCount,
    required this.status,
    required this.mapX,
    required this.mapY,
    this.description,
    this.isWindowSeat = false,
    this.mapSize,
    this.isCategoryExample = false,
  });

  final String id;
  final String label;
  final int seatCount;
  final TableStatus status;
  final double mapX;
  final double mapY;
  final String? description;
  final bool isWindowSeat;
  final double? mapSize;
  final bool isCategoryExample;

  bool get isSelectable => status == TableStatus.available;

  factory RestaurantTableModel.fromJson(Map<String, dynamic> json) {
    final double width =
        (json['width'] as num?)?.toDouble() ?? AppDimensions.floorPlanTableSize;
    final double height =
        (json['height'] as num?)?.toDouble() ??
        AppDimensions.floorPlanTableSize;
    final double mapSize = ((width + height) / 2).clamp(
      AppDimensions.floorPlanTableSize *
          AppDimensions.floorPlanTableMinSizeFactor,
      AppDimensions.floorPlanLargeTableSize,
    );

    return RestaurantTableModel(
      id: (json['tableId'] as String?) ?? (json['id'] as String?) ?? '',
      label:
          (json['tableNumber'] as String?) ?? (json['label'] as String?) ?? '',
      seatCount:
          (json['capacity'] as num?)?.toInt() ??
          (json['seatCount'] as num?)?.toInt() ??
          0,
      status: _mapStatusFromJson(json),
      mapX:
          (json['positionX'] as num?)?.toDouble() ??
          (json['mapX'] as num?)?.toDouble() ??
          0,
      mapY:
          (json['positionY'] as num?)?.toDouble() ??
          (json['mapY'] as num?)?.toDouble() ??
          0,
      mapSize: mapSize,
      isWindowSeat: json['indoor'] == false || json['isWindowSeat'] == true,
      description: (json['description'] as String?)?.trim(),
      isCategoryExample: false,
    );
  }

  static TableStatus _mapStatusFromJson(Map<String, dynamic> json) {
    if (json.containsKey('isAvailable')) {
      return json['isAvailable'] == true
          ? TableStatus.available
          : TableStatus.reserved;
    }
    return _mapStatus(json['status'] as String?);
  }

  static TableStatus _mapStatus(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case AppStrings.apiTableStatusAvailable:
        return TableStatus.available;
      case AppStrings.apiTableStatusOccupied:
      case AppStrings.apiTableStatusReserved:
      case AppStrings.apiTableStatusDisabled:
        return TableStatus.reserved;
      case AppStrings.apiTableStatusCleaning:
        return TableStatus.cleaning;
      default:
        return TableStatus.available;
    }
  }
}
