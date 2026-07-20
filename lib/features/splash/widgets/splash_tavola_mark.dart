import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

/// Branded Tavola splash lockup: elongated T stroke + lavender on the first A.
class SplashTavolaMark extends StatelessWidget {
  const SplashTavolaMark({
    super.key,
    required this.drawProgress,
    required this.lavenderImage,
  });

  final Animation<double> drawProgress;

  /// Prebuilt once so the asset is not re-created on every animation tick.
  final Widget lavenderImage;

  @override
  Widget build(BuildContext context) {
    final String mark = AppStrings.splashBrandMark;
    final List<double> advances = <double>[];
    for (int i = 0; i < mark.length; i++) {
      final TextPainter letter = TextPainter(
        text: TextSpan(text: mark[i], style: AppTextStyles.splashBrandGlyph),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      advances.add(letter.width);
    }

    final List<double> lefts = <double>[];
    double cursor = 0;
    for (int i = 0; i < advances.length; i++) {
      lefts.add(cursor);
      cursor += advances[i];
      if (i < advances.length - 1) {
        cursor += AppDimensions.splashBrandLetterSpacing;
      }
    }
    final double totalWidth = cursor;

    final TextPainter heightProbe = TextPainter(
      text: TextSpan(text: mark, style: AppTextStyles.splashBrandGlyph),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final double markHeight = heightProbe.height;

    final double tWidth = advances[0];
    final double firstALeft = lefts[1];
    final double firstAWidth = advances[1];
    final double lLeft = lefts[4];
    final double lWidth = advances[4];
    final double lastALeft = lefts[5];
    final double lastAWidth = advances[5];

    final double barY = markHeight * AppDimensions.splashBarHeightFactor;
    // Stem tip and bar cut share one X (pivot is the tip, not the box center).
    final double tipFrac =
        (1 + AppDimensions.splashLavenderPivotX) / 2;
    final double cutCenterX = firstALeft +
        (firstAWidth * AppDimensions.splashLavenderOnAFactor) +
        AppDimensions.splashLavenderHorizontalNudge;
    final double gapStart =
        cutCenterX - AppDimensions.splashLavenderBarGapHalf;
    final double gapEnd = cutCenterX + AppDimensions.splashLavenderBarGapHalf;
    final double cutY = barY;

    final _TavolaStrokeLayout strokeLayout = _TavolaStrokeLayout(
      tWidth: tWidth,
      lLeft: lLeft,
      lWidth: lWidth,
      lastALeft: lastALeft,
      lastAWidth: lastAWidth,
      markHeight: markHeight,
      gapStartX: gapStart,
      gapEndX: gapEnd,
    );

    final double lavenderTopLift = math.max(
      0,
      AppDimensions.splashLavenderHeight -
          AppDimensions.splashLavenderBarOverlap -
          barY,
    );
    final double sidePad = AppDimensions.splashLavenderWidth *
        AppDimensions.splashLavenderSidePadFactor;

    // Glyphs a, v, o, a — `l` is formed by the elongated T stroke itself.
    const List<int> revealGlyphIndexes = <int>[1, 2, 3, 5];

    return AnimatedBuilder(
      animation: drawProgress,
      child: lavenderImage,
      builder: (context, lavenderChild) {
        final double draw = Curves.easeInOutCubic.transform(drawProgress.value);
        final double lavT = ((draw - AppDimensions.splashLavenderRevealAt) /
                AppDimensions.splashLavenderRevealSpread)
            .clamp(0.0, 1.0);
        // Slow drop + settle, same easing family as the T stroke.
        final double lavMotion =
            Curves.easeInOutCubic.transform(lavT);
        final double lavOpacity = Curves.easeOut.transform(lavT);
        final double lavScale = AppDimensions.splashLavenderStartScale +
            (AppDimensions.splashLavenderEndScale -
                    AppDimensions.splashLavenderStartScale) *
                lavMotion;
        final double lavFromAbove =
            AppDimensions.splashLavenderDropDistance * (1 - lavMotion);
        final double lavTiltDegrees =
            AppDimensions.splashLavenderTiltDegrees +
                (AppDimensions.splashLavenderEntranceTiltExtra *
                    (1 - lavMotion));
        final double strokeFrontX = strokeLayout.frontX(draw);

        return SizedBox(
          width: totalWidth + (sidePad * 2),
          // Equal top/bottom reserve keeps the word optically screen-centered.
          height: markHeight + (lavenderTopLift * 2),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: sidePad,
                right: sidePad,
                top: lavenderTopLift,
                height: markHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final int index in revealGlyphIndexes)
                      Positioned(
                        left: lefts[index],
                        bottom: 0,
                        child: _RevealedBrandGlyph(
                          glyph: mark[index],
                          progress: _letterProgressFromStroke(
                            strokeFrontX: strokeFrontX,
                            letterLeft: lefts[index],
                            letterWidth: advances[index],
                          ),
                        ),
                      ),
                    CustomPaint(
                      size: Size(totalWidth, markHeight),
                      painter: _TavolaStrokePainter(
                        progress: draw,
                        layout: strokeLayout,
                      ),
                    ),
                    if (lavT > 0)
                      Positioned(
                        // Stem tip (pivot) sits exactly on cutCenterX, cutY.
                        left: cutCenterX -
                            (AppDimensions.splashLavenderWidth * tipFrac),
                        top: cutY -
                            AppDimensions.splashLavenderHeight +
                            AppDimensions.splashLavenderBarOverlap,
                        width: AppDimensions.splashLavenderWidth,
                        height: AppDimensions.splashLavenderHeight,
                        child: Opacity(
                          opacity: lavOpacity,
                          child: Transform.translate(
                            offset: Offset(0, -lavFromAbove),
                            child: Transform.rotate(
                              angle: lavTiltDegrees * math.pi / 180,
                              alignment: const Alignment(
                                AppDimensions.splashLavenderPivotX,
                                1,
                              ),
                              child: Transform.scale(
                                scale: lavScale,
                                alignment: const Alignment(
                                  AppDimensions.splashLavenderPivotX,
                                  1,
                                ),
                                child: lavenderChild,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _letterProgressFromStroke({
    required double strokeFrontX,
    required double letterLeft,
    required double letterWidth,
  }) {
    final double triggerX =
        letterLeft + (letterWidth * AppDimensions.splashLetterRevealAtFactor);
    final double span =
        math.max(letterWidth * AppDimensions.splashLetterRevealSpanFactor, 1);
    final double raw = ((strokeFrontX - triggerX) / span).clamp(0.0, 1.0);
    // Match the T-stroke easing so each glyph settles with the bar.
    return Curves.easeInOutCubic.transform(raw);
  }
}

class _RevealedBrandGlyph extends StatelessWidget {
  const _RevealedBrandGlyph({
    required this.glyph,
    required this.progress,
  });

  final String glyph;
  final double progress;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) {
      return const SizedBox.shrink();
    }

    final double settle = 1 - progress;
    final double opacity = progress;
    final double rise = AppDimensions.splashLetterRise * settle;
    final double slide = AppDimensions.splashLetterSlide * settle;
    final double scale = AppDimensions.splashLetterStartScale +
        ((1 - AppDimensions.splashLetterStartScale) * progress);

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(-slide, rise),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: Text(glyph, style: AppTextStyles.splashBrandGlyph),
        ),
      ),
    );
  }
}

/// Shared geometry for painting the T stroke and revealing letters in sync.
class _TavolaStrokeLayout {
  const _TavolaStrokeLayout({
    required this.tWidth,
    required this.lLeft,
    required this.lWidth,
    required this.lastALeft,
    required this.lastAWidth,
    required this.markHeight,
    required this.gapStartX,
    required this.gapEndX,
  });

  final double tWidth;
  final double lLeft;
  final double lWidth;
  final double lastALeft;
  final double lastAWidth;
  final double markHeight;
  final double gapStartX;
  final double gapEndX;

  double get barY => markHeight * AppDimensions.splashBarHeightFactor;

  double get stemX => tWidth * AppDimensions.splashTStemWidthFactor;

  double get serif => AppDimensions.splashBrandSerifDepth;

  double get barStartX =>
      stemX - (tWidth * AppDimensions.splashBarStartInsetFactor);

  double get barEndBeforeL =>
      lLeft + (lWidth * AppDimensions.splashBarEndOnLFactor);

  double get tipStartX =>
      lLeft + (lWidth * AppDimensions.splashTipStartOnLFactor);

  double get tipEndX =>
      lastALeft + (lastAWidth * AppDimensions.splashTipLengthFactor);

  double get lBottom => markHeight * AppDimensions.splashLDropBottomFactor;

  double get stemBottom =>
      markHeight * AppDimensions.splashTStemBottomFactor;

  /// Horizontal front of the elongated T as draw progress advances.
  double frontX(double progress) {
    if (progress <= AppDimensions.splashStrokeBarBeforeStart) {
      return barStartX;
    }

    if (progress < AppDimensions.splashStrokeBarBeforeEnd) {
      final double t = _segmentProgress(
        progress,
        AppDimensions.splashStrokeBarBeforeStart,
        AppDimensions.splashStrokeBarBeforeEnd,
      );
      final double endX = math.min(gapStartX, barEndBeforeL);
      return ui.lerpDouble(barStartX + serif, endX, t)!;
    }

    if (progress < AppDimensions.splashStrokeBarAfterStart) {
      return gapEndX;
    }

    if (progress < AppDimensions.splashStrokeTipStart) {
      final double t = _segmentProgress(
        progress,
        AppDimensions.splashStrokeBarAfterStart,
        AppDimensions.splashStrokeBarAfterEnd,
      );
      final double horiz = AppDimensions.splashStrokeBarAfterHorizPortion;
      if (t <= horiz) {
        return ui.lerpDouble(
          math.max(gapEndX, barStartX + serif),
          barEndBeforeL,
          t / horiz,
        )!;
      }
      // Vertical L drop: X stays on the L while the stem draws down.
      return barEndBeforeL;
    }

    final double tipT = _segmentProgress(
      progress,
      AppDimensions.splashStrokeTipStart,
      AppDimensions.splashStrokeTipEnd,
    );
    return ui.lerpDouble(tipStartX, tipEndX, tipT)!;
  }

  static double _segmentProgress(double overall, double start, double end) {
    if (overall <= start) {
      return 0;
    }
    if (overall >= end) {
      return 1;
    }
    return (overall - start) / (end - start);
  }
}

class _TavolaStrokePainter extends CustomPainter {
  const _TavolaStrokePainter({
    required this.progress,
    required this.layout,
  });

  final double progress;
  final _TavolaStrokeLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) {
      return;
    }

    final Path stemPath = Path()
      ..moveTo(layout.stemX, layout.stemBottom)
      ..lineTo(layout.stemX, layout.barY);

    // Split the long bar so nothing is drawn under the lavender.
    final Path barBeforeGap = Path()
      ..moveTo(layout.barStartX, layout.barY + layout.serif)
      ..quadraticBezierTo(
        layout.barStartX,
        layout.barY,
        layout.barStartX + layout.serif,
        layout.barY,
      )
      ..lineTo(math.min(layout.gapStartX, layout.barEndBeforeL), layout.barY);

    final Path barAfterGap = Path()
      ..moveTo(
        math.max(layout.gapEndX, layout.barStartX + layout.serif),
        layout.barY,
      )
      ..lineTo(layout.barEndBeforeL, layout.barY)
      ..lineTo(layout.barEndBeforeL, layout.lBottom);

    final Path tipPath = Path()
      ..moveTo(layout.tipStartX, layout.barY)
      ..lineTo(layout.tipEndX - layout.serif, layout.barY)
      ..quadraticBezierTo(
        layout.tipEndX,
        layout.barY,
        layout.tipEndX,
        layout.barY + layout.serif,
      );

    final Paint primaryPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppDimensions.splashBrandStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final Paint tipPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppDimensions.splashBrandTipStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    _drawMetric(
      canvas,
      stemPath,
      primaryPaint,
      _TavolaStrokeLayout._segmentProgress(
        progress,
        AppDimensions.splashStrokeStemStart,
        AppDimensions.splashStrokeStemEnd,
      ),
    );
    _drawMetric(
      canvas,
      barBeforeGap,
      primaryPaint,
      _TavolaStrokeLayout._segmentProgress(
        progress,
        AppDimensions.splashStrokeBarBeforeStart,
        AppDimensions.splashStrokeBarBeforeEnd,
      ),
    );
    _drawMetric(
      canvas,
      barAfterGap,
      primaryPaint,
      _TavolaStrokeLayout._segmentProgress(
        progress,
        AppDimensions.splashStrokeBarAfterStart,
        AppDimensions.splashStrokeBarAfterEnd,
      ),
    );
    _drawMetric(
      canvas,
      tipPath,
      tipPaint,
      _TavolaStrokeLayout._segmentProgress(
        progress,
        AppDimensions.splashStrokeTipStart,
        AppDimensions.splashStrokeTipEnd,
      ),
    );
  }

  void _drawMetric(Canvas canvas, Path path, Paint paint, double t) {
    if (t <= 0) {
      return;
    }
    for (final ui.PathMetric metric in path.computeMetrics()) {
      final Path extract = metric.extractPath(0, metric.length * t);
      canvas.drawPath(extract, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TavolaStrokePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.layout.tWidth != layout.tWidth ||
        oldDelegate.layout.lLeft != layout.lLeft ||
        oldDelegate.layout.lWidth != layout.lWidth ||
        oldDelegate.layout.lastALeft != layout.lastALeft ||
        oldDelegate.layout.lastAWidth != layout.lastAWidth ||
        oldDelegate.layout.markHeight != layout.markHeight ||
        oldDelegate.layout.gapStartX != layout.gapStartX ||
        oldDelegate.layout.gapEndX != layout.gapEndX;
  }
}
