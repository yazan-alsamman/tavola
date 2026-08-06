import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/concierge/model/conversation_message_model.dart';
import 'package:tavla/features/concierge/model/conversation_model.dart';

void main() {
  test('parses conversation list/detail fields used by Chat UI', () {
    final ConversationModel conversation = ConversationModel.fromJson(
      <String, dynamic>{
        'conversationId': 'c-1',
        'restaurantId': 'r-1',
        'restaurantName': 'Le Petit Bistro',
        'subject': 'Question about my reservation',
        'status': AppStrings.conversationStatusOpen,
        'lastMessagePreview': 'See you tonight',
        'unreadCount': 2,
      },
    );

    expect(conversation.conversationId, 'c-1');
    expect(conversation.restaurantId, 'r-1');
    expect(conversation.displayTitle, 'Question about my reservation');
    expect(conversation.isOpen, isTrue);
    expect(conversation.unreadCount, 2);
  });

  test('parses message body and customer sender for bubble alignment', () {
    final ConversationMessageModel message = ConversationMessageModel.fromJson(
      <String, dynamic>{
        'messageId': 'm-1',
        'body': 'Hello — looking forward to our reservation.',
        'senderType': AppStrings.conversationSenderCustomer,
        'createdAt': '2026-01-01T12:00:00.000Z',
      },
    );

    expect(message.messageId, 'm-1');
    expect(message.body, contains('looking forward'));
    expect(message.isFromCustomer, isTrue);
  });
}
