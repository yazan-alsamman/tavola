import '../../../core/network/api_exception.dart';

/// One row from `GET /auth/sessions` (`data.sessions[]`).
class AuthDeviceSessionModel {
  const AuthDeviceSessionModel({
    required this.sessionId,
    this.deviceName = '',
    this.deviceType = '',
    this.isCurrentSession = false,
    this.lastActiveAt,
    this.createdAt,
  });

  final String sessionId;
  final String deviceName;
  final String deviceType;
  final bool isCurrentSession;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;

  bool get isValid => sessionId.trim().isNotEmpty;

  factory AuthDeviceSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthDeviceSessionModel(
      sessionId: _firstNonEmpty(<Object?>[
        json['sessionId'],
        json['id'],
      ]),
      deviceName: _firstNonEmpty(<Object?>[
        json['deviceName'],
        json['device_name'],
      ]),
      deviceType: _firstNonEmpty(<Object?>[
        json['deviceType'],
        json['device_type'],
      ]),
      isCurrentSession: json['isCurrentSession'] == true ||
          json['is_current_session'] == true ||
          json['current'] == true,
      lastActiveAt: _parseDate(
        json['lastActiveAt'] ?? json['last_active_at'],
      ),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  static List<AuthDeviceSessionModel> listFromPayload(Object? raw) {
    final List<dynamic> items = _extractSessions(raw);
    final List<AuthDeviceSessionModel> sessions = <AuthDeviceSessionModel>[];
    for (final dynamic item in items) {
      if (item is! Map) {
        continue;
      }
      final AuthDeviceSessionModel session = AuthDeviceSessionModel.fromJson(
        Map<String, dynamic>.from(item),
      );
      if (session.isValid) {
        sessions.add(session);
      }
    }
    return sessions;
  }

  static List<dynamic> _extractSessions(Object? raw) {
    if (raw is List) {
      return raw;
    }
    if (raw is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      for (final String key in const <String>[
        'sessions',
        'items',
        'data',
      ]) {
        final Object? value = map[key];
        if (value is List) {
          return value;
        }
        if (value is Map && key == 'data') {
          return _extractSessions(value);
        }
      }
    }
    return const <dynamic>[];
  }

  static String _firstNonEmpty(List<Object?> candidates) {
    for (final Object? raw in candidates) {
      final String value = ApiException.coerceMessage(raw).trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is DateTime) {
      return raw;
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw.trim());
    }
    return null;
  }
}
