import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_images.dart';
import '../../core/utils/app_dependency.dart';
import '../auth/controller/login_controller.dart';
import '../auth/controller/sign_up_controller.dart';
import '../discovery/repository/discovery_repository.dart';
import '../home/home_entry_warmup.dart';
import '../taxonomy/repository/taxonomy_repository.dart';

/// Warms the post-Splash destination so the first frame after
/// [Get.offAllNamed] does not hitch on controllers / image decode / taxonomy.
///
/// Never creates [HomeController] — Home progressive init stays route-owned.
class SplashDestinationPrep {
  SplashDestinationPrep._();

  /// Best-effort warm for [route]. Always completes (errors are logged only).
  static Future<void> prepare(String route) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      await _prepare(route).timeout(AppDimensions.splashDestinationPrepTimeout);
      _log('ready $route', stopwatch);
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint(
          '[SplashPrep] $route failed after '
          '${stopwatch.elapsedMilliseconds}ms: $error\n$stack',
        );
      }
    }
  }

  static Future<void> _prepare(String route) {
    switch (route) {
      case AppRoutes.home:
        return _prepareHome();
      case AppRoutes.welcome:
        return _prepareWelcome();
      case AppRoutes.onboarding:
        return _prepareOnboarding();
      case AppRoutes.favoriteCuisines:
        return _prepareFavoriteCuisines();
      default:
        return Future<void>.value();
    }
  }

  static Future<void> _prepareHome() async {
    // Local DI + promo decode only. Never await Discovery/Taxonomy HTTP here —
    // a slow/unreachable API was holding Splash for ~apiHardRequestTimeout and
    // felt like a freeze/crash after the first Splash page. Home progressive
    // init owns catalog loads; kick prefetch best-effort in the background.
    await HomeEntryWarmup.warmIdle();
    AppDependency.ensureTaxonomyRepository();
    AppDependency.ensureDiscoveryRepository();
    unawaited(Get.find<TaxonomyRepository>().prefetch());
    unawaited(Get.find<DiscoveryRepository>().listRestaurants());
  }

  static Future<void> _prepareWelcome() async {
    // Login/SignUp controllers only — UsersRepository stays lazy
    // until post-login identity persist or Home Stage 4.
    AppDependency.putPermanentIfAbsent(LoginController.new);
    AppDependency.putPermanentIfAbsent(SignUpController.new);
    await Future.wait<void>(<Future<void>>[
      _precacheAsset(AppImages.welcomeHero),
      HomeEntryWarmup.warmIdle(),
    ]);
  }

  static Future<void> _prepareOnboarding() async {
    AppDependency.ensureReservationFlowDependencies();
    await _precacheAsset(AppImages.r3);
  }

  static Future<void> _prepareFavoriteCuisines() async {
    AppDependency.ensureTaxonomyRepository();
    // Screen controller loads categories; do not block leaving Splash on HTTP.
    unawaited(Get.find<TaxonomyRepository>().fetchCuisineCategories());
  }

  static Future<void> _precacheAsset(String assetPath) async {
    // FakeAsync / TestWidgetsFlutterBinding cannot drain image codec timers
    // cleanly when the Splash tree is disposed mid-test.
    if (_isFlutterTestBinding) {
      return;
    }

    final BuildContext? context = Get.context ?? Get.key.currentContext;
    if (context != null && context.mounted) {
      await precacheImage(
        AssetImage(assetPath),
        context,
      ).timeout(AppDimensions.homeAssetPrecacheTimeout);
      return;
    }

    // Fallback when no element tree yet — decode into memory.
    final ByteData data = await rootBundle
        .load(assetPath)
        .timeout(AppDimensions.homeAssetPrecacheTimeout);
    final ui.Codec codec = await ui
        .instantiateImageCodec(data.buffer.asUint8List())
        .timeout(AppDimensions.homeAssetPrecacheTimeout);
    await codec.getNextFrame().timeout(AppDimensions.homeAssetPrecacheTimeout);
  }

  static bool get _isFlutterTestBinding => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  static void _log(String label, Stopwatch stopwatch) {
    if (kDebugMode) {
      debugPrint('[SplashPrep] $label: ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}
