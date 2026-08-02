import '../../../core/network/api_exception.dart';

/// Single inbox row from `GET /notifications` (`data.items[]`).
class NotificationItemModel {
  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  NotificationItemModel copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
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
      createdAt: _asDateTime(
        json['createdAt'] ?? json['created_at'] ?? json['timestamp'],
      ),
    );
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
