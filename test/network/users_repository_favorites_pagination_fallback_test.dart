import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('favorites list retries when pageSize is rejected', () async {
    Get.put<AuthTokenReader>(_TokenReader());
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));

    int calls = 0;
    Map<String, dynamic>? firstQuery;
    Map<String, dynamic>? secondQuery;

    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          if (options.path != AppUrls.usersMeFavoritesPath ||
              options.method != 'GET') {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 404,
                  data: <String, dynamic>{'message': 'not found'},
                ),
              ),
            );
            return;
          }

          calls++;
          if (calls == 1) {
            firstQuery = Map<String, dynamic>.from(options.queryParameters);
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
                        'field': 'pageSize',
                        'message': 'property pageSize should not exist',
                      },
                    ],
                  },
                ),
              ),
            );
            return;
          }

          secondQuery = Map<String, dynamic>.from(options.queryParameters);
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
                      'restaurantId': 'r-1',
                      'name': 'Olive & Oak',
                      'cuisineType': 'Mediterranean',
                      'status': 'Active',
                    },
                  ],
                },
              },
            ),
          );
        },
      ),
    );

    final UsersRepository users = UsersRepository(Get.find<ApiClient>());
    final favorites = await users.fetchFavoriteRestaurants();

    expect(calls, 2);
    expect(firstQuery?['pageSize'], isNotNull);
    expect(secondQuery?['limit'], isNotNull);
    expect(secondQuery?.containsKey('pageSize'), isFalse);
    expect(favorites, hasLength(1));
    expect(favorites.first.id, 'r-1');
  });
}

class _TokenReader implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'access';
}
