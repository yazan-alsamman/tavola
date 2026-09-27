import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../controller/select_table_controller.dart';
import '../model/floor_plan_area_model.dart';
import '../model/floor_plan_geometry.dart';
import '../model/restaurant_table_model.dart';
import 'floor_plan_table.dart';
import 'table_status_legend.dart';

class RestaurantFloorMap extends StatefulWidget {
  const RestaurantFloorMap({super.key, required this.controller});

  final SelectTableController controller;

  @override
  State<RestaurantFloorMap> createState() => _RestaurantFloorMapState();
}

class _RestaurantFloorMapState extends State<RestaurantFloorMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  final TransformationController _transformController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDimensions.floorPlanPulseDuration,
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(
          begin: AppDimensions.floorPlanAvailablePulseMin,
          end: AppDimensions.floorPlanAvailablePulseMax,
        ).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints mapConstraints) {
                        final double mapWidth = mapConstraints.maxWidth;
                        final double mapHeight = mapConstraints.maxHeight;
                        return InteractiveViewer(
                          transformationController: _transformController,
                          minScale: AppDimensions.floorPlanMapMinScale,
                          maxScale: AppDimensions.floorPlanMapMaxScale,
                          boundaryMargin: const EdgeInsets.all(
                            AppDimensions.smallSpacing,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: mapWidth,
                            height: mapHeight,
                            child: Obx(() {
                              if (Get.isRegistered<LocaleController>()) {
                                Get.find<LocaleController>().languageCode.value;
                              }
                              final List<RestaurantTableModel> tables = widget
                                  .controller
                                  .floorPlanTables
                                  .toList(growable: false);
                              final List<FloorPlanAreaModel> areas = widget
                                  .controller
                                  .floorPlanAreas
                                  .toList(growable: false);
                              final Size canvas = FloorPlanGeometry.canvasSize(
                                tables,
                                areas: areas,
                              );
                              final double scale =
                                  canvas.width <= 0 || canvas.height <= 0
                                  ? 1
                                  : math.min(
                                      mapWidth / canvas.width,
                                      mapHeight / canvas.height,
                                    );
                              final double offsetX =
                                  (mapWidth - canvas.width * scale) / 2;
                              final double offsetY =
                                  (mapHeight - canvas.height * scale) / 2;

                              return Stack(
                                clipBehavior: Clip.hardEdge,
                                children: [
                                  const SizedBox.expand(
                                    child: CustomPaint(
                                      painter: _RestaurantMapPainter(),
                                    ),
                                  ),
                                  ...areas.map(
                                    (FloorPlanAreaModel area) => _buildArea(
                                      area,
                                      tables,
                                      areas: areas,
                                      scale: scale,
                                      offsetX: offsetX,
                                      offsetY: offsetY,
                                    ),
                                  ),
                                  ...tables.map(
                                    (RestaurantTableModel table) =>
                                        _buildMapTable(
                                          table,
                                          scale: scale,
                                          offsetX: offsetX,
                                          offsetY: offsetY,
                                        ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        );
                      },
                ),
              ),
              const TableStatusLegend(horizontal: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArea(
    FloorPlanAreaModel area,
    List<RestaurantTableModel> tables, {
    required List<FloorPlanAreaModel> areas,
    required double scale,
    required double offsetX,
    required double offsetY,
  }) {
    final Rect? rect = FloorPlanGeometry.areaRect(area, tables, areas: areas);
    if (rect == null) {
      return const SizedBox.shrink();
    }
    final Color color = area.colorValue ?? AppColors.border;
    final String? translationKey = FloorPlanAreaModel.translationKeyFor(
      area.name,
    );
    final String label = translationKey == null ? area.name : translationKey.tr;
    return Positioned(
      key: ValueKey<String>('floor-plan-area-${area.id}'),
      left: rect.left * scale + offsetX,
      top: rect.top * scale + offsetY,
      width: rect.width * scale,
      height: rect.height * scale,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(
              AppDimensions.floorPlanTableRadius,
            ),
            border: Border.all(
              color: color,
              width: AppDimensions.cardBorderWidth,
            ),
          ),
          child: label.isEmpty
              ? const SizedBox.shrink()
              : Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.tinySpacing),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.floorPlanLiveLabel.copyWith(
                        color: color,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMapTable(
    RestaurantTableModel table, {
    required double scale,
    required double offsetX,
    required double offsetY,
  }) {
    final Rect? rect = FloorPlanGeometry.tableRect(table);
    if (rect == null) {
      return const SizedBox.shrink();
    }

    final double left = rect.left * scale + offsetX;
    final double top = rect.top * scale + offsetY;
    final double width = rect.width * scale;
    final double height = rect.height * scale;
    if (width <= 0 || height <= 0) {
      return const SizedBox.shrink();
    }
    final bool isSelected =
        widget.controller.selectedTableId.value == table.tableId;
    final bool shouldPulse = table.isSelectable && !isSelected;

    return Positioned(
      key: ValueKey<String>('floor-plan-position-${table.tableId}'),
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scale: shouldPulse ? _pulseAnimation.value : 1,
            child: child,
          );
        },
        child: FloorPlanTable(
          key: ValueKey<String>('floor-plan-table-${table.tableId}'),
          table: table,
          isSelected: isSelected,
          width: width,
          height: height,
          onTap: () => widget.controller.selectTable(table),
        ),
      ),
    );
  }
}

/// Places a table at Backend `positionX`/`positionY` using [Positioned.left]/[Positioned.top].
/// RTL must not use Directional positioning — coordinates stay origin top-left.
class FloorPlanPlacedTable extends StatelessWidget {
  const FloorPlanPlacedTable({
    super.key,
    required this.table,
    required this.isSelected,
    required this.onTap,
    this.pulse,
  });

  final RestaurantTableModel table;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double>? pulse;

  @override
  Widget build(BuildContext context) {
    final Rect? rect = FloorPlanGeometry.tableRect(table);
    if (rect == null) {
      return const SizedBox.shrink();
    }

    final bool shouldPulse = table.isSelectable && !isSelected && pulse != null;
    final Widget tableWidget = FloorPlanTable(
      key: ValueKey<String>('floor-plan-table-${table.tableId}'),
      table: table,
      isSelected: isSelected,
      width: rect.width,
      height: rect.height,
      onTap: onTap,
    );

    return Positioned(
      key: ValueKey<String>('floor-plan-position-${table.tableId}'),
      left: rect.left,
      top: rect.top,
      child: pulse == null
          ? tableWidget
          : AnimatedBuilder(
              animation: pulse!,
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: shouldPulse ? pulse!.value : 1,
                  child: child,
                );
              },
              child: tableWidget,
            ),
    );
  }
}

class _RestaurantMapPainter extends CustomPainter {
  const _RestaurantMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.surface);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
