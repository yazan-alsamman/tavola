import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../../core/network/jwt_payload.dart';
import '../../../core/network/secure_auth_token_store.dart';
import '../../../core/utils/app_dependency.dart';
import '../../details/repository/restaurant_details_repository.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../home/controller/home_controller.dart';
import '../../home/home_entry_warmup.dart';
import '../../notifications/service/push_identity_service.dart';
import '../../profile/controller/profile_controller.dart';
import '../../reservation/repository/reservation_repository.dart';
import '../../users/repository/users_repository.dart';
import '../model/customer_auth_response_model.dart';
import '../model/session_mode.dart';
import '../repository/auth_repository.dart';
import '../session_mode_preferences.dart';

class AuthSessionController extends GetxController implements GuestModeReader {
  final RxBool isGuest = false.obs;
  final RxBool hasAuthenticatedSession = false.obs;

  /// True anonymous browsing — no tokens, no authenticated APIs.
  @override
  bool get isAnonymousGuest =>
      isGuest.value && !hasAuthenticatedSession.value;

  /// App-bar Login CTA: guest-only, never while a real session exists.
  bool get shouldShowGuestLoginButton => isAnonymousGuest;

  /// Shared avatar URL from the permanent users cache (survives Profile dispose).
  ///
  /// Reading [UsersRepository.profileRx] inside Obx keeps the app bar in sync
  /// without views touching the repository directly.
  String? observeSharedAvatarUrl() {
    // Touch session flags so AppBar Obx stays valid before UsersRepository
    // exists (anonymous Guest Home skips profile registration).
    isGuest.value;
    hasAuthenticatedSession.value;
    if (!Get.isRegistered<UsersRepository>()) {
      return null;
    }
    final String? url = Get.find<UsersRepository>().profileRx.value?.avatarUrl
        ?.trim();
    if (url == null || url.isEmpty) {
      return null;
    }
    return url;
  }

  /// Aligns guest/session flags with Secure Storage tokens (app start / resume).
  ///
  /// When a Bearer token exists, also persists [SessionMode.authenticated] so
  /// upgrades from older builds keep Welcome skipped after restart.
  Future<void> syncFromStoredTokens() async {
    final AuthTokenReader? reader = Get.isRegistered<AuthTokenReader>()
        ? Get.find<AuthTokenReader>()
        : null;
    if (reader is SecureAuthTokenStore) {
      // Splash must wait for Keychain hydrate before routing — not race it.
      await reader.hydrate();
    }
    final String? access = await reader?.readAccessToken();
    final String? refresh = reader is AuthTokenSession
        ? await reader.readRefreshToken()
        : null;
    final bool hasToken = access != null && access.trim().isNotEmpty;
    hasAuthenticatedSession.value = hasToken;
    if (hasToken) {
      isGuest.value = false;
      await _persistSessionMode(SessionMode.authenticated);
    }
    _logStartup(
      'syncFromStoredTokens',
      accessPresent: hasToken,
      refreshPresent: refresh != null && refresh.trim().isNotEmpty,
    );
  }

  /// Restores anonymous guest flags after process death (no tokens created).
  ///
  /// Used by Splash when [SessionMode.guest] is persisted and Keychain has no
  /// access token. Does not call login/refresh.
  Future<void> restorePersistedGuestSession() async {
    await enterAsGuest();
  }

  /// Restores authenticated flags when [SessionMode.authenticated] survived
  /// process death but Keychain hydrate is still empty/slow.
  ///
  /// Does not invent tokens. Splash routes Home; hydrate retries for Bearer.
  void restorePersistedAuthenticatedSession() {
    isGuest.value = false;
    hasAuthenticatedSession.value = true;
  }

  Future<void> _persistSessionMode(SessionMode mode) async {
    try {
      await SessionModePreferences.write(mode);
      _logStartup('persistSessionMode', mode: mode);
    } catch (_) {
      // Session flags already updated in memory; disk is best-effort.
    }
  }

  static void _logStartup(
    String label, {
    SessionMode? mode,
    bool? accessPresent,
    bool? refreshPresent,
    String? destination,
  }) {
    if (!kDebugMode) {
      return;
    }
    final StringBuffer buffer = StringBuffer('[StartupSession] $label');
    if (mode != null) {
      buffer.write(' mode=${mode.storageValue}');
    }
    if (accessPresent != null) {
      buffer.write(' access=$accessPresent');
    }
    if (refreshPresent != null) {
      buffer.write(' refresh=$refreshPresent');
    }
    if (destination != null) {
      buffer.write(' destination=$destination');
    }
    debugPrint(buffer.toString());
  }

  bool _deferGuestDiskClear = false;

  /// Marks guest in memory immediately. Keychain / identity clears are
  /// best-effort and must never block Welcome → Home on the first tap.
  ///
  /// When [deferSecureStorage] is true (Welcome bridge), only memory tokens
  /// are cleared — call [flushDeferredGuestSecureStorage] after Home paints.
  Future<void> enterAsGuest({bool deferSecureStorage = false}) async {
    // Clear Bearer tokens from memory before flipping session flags so
    // in-flight Home loads cannot attach a stale Authorization header.
    try {
      final AuthTokenReader? reader = Get.isRegistered<AuthTokenReader>()
          ? Get.find<AuthTokenReader>()
          : null;
      if (reader is SecureAuthTokenStore) {
        // Memory clear is mandatory for Guest purity; Keychain can wait.
        reader.clearMemorySessionOnly();
        if (deferSecureStorage) {
          _deferGuestDiskClear = true;
        } else {
          reader.scheduleDiskClear();
        }
      } else if (reader is AuthTokenSession) {
        // Non-Keychain sessions: always drop tokens when entering Guest.
        unawaited(reader.clearSessionTokens());
      }
    } catch (_) {
      // Guest UI still advances.
    }
    isGuest.value = true;
    hasAuthenticatedSession.value = false;
    _pendingIdentity = null;
    _pendingSignupUsername = null;
    _postLoginBootstrapPending = false;
    _resetHomeAuthenticatedBootstrapGate();
    // Persist guest so Splash restores Home after Hot Restart / reboot.
    // SharedPreferences must not block Welcome → Home.
    unawaited(_persistSessionMode(SessionMode.guest));
    if (deferSecureStorage) {
      _deferGuestDiskClear = true;
    } else {
      unawaited(_clearGuestIdentity());
    }
  }

  void _resetHomeAuthenticatedBootstrapGate() {
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().resetAuthenticatedBootstrapGate();
      }
    } catch (_) {
      // Home may not exist yet (Welcome / Splash).
    }
  }

  /// Finishes Keychain / identity clear deferred from the Welcome guest bridge.
  void flushDeferredGuestSecureStorage() {
    if (!_deferGuestDiskClear) {
      return;
    }
    _deferGuestDiskClear = false;
    try {
      final AuthTokenReader? reader = Get.isRegistered<AuthTokenReader>()
          ? Get.find<AuthTokenReader>()
          : null;
      if (reader is SecureAuthTokenStore) {
        reader.scheduleDiskClear();
      }
    } catch (_) {}
    unawaited(_clearGuestIdentity());
  }

  Future<void> _clearGuestIdentity() async {
    try {
      if (Get.isRegistered<UsersRepository>()) {
        final UsersRepository usersRepository = Get.find<UsersRepository>();
        usersRepository.clearSessionCaches();
        await usersRepository.clearCustomerIdentity();
      }
      if (Get.isRegistered<FavoritesRepository>()) {
        Get.find<FavoritesRepository>().clearSessionState();
      }
      _clearReservationSessionCaches();
    } catch (_) {
      // Guest UI already advanced; persistence is best-effort.
    }
  }

  /// Drops in-session Profile bookings so account A never leaks into account B.
  void _clearReservationSessionCaches() {
    try {
      if (Get.isRegistered<ReservationRepository>()) {
        Get.find<ReservationRepository>().clearSessionState();
      }
      if (Get.isRegistered<ProfileController>()) {
        final ProfileController profile = Get.find<ProfileController>();
        if (!profile.isClosed) {
          profile.refreshReservations();
        }
      }
    } catch (_) {
      // Session navigation must not fail on cache cleanup.
    }
  }

  void _clearWorkingHoursCacheBestEffort() {
    try {
      if (Get.isRegistered<RestaurantDetailsRepository>()) {
        Get.find<RestaurantDetailsRepository>().clearWorkingHoursCache();
      }
    } catch (_) {
      // Hours reload on next Details visit.
    }
  }

  /// Login/register critical path: **memory tokens + session flags only**.
  ///
  /// Never starts Keychain, SharedPreferences, UsersRepository, Home catch-up,
  /// or cache wipes here — those race `goShell(home)` on iOS and can kill the
  /// process (`Lost connection to device`). Call [schedulePostLoginBootstrap]
  /// only after navigation to Home returns.
  Future<void> completeSignIn(CustomerAuthResponseModel response) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    final AuthTokenReader reader = Get.find<AuthTokenReader>();
    if (reader is! AuthTokenSession) {
      throw ApiException(message: AppStrings.invalidAuthSessionPayload);
    }
    final Stopwatch tokenWatch = Stopwatch()..start();
    await reader.updateSessionTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      persistToDisk: false,
    );
    _perf('updateSessionTokens', tokenWatch);
    // Cancel any deferred Guest Keychain clear so a later bootstrap persist
    // cannot be wiped by a stale Guest disk-clear still in flight.
    _deferGuestDiskClear = false;
    isGuest.value = false;
    hasAuthenticatedSession.value = true;
    _pendingIdentity = response;
    _postLoginBootstrapPending = true;
    _perf('completeSignIn total', stopwatch);
  }

  bool _postLoginBootstrapPending = false;

  /// Runs every side-effect that used to race Login — only after Home paints.
  ///
  /// Call immediately after [AppNavigation.goShell] to Home (Login / Sign Up).
  void schedulePostLoginBootstrap() {
    if (!_postLoginBootstrapPending && _pendingIdentity == null) {
      return;
    }
    scheduleMicrotask(() {
      final SchedulerBinding binding = SchedulerBinding.instance;
      // Two frames: (1) Login dispose / Home mount (2) Home first paint settled.
      binding.addPostFrameCallback((_) {
        binding.addPostFrameCallback((_) {
          unawaited(_runPostLoginBootstrap());
        });
        binding.scheduleFrame();
      });
      binding.scheduleFrame();
    });
  }

  /// Runs deferred post-login work immediately (idempotent). Used by tests;
  /// production relies on [schedulePostLoginBootstrap] after Home paints.
  Future<void> flushPostLoginBootstrap() => _runPostLoginBootstrap();

  Future<void> _runPostLoginBootstrap() async {
    if (!_postLoginBootstrapPending) {
      return;
    }
    _postLoginBootstrapPending = false;
    final CustomerAuthResponseModel? identity = _pendingIdentity;

    // Cache / prefs / Keychain / identity — all off the Login submit stack.
    _clearReservationSessionCaches();
    _clearWorkingHoursCacheBestEffort();
    await _persistSessionMode(SessionMode.authenticated);
    final AuthTokenReader? reader = Get.isRegistered<AuthTokenReader>()
        ? Get.find<AuthTokenReader>()
        : null;
    if (reader is SecureAuthTokenStore) {
      reader.scheduleDiskPersist();
    }
    if (identity != null) {
      _applyPendingIdentityInMemory(identity);
    }
    final String? signupUsername = _pendingSignupUsername?.trim();
    if (signupUsername != null && signupUsername.isNotEmpty) {
      try {
        AppDependency.ensureUsersRepository();
        Get.find<UsersRepository>().applyCustomerIdentityInMemory(
          username: signupUsername,
          phone: '',
        );
      } catch (_) {
        // Disk flush still happens in persistDeferredSessionArtifacts.
      }
    }
    _notifyHomeBecameAuthenticated();
  }

  void _notifyHomeBecameAuthenticated() {
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().onBecameAuthenticated();
      }
    } catch (_) {
      // Home created later; its first progressive start sees auth session.
    }
  }

  void _applyPendingIdentityInMemory(CustomerAuthResponseModel response) {
    try {
      AppDependency.ensureUsersRepository();
      final UsersRepository users = Get.find<UsersRepository>();
      users.resetProfileLoadGate();
      String username = response.username.trim();
      if (username.isEmpty) {
        username = JwtPayload.readUsername(response.accessToken);
      }
      if (kDebugMode) {
        debugPrint(
          '[ProfileIdentity] remember login username="$username" '
          'phone="${response.phone}"',
        );
      }
      users.applyCustomerIdentityInMemory(
        username: username,
        phone: response.phone,
        avatarUrl: response.avatarUrl,
      );
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('[ProfileIdentity] remember failed: $error\n$stack');
      }
    }
  }

  /// Keeps a known signup username when login/me payloads omit it.
  Future<void> rememberProfileUsername(String username) async {
    final String value = username.trim();
    if (value.isEmpty) {
      return;
    }
    try {
      AppDependency.ensureUsersRepository();
      final UsersRepository users = Get.find<UsersRepository>();
      await users.rememberCustomerIdentity(
        username: value,
        phone: users.cachedProfile?.phone ?? '',
        avatarUrl: users.cachedProfile?.avatarUrl,
      );
    } catch (_) {
      // Profile can still recover from `/users/me` later.
    }
  }

  CustomerAuthResponseModel? _pendingIdentity;
  String? _pendingSignupUsername;

  /// Stashes signup username in memory until [schedulePostLoginBootstrap].
  void stashSignupUsername(String username) {
    final String value = username.trim();
    if (value.isEmpty) {
      return;
    }
    _pendingSignupUsername = value;
  }

  /// Flushes memory session + identity to Keychain after Login→Home paints.
  ///
  /// Called from [HomeProgressiveInit] — never from the Login submit path.
  Future<void> persistDeferredSessionArtifacts() async {
    final AuthTokenReader? reader = Get.isRegistered<AuthTokenReader>()
        ? Get.find<AuthTokenReader>()
        : null;
    if (reader is SecureAuthTokenStore) {
      reader.scheduleDiskPersist();
    }
    final CustomerAuthResponseModel? pending = _pendingIdentity;
    _pendingIdentity = null;
    if (pending != null) {
      await _persistCustomerIdentity(pending);
    }
    final String? signupUsername = _pendingSignupUsername;
    _pendingSignupUsername = null;
    if (signupUsername != null && signupUsername.isNotEmpty) {
      await rememberProfileUsername(signupUsername);
    }
    // Non-blocking push identity JWT for OneSignal / backend registration.
    unawaited(_syncPushIdentityBestEffort());
  }

  Future<void> _syncPushIdentityBestEffort() async {
    try {
      AppDependency.ensurePushIdentityService();
      await Get.find<PushIdentityService>().syncIdentityToken();
    } catch (_) {
      // Push identity is optional for App Store customer flows.
    }
  }

  static void _perf(String label, Stopwatch stopwatch) {
    if (kDebugMode) {
      debugPrint(
        '[LoginPerf] authSession $label: ${stopwatch.elapsedMicroseconds}µs',
      );
    }
  }

  /// Best-effort username/phone cache after tokens are already live in memory.
  Future<void> _persistCustomerIdentity(
    CustomerAuthResponseModel response,
  ) async {
    try {
      AppDependency.ensureUsersRepository();
      await Get.find<UsersRepository>().rememberCustomerIdentity(
        username: response.username,
        phone: response.phone,
        avatarUrl: response.avatarUrl,
      );
      await Get.find<UsersRepository>().flushIdentityToDisk();
    } catch (_) {
      // Identity cache is optional; session tokens already establish login.
    }
  }

  /// True when a non-empty access token is available in the session store.
  Future<bool> hasAccessToken() => AuthAccessGuard.hasAccessToken();


  /// Account-only gate (favorites, avatar, reservations, settings, …).
  ///
  /// Opens Login when there is no Bearer token.
  /// Returns `true` when the caller may proceed with authenticated APIs.
  Future<bool> requireSignInForProtectedAction() async {
    if (await hasAccessToken()) {
      hasAuthenticatedSession.value = true;
      isGuest.value = false;
      unawaited(_persistSessionMode(SessionMode.authenticated));
      return true;
    }
    hasAuthenticatedSession.value = false;
    openLogin();
    return false;
  }

  /// Controller-layer helper for feature toggles (favorites, etc.).
  static Future<bool> requireSignInIfRegistered() async {
    if (!Get.isRegistered<AuthSessionController>()) {
      return false;
    }
    return Get.find<AuthSessionController>().requireSignInForProtectedAction();
  }

  void openLogin() {
    AppNavigation.pushOnce(AppRoutes.login);
  }

  /// Welcome guest bridge: memory guest session + Home Stage 0 warm.
  Future<void> prepareGuestHomeEntry() async {
    await Future.wait<void>(<Future<void>>[
      enterAsGuest(deferSecureStorage: true),
      HomeEntryWarmup.warmIdle(),
    ]);
    AppDependency.ensureHomeController();
  }

  /// Settings → branded bridge → Welcome (Login / Sign Up + Guest).
  ///
  /// 1. Best-effort `POST /auth/logout` while Bearer is still available
  ///    (revokes the current server session)
  /// 2. Await local token wipe (memory + Keychain) so the next cold start
  ///    cannot resurrect an authenticated session from leftover SecItem*
  /// 3. Clear identity / [SessionMode.none]
  /// 4. Navigate via logout bridge
  ///
  /// Remote failure never blocks local logout (offline / already-revoked).
  Future<void> logOut({bool allDevices = false}) async {
    await _revokeRemoteSessionBestEffort(allDevices: allDevices);
    await _clearLocalSessionTokensBestEffort();
    unawaited(_clearGuestIdentity());
    if (Get.isRegistered<PushIdentityService>()) {
      Get.find<PushIdentityService>().clear();
    }
    _pendingIdentity = null;
    _pendingSignupUsername = null;
    _postLoginBootstrapPending = false;
    _deferGuestDiskClear = false;
    isGuest.value = false;
    hasAuthenticatedSession.value = false;
    _resetHomeAuthenticatedBootstrapGate();
    // Clear persisted mode before Welcome so the next cold start is Fresh.
    await _persistSessionMode(SessionMode.none);
    AppNavigation.goShell(AppRoutes.logoutTransition);
    // Warm Login/SignUp after leaving the shell so Welcome after the bridge
    // is ready — never block logout navigation on idle Home warm-up.
    scheduleMicrotask(AppDependency.ensureLoginRouteDependencies);
  }

  /// Wipes Bearer tokens from memory and awaits Keychain clear (bounded).
  Future<void> _clearLocalSessionTokensBestEffort() async {
    try {
      final AuthTokenReader? reader = Get.isRegistered<AuthTokenReader>()
          ? Get.find<AuthTokenReader>()
          : null;
      if (reader is! AuthTokenSession) {
        return;
      }
      await reader.clearSessionTokens().timeout(
        AppDimensions.secureStorageTimeout,
      );
    } catch (_) {
      // Still leave the shell for the logout bridge.
    }
  }

  /// Calls `POST /auth/logout` (or logout-all) before tokens are wiped.
  Future<void> _revokeRemoteSessionBestEffort({
    required bool allDevices,
  }) async {
    try {
      if (!Get.isRegistered<AuthRepository>() ||
          !Get.isRegistered<AuthTokenReader>()) {
        return;
      }
      final String? access =
          await Get.find<AuthTokenReader>().readAccessToken();
      if (access == null || access.trim().isEmpty) {
        return;
      }
      final AuthRepository auth = Get.find<AuthRepository>();
      if (allDevices) {
        await auth
            .logoutAllSessions(access)
            .timeout(AppDimensions.authLogoutTimeout);
      } else {
        await auth
            .logoutCurrentSession(access)
            .timeout(AppDimensions.authLogoutTimeout);
      }
    } catch (_) {
      // Local session clear must still run.
    }
  }

  /// Clears stored tokens when refresh fails.
  /// Redirects to login only if a prior session existed.
  Future<void> handleSessionExpired() async {
    final AuthTokenReader? reader = Get.isRegistered<AuthTokenReader>()
        ? Get.find<AuthTokenReader>()
        : null;

    bool hadSession = false;
    if (reader is AuthTokenSession) {
      final String? refresh = await reader.readRefreshToken();
      hadSession = refresh != null && refresh.isNotEmpty;
      await reader.clearSessionTokens();
    }
    if (Get.isRegistered<UsersRepository>()) {
      await Get.find<UsersRepository>().clearCustomerIdentity();
    }

    hasAuthenticatedSession.value = false;
    if (hadSession) {
      // Real session expired — leave guest mode and send user to Login.
      isGuest.value = false;
      _resetHomeAuthenticatedBootstrapGate();
      await _persistSessionMode(SessionMode.none);
      // Register Login before navigation: expiry often fires from ApiClient's
      // 401 interceptor while Home is still mounting. Relying only on the
      // Login route Binding races the first LoginScreen.build Get.find.
      AppDependency.ensureLoginRouteDependencies();
      AppNavigation.goShell(AppRoutes.login);
    }
    // Guest probing `/users/me` without a token must NOT clear isGuest,
    // or the Home app-bar Login CTA disappears.
  }
}
