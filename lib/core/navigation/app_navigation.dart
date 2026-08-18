import 'package:get/get.dart';

/// Stack-safe navigation helpers shared across shell tabs and drill-down flows.
class AppNavigation {
  AppNavigation._();

  static bool _shellInFlight = false;
  static bool _pushInFlight = false;
  static String? _pendingShellRoute;
  static dynamic _pendingShellArguments;
  static bool _pendingShellHasArguments = false;

  static bool isCurrent(String route) => Get.currentRoute == route;

  /// Shell destinations (home / map / profile / …): replace the entire stack.
  ///
  /// Shell tab controllers are registered permanent via
  /// [AppDependency.putPermanentIfAbsent] so `offAllNamed` does not dispose
  /// Home when opening Profile (and likewise for other shell tabs).
  ///
  /// Note: GetX route Futures complete when the route is *removed*, not when
  /// navigation finishes — never await them to clear in-flight guards.
  ///
  /// When [arguments] is provided, navigation always runs so a route can be
  /// re-opened with a fresh payload (e.g. login after password reset).
  ///
  /// Concurrent [goShell] calls coalesce to the latest destination instead of
  /// dropping a real transition (e.g. Home then session-expired Login).
  static void goShell(String route, {dynamic arguments}) {
    if (_shellInFlight) {
      _pendingShellRoute = route;
      _pendingShellArguments = arguments;
      _pendingShellHasArguments = true;
      return;
    }
    if (arguments == null && isCurrent(route)) {
      return;
    }

    _shellInFlight = true;
    _pendingShellRoute = null;
    _pendingShellArguments = null;
    _pendingShellHasArguments = false;
    try {
      Get.offAllNamed(route, arguments: arguments);
    } finally {
      // Allow the next tab tap after this synchronous navigation call.
      Future<void>.delayed(Duration.zero, () {
        _shellInFlight = false;
        final String? pending = _pendingShellRoute;
        if (pending == null) {
          return;
        }
        final dynamic pendingArgs = _pendingShellArguments;
        final bool hasArgs = _pendingShellHasArguments;
        _pendingShellRoute = null;
        _pendingShellArguments = null;
        _pendingShellHasArguments = false;
        goShell(pending, arguments: hasArgs ? pendingArgs : null);
      });
    }
  }

  /// Drill-down push: never stacks the same named route on top of itself.
  static void pushOnce(String route, {dynamic arguments}) {
    pushNamed(route, arguments: arguments);
  }

  /// Push a named route.
  ///
  /// Set [allowDuplicate] when re-opening a flow like OTP with new arguments
  /// (e.g. Forgot Password after a previous OTP visit).
  static void pushNamed(
    String route, {
    dynamic arguments,
    bool allowDuplicate = false,
  }) {
    if (_pushInFlight) {
      return;
    }
    if (!allowDuplicate && isCurrent(route)) {
      return;
    }

    _pushInFlight = true;
    try {
      Get.toNamed(
        route,
        arguments: arguments,
        preventDuplicates: !allowDuplicate,
      );
    } finally {
      Future<void>.delayed(Duration.zero, () {
        _pushInFlight = false;
      });
    }
  }
}
