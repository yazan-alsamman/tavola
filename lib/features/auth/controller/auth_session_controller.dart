import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../../core/network/secure_auth_token_store.dart';
import '../../../core/utils/app_dependency.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../home/home_entry_warmup.dart';
import '../../profile/controller/profile_controller.dart';
import '../../reservation/repository/reservation_repository.dart';
import '../../users/repository/users_repository.dart';
import '../model/customer_auth_response_model.dart';

class AuthSessionController extends GetxController {
  final RxBool isGuest = false.obs;
  final RxBool hasAuthenticatedSession = false.obs;

  /// App-bar Login CTA: guest-only, never while a real session exists.
  bool get shouldShowGuestLoginButton =>
      isGuest.value && !hasAuthenticatedSession.value;

  /// Shared avatar URL from the permanent users cache (survives Profile dispose).
  ///
  /// Reading [UsersRepository.profileRx] inside Obx keeps the app bar in sync
  /// without views touching the repository directly.
  String? observeSharedAvatarUrl() {
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
  Future<void> syncFromStoredTokens() async {
    final AuthTokenReader? reader = Get.isRegistered<AuthTokenReader>()
        ? Get.find<AuthTokenReader>()
        : null;
    final String? access = await reader?.readAccessToken();
    final bool hasToken = access != null && access.trim().isNotEmpty;
    hasAuthenticatedSession.value = hasToken;
    if (hasToken) {
      isGuest.value = false;
    }
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
        reader.clearMemorySessionOnly();
        if (deferSecureStorage) {
          _deferGuestDiskClear = true;
        } else {
          reader.scheduleDiskClear();
        }
      } else if (reader is AuthTokenSession) {
        // Test doubles / non-secure sessions: never hit storage when deferred.
        if (!deferSecureStorage) {
          unawaited(reader.clearSessionTokens());
        }
      }
    } catch (_) {
      // Guest UI still advances.
    }
    isGuest.value = true;
    hasAuthenticatedSession.value = false;
    if (deferSecureStorage) {
      _deferGuestDiskClear = true;
    } else {
      unawaited(_clearGuestIdentity());
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

  Future<void> completeSignIn(CustomerAuthResponseModel response) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    final AuthTokenReader reader = Get.find<AuthTokenReader>();
    if (reader is! AuthTokenSession) {
      throw ApiException(message: AppStrings.invalidAuthSessionPayload);
    }
    // New account session — never keep the previous account's in-memory bookings.
    _clearReservationSessionCaches();
    // Blocking Login path: memory tokens only — then navigate.
    // Keychain persistence is deferred until after Home's first frames
    // ([persistDeferredSessionArtifacts]) so physical iOS never freezes on
    // SecItem* during goShell(Home).
    final Stopwatch tokenWatch = Stopwatch()..start();
    await reader.updateSessionTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    _perf('updateSessionTokens', tokenWatch);
    // Clear guest immediately so the Login CTA never stays after a real login.
    isGuest.value = false;
    hasAuthenticatedSession.value = true;
    _pendingIdentity = response;
    // Apply username/phone in memory now. Home progressive init runs once, so
    // guest → login would otherwise never call [persistDeferredSessionArtifacts].
    unawaited(_applyPendingIdentityInMemory(response));
    _perf('completeSignIn total', stopwatch);
  }

  Future<void> _applyPendingIdentityInMemory(
    CustomerAuthResponseModel response,
  ) async {
    try {
      AppDependency.ensureUsersRepository();
      final UsersRepository users = Get.find<UsersRepository>();
      users.resetProfileLoadGate();
      await users.rememberCustomerIdentity(
        username: response.username,
        phone: response.phone,
      );
      unawaited(users.ensureProfileLoaded());
    } catch (_) {
      // Profile UI can still load later from `/users/me`.
    }
  }

  CustomerAuthResponseModel? _pendingIdentity;

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
      );
      await Get.find<UsersRepository>().flushIdentityToDisk();
    } catch (_) {
      // Identity cache is optional; session tokens already establish login.
    }
  }

  /// True when a non-empty access token is available in the session store.
  Future<bool> hasAccessToken() async {
    final AuthTokenReader? reader = Get.isRegistered<AuthTokenReader>()
        ? Get.find<AuthTokenReader>()
        : null;
    final String? access = await reader?.readAccessToken();
    return access != null && access.trim().isNotEmpty;
  }

  /// Account-only gate (favorites, avatar, reservations, settings, …).
  ///
  /// Opens Login when there is no Bearer token.
  /// Returns `true` when the caller may proceed with authenticated APIs.
  Future<bool> requireSignInForProtectedAction() async {
    if (await hasAccessToken()) {
      hasAuthenticatedSession.value = true;
      isGuest.value = false;
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
  /// Clears Bearer tokens and identity without blocking navigation on Keychain.
  /// The bridge matches Login / Guest transition UI for
  /// [AppDimensions.logoutTransitionDisplayDuration].
  Future<void> logOut() async {
    try {
      final AuthTokenReader? reader = Get.isRegistered<AuthTokenReader>()
          ? Get.find<AuthTokenReader>()
          : null;
      if (reader is AuthTokenSession) {
        // Memory clears synchronously before the first await.
        unawaited(reader.clearSessionTokens());
      }
    } catch (_) {
      // Still leave the shell for the logout bridge.
    }
    unawaited(_clearGuestIdentity());
    _pendingIdentity = null;
    _deferGuestDiskClear = false;
    isGuest.value = false;
    hasAuthenticatedSession.value = false;
    AppDependency.ensureLoginRouteDependencies();
    AppNavigation.goShell(AppRoutes.logoutTransition);
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
