import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

import 'package:tavla/app/routes/app_routes.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
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
  });

  tearDown(Get.reset);

  testWidgets('polls only the open restaurant thread and stops on leave', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.concierge,
        getPages: <GetPage<dynamic>>[
          GetPage<dynamic>(
            name: AppRoutes.concierge,
            page: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
    Get.put(ConciergeController());
    await tester.pump();

    final int opened = repository.messageFetches;
    expect(opened, greaterThan(0));

    await tester.pump(AppDimensions.conciergeActiveThreadRefreshInterval);
    expect(repository.messageFetches, opened + 1);
    expect(repository.lastConversationId, 'c-1');

    Get.find<ConciergeController>().showAllConversations();
    await tester.pump(AppDimensions.conciergeActiveThreadRefreshInterval);
    expect(repository.messageFetches, opened + 1);
  });

  testWidgets('does not poll a thread that has no restaurant', (
    WidgetTester tester,
  ) async {
    repository.withRestaurant = false;
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.concierge,
        getPages: <GetPage<dynamic>>[
          GetPage<dynamic>(
            name: AppRoutes.concierge,
            page: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
    Get.put(ConciergeController());
    await tester.pump();
    final int opened = repository.messageFetches;

    await tester.pump(AppDimensions.conciergeActiveThreadRefreshInterval);
    expect(repository.messageFetches, opened);
  });
}

class _Token implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'token';
}

class _Repo extends ConversationsRepository {
  _Repo(super.apiClient);

  int messageFetches = 0;
  String? lastConversationId;
  bool withRestaurant = true;

  @override
  Future<List<ConversationModel>> listConversations({
    int limit = 20,
    String? cursor,
  }) async {
    return <ConversationModel>[
      ConversationModel(
        conversationId: 'c-1',
        restaurantId: withRestaurant ? 'r-1' : '',
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
    lastConversationId = conversationId;
    return ConversationMessagesPage(
      items: <ConversationMessageModel>[
        ConversationMessageModel.fromJson(<String, dynamic>{
          'messageId': 'm-1',
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
