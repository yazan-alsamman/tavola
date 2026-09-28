import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/api_exception.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/concierge/controller/concierge_controller.dart';
import 'package:tavla/features/concierge/model/conversation_message_model.dart';
import 'package:tavla/features/concierge/model/conversation_model.dart';
import 'package:tavla/features/concierge/repository/conversations_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Repo repository;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<AuthTokenReader>(_Token());
    final ApiClient api = ApiClient(
      dio: Dio(),
      tokenReader: Get.find<AuthTokenReader>(),
    );
    repository = _Repo(api);
    Get.put<ConversationsRepository>(repository);
  });

  tearDown(Get.reset);

  testWidgets('notification conversation id loads backend messages once', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    final ConciergeController controller = Get.put(ConciergeController());
    await tester.pump();

    final int before = repository.messageFetches;
    final bool opened = await controller.openFromNotification(
      conversationId: 'c-9',
    );
    await tester.pump();

    expect(opened, isTrue);
    expect(controller.activeConversation.value?.conversationId, 'c-9');
    expect(controller.messages.map((ConversationMessageModel m) => m.body), [
      'Owner reply',
    ]);
    expect(repository.messageFetches, before + 1);
    expect(controller.messages.length, 1);

    final bool again = await controller.openFromNotification(
      conversationId: 'c-9',
    );
    await tester.pump();
    expect(again, isTrue);
    expect(controller.messages.length, 1);
    expect(repository.messageFetches, before + 2);
  });

  testWidgets('missing conversation does not invent a message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    final ConciergeController controller = Get.put(ConciergeController());
    await tester.pump();

    final int before = repository.messageFetches;
    final bool opened = await controller.openFromNotification(
      conversationId: 'missing',
    );
    await tester.pump();

    expect(opened, isFalse);
    expect(repository.messageFetches, before);
    expect(
      controller.messages.where(
        (ConversationMessageModel message) =>
            message.body == 'This inbox text is not a chat message',
      ),
      isEmpty,
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('restaurant id opens the matching conversation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    final ConciergeController controller = Get.put(ConciergeController());
    await tester.pump();

    final bool opened = await controller.openFromNotification(
      restaurantId: 'r-1',
    );
    await tester.pump();

    expect(opened, isTrue);
    expect(controller.activeConversation.value?.conversationId, 'c-1');
    expect(controller.messages.single.body, 'Owner reply');
  });

  testWidgets('payload without ids does not fetch messages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    final ConciergeController controller = Get.put(ConciergeController());
    await tester.pump();

    final int messagesBefore = repository.messageFetches;
    final int conversationsBefore = repository.conversationFetches;
    final bool opened = await controller.openFromNotification();
    expect(opened, isFalse);
    expect(repository.messageFetches, messagesBefore);
    expect(repository.conversationFetches, conversationsBefore);
  });
}

class _Token implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'token';
}

class _Repo extends ConversationsRepository {
  _Repo(super.apiClient);

  int messageFetches = 0;
  int conversationFetches = 0;

  @override
  Future<List<ConversationModel>> listConversations({
    int limit = 20,
    String? cursor,
  }) async {
    return <ConversationModel>[
      const ConversationModel(
        conversationId: 'c-1',
        restaurantId: 'r-1',
        restaurantName: 'SakuraGrape',
        status: AppStrings.conversationStatusOpen,
      ),
    ];
  }

  @override
  Future<ConversationModel> getConversation(String conversationId) async {
    conversationFetches++;
    if (conversationId == 'missing') {
      throw const ApiException(
        message: 'Conversation not found',
        statusCode: 404,
      );
    }
    return ConversationModel(
      conversationId: conversationId,
      restaurantId: 'r-9',
      restaurantName: 'SakuraGrape',
      status: AppStrings.conversationStatusOpen,
    );
  }

  @override
  Future<ConversationMessagesPage> listMessages(
    String conversationId, {
    int limit = 20,
    String? cursor,
  }) async {
    messageFetches++;
    return ConversationMessagesPage(
      items: <ConversationMessageModel>[
        ConversationMessageModel.fromJson(<String, dynamic>{
          'messageId': 'm-$conversationId',
          'body': 'Owner reply',
          'senderType': 'Employee',
          'createdAt': '2026-09-29T00:01:00.000Z',
        }),
      ],
      hasMore: false,
    );
  }

  @override
  Future<void> markRead(String conversationId) async {}
}
