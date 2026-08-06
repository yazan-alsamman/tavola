import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../core/network/auth_token_reader.dart';
import '../../core/utils/app_dependency.dart';
import '../auth/controller/auth_session_controller.dart';
import '../favorites/repository/favorites_repository.dart';
import '../notifications/controller/notifications_badge_controller.dart';
import '../users/repository/users_repository.dart';
import 'controller/home_controller.dart';

/// Staged Home shell initialization — one unit of work per committed frame.
///
/// First Home paint only needs [HomeController] + taxonomy cache hydrate
/// (see [AppDependency.ensureHomeController]). Everything below runs after
/// that frame, never in parallel batches of network/JSON work.
///
/// Does not use [Future.delayed].
///
/// Timeline after first frame:
/// 0. Deferred Keychain session/identity persist (Login→Home must not block)
/// 1. Cuisine categories HTTP
/// 2. Occasion categories HTTP
/// 3. Discovery restaurants HTTP
/// 4. Users repository + profile
/// 5. Preferences
/// 6. Favorites
/// 7. Notifications badge
/// 8. Location stack
class HomeProgressiveInit {
  HomeProgressiveInit(this._home);

  final HomeController _home;

  /// Last progressive band (location). Used by tests / perf probes.
  static const int stageComplete = 8;

  bool _started = false;
  bool _cancelled = false;

  /// Starts the first post-frame band (caller is already past first paint).
  void startAfterFirstFrame() {
    if (_started || _cancelled) {
      return;
    }
    _started = true;
    _stagePersistSession();
  }

  /// Cancels any pending stage hop (Hot Restart / test teardown / onClose).
  void cancel() {
    _cancelled = true;
  }

  void _scheduleNextStage(void Function() stage) {
    // Microtask → next frame. Chaining addPostFrameCallback alone is drained
    // in the same frame by Flutter; this hop keeps one band per paint.
    scheduleMicrotask(() {
      if (_cancelled || _home.isClosed) {
        return;
      }
      final SchedulerBinding binding = SchedulerBinding.instance;
      binding.addPostFrameCallback((_) {
        if (_cancelled || _home.isClosed) {
          return;
        }
        stage();
      });
      binding.scheduleFrame();
    });
  }

  void _stagePersistSession() {
    if (_cancelled || _home.isClosed) {
      return;
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    if (Get.isRegistered<AuthSessionController>()) {
      final AuthSessionController session = Get.find<AuthSessionController>();
      if (session.isAnonymousGuest) {
        // Guest: clear deferred Keychain — never persist Bearer tokens.
        session.flushDeferredGuestSecureStorage();
      } else {
        unawaited(session.persistDeferredSessionArtifacts());
      }
    }
    _home.markProgressiveStage(0);
    _log('stage0 session disk', stopwatch);
    _scheduleNextStage(_stageCuisineCategories);
  }

  void _stageCuisineCategories() {
    if (_cancelled || _home.isClosed) {
      return;
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    unawaited(_home.loadCuisineCategories());
    _home.markProgressiveStage(1);
    _log('stage1 cuisine', stopwatch);
    _scheduleNextStage(_stageOccasionCategories);
  }

  void _stageOccasionCategories() {
    if (_cancelled || _home.isClosed) {
      return;
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    unawaited(_home.loadOccasionCategories());
    _home.markProgressiveStage(2);
    _log('stage2 occasion', stopwatch);
    _scheduleNextStage(_stageRestaurants);
  }

  void _stageRestaurants() {
    if (_cancelled || _home.isClosed) {
      return;
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    AppDependency.ensureDiscoveryRepository();
    unawaited(_home.loadRestaurants());
    _home.markProgressiveStage(3);
    _log('stage3 restaurants', stopwatch);
    // Anonymous guest: public Discovery/taxonomy only — skip auth bands.
    if (_isAnonymousGuestSession) {
      _scheduleNextStage(_stageLocation);
      return;
    }
    _scheduleNextStage(_stageUserProfile);
  }

  void _stageUserProfile() {
    if (_cancelled || _home.isClosed) {
      return;
    }
    if (_isAnonymousGuestSession) {
      _scheduleNextStage(_stageLocation);
      return;
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    AppDependency.ensureUsersRepository();
    unawaited(Get.find<UsersRepository>().ensureProfileLoaded());
    _home.markProgressiveStage(4);
    _log('stage4 profile', stopwatch);
    _scheduleNextStage(_stagePreferences);
  }

  void _stagePreferences() {
    if (_cancelled || _home.isClosed) {
      return;
    }
    if (_isAnonymousGuestSession) {
      _scheduleNextStage(_stageLocation);
      return;
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    if (Get.isRegistered<UsersRepository>()) {
      unawaited(_loadPreferencesQuietly(Get.find<UsersRepository>()));
    }
    _home.markProgressiveStage(5);
    _log('stage5 preferences', stopwatch);
    _scheduleNextStage(_stageFavorites);
  }

  void _stageFavorites() {
    if (_cancelled || _home.isClosed) {
      return;
    }
    if (_isAnonymousGuestSession) {
      _scheduleNextStage(_stageLocation);
      return;
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    AppDependency.ensureFavoritesRepository();
    unawaited(Get.find<FavoritesRepository>().ensureInitialized());
    _home.markProgressiveStage(6);
    _log('stage6 favorites', stopwatch);
    _scheduleNextStage(_stageNotifications);
  }

  void _stageNotifications() {
    if (_cancelled || _home.isClosed) {
      return;
    }
    if (_isAnonymousGuestSession) {
      _scheduleNextStage(_stageLocation);
      return;
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    AppDependency.ensureNotificationsBadge();
    if (Get.isRegistered<NotificationsBadgeController>()) {
      Get.find<NotificationsBadgeController>().scheduleRefresh();
    }
    _home.markProgressiveStage(7);
    _log('stage7 notifications', stopwatch);
    _scheduleNextStage(_stageLocation);
  }

  void _stageLocation() {
    if (_cancelled || _home.isClosed) {
      return;
    }
    final Stopwatch stopwatch = Stopwatch()..start();
    // Guest jumps here from stage 3 — mark skipped auth bands for stage watchers.
    if (_isAnonymousGuestSession) {
      _home.markProgressiveStage(4);
      _home.markProgressiveStage(5);
      _home.markProgressiveStage(6);
      _home.markProgressiveStage(7);
    }
    AppDependency.ensureLocationStack();
    // Nearby + offers for the Home Special Offer card (after location stack).
    unawaited(_home.loadSpecialOfferPromo());
    _home.markProgressiveStage(stageComplete);
    _log('stage8 location', stopwatch);
  }

  bool get _isAnonymousGuestSession {
    if (!Get.isRegistered<AuthSessionController>()) {
      return false;
    }
    return Get.find<AuthSessionController>().isAnonymousGuest;
  }

  static Future<void> _loadPreferencesQuietly(UsersRepository users) async {
    try {
      if (Get.isRegistered<AuthSessionController>() &&
          Get.find<AuthSessionController>().isAnonymousGuest) {
        return;
      }
      if (Get.isRegistered<AuthTokenReader>()) {
        final String? access = await Get.find<AuthTokenReader>()
            .readAccessToken();
        if (access == null || access.trim().isEmpty) {
          return;
        }
      }
      await users.fetchMyPreferences();
    } catch (_) {
      // Preferences are non-critical for Home chrome; Profile can retry.
    }
  }

  static void _log(String label, Stopwatch stopwatch) {
    if (kDebugMode) {
      debugPrint('[HomePerf] $label: ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}
