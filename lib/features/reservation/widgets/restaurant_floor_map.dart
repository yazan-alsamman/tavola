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
import 'floor_plan_unavailable_notice.dart';
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
  String? _unavailableMessage;
  int _unavailableNoticeId = 0;

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
                        final String? unavailableMessage = _unavailableMessage;
                        final int unavailableNoticeId = _unavailableNoticeId;
                        return Stack(
                          children: [
                            InteractiveViewer(
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
                                    Get.find<LocaleController>()
                                        .languageCode
                                        .value;
                                  }
                                  final List<RestaurantTableModel> tables =
                                      widget.controller.floorPlanTables.toList(
                                        growable: false,
                                      );
                                  final List<FloorPlanAreaModel> areas = widget
                                      .controller
                                      .floorPlanAreas
                                      .toList(growable: false);
                                  final Size viewport = Size(
                                    mapWidth,
                                    mapHeight,
                                  );
                                  final _FloorPlanLayout layout =
                                      _layoutFloorPlan(
                                        viewport: viewport,
                                        tables: tables,
                                        areas: areas,
                                        textDirection: Directionality.of(
                                          context,
                                        ),
                                      );

                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      const SizedBox.expand(
                                        child: CustomPaint(
                                          painter: _RestaurantMapPainter(),
                                        ),
                                      ),
                                      ...areas.map(
                                        (FloorPlanAreaModel area) =>
                                            _buildArea(area, layout: layout),
                                      ),
                                      ...tables.map(
                                        (RestaurantTableModel table) =>
                                            _buildMapTable(
                                              table,
                                              frame: layout.frame,
                                            ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                            Positioned(
                              left: AppDimensions.contentPadding,
                              right: AppDimensions.contentPadding,
                              bottom: AppDimensions.smallSpacing,
                              child: unavailableMessage == null
                                  ? const SizedBox.shrink()
                                  : Align(
                                      alignment: Alignment.bottomCenter,
                                      child: IgnorePointer(
                                        child: FloorPlanUnavailableNotice(
                                          key: ValueKey<int>(
                                            unavailableNoticeId,
                                          ),
                                          message: unavailableMessage,
                                          onDismissed: () =>
                                              _clearUnavailableNotice(
                                                unavailableNoticeId,
                                              ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
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
    FloorPlanAreaModel area, {
    required _FloorPlanLayout layout,
  }) {
    final Rect? rect = layout.areas[area.id];
    if (rect == null) {
      return const SizedBox.shrink();
    }
    final FloorPlanFrame frame = layout.frame;
    final Color color = area.colorValue ?? AppColors.border;
    final String? translationKey = FloorPlanAreaModel.translationKeyFor(
      area.name,
    );
    final String label = translationKey == null ? area.name : translationKey.tr;
    return Positioned(
      key: ValueKey<String>('floor-plan-area-${area.id}'),
      left: frame.x(rect.left),
      top: frame.y(rect.top),
      width: frame.length(rect.width),
      height: frame.length(rect.height),
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
    required FloorPlanFrame frame,
  }) {
    final Rect? rect = FloorPlanGeometry.tableRect(table);
    if (rect == null) {
      return const SizedBox.shrink();
    }

    final double left = frame.x(rect.left);
    final double top = frame.y(rect.top);
    final double width = frame.length(rect.width);
    final double height = frame.length(rect.height);
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
          onTap: () => _onTableTap(table),
        ),
      ),
    );
  }

  void _onTableTap(RestaurantTableModel table) {
    routeFloorPlanTableTap(
      table: table,
      selectTable: widget.controller.selectTable,
      showUnavailable: _showUnavailableNotice,
    );
  }

  void _showUnavailableNotice(String message) {
    setState(() {
      _unavailableNoticeId += 1;
      _unavailableMessage = message;
    });
  }

  void _clearUnavailableNotice(int noticeId) {
    if (!mounted || noticeId != _unavailableNoticeId) {
      return;
    }
    setState(() => _unavailableMessage = null);
  }
}

/// Floor-plan taps. A blocked table shows [showUnavailable] and is not selected.
void routeFloorPlanTableTap({
  required RestaurantTableModel table,
  required void Function(RestaurantTableModel table) selectTable,
  required void Function(String message) showUnavailable,
}) {
  final String? blocked = table.selectionBlockedMessage;
  if (blocked != null) {
    showUnavailable(blocked);
    return;
  }
  selectTable(table);
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

class _FloorPlanLayout {
  const _FloorPlanLayout({required this.frame, required this.areas});

  final FloorPlanFrame frame;
  final Map<String, Rect> areas;
}

_FloorPlanLayout _layoutFloorPlan({
  required Size viewport,
  required List<RestaurantTableModel> tables,
  required List<FloorPlanAreaModel> areas,
  required TextDirection textDirection,
}) {
  final Rect? tablesBounds = FloorPlanGeometry.contentBounds(tables);
  if (tablesBounds == null) {
    return const _FloorPlanLayout(
      frame: FloorPlanFrame.identity,
      areas: <String, Rect>{},
    );
  }

  FloorPlanFrame frame = FloorPlanGeometry.frameContent(
    viewport: viewport,
    content: tablesBounds,
    inset: 0,
  );
  Map<String, Rect> visual = <String, Rect>{};
  for (int pass = 0; pass < 3; pass++) {
    final double scale = frame.scale <= 0 ? 1 : frame.scale;
    visual = <String, Rect>{};
    Rect? content;
    final Set<String> placed = <String>{};
    for (final FloorPlanAreaModel area in areas) {
      final Rect? cluster = FloorPlanGeometry.areaCluster(area, tables);
      if (cluster == null) {
        continue;
      }
      final Size label = _labelSize(_areaLabel(area), textDirection);
      final Rect wrapped = FloorPlanGeometry.encloseCluster(
        cluster: cluster,
        sideApi: label.height / scale,
        topBandApi: label.height / scale,
        minWidthApi: label.width / scale,
      );
      visual[area.id] = wrapped;
      content = content == null ? wrapped : content.expandToInclude(wrapped);
      for (final RestaurantTableModel table in tables) {
        if (table.floorPlanAreaId == area.id) {
          placed.add(table.id);
        }
      }
    }
    for (final RestaurantTableModel table in tables) {
      if (placed.contains(table.id)) {
        continue;
      }
      final Rect? occupied = FloorPlanGeometry.occupiedBounds(table);
      if (occupied == null) {
        continue;
      }
      content = content == null ? occupied : content.expandToInclude(occupied);
    }
    frame = FloorPlanGeometry.frameContent(
      viewport: viewport,
      content: content ?? tablesBounds,
      inset: 0,
    );
  }

  return _FloorPlanLayout(frame: frame, areas: visual);
}

String _areaLabel(FloorPlanAreaModel area) {
  final String? translationKey = FloorPlanAreaModel.translationKeyFor(
    area.name,
  );
  return translationKey == null ? area.name : translationKey.tr;
}

Size _labelSize(String label, TextDirection textDirection) {
  if (label.trim().isEmpty) {
    return Size.zero;
  }
  final TextPainter painter = TextPainter(
    text: TextSpan(text: label, style: AppTextStyles.floorPlanLiveLabel),
    textDirection: textDirection,
    maxLines: 1,
  )..layout();
  return Size(painter.width, painter.height);
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
