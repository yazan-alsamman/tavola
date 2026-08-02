import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/utils/app_dependency.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../home/controller/home_controller.dart';
import '../welcome_bridge_timing.dart';
import '../widgets/welcome_bridge_scaffold.dart';

/// Branded bridge: Welcome → Home (guest).
///
/// UI-only: paints the Tavola lockup, then asks [AuthSessionController] to
/// prepare the guest session before opening Home.
class GuestTransitionScreen extends StatefulWidget {
  const GuestTransitionScreen({super.key});

  @override
  State<GuestTransitionScreen> createState() => _GuestTransitionScreenState();
}

class _GuestTransitionScreenState extends State<GuestTransitionScreen> {
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
      final AuthSessionController? session =
          Get.isRegistered<AuthSessionController>()
          ? Get.find<AuthSessionController>()
          : null;
      await waitForWelcomeBridgeReady(
        session != null
            ? session.prepareGuestHomeEntry()
            : Future<void>.sync(AppDependency.ensureHomeController),
      );
    } catch (_) {
      if (!Get.isRegistered<HomeController>()) {
        AppDependency.ensureHomeController();
      }
    }
    if (!mounted) {
      return;
    }
    AppNavigation.goShell(AppRoutes.home);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<AuthSessionController>()) {
        Get.find<AuthSessionController>().flushDeferredGuestSecureStorage();
      }
    });
  }

  @override
  Widget build(BuildContext context) => const WelcomeBridgeScaffold();
}
