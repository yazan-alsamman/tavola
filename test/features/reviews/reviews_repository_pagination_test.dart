import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/reviews/repository/reviews_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('fetchRestaurantReviews uses limit and omits pageSize', () async {
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));

    Map<String, dynamic>? query;
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          query = Map<String, dynamic>.from(options.queryParameters);
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{'items': <Map<String, dynamic>>[]},
                'meta': <String, dynamic>{'page': 1, 'limit': 20, 'total': 0},
              },
            ),
          );
        },
      ),
    );

    final ReviewsRepository repo = ReviewsRepository(Get.find<ApiClient>());
    await repo.fetchRestaurantReviews(restaurantId: 'r-1');

    expect(query?[AppUrls.reviewsLimitQueryKey], 20);
    expect(query?.containsKey(AppUrls.reviewsPageSizeQueryKey), isFalse);
  });

  test(
    'fetchRestaurantReviews falls back to pageSize when limit is rejected',
    () async {
      final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
      Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
      Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));

      int calls = 0;
      Map<String, dynamic>? firstQuery;
      Map<String, dynamic>? secondQuery;
      dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                calls++;
                if (calls == 1) {
                  firstQuery = Map<String, dynamic>.from(
                    options.queryParameters,
                  );
                  handler.reject(
                    DioException(
                      requestOptions: options,
                      type: DioExceptionType.badResponse,
                      response: Response<dynamic>(
                        requestOptions: options,
                        statusCode: 400,
                        data: <String, dynamic>{
                          'success': false,
                          'message': 'Validation failed',
                          'code': 'VALIDATION_ERROR',
                          'errors': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'field': 'limit',
                              'message': 'property limit should not exist',
                            },
                          ],
                        },
                      ),
                    ),
                  );
                  return;
                }
                secondQuery = Map<String, dynamic>.from(
                  options.queryParameters,
                );
                handler.resolve(
                  Response<dynamic>(
                    requestOptions: options,
                    statusCode: 200,
                    data: <String, dynamic>{
                      'success': true,
                      'message': 'ok',
                      'data': <String, dynamic>{
                        'items': <Map<String, dynamic>>[],
                      },
                      'meta': <String, dynamic>{
                        'page': 1,
                        'pageSize': 20,
                        'total': 0,
                      },
                    },
                  ),
                );
              },
        ),
      );

      final ReviewsRepository repo = ReviewsRepository(Get.find<ApiClient>());
      await repo.fetchRestaurantReviews(restaurantId: 'r-1');

      expect(calls, 2);
      expect(firstQuery?[AppUrls.reviewsLimitQueryKey], 20);
      expect(secondQuery?[AppUrls.reviewsPageSizeQueryKey], 20);
    },
  );
}
