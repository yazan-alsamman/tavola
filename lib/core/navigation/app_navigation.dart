import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';

/// Stack-safe navigation helpers shared across shell tabs and drill-down flows.
class AppNavigation {
  AppNavigation._();

  static bool _shellInFlight = false;
  static bool _pushInFlight = false;
  static String? _pendingShellRoute;
  static dynamic _pendingShellArguments;
  static bool _pendingShellHasArguments = false;
  static bool? _pendingShellFromRight;
  static bool? _shellFromRight;
  static const Duration _shellSlideDuration = Duration(milliseconds: 300);
  static CustomTransition? _previousCustomTransition;
  static _ShellDepthTransition? _activeShellSlide;

  static bool isCurrent(String route) => Get.currentRoute == route;

  /// Next [goShell] slides with the bottom-nav tab order.
  ///
  /// [fromRight] is true when the new tab index is higher (page enters from
  /// the right). False enters from the left. Cleared after that navigation.
  static void prepareShellDirection({required bool fromRight}) {
    _shellFromRight = fromRight;
  }

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
    final bool? fromRight = _shellFromRight;
    _shellFromRight = null;
    if (_shellInFlight) {
      _pendingShellRoute = route;
      _pendingShellArguments = arguments;
      _pendingShellHasArguments = true;
      _pendingShellFromRight = fromRight;
      return;
    }
    if (arguments == null && isCurrent(route)) {
      return;
    }

    _shellInFlight = true;
    _pendingShellRoute = null;
    _pendingShellArguments = null;
    _pendingShellHasArguments = false;
    _pendingShellFromRight = null;
    GetPageRoute<void>? shellRoute;
    try {
      if (fromRight == null) {
        Get.offAllNamed(route, arguments: arguments);
      } else {
        shellRoute = _replaceShell(route, arguments: arguments);
      }
    } finally {
      // Hold the stack until the depth transition finishes so both tabs move.
      final Duration wait = shellRoute == null
          ? Duration.zero
          : _shellSlideDuration;
      Future<void>.delayed(wait, () {
        if (shellRoute != null) {
          _finishShellSlide(shellRoute);
        }
        _shellInFlight = false;
        final String? pending = _pendingShellRoute;
        if (pending == null) {
          return;
        }
        final dynamic pendingArgs = _pendingShellArguments;
        final bool hasArgs = _pendingShellHasArguments;
        final bool? pendingFromRight = _pendingShellFromRight;
        _pendingShellRoute = null;
        _pendingShellArguments = null;
        _pendingShellHasArguments = false;
        _pendingShellFromRight = null;
        if (pendingFromRight != null) {
          _shellFromRight = pendingFromRight;
        }
        goShell(pending, arguments: hasArgs ? pendingArgs : null);
      });
    }
  }

  /// Pushes the next tab above the current one so both can move together.
  static GetPageRoute<void>? _replaceShell(
    String route, {
    required dynamic arguments,
  }) {
    GetPage<dynamic>? page;
    for (final GetPage<dynamic> candidate in AppRoutes.routes) {
      if (candidate.name == route) {
        page = candidate;
        break;
      }
    }
    final NavigatorState? navigator = Get.key.currentState;
    if (page == null || navigator == null) {
      Get.offAllNamed(route, arguments: arguments);
      return null;
    }
    final _ShellDepthTransition slide = _ShellDepthTransition();
    _previousCustomTransition = Get.customTransition;
    _activeShellSlide = slide;
    // The page underneath reads this while it is covered.
    Get.customTransition = slide;
    final GetPageRoute<void> shellRoute = _ShellPageRoute<void>(
      page: page.page,
      binding: page.binding,
      bindings: page.bindings,
      settings: RouteSettings(name: route, arguments: arguments),
      routeName: route,
      slide: slide,
    );
    navigator.push<void>(shellRoute);
    return shellRoute;
  }

  static void _finishShellSlide(GetPageRoute<void> shellRoute) {
    if (identical(Get.customTransition, _activeShellSlide)) {
      Get.customTransition = _previousCustomTransition;
    }
    _activeShellSlide = null;
    _previousCustomTransition = null;
    final NavigatorState? navigator = Get.key.currentState;
    if (navigator == null || !navigator.mounted || !shellRoute.isCurrent) {
      return;
    }
    for (int i = 0; i < 12 && navigator.canPop(); i++) {
      navigator.removeRouteBelow(shellRoute);
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

/// Tab handoff that is not a back-stack pop. The route underneath stays until
/// the depth transition ends, then it is removed.
class _ShellPageRoute<T> extends GetPageRoute<T> {
  _ShellPageRoute({
    required GetPageBuilder page,
    required RouteSettings settings,
    required String routeName,
    required _ShellDepthTransition slide,
    super.binding,
    super.bindings,
  }) : super(
         page: page,
         settings: settings,
         routeName: routeName,
         // The page underneath must stay painted while the new tab fades in.
         opaque: false,
         curve: Curves.linear,
         popGesture: false,
         transitionDuration: AppNavigation._shellSlideDuration,
         customTransition: slide,
       );

  @override
  RoutePopDisposition get popDisposition => RoutePopDisposition.doNotPop;
}

/// Shared-axis depth between shell tabs. The current page eases back to 98%
/// and dims slightly. The next page eases from 98% to full size as it fades in.
/// A full-bleed backdrop stays under the outgoing page so the 2% inset never
/// uncovers the window.
class _ShellDepthTransition extends CustomTransition {
  _ShellDepthTransition();

  static const double _restScale = 0.98;
  static const double _outgoingOpacity = 0.92;
  static const Curve _curve = Curves.easeInOutCubic;

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final double outgoing = secondaryAnimation.value;
    if (outgoing > 0 && animation.value > 0.999) {
      final double t = _curve.transform(outgoing.clamp(0.0, 1.0));
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _depth(
          scale: 1 - ((1 - _restScale) * t),
          opacity: 1 - ((1 - _outgoingOpacity) * t),
          child: child,
        ),
      );
    }
    final double t = _curve.transform(animation.value.clamp(0.0, 1.0));
    return _depth(
      scale: _restScale + ((1 - _restScale) * t),
      opacity: t,
      child: child,
    );
  }

  Widget _depth({
    required double scale,
    required double opacity,
    required Widget child,
  }) {
    return Transform.scale(
      scale: scale,
      child: Opacity(opacity: opacity, child: child),
    );
  }
}
