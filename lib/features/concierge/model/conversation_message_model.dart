import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';

/// Message row from `GET/POST /conversations/:id/messages`.
class ConversationMessageModel {
  const ConversationMessageModel({
    required this.messageId,
    required this.body,
    this.conversationId = '',
    this.senderType = '',
    this.attachmentUrl = '',
    this.createdAt,
  });

  final String messageId;
  final String body;
  final String conversationId;
  final String senderType;
  final String attachmentUrl;
  final DateTime? createdAt;

  /// Customer-authored bubble (right-aligned in UI).
  bool get isFromCustomer {
    final String normalized = senderType.trim().toLowerCase();
    return normalized ==
            AppStrings.conversationSenderCustomer.toLowerCase() ||
        normalized == AppStrings.conversationSenderUser.toLowerCase() ||
        normalized == AppStrings.conversationSenderGuest.toLowerCase();
  }

  factory ConversationMessageModel.fromJson(Map<String, dynamic> json) {
    final String id = _firstNonEmpty(<Object?>[
      json['messageId'],
      json['id'],
    ]);
    final String body = _firstNonEmpty(<Object?>[
      json['body'],
      json['content'],
      json['text'],
      json['message'],
    ]);
    if (id.isEmpty && body.isEmpty) {
      throw StateError(AppStrings.invalidConversationMessagePayload);
    }

    return ConversationMessageModel(
      messageId: id.isNotEmpty ? id : body.hashCode.toString(),
      body: body,
      conversationId: ApiException.coerceString(json['conversationId']),
      senderType: _firstNonEmpty(<Object?>[
        json['senderType'],
        json['role'],
        json['sender'],
        json['authorType'],
      ]),
      attachmentUrl: _firstNonEmpty(<Object?>[
        json['attachmentUrl'],
        json['attachment'],
        json['fileUrl'],
      ]),
      createdAt: _parseDate(json['createdAt'] ?? json['sentAt']),
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
