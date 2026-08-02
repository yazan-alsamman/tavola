import '../../../core/network/api_exception.dart';

class CustomerAuthResponseModel {
  const CustomerAuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.userId,
    this.username = '',
    this.phone = '',
    this.sessionVersion,
  });

  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final String userId;

  /// From login/register user payload — used as Profile card name.
  final String username;
  final String phone;
  final int? sessionVersion;

  factory CustomerAuthResponseModel.fromJson(Map<String, dynamic> json) {
    final Object? rawUser = json['user'];
    final Map<String, dynamic>? user = rawUser is Map
        ? Map<String, dynamic>.from(rawUser)
        : null;
    return CustomerAuthResponseModel(
      // Never `as String?` — Nest/proxies may send null/num/map and that
      // TypeError escapes Dio catch clauses and crashes the auth submit.
      accessToken: _tokenField(json['accessToken']),
      refreshToken: _tokenField(json['refreshToken']),
      sessionId: _tokenField(json['sessionId']),
      sessionVersion: (json['sessionVersion'] as num?)?.toInt(),
      userId: _tokenField(user?['userId']),
      username: _tokenField(user?['username']),
      phone: _tokenField(user?['phone']),
    );
  }

  /// Tokens are required to establish a session. `sessionId` / `userId` are
  /// optional metadata and must not block a successful login response.
  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  static String _tokenField(Object? raw) {
    final String value = ApiException.coerceMessage(raw);
    // Reject map/list stringifications — only plain scalar tokens are valid.
    if (raw is Map || raw is List) {
      return '';
    }
    return value;
  }
}
