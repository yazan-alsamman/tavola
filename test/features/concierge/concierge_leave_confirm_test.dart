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
    Get.put(ConciergeController());
  });

  tearDown(Get.reset);

  testWidgets('back arrow asks before ending any restaurant conversation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    final ConciergeController controller = Get.find<ConciergeController>();
    controller.activeConversation.value = const ConversationModel(
      conversationId: 'c-1',
      restaurantId: 'r-1',
      restaurantName: 'SakuraGrape',
      status: AppStrings.conversationStatusOpen,
    );
    controller.showConversationList.value = false;

    final Future<void> leaving = controller.leaveConversationFromBack();
    await tester.pump();

    expect(find.text(AppStrings.endConversationPrompt), findsOneWidget);
    expect(find.text(AppStrings.yes), findsOneWidget);
    expect(find.text(AppStrings.no), findsOneWidget);
    expect(repository.closeCalls, 0);

    await tester.tap(find.text(AppStrings.no));
    await tester.pump();
    await leaving;

    expect(repository.closeCalls, 0);
    expect(controller.showConversationList.value, isTrue);
    expect(controller.activeConversation.value?.isOpen, isTrue);
  });

  testWidgets('yes ends the conversation then returns to the list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    final ConciergeController controller = Get.find<ConciergeController>();
    controller.activeConversation.value = const ConversationModel(
      conversationId: 'c-9',
      restaurantId: 'r-9',
      restaurantName: 'La Joya',
      status: AppStrings.conversationStatusOpen,
    );
    controller.showConversationList.value = false;

    final Future<void> leaving = controller.leaveConversationFromBack();
    await tester.pump();
    await tester.tap(find.text(AppStrings.yes));
    await tester.pump();
    await leaving;

    expect(repository.closeCalls, 1);
    expect(repository.closedId, 'c-9');
    expect(controller.showConversationList.value, isTrue);
    expect(controller.activeConversation.value?.isClosed, isTrue);
  });
}

class _Token implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'token';
}

class _Repo extends ConversationsRepository {
  _Repo(super.apiClient);

  int closeCalls = 0;
  String? closedId;

  @override
  Future<List<ConversationModel>> listConversations({
    int limit = 20,
    String? cursor,
  }) async {
    return const <ConversationModel>[];
  }

  @override
  Future<ConversationMessagesPage> listMessages(
    String conversationId, {
    int limit = 20,
    String? cursor,
  }) async {
    return const ConversationMessagesPage(
      items: <ConversationMessageModel>[],
      hasMore: false,
    );
  }

  @override
  Future<ConversationModel?> closeConversation(String conversationId) async {
    closeCalls++;
    closedId = conversationId;
    return ConversationModel(
      conversationId: conversationId,
      restaurantId: 'r-9',
      status: AppStrings.conversationStatusClosed,
    );
  }
}
