import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../../core/utils/favorite_cuisines_preferences.dart';
import '../../../core/utils/onboarding_preferences.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../auth/model/session_mode.dart';
import '../../auth/session_mode_preferences.dart';
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
    _destinationFuture = resolveDestination();
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

  /// Post-Splash named route from onboarding gates + persisted session mode.
  ///
  /// Controllers own this decision tree (MVC). Tests call the same method.
  ///
  /// Waits for token-store hydrate (via [AuthSessionController.syncFromStoredTokens])
  /// + SessionMode prefs before deciding. Never clears
  /// [SessionMode.authenticated] on a missing-token race — only Logout /
  /// session expiry clear that mode.
  static Future<String> resolveDestination() async {
    final bool onboardingCompleted = await OnboardingPreferences.isCompleted();
    if (!onboardingCompleted) {
      return _finish(AppRoutes.onboarding, SessionMode.none, false, false);
    }
    final bool cuisinesCompleted =
        await FavoriteCuisinesPreferences.isCompleted();
    if (!cuisinesCompleted) {
      return _finish(
        AppRoutes.favoriteCuisines,
        SessionMode.none,
        false,
        false,
      );
    }
    if (!Get.isRegistered<AuthSessionController>()) {
      return _finish(AppRoutes.welcome, SessionMode.none, false, false);
    }

    final AuthSessionController session = Get.find<AuthSessionController>();
    try {
      // syncFromStoredTokens awaits SecureAuthTokenStore.hydrate() first.
      await session.syncFromStoredTokens().timeout(
        AppDimensions.secureStorageTimeout,
      );
    } on TimeoutException {
      _debugLog('syncFromStoredTokens timeout — using SessionMode fallback');
    }

    final SessionMode mode = await SessionModePreferences.read();
    final bool accessPresent = await _readTokenPresent(isRefresh: false);
    final bool refreshPresent = await _readTokenPresent(isRefresh: true);

    _debugLog(
      'inputs mode=${mode.storageValue} access=$accessPresent '
      'refresh=$refreshPresent '
      'hasAuthenticatedSession=${session.hasAuthenticatedSession.value}',
    );

    if (session.hasAuthenticatedSession.value || accessPresent) {
      session.restorePersistedAuthenticatedSession();
      return _finish(
        AppRoutes.home,
        mode == SessionMode.none ? SessionMode.authenticated : mode,
        accessPresent,
        refreshPresent,
      );
    }

    if (mode == SessionMode.guest) {
      await session.restorePersistedGuestSession();
      return _finish(
        AppRoutes.home,
        SessionMode.guest,
        accessPresent,
        refreshPresent,
      );
    }

    if (mode == SessionMode.authenticated) {
      // Persisted login survived process death. Tokens may still be hydrating
      // (or Keychain timed out). Do NOT clear SessionMode — that was the Hot
      // Restart → Welcome bug. Restore flags and open Home.
      session.restorePersistedAuthenticatedSession();
      return _finish(
        AppRoutes.home,
        SessionMode.authenticated,
        accessPresent,
        refreshPresent,
      );
    }

    return _finish(AppRoutes.welcome, mode, accessPresent, refreshPresent);
  }

  static Future<bool> _readTokenPresent({required bool isRefresh}) async {
    if (!Get.isRegistered<AuthTokenReader>()) {
      return false;
    }
    final AuthTokenReader reader = Get.find<AuthTokenReader>();
    try {
      final String? value = isRefresh
          ? (reader is AuthTokenSession
                ? await reader.readRefreshToken().timeout(
                    AppDimensions.secureStorageTimeout,
                  )
                : null)
          : await reader.readAccessToken().timeout(
              AppDimensions.secureStorageTimeout,
            );
      return value != null && value.trim().isNotEmpty;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static String _finish(
    String destination,
    SessionMode mode,
    bool accessPresent,
    bool refreshPresent,
  ) {
    _debugLog(
      'final destination=$destination mode=${mode.storageValue} '
      'access=$accessPresent refresh=$refreshPresent',
    );
    return destination;
  }

  static void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[StartupSession] $message');
    }
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
    final String route =
        await (_destinationFuture ?? resolveDestination());
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

    final String route =
        await (_destinationFuture ?? resolveDestination());
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
