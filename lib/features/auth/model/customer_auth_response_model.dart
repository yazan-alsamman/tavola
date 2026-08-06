import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/customer_identity_payload.dart';
import '../../../core/network/jwt_payload.dart';

class CustomerAuthResponseModel {
  const CustomerAuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.userId,
    this.username = '',
    this.phone = '',
    this.avatarUrl = '',
    this.sessionVersion,
  });

  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final String userId;

  /// From login/register user payload — used as Profile card name.
  final String username;
  final String phone;
  final String avatarUrl;
  final int? sessionVersion;

  factory CustomerAuthResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> identity = CustomerIdentityPayload.flatten(json);
    final String accessToken = _tokenField(json['accessToken']);
    String username = _tokenField(identity['username']);
    if (username.isEmpty || _looksLikeUuid(username)) {
      username = CustomerIdentityPayload.readUsername(json);
    }
    if ((username.isEmpty || _looksLikeUuid(username)) &&
        accessToken.isNotEmpty) {
      username = JwtPayload.readUsername(accessToken);
    }
    if (kDebugMode) {
      debugPrint(
        '[AuthIdentity] keys=${identity.keys.toList()} username="$username" '
        'phone="${_phoneField(identity) ?? ''}"',
      );
    }
    return CustomerAuthResponseModel(
      // Never `as String?` — Nest/proxies may send null/num/map and that
      // TypeError escapes Dio catch clauses and crashes the auth submit.
      accessToken: accessToken,
      refreshToken: _tokenField(json['refreshToken']),
      sessionId: _tokenField(json['sessionId']),
      sessionVersion: (json['sessionVersion'] as num?)?.toInt(),
      userId: _tokenField(
        identity['userId'] ?? identity['id'] ?? json['userId'] ?? json['id'],
      ),
      username: _looksLikeUuid(username) ? '' : username,
      phone: _phoneField(identity) ?? '',
      avatarUrl: _avatarField(identity),
    );
  }

  /// Tokens are required to establish a session. `sessionId` / `userId` are
  /// optional metadata and must not block a successful login response.
  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  static String? _phoneField(Map<String, dynamic>? source) {
    if (source == null) {
      return null;
    }
    final String direct = _tokenField(source['phone']);
    if (direct.isNotEmpty) {
      return direct;
    }
    final String countryCode = _tokenField(
      source['countryCode'] ?? source['dialCode'],
    );
    final String national = _tokenField(
      source['phoneNumber'] ?? source['nationalNumber'] ?? source['mobile'],
    );
    if (countryCode.isNotEmpty && national.isNotEmpty) {
      final String dial =
          countryCode.startsWith('+') ? countryCode : '+$countryCode';
      final String digits = national.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        return '$dial$digits';
      }
    }
    if (national.isNotEmpty) {
      return national;
    }
    return null;
  }

  static String _tokenField(Object? raw) {
    final String value = ApiException.coerceMessage(raw);
    // Reject map/list stringifications — only plain scalar tokens are valid.
    if (raw is Map || raw is List) {
      return '';
    }
    return value;
  }

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool _looksLikeUuid(String value) => _uuidPattern.hasMatch(value);

  static String _avatarField(Map<String, dynamic> user) {
    for (final String key in <String>[
      'avatarUrl',
      'avatar',
      'imageUrl',
      'url',
      'path',
      'avatarPath',
      'profileImage',
    ]) {
      final Object? value = user[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value is Map) {
        final Map<String, dynamic> nestedMap = Map<String, dynamic>.from(value);
        for (final String nestedKey in <String>[
          'avatarUrl',
          'imageUrl',
          'url',
          'path',
          'avatar',
        ]) {
          final Object? nested = nestedMap[nestedKey];
          if (nested is String && nested.trim().isNotEmpty) {
            return nested.trim();
          }
        }
      }
    }
    return '';
  }
}
