import '../../../core/constants/app_strings.dart';
import 'table_shape.dart';
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
    this.floorPlanId,
    this.floorPlanAreaId,
    this.description,
    this.indoor,
    this.vip = false,
    this.smoking = false,
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

  /// Backend floor-plan id when the table row includes `floorPlanId`.
  final String? floorPlanId;

  /// Backend dining-area id when the table row includes `floorPlanAreaId`.
  final String? floorPlanAreaId;

  final String? description;

  /// Backend `indoor`. Null when the payload omits it.
  final bool? indoor;

  /// Backend `vip`.
  final bool vip;

  /// Backend `smoking`.
  final bool smoking;

  /// Explicit backend `isWindowSeat` only. `indoor` does not imply a window zone.
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
      height != null &&
      width! > 0 &&
      height! > 0;

  TableShape? get tableShape => TableShapeApi.fromApi(shape);

  bool get isRound => tableShape == TableShape.circle;

  /// Operational status blocks booking only when the payload included `status`.
  /// A missing status is not treated as [TableStatus.available].
  bool get isOperationallyBlocked =>
      hasExplicitStatus && status != TableStatus.available;

  bool get isSelectable =>
      !isOperationallyBlocked && isAvailableForWindow != false;

  /// Why a tap must not select this table. Null when the table can be booked.
  String? get selectionBlockedMessage {
    if (isOperationallyBlocked) {
      switch (status) {
        case TableStatus.occupied:
          return AppStrings.occupiedTableNote;
        case TableStatus.cleaning:
          return AppStrings.cleaningTableNote;
        case TableStatus.disabled:
          return AppStrings.disabledTableNote;
        case TableStatus.reserved:
          return AppStrings.reservedTableNote;
        case TableStatus.available:
        case TableStatus.merged:
        case TableStatus.unrecognized:
          return AppStrings.tableCurrentlyUnavailable;
      }
    }
    if (isAvailableForWindow == false) {
      return AppStrings.tableUnavailableForSlotNote;
    }
    return null;
  }

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
    String? floorPlanId,
    String? floorPlanAreaId,
    String? description,
    bool? indoor,
    bool? vip,
    bool? smoking,
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
      floorPlanId: floorPlanId ?? this.floorPlanId,
      floorPlanAreaId: floorPlanAreaId ?? this.floorPlanAreaId,
      description: description ?? this.description,
      indoor: indoor ?? this.indoor,
      vip: vip ?? this.vip,
      smoking: smoking ?? this.smoking,
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
    final Map<String, RestaurantTableModel> byId =
        <String, RestaurantTableModel>{
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
      id:
          (json['tableId'] as String?)?.trim() ??
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
      status: hasExplicitStatus ? _mapStatus(rawStatus) : TableStatus.available,
      hasExplicitStatus: hasExplicitStatus,
      positionX: _readDouble(json, 'positionX'),
      positionY: _readDouble(json, 'positionY'),
      width: _readDouble(json, 'width'),
      height: _readDouble(json, 'height'),
      rotation: _readDouble(json, 'rotation'),
      shape: (json['shape'] as String?)?.trim(),
      floorPlanId: _readId(json['floorPlanId']),
      floorPlanAreaId: _readId(json['floorPlanAreaId']),
      indoor: json['indoor'] is bool ? json['indoor'] as bool : null,
      vip: json['vip'] == true,
      smoking: json['smoking'] == true,
      isWindowSeat: json['isWindowSeat'] == true,
      description: (json['description'] as String?)?.trim(),
      isAvailableForWindow: json.containsKey('isAvailable')
          ? json['isAvailable'] == true
          : null,
    );
  }

  static String? _readId(Object? value) {
    if (value is! String) {
      return null;
    }
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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
      case AppStrings.apiTableStatusReserved:
        return TableStatus.reserved;
      case AppStrings.apiTableStatusMerged:
        return TableStatus.merged;
      default:
        return TableStatus.unrecognized;
    }
  }
}
