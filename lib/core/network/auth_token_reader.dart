/// Reads the current access token for Authorization headers.
abstract class AuthTokenReader {
  Future<String?> readAccessToken();
}

/// Mutable session tokens used for `POST /auth/refresh` rotation.
abstract class AuthTokenSession extends AuthTokenReader {
  Future<String?> readRefreshToken();

  Future<void> updateSessionTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clearSessionTokens();
}

/// Default stub — never attaches a Bearer token.
class EmptyAuthTokenReader implements AuthTokenReader {
  const EmptyAuthTokenReader();

  @override
  Future<String?> readAccessToken() async => null;
}
