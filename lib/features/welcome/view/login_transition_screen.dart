import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/app_dependency.dart';
import '../welcome_bridge_timing.dart';
import '../widgets/welcome_bridge_scaffold.dart';

/// Branded bridge: Welcome → Login.
///
/// No GetX controller or Binding. Paints the Tavola lockup on the first
/// frame, warms Login deps after paint, then replaces itself.
class LoginTransitionScreen extends StatefulWidget {
  const LoginTransitionScreen({super.key});

  @override
  State<LoginTransitionScreen> createState() => _LoginTransitionScreenState();
}

class _LoginTransitionScreenState extends State<LoginTransitionScreen> {
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
      unawaited(_prepareAndNavigate());
    });
  }

  Future<void> _prepareAndNavigate() async {
    try {
      await waitForWelcomeBridgeReady(_prepareLogin());
    } catch (_) {
      // Destination Binding can still put LoginController if needed.
    }
    if (!mounted) {
      return;
    }
    Get.offNamed(AppRoutes.login);
  }

  Future<void> _prepareLogin() async {
    // Controllers only — no API / Keychain on this bridge.
    AppDependency.ensureLoginRouteDependencies();
  }

  @override
  Widget build(BuildContext context) => const WelcomeBridgeScaffold();
}
