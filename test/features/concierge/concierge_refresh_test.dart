import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/concierge/controller/concierge_controller.dart';
import 'package:tavla/features/concierge/model/conversation_message_model.dart';
import 'package:tavla/features/concierge/model/conversation_model.dart';
import 'package:tavla/features/concierge/repository/conversations_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeConversationsRepository repository;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put<AuthTokenReader>(_TokenReader());
    final ApiClient api = ApiClient(
      dio: Dio(),
      tokenReader: Get.find<AuthTokenReader>(),
    );
    repository = _FakeConversationsRepository(api);
    Get.put<ConversationsRepository>(repository);
  });

  tearDown(Get.reset);

  testWidgets('returning to an open chat reloads messages once', (
    WidgetTester tester,
  ) async {
    repository.rows = <Map<String, dynamic>>[
      _message('m-1', 'Earlier', '2026-09-29T00:00:00Z'),
    ];
    final ConciergeController controller = Get.put(ConciergeController());
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(
      controller.messages.map((ConversationMessageModel m) => m.messageId),
      ['m-1'],
    );
    expect(repository.messageFetches, 1);

    repository.rows = <Map<String, dynamic>>[
      _message('m-2', 'Owner reply', '2026-09-29T00:01:00Z'),
      _message('m-1', 'Earlier', '2026-09-29T00:00:00Z'),
    ];
    controller.onChatRouteOpened();
    await tester.pump();

    expect(
      controller.messages.map((ConversationMessageModel m) => m.messageId),
      ['m-1', 'm-2'],
    );
    expect(repository.messageFetches, 2);
    expect(controller.errorMessage.value, isNull);
    expect(controller.isLoadingMessages.value, isFalse);
  });

  testWidgets('a second refresh while one is running does not fetch again', (
    WidgetTester tester,
  ) async {
    repository.rows = <Map<String, dynamic>>[
      _message('m-1', 'Earlier', '2026-09-29T00:00:00Z'),
    ];
    final ConciergeController controller = Get.put(ConciergeController());
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(repository.messageFetches, 1);

    repository.gate = Completer<void>();
    repository.rows = <Map<String, dynamic>>[
      _message('m-1', 'Earlier', '2026-09-29T00:00:00Z'),
      _message('m-2', 'Owner reply', '2026-09-29T00:01:00Z'),
      _message('m-2', 'Owner reply', '2026-09-29T00:01:00Z'),
    ];
    final Future<void> first = controller.refreshVisibleChat();
    final Future<void> second = controller.refreshVisibleChat();
    repository.gate!.complete();
    await Future.wait(<Future<void>>[first, second]);
    await tester.pump();

    expect(repository.messageFetches, 2);
    expect(
      controller.messages.map((ConversationMessageModel m) => m.messageId),
      ['m-1', 'm-2'],
    );
  });
}

Map<String, dynamic> _message(String id, String body, String createdAt) {
  return <String, dynamic>{
    'messageId': id,
    'body': body,
    'senderType': 'Staff',
    'createdAt': createdAt,
  };
}

class _TokenReader implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'token';
}

class _FakeConversationsRepository extends ConversationsRepository {
  _FakeConversationsRepository(super.apiClient);

  List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
  int messageFetches = 0;
  int listFetches = 0;
  Completer<void>? gate;

  @override
  Future<List<ConversationModel>> listConversations({
    int limit = 20,
    String? cursor,
  }) async {
    listFetches++;
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
  Future<ConversationMessagesPage> listMessages(
    String conversationId, {
    int limit = 20,
    String? cursor,
  }) async {
    messageFetches++;
    final Completer<void>? pending = gate;
    if (pending != null) {
      await pending.future;
    }
    return ConversationMessagesPage(
      items: rows
          .map(
            (Map<String, dynamic> row) =>
                ConversationMessageModel.fromJson(row),
          )
          .toList(growable: false),
      hasMore: false,
    );
  }

  @override
  Future<void> markRead(String conversationId) async {}
}
