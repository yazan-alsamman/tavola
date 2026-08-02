import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Collects [FrameTiming] samples for auth navigation benchmarks.
///
/// Active in profile/release when measuring; used by integration_test and the
/// optional `--dart-define=AUTH_NAV_PERF=1` probe.
class FrameTimingCollector {
  FrameTimingCollector();

  final List<FrameTiming> _timings = <FrameTiming>[];
  bool _listening = false;

  void start() {
    if (_listening) {
      return;
    }
    _timings.clear();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _listening = true;
  }

  void stop() {
    if (!_listening) {
      return;
    }
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _listening = false;
  }

  void _onTimings(List<FrameTiming> timings) {
    _timings.addAll(timings);
  }

  FrameTimingReport report({required String label}) {
    return FrameTimingReport.fromTimings(label: label, timings: _timings);
  }
}

class FrameTimingReport {
  const FrameTimingReport({
    required this.label,
    required this.sampleCount,
    required this.averageUiMs,
    required this.worstUiMs,
    required this.averageRasterMs,
    required this.worstRasterMs,
    required this.framesOver16Ms,
    required this.framesOver33Ms,
    required this.skippedFramesEstimate,
    required this.shaderCompilationSuspect,
  });

  final String label;
  final int sampleCount;
  final double averageUiMs;
  final double worstUiMs;
  final double averageRasterMs;
  final double worstRasterMs;
  final int framesOver16Ms;
  final int framesOver33Ms;

  /// Frames whose build+raster budget exceeded ~2 vsyncs (33ms).
  final int skippedFramesEstimate;

  /// True when any raster sample is extreme (typical first-shader compile).
  final bool shaderCompilationSuspect;

  static const double budgetMs = 16.6;
  static const double doubleBudgetMs = 33.2;
  static const double shaderSuspectRasterMs = 40.0;

  factory FrameTimingReport.fromTimings({
    required String label,
    required List<FrameTiming> timings,
  }) {
    if (timings.isEmpty) {
      return FrameTimingReport(
        label: label,
        sampleCount: 0,
        averageUiMs: 0,
        worstUiMs: 0,
        averageRasterMs: 0,
        worstRasterMs: 0,
        framesOver16Ms: 0,
        framesOver33Ms: 0,
        skippedFramesEstimate: 0,
        shaderCompilationSuspect: false,
      );
    }

    double uiSum = 0;
    double rasterSum = 0;
    double worstUi = 0;
    double worstRaster = 0;
    int over16 = 0;
    int over33 = 0;
    int skipped = 0;
    bool shaderSuspect = false;

    for (final FrameTiming timing in timings) {
      final double uiMs = timing.buildDuration.inMicroseconds / 1000.0;
      final double rasterMs = timing.rasterDuration.inMicroseconds / 1000.0;
      final double totalMs = uiMs + rasterMs;

      uiSum += uiMs;
      rasterSum += rasterMs;
      if (uiMs > worstUi) {
        worstUi = uiMs;
      }
      if (rasterMs > worstRaster) {
        worstRaster = rasterMs;
      }
      if (uiMs > budgetMs || rasterMs > budgetMs) {
        over16++;
      }
      if (uiMs > doubleBudgetMs || rasterMs > doubleBudgetMs) {
        over33++;
      }
      if (totalMs > doubleBudgetMs) {
        skipped++;
      }
      if (rasterMs >= shaderSuspectRasterMs) {
        shaderSuspect = true;
      }
    }

    final int n = timings.length;
    return FrameTimingReport(
      label: label,
      sampleCount: n,
      averageUiMs: uiSum / n,
      worstUiMs: worstUi,
      averageRasterMs: rasterSum / n,
      worstRasterMs: worstRaster,
      framesOver16Ms: over16,
      framesOver33Ms: over33,
      skippedFramesEstimate: skipped,
      shaderCompilationSuspect: shaderSuspect,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'label': label,
    'sampleCount': sampleCount,
    'averageUiMs': double.parse(averageUiMs.toStringAsFixed(2)),
    'worstUiMs': double.parse(worstUiMs.toStringAsFixed(2)),
    'averageRasterMs': double.parse(averageRasterMs.toStringAsFixed(2)),
    'worstRasterMs': double.parse(worstRasterMs.toStringAsFixed(2)),
    'framesOver16Ms': framesOver16Ms,
    'framesOver33Ms': framesOver33Ms,
    'skippedFramesEstimate': skippedFramesEstimate,
    'shaderCompilationSuspect': shaderCompilationSuspect,
    'budgetMs': budgetMs,
  };

  String toPrettyString() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('[AuthNavPerf] $label')
      ..writeln('  samples=$sampleCount')
      ..writeln('  avgUI=${averageUiMs.toStringAsFixed(2)}ms')
      ..writeln('  worstUI=${worstUiMs.toStringAsFixed(2)}ms')
      ..writeln('  avgRaster=${averageRasterMs.toStringAsFixed(2)}ms')
      ..writeln('  worstRaster=${worstRasterMs.toStringAsFixed(2)}ms')
      ..writeln('  frames>16.6ms=$framesOver16Ms')
      ..writeln('  frames>33ms=$framesOver33Ms')
      ..writeln('  skippedFramesEstimate=$skippedFramesEstimate')
      ..writeln('  shaderCompilationSuspect=$shaderCompilationSuspect');
    return buffer.toString();
  }

  void dump({String? path}) {
    // Always print in profile — this is the measurement evidence.
    // ignore: avoid_print
    print(toPrettyString());
    // ignore: avoid_print
    print('[AuthNavPerf:json] ${jsonEncode(toJson())}');
    if (path != null && !kIsWeb) {
      File(path).writeAsStringSync('${jsonEncode(toJson())}\n');
    }
  }
}
