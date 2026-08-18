import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/concierge/model/conversation_model.dart';
import 'package:tavla/features/concierge/repository/conversations_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('list/start/messages/read/close hit Postman paths and query keys', () async {
    final List<RequestOptions> requests = <RequestOptions>[];
    Get.put<AuthTokenReader>(_TokenReader());
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    // Insert before ApiClient auth interceptor so the mock always resolves.
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          requests.add(options);
          final String path = options.path;
          if (path.contains('/messages') && options.method == 'GET') {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'success': true,
                  'message': 'ok',
                  'data': <String, dynamic>{
                    'items': <dynamic>[
                      <String, dynamic>{
                        'messageId': 'm-1',
                        'body': 'Host reply',
                        'senderType': 'Staff',
                      },
                    ],
                  },
                  'meta': <String, dynamic>{'hasMore': false},
                },
              ),
            );
            return;
          }
          if (path.contains('/messages') && options.method == 'POST') {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 201,
                data: <String, dynamic>{
                  'success': true,
                  'message': 'ok',
                  'data': <String, dynamic>{
                    'messageId': 'm-2',
                    'body': 'Hello',
                    'senderType': AppStrings.conversationSenderCustomer,
                  },
                },
              ),
            );
            return;
          }
          if (path == AppUrls.conversationsPath && options.method == 'POST') {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 201,
                data: <String, dynamic>{
                  'success': true,
                  'message': 'ok',
                  'data': <String, dynamic>{
                    'conversationId': 'c-new',
                    'restaurantId': 'r-1',
                    'subject': 'Hello',
                    'status': AppStrings.conversationStatusOpen,
                  },
                },
              ),
            );
            return;
          }
          if (path.endsWith('/read') || path.endsWith('/close')) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'success': true,
                  'message': 'ok',
                  'data': <String, dynamic>{
                    'conversationId': 'c-1',
                    'status': path.endsWith('/close')
                        ? AppStrings.conversationStatusClosed
                        : AppStrings.conversationStatusOpen,
                  },
                },
              ),
            );
            return;
          }
          if (path == AppUrls.conversationPath('c-1') &&
              options.method == 'GET') {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'success': true,
                  'message': 'ok',
                  'data': <String, dynamic>{
                    'conversationId': 'c-1',
                    'restaurantId': 'r-1',
                    'subject': 'Reservation help',
                    'status': AppStrings.conversationStatusOpen,
                  },
                },
              ),
            );
            return;
          }
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{
                  'items': <dynamic>[
                    <String, dynamic>{
                      'conversationId': 'c-1',
                      'restaurantId': 'r-1',
                      'subject': 'Reservation help',
                      'status': AppStrings.conversationStatusOpen,
                    },
                  ],
                },
              },
            ),
          );
        },
      ),
    );

    final ConversationsRepository repo = ConversationsRepository(
      Get.find<ApiClient>(),
      tokenReader: Get.find<AuthTokenReader>(),
    );

    final List<ConversationModel> list = await repo.listConversations();
    expect(list.single.conversationId, 'c-1');
    expect(
      requests.first.queryParameters[AppUrls.conversationsPageQueryKey],
      isNotNull,
    );
    expect(
      requests.first.queryParameters[AppUrls.conversationsPageSizeQueryKey],
      isNotNull,
    );

    final ConversationModel started = await repo.startConversation(
      restaurantId: 'r-1',
      subject: 'Hello',
    );
    expect(started.conversationId, 'c-new');

    final ConversationModel detail = await repo.getConversation('c-1');
    expect(detail.conversationId, 'c-1');

    final messages = await repo.listMessages('c-1');
    expect(messages.items.single.body, 'Host reply');

    final sent = await repo.sendMessage(conversationId: 'c-1', body: 'Hello');
    expect(sent.messageId, 'm-2');
    expect(requests.any((RequestOptions r) => r.data is FormData), isTrue);

    await repo.markRead('c-1');
    final ConversationModel? closed = await repo.closeConversation('c-1');
    expect(closed?.isClosed, isTrue);

    expect(
      requests.any((RequestOptions r) => r.path == AppUrls.conversationsPath),
      isTrue,
    );
    expect(
      requests.any(
        (RequestOptions r) => r.path == AppUrls.conversationPath('c-1'),
      ),
      isTrue,
    );
    expect(
      requests.any(
        (RequestOptions r) =>
            r.path == AppUrls.conversationMessagesPath('c-1'),
      ),
      isTrue,
    );
    expect(
      requests.any(
        (RequestOptions r) => r.path == AppUrls.conversationReadPath('c-1'),
      ),
      isTrue,
    );
    expect(
      requests.any(
        (RequestOptions r) => r.path == AppUrls.conversationClosePath('c-1'),
      ),
      isTrue,
    );
  });
}

class _TokenReader implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'access';
}
