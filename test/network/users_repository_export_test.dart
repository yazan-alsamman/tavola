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

  test('exportMyData calls /users/me/export and parses totals', () async {
    Get.put<AuthTokenReader>(_TokenReader());
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));

    String? hitPath;
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          hitPath = options.path;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'Data export generated successfully.',
                'data': <String, dynamic>{
                  'exportedAt': '2026-08-17T10:00:00.000Z',
                  'reservations': <String, dynamic>{'items': <dynamic>[], 'total': 4},
                  'reviews': <String, dynamic>{'items': <dynamic>[], 'total': 2},
                  'favorites': <String, dynamic>{'items': <dynamic>[], 'total': 7},
                },
              },
            ),
          );
        },
      ),
    );

    final UsersRepository users = UsersRepository(Get.find<ApiClient>());
    final result = await users.exportMyData();

    expect(hitPath, AppUrls.usersMeExportPath);
    expect(result.exportedAt, '2026-08-17T10:00:00.000Z');
    expect(result.reservationsTotal, 4);
    expect(result.reviewsTotal, 2);
    expect(result.favoritesTotal, 7);
    expect(result.message, 'Data export generated successfully.');
  });
}

class _TokenReader implements AuthTokenReader {
  @override
  Future<String?> readAccessToken() async => 'access';
}
