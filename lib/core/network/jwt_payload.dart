import 'dart:convert';

/// Minimal JWT helpers for proactive access-token refresh and identity claims.
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
    final Map<String, dynamic>? claims = readClaims(token);
    if (claims == null) {
      return null;
    }
    final Object? exp = claims['exp'];
    if (exp is! num) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(
      (exp * 1000).round(),
      isUtc: true,
    ).toLocal();
  }

  /// Best-effort username/display claim from a customer access token.
  static String readUsername(String token) {
    final Map<String, dynamic>? claims = readClaims(token);
    if (claims == null) {
      return '';
    }
    for (final String key in <String>[
      'username',
      'preferred_username',
      'preferredUsername',
      'name',
      'displayName',
      'userName',
    ]) {
      final String value = _asScalar(claims[key]);
      if (value.isEmpty || _looksLikeUuid(value)) {
        continue;
      }
      return value;
    }
    return '';
  }

  static Map<String, dynamic>? readClaims(String token) {
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
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
  }

  static String _asScalar(Object? raw) {
    if (raw is String) {
      return raw.trim();
    }
    if (raw is num || raw is bool) {
      return '$raw'.trim();
    }
    return '';
  }

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool _looksLikeUuid(String value) => _uuidPattern.hasMatch(value);
}
