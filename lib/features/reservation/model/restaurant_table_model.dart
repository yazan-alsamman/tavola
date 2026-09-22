import '../../../core/constants/app_strings.dart';
import 'table_status.dart';

class RestaurantTableModel {
  const RestaurantTableModel({
    required this.id,
    required this.label,
    required this.seatCount,
    required this.status,
    this.positionX,
    this.positionY,
    this.width,
    this.height,
    this.rotation,
    this.shape,
    this.description,
    this.isWindowSeat = false,
    this.isAvailableForWindow,
    this.hasExplicitStatus = false,
  });

  /// Backend `tableId` — database / API identity.
  final String id;

  /// Backend `tableNumber` — user-facing label only.
  final String label;

  /// Backend `capacity`.
  final int seatCount;

  /// Operational table status from Backend `status` when present.
  ///
  /// Floor-plan rows do not include `status`. Reservation availability is
  /// [isAvailableForWindow], never this field.
  final TableStatus status;

  final double? positionX;
  final double? positionY;
  final double? width;
  final double? height;
  final double? rotation;
  final String? shape;
  final String? description;
  final bool isWindowSeat;

  /// From `GET /reservations/availability` `isAvailable` for a booking window.
  final bool? isAvailableForWindow;

  /// True only when the JSON included a non-empty `status` field.
  final bool hasExplicitStatus;

  String get tableId => id;

  String get tableNumber => label;

  bool get hasRenderableGeometry =>
      positionX != null &&
      positionY != null &&
      width != null &&
      height != null;

  bool get isRound => (shape ?? '').trim().toLowerCase() == 'round';

  bool get isSelectable =>
      status == TableStatus.available && (isAvailableForWindow ?? true);

  RestaurantTableModel copyWith({
    String? id,
    String? label,
    int? seatCount,
    TableStatus? status,
    double? positionX,
    double? positionY,
    double? width,
    double? height,
    double? rotation,
    String? shape,
    String? description,
    bool? isWindowSeat,
    bool? isAvailableForWindow,
    bool? hasExplicitStatus,
    bool keepAvailability = true,
  }) {
    return RestaurantTableModel(
      id: id ?? this.id,
      label: label ?? this.label,
      seatCount: seatCount ?? this.seatCount,
      status: status ?? this.status,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      shape: shape ?? this.shape,
      description: description ?? this.description,
      isWindowSeat: isWindowSeat ?? this.isWindowSeat,
      isAvailableForWindow: keepAvailability
          ? (isAvailableForWindow ?? this.isAvailableForWindow)
          : isAvailableForWindow,
      hasExplicitStatus: hasExplicitStatus ?? this.hasExplicitStatus,
    );
  }

  /// Keep floor-plan geometry; overlay availability / get-by-id details.
  RestaurantTableModel overlayWith(RestaurantTableModel incoming) {
    return copyWith(
      label: incoming.label.isNotEmpty ? incoming.label : null,
      seatCount: incoming.seatCount > 0 ? incoming.seatCount : null,
      status: incoming.hasExplicitStatus ? incoming.status : null,
      hasExplicitStatus: incoming.hasExplicitStatus ? true : null,
      positionX: incoming.positionX,
      positionY: incoming.positionY,
      width: incoming.width,
      height: incoming.height,
      rotation: incoming.rotation,
      shape: incoming.shape,
      description: incoming.description,
      isAvailableForWindow: incoming.isAvailableForWindow,
      keepAvailability: incoming.isAvailableForWindow == null,
    );
  }

  /// Floor-plan tables are the geometry source of truth.
  /// Availability only sets [isAvailableForWindow] by `tableId`.
  static List<RestaurantTableModel> overlayAvailability({
    required List<RestaurantTableModel> floorPlan,
    required List<RestaurantTableModel> availability,
  }) {
    final Map<String, RestaurantTableModel> byId = <String, RestaurantTableModel>{
      for (final RestaurantTableModel table in availability)
        if (table.id.isNotEmpty) table.id: table,
    };
    return floorPlan
        .map((RestaurantTableModel table) {
          final RestaurantTableModel? match = byId[table.id];
          if (match == null) {
            return table.copyWith(
              isAvailableForWindow: false,
              keepAvailability: false,
            );
          }
          return table.copyWith(
            isAvailableForWindow: match.isAvailableForWindow ?? false,
            keepAvailability: false,
            status: match.hasExplicitStatus ? match.status : null,
            hasExplicitStatus: match.hasExplicitStatus ? true : null,
          );
        })
        .toList(growable: false);
  }

  factory RestaurantTableModel.fromJson(Map<String, dynamic> json) {
    final String rawStatus = (json['status'] as String?)?.trim() ?? '';
    final bool hasExplicitStatus = rawStatus.isNotEmpty;

    return RestaurantTableModel(
      id: (json['tableId'] as String?)?.trim() ??
          (json['id'] as String?)?.trim() ??
          '',
      label:
          (json['tableNumber'] as String?)?.trim() ??
          (json['label'] as String?)?.trim() ??
          '',
      seatCount:
          (json['capacity'] as num?)?.toInt() ??
          (json['seatCount'] as num?)?.toInt() ??
          0,
      status: hasExplicitStatus
          ? _mapStatus(rawStatus)
          : TableStatus.available,
      hasExplicitStatus: hasExplicitStatus,
      positionX: _readDouble(json, 'positionX'),
      positionY: _readDouble(json, 'positionY'),
      width: _readDouble(json, 'width'),
      height: _readDouble(json, 'height'),
      rotation: _readDouble(json, 'rotation'),
      shape: (json['shape'] as String?)?.trim(),
      isWindowSeat: json['indoor'] == false || json['isWindowSeat'] == true,
      description: (json['description'] as String?)?.trim(),
      isAvailableForWindow: json.containsKey('isAvailable')
          ? json['isAvailable'] == true
          : null,
    );
  }

  static double? _readDouble(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static TableStatus _mapStatus(String raw) {
    switch (raw.toLowerCase()) {
      case AppStrings.apiTableStatusAvailable:
        return TableStatus.available;
      case AppStrings.apiTableStatusOccupied:
        return TableStatus.occupied;
      case AppStrings.apiTableStatusCleaning:
        return TableStatus.cleaning;
      case AppStrings.apiTableStatusDisabled:
        return TableStatus.disabled;
      default:
        return TableStatus.disabled;
    }
  }
}
