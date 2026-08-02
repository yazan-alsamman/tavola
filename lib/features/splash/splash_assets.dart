import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_images.dart';

/// Splash-only asset warm-up so the lavender decode finishes before first paint.
class SplashAssets {
  SplashAssets._();

  static Uint8List? _lavenderBytes;
  static ui.Image? _lavenderImage;

  static bool get isLavenderReady => _lavenderImage != null;

  /// Decoded image when [precacheLavender] succeeded; otherwise null.
  static ui.Image? get lavenderImage => _lavenderImage;

  /// Provider for [Image] widgets — prefers in-memory bytes after warm-up.
  static ImageProvider get lavenderProvider {
    final Uint8List? bytes = _lavenderBytes;
    if (bytes != null) {
      return MemoryImage(bytes);
    }
    return const AssetImage(AppImages.splashLavender);
  }

  /// Loads + decodes [AppImages.splashLavender] before `runApp`.
  ///
  /// Uses [rootBundle] / [ui.instantiateImageCodec] (no ImageStream timers) so
  /// FakeAsync widget tests cannot hang on an unfinished timeout Timer.
  static Future<void> precacheLavender() async {
    if (_lavenderImage != null) {
      return;
    }

    try {
      final ByteData data = await rootBundle
          .load(AppImages.splashLavender)
          .timeout(AppDimensions.splashAssetPrecacheTimeout);
      final Uint8List bytes = data.buffer.asUint8List();
      _lavenderBytes = bytes;

      final ui.Codec codec = await ui
          .instantiateImageCodec(bytes)
          .timeout(AppDimensions.splashAssetPrecacheTimeout);
      final ui.FrameInfo frame = await codec.getNextFrame().timeout(
        AppDimensions.splashAssetPrecacheTimeout,
      );
      _lavenderImage = frame.image;
    } catch (_) {
      // First frame may still decode via [lavenderProvider] — never block launch.
    }
  }
}
