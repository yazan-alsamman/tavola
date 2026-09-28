import '../../../core/network/api_exception.dart';

/// Single inbox row from `GET /notifications` (`data.items[]`).
class NotificationItemModel {
  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.type = '',
    this.data = const <String, String>{},
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool isRead;

  /// `NotificationResponseDto.type`.
  final String type;

  /// String values from `NotificationResponseDto.data`.
  final Map<String, String> data;
  final DateTime? createdAt;

  /// Present only when the payload `data` object includes `conversationId`.
  String get conversationId => data['conversationId'] ?? '';

  /// Present only when the payload `data` object includes `restaurantId`.
  String get restaurantId => data['restaurantId'] ?? '';

  NotificationItemModel copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    String? type,
    Map<String, String>? data,
    DateTime? createdAt,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    final String id = _firstNonEmpty(<Object?>[
      json['id'],
      json['notificationId'],
    ]);
    if (id.isEmpty) {
      throw StateError('invalid notification payload');
    }

    final String title = _firstNonEmpty(<Object?>[
      json['title'],
      json['subject'],
      json['heading'],
    ]);
    final String body = _firstNonEmpty(<Object?>[
      json['body'],
      json['message'],
      json['content'],
      json['text'],
    ]);

    final bool isRead = _asBool(
      json['isRead'] ?? json['read'] ?? json['is_read'],
    );

    return NotificationItemModel(
      id: id,
      title: title,
      body: body,
      isRead: isRead,
      type: ApiException.coerceString(json['type']),
      data: _readData(json['data']),
      createdAt: _asDateTime(
        json['createdAt'] ?? json['created_at'] ?? json['timestamp'],
      ),
    );
  }

  static Map<String, String> _readData(Object? raw) {
    if (raw is! Map) {
      return const <String, String>{};
    }
    final Map<String, String> values = <String, String>{};
    for (final Object? key in raw.keys) {
      if (key is! String || key.trim().isEmpty) {
        continue;
      }
      final String? value = ApiException.coerceOptionalString(raw[key]);
      if (value == null) {
        continue;
      }
      values[key.trim()] = value;
    }
    return Map<String, String>.unmodifiable(values);
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

  static bool _asBool(Object? raw) {
    if (raw is bool) {
      return raw;
    }
    if (raw is num) {
      return raw != 0;
    }
    final String value = ApiException.coerceMessage(raw).trim().toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }

  static DateTime? _asDateTime(Object? raw) {
    if (raw is DateTime) {
      return raw;
    }
    final String value = ApiException.coerceMessage(raw).trim();
    if (value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
