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
}
