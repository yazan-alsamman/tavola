import 'dart:convert';

/// Minimal JWT helpers for proactive access-token refresh.
class JwtPayload {
  JwtPayload._();

  /// Returns true when the token has an `exp` claim that is already expired
  /// or will expire within [skew].
  ///
  /// Opaque / non-JWT access tokens (no parseable `exp`) return false so
  /// refresh is driven by the 401 path instead of a useless proactive call.
  static bool needsRefresh(String token, {required Duration skew}) {
    final DateTime? expiresAt = readExpiry(token);
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().isAfter(expiresAt.subtract(skew));
  }

  static DateTime? readExpiry(String token) {
    final List<String> parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }
    try {
      final String normalized = base64Url.normalize(parts[1]);
      final String payloadJson = utf8.decode(base64Url.decode(normalized));
      final Object? decoded = jsonDecode(payloadJson);
      if (decoded is! Map) {
        return null;
      }
      final Map<String, dynamic> claims = Map<String, dynamic>.from(decoded);
      final Object? exp = claims['exp'];
      if (exp is! num) {
        return null;
      }
      return DateTime.fromMillisecondsSinceEpoch(
        (exp * 1000).round(),
        isUtc: true,
      ).toLocal();
    } catch (_) {
      return null;
    }
  }
}
