import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';

/// Customer conversation (`GET/POST /conversations`, `GET /conversations/:id`).
class ConversationModel {
  const ConversationModel({
    required this.conversationId,
    this.restaurantId = '',
    this.restaurantName = '',
    this.branchId = '',
    this.reservationId = '',
    this.subject = '',
    this.status = '',
    this.lastMessagePreview = '',
    this.unreadCount = 0,
    this.lastMessageAt,
    this.createdAt,
  });

  final String conversationId;
  final String restaurantId;
  final String restaurantName;
  final String branchId;
  final String reservationId;
  final String subject;
  final String status;
  final String lastMessagePreview;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  bool get isClosed {
    final String normalized = status.trim().toLowerCase();
    return normalized == AppStrings.conversationStatusClosed.toLowerCase() ||
        normalized == AppStrings.conversationStatusArchived.toLowerCase();
  }

  bool get isOpen => !isClosed;

  String get displayTitle {
    if (subject.trim().isNotEmpty) {
      return subject.trim();
    }
    if (restaurantName.trim().isNotEmpty) {
      return restaurantName.trim();
    }
    return AppStrings.conciergeTitle;
  }

  String get displayStatus =>
      isClosed ? AppStrings.conversationClosedStatus : AppStrings.conversationOpenStatus;

  ConversationModel copyWith({
    String? conversationId,
    String? restaurantId,
    String? restaurantName,
    String? branchId,
    String? reservationId,
    String? subject,
    String? status,
    String? lastMessagePreview,
    int? unreadCount,
    DateTime? lastMessageAt,
    DateTime? createdAt,
  }) {
    return ConversationModel(
      conversationId: conversationId ?? this.conversationId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      branchId: branchId ?? this.branchId,
      reservationId: reservationId ?? this.reservationId,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final String id = _firstNonEmpty(<Object?>[
      json['conversationId'],
      json['id'],
    ]);
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidConversationPayload);
    }

    final Object? restaurantRaw = json['restaurant'];
    Map<String, dynamic>? restaurantMap;
    if (restaurantRaw is Map) {
      restaurantMap = Map<String, dynamic>.from(restaurantRaw);
    }

    return ConversationModel(
      conversationId: id,
      restaurantId: _firstNonEmpty(<Object?>[
        json['restaurantId'],
        restaurantMap?['restaurantId'],
        restaurantMap?['id'],
      ]),
      restaurantName: _firstNonEmpty(<Object?>[
        json['restaurantName'],
        restaurantMap?['name'],
      ]),
      branchId: ApiException.coerceString(json['branchId']),
      reservationId: ApiException.coerceString(json['reservationId']),
      subject: ApiException.coerceString(json['subject']),
      status: ApiException.coerceString(json['status']),
      lastMessagePreview: _firstNonEmpty(<Object?>[
        json['lastMessagePreview'],
        json['lastMessage'],
        json['lastMessageBody'],
        json['preview'],
      ]),
      unreadCount: _readInt(json['unreadCount'] ?? json['unread']) ?? 0,
      lastMessageAt: _parseDate(
        json['lastMessageAt'] ?? json['updatedAt'] ?? json['lastActivityAt'],
      ),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static String _firstNonEmpty(List<Object?> candidates) {
    for (final Object? raw in candidates) {
      final String value = ApiException.coerceString(raw).trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static int? _readInt(Object? raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim());
    }
    return null;
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is DateTime) {
      return raw;
    }
    final String value = ApiException.coerceString(raw).trim();
    if (value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
