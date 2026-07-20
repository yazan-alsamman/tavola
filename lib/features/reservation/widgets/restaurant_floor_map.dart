import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/select_table_controller.dart';
import '../model/restaurant_table_model.dart';
import '../model/table_status.dart';
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

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDimensions.floorPlanPulseDuration,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
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
      builder: (context, constraints) {
        final double mapWidth = constraints.maxWidth;
        final double mapHeight = constraints.maxHeight;
        final double scaleX = mapWidth / AppDimensions.floorPlanMapWidth;
        final double scaleY = mapHeight / AppDimensions.floorPlanMapHeight;
        final double tableScale = scaleX < scaleY ? scaleX : scaleY;

        return SizedBox(
          width: mapWidth,
          height: mapHeight,
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: AppDimensions.floorPlanMapMinScale,
            maxScale: AppDimensions.floorPlanMapMaxScale,
            boundaryMargin: const EdgeInsets.all(AppDimensions.smallSpacing),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: mapWidth,
              height: mapHeight,
              child: Obx(
                () => Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    SizedBox.expand(
                      child: CustomPaint(painter: _RestaurantMapPainter()),
                    ),
                    PositionedDirectional(
                      top: AppDimensions.regularSpacing,
                      start: AppDimensions.regularSpacing,
                      child: const TableStatusLegend(overlay: true),
                    ),
                    const PositionedDirectional(
                      top: AppDimensions.regularSpacing,
                      end: AppDimensions.regularSpacing,
                      child: FloorPlanLiveTimeBadge(),
                    ),
                    ...widget.controller.floorPlanTables.map(
                      (table) => _buildMapTable(
                        table,
                        scaleX: scaleX,
                        scaleY: scaleY,
                        tableScale: tableScale,
                        mapWidth: mapWidth,
                        mapHeight: mapHeight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapTable(
    RestaurantTableModel table, {
    required double scaleX,
    required double scaleY,
    required double tableScale,
    required double mapWidth,
    required double mapHeight,
  }) {
    final double baseSize = table.mapSize ?? AppDimensions.floorPlanTableSize;
    final double size = baseSize * tableScale;
    final double left = table.mapX * scaleX;
    final double top = table.mapY * scaleY;
    final bool isSelected =
        widget.controller.selectedTableId.value == table.id;
    final bool shouldPulse =
        table.status == TableStatus.available && !isSelected;

    final double clampedLeft = left.clamp(0.0, mapWidth - size);
    final double clampedTop = top.clamp(0.0, mapHeight - size);

    return Positioned(
      left: clampedLeft,
      top: clampedTop,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: shouldPulse ? _pulseAnimation.value : 1,
            child: child,
          );
        },
        child: FloorPlanTable(
          table: table,
          isSelected: isSelected,
          size: size,
          onTap: () => widget.controller.selectTable(table),
        ),
      ),
    );
  }
}

class _RestaurantMapPainter extends CustomPainter {
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
    const double padding = AppDimensions.floorPlanMapInnerPadding;

    final RRect outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
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

    final double diningLineY =
        size.height * AppDimensions.floorPlanDiningLineFactor;
    final double serviceLineY =
        size.height * AppDimensions.floorPlanServiceLineFactor;
    final double serviceSplitX =
        size.width * AppDimensions.floorPlanServiceSplitFactor;

    final RRect windowBay = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        padding,
        padding,
        size.width - padding * 2,
        size.height * AppDimensions.floorPlanWindowHeightFactor,
      ),
      const Radius.circular(AppDimensions.regularSpacing),
    );
    canvas.drawRRect(windowBay, Paint()..color = AppColors.secondaryLight);
    canvas.drawRRect(
      windowBay,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppDimensions.floorPlanHairlineStroke,
    );

    canvas.drawRect(
      Rect.fromLTRB(padding, diningLineY, size.width - padding, serviceLineY),
      Paint()..color = AppColors.primaryDark10,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        serviceSplitX,
        serviceLineY,
        size.width - padding,
        size.height - padding,
      ),
      Paint()..color = AppColors.secondaryLight,
    );

    final Paint zoneLine = Paint()
      ..color = AppColors.border
      ..strokeWidth = AppDimensions.floorPlanHairlineStroke;

    canvas.drawLine(
      Offset(padding, diningLineY),
      Offset(size.width - padding, diningLineY),
      zoneLine,
    );
    canvas.drawLine(
      Offset(padding, serviceLineY),
      Offset(size.width - padding, serviceLineY),
      zoneLine,
    );
    canvas.drawLine(
      Offset(serviceSplitX, serviceLineY),
      Offset(serviceSplitX, size.height - padding),
      zoneLine,
    );

    _drawZoneLabel(
      canvas,
      AppStrings.windowSeating,
      Offset(
        size.width * AppDimensions.floorPlanZoneLabelXFactor,
        AppDimensions.floorPlanZoneLabelTop,
      ),
      size.width,
    );
    _drawZoneLabel(
      canvas,
      AppStrings.mainDining,
      Offset(
        size.width * AppDimensions.floorPlanZoneLabelXFactor,
        diningLineY + AppDimensions.floorPlanZoneLabelOffsetY,
      ),
      size.width,
    );
    _drawZoneLabel(
      canvas,
      AppStrings.serviceArea,
      Offset(
        size.width * AppDimensions.floorPlanServiceLabelXFactor,
        serviceLineY + AppDimensions.floorPlanZoneLabelOffsetY,
      ),
      size.width,
    );

    final RRect entrance = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          size.width * AppDimensions.floorPlanEntranceXFactor,
          size.height - AppDimensions.floorPlanEntranceBottomOffset,
        ),
        width: size.width * AppDimensions.floorPlanEntranceWidthFactor,
        height: AppDimensions.floorPlanEntranceHeight,
      ),
      const Radius.circular(AppDimensions.pillRadius),
    );
    canvas.drawRRect(entrance, Paint()..color = AppColors.primaryDark10);
    _drawZoneLabel(
      canvas,
      AppStrings.entrance,
      Offset(
        size.width * AppDimensions.floorPlanEntranceLabelXFactor,
        size.height - AppDimensions.floorPlanEntranceLabelBottomOffset,
      ),
      size.width,
    );
  }

  void _drawZoneLabel(
    Canvas canvas,
    String label,
    Offset offset,
    double maxWidth,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: label, style: AppTextStyles.floorPlanZoneLabel),
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
