import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/select_table_controller.dart';
import '../model/floor_plan_geometry.dart';
import '../model/restaurant_table_model.dart';
import 'floor_plan_live_time_badge.dart';
import 'floor_plan_table.dart';
import 'floor_plan_zone_pills.dart';
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
                              final List<RestaurantTableModel> tables = widget
                                  .controller
                                  .floorPlanTables
                                  .toList(growable: false);
                              final Size canvas = FloorPlanGeometry.canvasSize(
                                tables,
                              );
                              final double scaleX = canvas.width <= 0
                                  ? 1
                                  : mapWidth / canvas.width;
                              final double scaleY = canvas.height <= 0
                                  ? 1
                                  : mapHeight / canvas.height;

                              return Stack(
                                clipBehavior: Clip.hardEdge,
                                children: [
                                  const SizedBox.expand(
                                    child: CustomPaint(
                                      painter: _RestaurantMapPainter(),
                                    ),
                                  ),
                                  const PositionedDirectional(
                                    top: AppDimensions.smallSpacing,
                                    start: AppDimensions.smallSpacing,
                                    end: AppDimensions.floorPlanPillsEndInset,
                                    child: FloorPlanZonePills(),
                                  ),
                                  const PositionedDirectional(
                                    top: AppDimensions.smallSpacing,
                                    end: AppDimensions.smallSpacing,
                                    child: FloorPlanLiveTimeBadge(),
                                  ),
                                  ...tables.map(
                                    (RestaurantTableModel table) =>
                                        _buildMapTable(
                                          table,
                                          scaleX: scaleX,
                                          scaleY: scaleY,
                                          mapWidth: mapWidth,
                                          mapHeight: mapHeight,
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

  Widget _buildMapTable(
    RestaurantTableModel table, {
    required double scaleX,
    required double scaleY,
    required double mapWidth,
    required double mapHeight,
  }) {
    final Rect? rect = FloorPlanGeometry.tableRect(table);
    if (rect == null) {
      return const SizedBox.shrink();
    }

    final double left = rect.left * scaleX;
    final double top = rect.top * scaleY;
    final double width = math.max(1, rect.width * scaleX);
    final double height = math.max(1, rect.height * scaleY);
    final bool isSelected =
        widget.controller.selectedTableId.value == table.tableId;
    final bool shouldPulse = table.isSelectable && !isSelected;

    return Positioned(
      key: ValueKey<String>('floor-plan-position-${table.tableId}'),
      left: left.clamp(0.0, math.max(0.0, mapWidth - width)),
      top: top.clamp(0.0, math.max(0.0, mapHeight - height)),
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
    final Rect bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = AppColors.floorPlanCanvas);

    const double inset = AppDimensions.floorPlanMapInset;
    const double padding = AppDimensions.floorPlanMapInnerPadding;
    const double roomRadius = AppDimensions.floorPlanRoomRadius;

    final RRect outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        math.max(0, size.width - inset * 2),
        math.max(0, size.height - inset * 2),
      ),
      const Radius.circular(AppDimensions.cardRadius),
    );
    canvas.drawRRect(outer, Paint()..color = AppColors.floorPlanCanvas);
    canvas.drawRRect(
      outer,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppDimensions.cardBorderWidth,
    );

    final double roomTop = size.height * AppDimensions.floorPlanRoomTopFactor;
    final double roomBottom =
        size.height * AppDimensions.floorPlanRoomBottomFactor;
    final double leftRoomEnd =
        size.width * AppDimensions.floorPlanLeftRoomEndFactor;
    final double rightRoomStart =
        size.width * AppDimensions.floorPlanRightRoomStartFactor;

    _drawRoom(
      canvas,
      RRect.fromRectAndRadius(
        Rect.fromLTRB(padding, roomTop, leftRoomEnd, roomBottom),
        const Radius.circular(roomRadius),
      ),
      fill: AppColors.floorPlanRoom,
      accent: AppColors.floorPlanDining,
      label: AppStrings.mainDining,
      labelOffset: Offset(
        padding + AppDimensions.regularSpacing,
        roomTop + AppDimensions.smallSpacing,
      ),
      maxWidth: size.width,
    );

    _drawRoom(
      canvas,
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          rightRoomStart,
          roomTop,
          size.width - padding,
          roomBottom - AppDimensions.sectionSpacing,
        ),
        const Radius.circular(roomRadius),
      ),
      fill: AppColors.floorPlanRoomAlt,
      accent: AppColors.floorPlanWindow,
      label: AppStrings.windowSeating,
      labelOffset: Offset(
        rightRoomStart + AppDimensions.regularSpacing,
        roomTop + AppDimensions.smallSpacing,
      ),
      maxWidth: size.width,
    );

    _drawRoom(
      canvas,
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          padding,
          roomBottom + AppDimensions.tinySpacing,
          math.max(0, leftRoomEnd - padding),
          AppDimensions.floorPlanBottomBarHeight,
        ),
        const Radius.circular(AppDimensions.pillRadius),
      ),
      fill: AppColors.floorPlanServiceFill,
      accent: AppColors.floorPlanService,
      label: AppStrings.serviceArea,
      labelOffset: Offset(
        padding + AppDimensions.smallSpacing,
        roomBottom + AppDimensions.tinySpacing,
      ),
      maxWidth: size.width,
    );

    final RRect entrance = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          size.width * AppDimensions.floorPlanEntranceXFactor,
          size.height - AppDimensions.floorPlanEntranceBottomOffset,
        ),
        width: size.width * AppDimensions.floorPlanEntranceWidthFactor,
        height: AppDimensions.floorPlanEntranceHeight + 4,
      ),
      const Radius.circular(AppDimensions.pillRadius),
    );
    canvas.drawRRect(
      entrance,
      Paint()..color = AppColors.floorPlanEntranceFill,
    );
    canvas.drawRRect(
      entrance,
      Paint()
        ..color = AppColors.floorPlanEntrance
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppDimensions.occasionSelectedBorderWidth,
    );
    _drawZoneLabel(
      canvas,
      AppStrings.entrance,
      Offset(
        size.width * AppDimensions.floorPlanEntranceLabelXFactor,
        size.height - AppDimensions.floorPlanEntranceLabelBottomOffset,
      ),
      size.width,
      color: AppColors.floorPlanEntrance,
    );

    final RRect bottomBar = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        padding,
        size.height - padding,
        math.max(0, size.width - padding * 2),
        AppDimensions.floorPlanBottomBarHeight,
      ),
      const Radius.circular(AppDimensions.pillRadius),
    );
    canvas.drawRRect(
      bottomBar,
      Paint()..color = AppColors.floorPlanEntranceFill,
    );
    canvas.drawCircle(
      Offset(size.width - padding - 16, size.height - padding + 9),
      5,
      Paint()..color = AppColors.primaryDark,
    );
  }

  void _drawRoom(
    Canvas canvas,
    RRect room, {
    required Color fill,
    required Color accent,
    required String label,
    required Offset labelOffset,
    required double maxWidth,
  }) {
    canvas.drawRRect(room, Paint()..color = fill);
    canvas.drawRRect(
      room,
      Paint()
        ..color = accent.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppDimensions.floorPlanHairlineStroke,
    );
    _drawZoneLabel(canvas, label, labelOffset, maxWidth, color: accent);
  }

  void _drawZoneLabel(
    Canvas canvas,
    String label,
    Offset offset,
    double maxWidth, {
    Color? color,
  }) {
    final TextPainter painter =
        TextPainter(
          text: TextSpan(
            text: label,
            style: AppTextStyles.floorPlanZoneLabel.copyWith(color: color),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: AppStrings.textEllipsis,
        )..layout(
          maxWidth: maxWidth * AppDimensions.floorPlanZoneLabelMaxWidthFactor,
        );

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
