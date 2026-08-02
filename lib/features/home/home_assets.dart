import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_images.dart';

/// Home first-frame assets. Precache during Welcome/Login idle — not at cold start.
class HomeAssets {
  HomeAssets._();

  static Uint8List? _promoBytes;
  static ui.Image? _promoImage;
  static Future<void>? _promoInFlight;

  static bool get isPromoReady => _promoImage != null;

  static ImageProvider get promoProvider {
    final Uint8List? bytes = _promoBytes;
    if (bytes != null) {
      return MemoryImage(bytes);
    }
    return const AssetImage(AppImages.r5);
  }

  /// Decodes [AppImages.r5] so the first Home promo paint skips disk decode jank.
  static Future<void> precachePromo() {
    // Never start image codecs under the test binding — FakeAsync cannot
    // tolerate leftover decode/timeout Timers when the widget tree is disposed.
    if (_isFlutterTestBinding) {
      return Future<void>.value();
    }
    final Future<void>? inFlight = _promoInFlight;
    if (_promoImage != null) {
      return Future<void>.value();
    }
    if (inFlight != null) {
      return inFlight;
    }
    final Future<void> request = _decodePromo();
    _promoInFlight = request;
    return request.whenComplete(() {
      if (identical(_promoInFlight, request)) {
        _promoInFlight = null;
      }
    });
  }

  static bool get _isFlutterTestBinding => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  static Future<void> _decodePromo() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final ByteData data = await rootBundle
          .load(AppImages.r5)
          .timeout(AppDimensions.homeAssetPrecacheTimeout);
      final Uint8List bytes = data.buffer.asUint8List();
      _promoBytes = bytes;

      final ui.Codec codec = await ui
          .instantiateImageCodec(bytes)
          .timeout(AppDimensions.homeAssetPrecacheTimeout);
      final ui.FrameInfo frame = await codec.getNextFrame().timeout(
        AppDimensions.homeAssetPrecacheTimeout,
      );
      _promoImage = frame.image;
      _log('promo decode', stopwatch);
    } catch (_) {
      _log('promo decode failed', stopwatch);
      // First Home frame may still decode via AssetImage — never block navigation.
    }
  }

  static void _log(String label, Stopwatch stopwatch) {
    if (kDebugMode) {
      debugPrint('[HomePerf] $label: ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}
