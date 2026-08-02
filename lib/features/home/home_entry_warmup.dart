import 'package:flutter/foundation.dart';

import '../../core/utils/app_dependency.dart';
import 'home_assets.dart';

/// Idle warm-up for the first Home entry after Welcome / Login.
///
/// Does **not** create [HomeController] (still route-scoped / lazy). Only:
/// - [TaxonomyRepository] + [DiscoveryRepository] registration (no HTTP)
/// - Home promo image decode
///
/// Taxonomy / Discovery HTTP stay on Home progressive init (or Splash prep)
/// so idle warm-up never leaves dangling Dio timers.
class HomeEntryWarmup {
  HomeEntryWarmup._();

  static Future<void>? _inFlight;
  static bool _completed = false;

  static bool get isCompleted => _completed;

  /// Clears idle warm-up state between widget tests.
  @visibleForTesting
  static void resetForTest() {
    _inFlight = null;
    _completed = false;
  }

  /// Safe to call multiple times; work is deduped.
  static Future<void> warmIdle() {
    if (_completed) {
      return Future<void>.value();
    }
    final Future<void>? inFlight = _inFlight;
    if (inFlight != null) {
      return inFlight;
    }
    final Future<void> request = _run();
    _inFlight = request;
    return request.whenComplete(() {
      if (identical(_inFlight, request)) {
        _inFlight = null;
      }
    });
  }

  static Future<void> _run() async {
    final Stopwatch total = Stopwatch()..start();
    try {
      // Taxonomy + Discovery repos only — no Users/Favorites, no HTTP here.
      final Stopwatch deps = Stopwatch()..start();
      AppDependency.ensureTaxonomyRepository();
      AppDependency.ensureDiscoveryRepository();
      _log('ensureTaxonomy+Discovery', deps);

      final Stopwatch promo = Stopwatch()..start();
      await HomeAssets.precachePromo();
      _log('promo precache', promo);

      _completed = true;
      _log('warmIdle total', total);
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('[HomePerf] warmIdle failed: $error\n$stack');
      }
    }
  }

  static void _log(String label, Stopwatch stopwatch) {
    if (kDebugMode) {
      debugPrint('[HomePerf] $label: ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}
