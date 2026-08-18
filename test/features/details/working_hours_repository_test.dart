import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/details/repository/restaurant_details_repository.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test(
    'fetchDetails fills openingHours from discovery workingHours',
    () async {
      Get.put<AuthTokenReader>(_TokenReader());
      final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
      Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
      final List<String> workingHoursPaths = <String>[];
      dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                final String path = options.path;
                if (path.contains('/working-hours')) {
                  workingHoursPaths.add(path);
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
                if (path.contains('/branches')) {
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
                              'branchId': 'branch-1',
                              'city': 'Chicago',
                              'district': 'River North',
                              'address': '451 N LaSalle St',
                            },
                          ],
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
                        'restaurantId': 'rest-1',
                        'name': 'Hours Bistro',
                        'status': 'Active',
                        'description': 'Test',
                        'workingHours': <dynamic>[
                          <String, dynamic>{
                            'dayOfWeek': 0,
                            'openingTime': '10:00',
                            'closingTime': '22:00',
                          },
                          <String, dynamic>{
                            'dayOfWeek': 1,
                            'openingTime': '10:00',
                            'closingTime': '22:00',
                          },
                        ],
                      },
                    },
                  ),
                );
              },
        ),
      );

      final RestaurantDetailsRepository repo = RestaurantDetailsRepository(
        DiscoveryRepository(Get.find<ApiClient>()),
        Get.find<ApiClient>(),
      );

      final detail = await repo.fetchDetails('rest-1');
      expect(detail.hasWorkingHours, isTrue);
      expect(detail.openingHours, hasLength(7));
      expect(detail.openingHours.first.hours, '10:00 – 22:00');
      expect(detail.todayHoursLabel, isNotEmpty);
      expect(workingHoursPaths, isEmpty);

      final String cardLabel = await repo.fetchTodayHoursLabel('rest-1');
      expect(cardLabel, isNotEmpty);
    },
  );

  test('fetchDetails skips hours when discovery workingHours is empty', () async {
    Get.put<AuthTokenReader>(_TokenReader());
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    var workingHoursHits = 0;
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          if (options.path.contains('/working-hours')) {
            workingHoursHits++;
          }
          if (options.path.contains('/branches')) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'success': true,
                  'message': 'ok',
                  'data': <String, dynamic>{'items': <dynamic>[]},
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
                  'restaurantId': 'rest-1',
                  'name': 'Hours Bistro',
                  'status': 'Active',
                  'description': 'Test',
                  'workingHours': <dynamic>[],
                },
              },
            ),
          );
        },
      ),
    );

    final RestaurantDetailsRepository repo = RestaurantDetailsRepository(
      DiscoveryRepository(Get.find<ApiClient>()),
      Get.find<ApiClient>(),
    );

    final detail = await repo.fetchDetails('rest-1');
    expect(detail.hasWorkingHours, isFalse);
    expect(detail.openingHours, isEmpty);
    expect(workingHoursHits, 0);
  });
}

class _TokenReader implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'access';
}
