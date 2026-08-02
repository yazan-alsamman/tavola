import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/favorite_cuisines_preferences.dart';
import '../../../core/utils/onboarding_preferences.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../splash_destination_prep.dart';

class SplashController extends GetxController {
  Timer? _navigationTimer;
  Timer? _prepTimer;
  bool _didNavigate = false;
  Future<String>? _destinationFuture;
  Future<void>? _destinationPrepFuture;

  @override
  void onInit() {
    super.onInit();
    // Start preference reads immediately so navigation after the display
    // duration does not hitch on SharedPreferences I/O.
    _destinationFuture = _resolveDestination();
  }

  @override
  void onReady() {
    super.onReady();
    final Duration ready = AppDimensions.splashReadyDuration;
    final Duration prepLead = AppDimensions.splashDestinationPrepLead;
    final Duration prepAt = ready > prepLead ? ready - prepLead : Duration.zero;

    // Warm the next route [prepLead] before leaving Splash so the transition
    // paints a fully prepared first frame (no mid-transition decode/DI hitch).
    _prepTimer = Timer(prepAt, () {
      unawaited(_ensureDestinationPrepared());
    });

    _navigationTimer = Timer(ready, () {
      unawaited(_navigateAfterSplash());
    });
  }

  Future<String> _resolveDestination() async {
    final bool onboardingCompleted = await OnboardingPreferences.isCompleted();
    if (!onboardingCompleted) {
      return AppRoutes.onboarding;
    }
    final bool cuisinesCompleted =
        await FavoriteCuisinesPreferences.isCompleted();
    if (!cuisinesCompleted) {
      return AppRoutes.favoriteCuisines;
    }
    if (Get.isRegistered<AuthSessionController>()) {
      final AuthSessionController session = Get.find<AuthSessionController>();
      try {
        await session.syncFromStoredTokens().timeout(
          AppDimensions.secureStorageTimeout,
        );
      } on TimeoutException {
        // Stuck Keychain must not pin Splash — fall through to Welcome.
      }
      if (session.hasAuthenticatedSession.value) {
        return AppRoutes.home;
      }
    }
    return AppRoutes.welcome;
  }

  Future<void> _ensureDestinationPrepared() {
    final Future<void>? inFlight = _destinationPrepFuture;
    if (inFlight != null) {
      return inFlight;
    }
    final Future<void> request = _prepareDestination();
    _destinationPrepFuture = request;
    return request;
  }

  Future<void> _prepareDestination() async {
    final String route = await (_destinationFuture ?? _resolveDestination());
    if (isClosed) {
      return;
    }
    await SplashDestinationPrep.prepare(route);
  }

  Future<void> _navigateAfterSplash() async {
    if (_didNavigate || isClosed) {
      return;
    }

    // Best-effort warm only — never hold Splash for slow network / Keychain.
    // Prep usually started [splashDestinationPrepLead] earlier; grace covers
    // a short remaining local warm, then we leave regardless.
    try {
      await _ensureDestinationPrepared().timeout(
        AppDimensions.splashNavigationPrepGrace,
      );
    } on TimeoutException {
      // Destination screens own their own loading / progressive init.
    }
    if (isClosed || _didNavigate) {
      return;
    }
    _didNavigate = true;

    final String route = await (_destinationFuture ?? _resolveDestination());
    if (isClosed) {
      return;
    }
    Get.offAllNamed(route);
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    _navigationTimer = null;
    _prepTimer?.cancel();
    _prepTimer = null;
    super.onClose();
  }
}
