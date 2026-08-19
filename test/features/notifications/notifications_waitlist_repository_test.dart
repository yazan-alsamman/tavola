import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/notifications/model/notifications_page_model.dart';
import 'package:tavla/features/notifications/repository/notifications_repository.dart';
import 'package:tavla/features/waitlist/model/waitlist_entry_model.dart';
import 'package:tavla/features/waitlist/model/waitlist_join_request_model.dart';
import 'package:tavla/features/waitlist/repository/waitlist_repository.dart';

class _StaticTokenReader implements AuthTokenReader {
  const _StaticTokenReader(this.token);

  final String token;

  @override
  Future<String?> readAccessToken() async => token;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio mockDio;
  late ApiClient apiClient;

  setUp(() {
    Get.reset();
    Get.put<AuthTokenReader>(const _StaticTokenReader('test-token'));
    mockDio = Dio(
      BaseOptions(
        baseUrl: AppUrls.apiBaseUrl,
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    apiClient = ApiClient(
      dio: mockDio,
      tokenReader: Get.find<AuthTokenReader>(),
    );
  });

  tearDown(Get.reset);

  group('NotificationsRepository', () {
    test('fetchNotifications parses items and unread count', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                if (options.path.endsWith('/notifications') &&
                    options.method == 'GET') {
                  expect(
                    options.queryParameters[AppUrls.notificationsLimitQueryKey],
                    isNotNull,
                  );
                  expect(
                    options.queryParameters.containsKey('pageSize'),
                    isFalse,
                    reason: 'Live notifications API rejects pageSize',
                  );
                  handler.resolve(
                    Response<dynamic>(
                      requestOptions: options,
                      statusCode: 200,
                      data: <String, dynamic>{
                        'success': true,
                        'message': 'ok',
                        'data': <String, dynamic>{
                          'items': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n1',
                              'title': 'Table ready',
                              'body': 'Your table is ready.',
                              'isRead': false,
                              'createdAt': '2026-07-24T18:00:00.000Z',
                            },
                          ],
                        },
                        'meta': <String, dynamic>{
                          'page': 1,
                          'limit': 20,
                          'total': 1,
                          'totalPages': 1,
                        },
                      },
                    ),
                  );
                  return;
                }
                if (options.path.endsWith('/notifications/unread-count')) {
                  handler.resolve(
                    Response<dynamic>(
                      requestOptions: options,
                      statusCode: 200,
                      data: <String, dynamic>{
                        'success': true,
                        'message': 'ok',
                        'data': <String, dynamic>{'count': 3},
                      },
                    ),
                  );
                  return;
                }
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.badResponse,
                  ),
                );
              },
        ),
      );

      final NotificationsRepository repository = NotificationsRepository(
        apiClient,
      );
      final NotificationsPageModel page = await repository.fetchNotifications();
      expect(page.items, hasLength(1));
      expect(page.items.first.id, 'n1');
      expect(page.items.first.isRead, isFalse);
      expect(page.hasMore, isFalse);

      final int unread = await repository.fetchUnreadCount();
      expect(unread, 3);
      expect(repository.unreadCount.value, 3);
    });

    test('markRead and markAllRead update unread cache', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                if (options.path.contains('/read') &&
                    options.method == 'PATCH') {
                  handler.resolve(
                    Response<dynamic>(
                      requestOptions: options,
                      statusCode: 200,
                      data: <String, dynamic>{
                        'success': true,
                        'message': 'ok',
                        'data': <String, dynamic>{},
                      },
                    ),
                  );
                  return;
                }
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.badResponse,
                  ),
                );
              },
        ),
      );

      final NotificationsRepository repository = NotificationsRepository(
        apiClient,
      );
      repository.unreadCount.value = 2;
      await repository.markRead('n1');
      expect(repository.unreadCount.value, 1);
      await repository.markAllRead();
      expect(repository.unreadCount.value, 0);
    });

    test('fetchIdentityToken parses token map', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                handler.resolve(
                  Response<dynamic>(
                    requestOptions: options,
                    statusCode: 200,
                    data: <String, dynamic>{
                      'success': true,
                      'message': 'ok',
                      'data': <String, dynamic>{
                        'identityToken': 'onesignal-jwt',
                      },
                    },
                  ),
                );
              },
        ),
      );

      final NotificationsRepository repository = NotificationsRepository(
        apiClient,
      );
      expect(await repository.fetchIdentityToken(), 'onesignal-jwt');
    });
  });

  group('WaitlistRepository', () {
    test('join and cancel round-trip entryId', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                if (options.path.endsWith('/waitlist') &&
                    options.method == 'POST') {
                  handler.resolve(
                    Response<dynamic>(
                      requestOptions: options,
                      statusCode: 201,
                      data: <String, dynamic>{
                        'success': true,
                        'message': 'ok',
                        'data': <String, dynamic>{'entryId': 'wl-1'},
                      },
                    ),
                  );
                  return;
                }
                if (options.path.endsWith('/waitlist/wl-1/cancel') &&
                    options.method == 'POST') {
                  handler.resolve(
                    Response<dynamic>(
                      requestOptions: options,
                      statusCode: 200,
                      data: <String, dynamic>{
                        'success': true,
                        'message': 'ok',
                        'data': <String, dynamic>{},
                      },
                    ),
                  );
                  return;
                }
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.badResponse,
                  ),
                );
              },
        ),
      );

      final WaitlistRepository repository = WaitlistRepository(apiClient);
      final WaitlistEntryModel entry = await repository.join(
        const WaitlistJoinRequestModel(
          branchId: 'b1',
          partySize: 2,
          preferredDate: '2026-08-01',
          preferredTimeFrom: '19:00',
          preferredTimeTo: '20:00',
        ),
      );
      expect(entry.entryId, 'wl-1');
      expect(repository.lastEntryId.value, 'wl-1');

      await repository.cancel('wl-1');
      expect(repository.lastEntryId.value, isNull);
    });
  });
}
