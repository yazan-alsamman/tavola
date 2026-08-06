import 'package:get/get.dart';

/// Reads the current access token for Authorization headers.
abstract class AuthTokenReader {
  Future<String?> readAccessToken();
}

/// Shared Bearer-presence check for controllers / repositories.
///
/// Single source of truth — avoids duplicated guest + token guards.
class AuthAccessGuard {
  AuthAccessGuard._();

  /// Returns `false` for anonymous guests and when no non-empty access token
  /// is registered. Optional [tokenReader] / [guestMode] override Get lookups
  /// (tests / repositories with injected readers).
  static Future<bool> hasAccessToken({
    AuthTokenReader? tokenReader,
    GuestModeReader? guestMode,
  }) async {
    final GuestModeReader? guest = guestMode ??
        (Get.isRegistered<GuestModeReader>()
            ? Get.find<GuestModeReader>()
            : null);
    if (guest != null && guest.isAnonymousGuest) {
      return false;
    }
    final AuthTokenReader? reader = tokenReader ??
        (Get.isRegistered<AuthTokenReader>()
            ? Get.find<AuthTokenReader>()
            : null);
    if (reader == null) {
      return false;
    }
    final String? access = await reader.readAccessToken();
    return access != null && access.trim().isNotEmpty;
  }
}

/// Mutable session tokens used for `POST /auth/refresh` rotation.
abstract class AuthTokenSession extends AuthTokenReader {
  Future<String?> readRefreshToken();

  /// When [persistToDisk] is false, only memory caches update — callers that
  /// must keep the iOS platform thread free (Login) schedule Keychain later.
  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
    bool persistToDisk = true,
  });

  Future<void> clearSessionTokens();
}

/// Anonymous "Continue as Guest" signal for [ApiClient] (no Bearer / no refresh).
abstract class GuestModeReader {
  bool get isAnonymousGuest;
}

/// Default stub — never treats the session as guest.
class NeverGuestModeReader implements GuestModeReader {
  const NeverGuestModeReader();

  @override
  bool get isAnonymousGuest => false;
}

/// Default stub — never attaches a Bearer token.
class EmptyAuthTokenReader implements AuthTokenReader {
  const EmptyAuthTokenReader();

  @override
  Future<String?> readAccessToken() async => null;
}
