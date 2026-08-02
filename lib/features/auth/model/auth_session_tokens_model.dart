import '../../../core/network/api_exception.dart';

class AuthSessionTokensModel {
  const AuthSessionTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthSessionTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionTokensModel(
      accessToken: _tokenField(json['accessToken'] ?? json['access_token']),
      refreshToken: _tokenField(json['refreshToken'] ?? json['refresh_token']),
    );
  }

  /// Refresh rotates the refresh token (Postman). Both values are required —
  /// keeping a pre-rotation refresh token revokes the whole token family.
  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  static String _tokenField(Object? raw) {
    if (raw is Map || raw is List) {
      return '';
    }
    return ApiException.coerceMessage(raw);
  }
}
