import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('selectOccasion toggles off when tapped again', () async {
    Get.testMode = true;
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
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
        },
      ),
    );
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    Get.put(UsersRepository(Get.find<ApiClient>()));
    Get.put(FavoritesRepository(usersRepository: Get.find<UsersRepository>()));
    Get.put(TaxonomyRepository(Get.find<ApiClient>()));
    Get.put(DiscoveryRepository(Get.find<ApiClient>()));

    final HomeController controller = HomeController();
    await controller.selectOccasion('Date night');
    expect(controller.selectedOccasion.value, 'Date night');

    await controller.selectOccasion('Date night');
    expect(controller.selectedOccasion.value, isNull);

    await controller.selectOccasion('Family');
    expect(controller.selectedOccasion.value, 'Family');
    await controller.selectOccasion('Date night');
    expect(controller.selectedOccasion.value, 'Date night');
  });
}
