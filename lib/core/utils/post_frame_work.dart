import 'dart:async';

import 'package:flutter/scheduler.dart';

/// Runs [work] after the current frame is committed.
///
/// Use from GetX [onInit] when Binding creates the controller on the navigation
/// frame — so the destination's first paint is not blocked by I/O.
class PostFrameWork {
  PostFrameWork._();

  static void schedule(void Function() work) {
    SchedulerBinding.instance.addPostFrameCallback((_) => work());
  }

  /// Runs [work] on the next frame after yielding the event loop.
  ///
  /// Chaining [schedule] inside a post-frame callback is drained in the same
  /// frame by Flutter. A microtask hop spreads progressive Home stages.
  static void scheduleAfterNextFrame(void Function() work) {
    scheduleMicrotask(() {
      final SchedulerBinding binding = SchedulerBinding.instance;
      binding.addPostFrameCallback((_) => work());
      binding.scheduleFrame();
    });
  }
}
