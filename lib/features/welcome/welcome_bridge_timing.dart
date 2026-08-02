import '../../core/constants/app_dimensions.dart';

/// Ensures the branded Welcome bridge stays on screen long enough to read
/// while [prepare] runs in parallel.
Future<void> waitForWelcomeBridgeReady(Future<void> prepare) async {
  await Future.wait<void>(<Future<void>>[
    prepare
        .timeout(
          AppDimensions.welcomeTransitionMinDisplayDuration,
          onTimeout: () {},
        )
        .catchError((Object _) {}),
    Future<void>.delayed(AppDimensions.welcomeTransitionMinDisplayDuration),
  ]);
}
