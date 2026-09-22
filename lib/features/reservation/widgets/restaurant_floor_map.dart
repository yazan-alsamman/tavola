import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../controller/select_table_controller.dart';
import '../model/floor_plan_geometry.dart';
import '../model/restaurant_table_model.dart';
import 'floor_plan_live_time_badge.dart';
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
  String _fittedSignature = '';

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

  void _fitCanvas({
    required Size viewport,
    required Size canvas,
    required List<RestaurantTableModel> tables,
  }) {
    final String signature = tables
        .map(
          (RestaurantTableModel table) =>
              '${table.tableId}:${table.positionX}:${table.positionY}:${table.width}:${table.height}',
        )
        .join('|');
    if (signature == _fittedSignature) {
      return;
    }
    _fittedSignature = signature;
    final Matrix4 fitted = FloorPlanGeometry.fitToViewport(
      viewport: viewport,
      canvas: canvas,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _transformController.value = fitted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double viewportWidth = constraints.maxWidth;
        final double viewportHeight = constraints.maxHeight;

        return SizedBox(
          width: viewportWidth,
          height: viewportHeight,
          child: Obx(() {
            final List<RestaurantTableModel> tables = widget
                .controller
                .floorPlanTables
                .toList(growable: false);
            final Size canvas = FloorPlanGeometry.canvasSize(tables);
            _fitCanvas(
              viewport: Size(viewportWidth, viewportHeight),
              canvas: canvas,
              tables: tables,
            );

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    constrained: false,
                    minScale: AppDimensions.floorPlanMapMinScale,
                    maxScale: AppDimensions.floorPlanMapMaxScale,
                    boundaryMargin: const EdgeInsets.all(
                      AppDimensions.smallSpacing,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: canvas.width,
                      height: canvas.height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Positioned.fill(
                            child: CustomPaint(painter: _FloorPlanSurfacePainter()),
                          ),
                          ...tables.map(
                            (RestaurantTableModel table) => FloorPlanPlacedTable(
                              table: table,
                              isSelected:
                                  widget.controller.selectedTableId.value ==
                                  table.tableId,
                              pulse: _pulseAnimation,
                              onTap: () => widget.controller.selectTable(table),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const PositionedDirectional(
                  top: AppDimensions.regularSpacing,
                  start: AppDimensions.regularSpacing,
                  child: TableStatusLegend(overlay: true),
                ),
                const PositionedDirectional(
                  top: AppDimensions.regularSpacing,
                  end: AppDimensions.regularSpacing,
                  child: FloorPlanLiveTimeBadge(),
                ),
              ],
            );
          }),
        );
      },
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

class _FloorPlanSurfacePainter extends CustomPainter {
  const _FloorPlanSurfacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surface, AppColors.surfaceAlt],
        ).createShader(bounds),
    );

    const double inset = AppDimensions.floorPlanMapInset;
    final RRect outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        math.max(0, size.width - inset * 2),
        math.max(0, size.height - inset * 2),
      ),
      const Radius.circular(AppDimensions.cardRadius),
    );

    canvas.drawRRect(
      outer,
      Paint()
        ..color = AppColors.surfaceAlt
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppDimensions.cardBorderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
