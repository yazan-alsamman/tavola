import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/navigation/app_navigation.dart';
import '../widgets/welcome_bridge_scaffold.dart';

/// Branded bridge: Settings logout → Welcome.
///
/// Same Tavola lockup as Login / Guest transitions. Holds for
/// [AppDimensions.logoutTransitionDisplayDuration], then opens Welcome.
/// No GetX controller — session was already cleared before this route.
class LogoutTransitionScreen extends StatefulWidget {
  const LogoutTransitionScreen({super.key});

  @override
  State<LogoutTransitionScreen> createState() => _LogoutTransitionScreenState();
}

class _LogoutTransitionScreenState extends State<LogoutTransitionScreen> {
  bool _didStart = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didStart) {
      return;
    }
    _didStart = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_holdThenWelcome());
    });
  }

  Future<void> _holdThenWelcome() async {
    await Future<void>.delayed(
      AppDimensions.logoutTransitionDisplayDuration,
    );
    if (!mounted) {
      return;
    }
    AppNavigation.goShell(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) => const WelcomeBridgeScaffold();
}
