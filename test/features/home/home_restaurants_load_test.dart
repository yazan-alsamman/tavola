import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HomeEntryWarmup.resetForTest();
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  testWidgets('Home loadRestaurants calls Discovery and shows empty catalog', (
    WidgetTester tester,
  ) async {
    final List<String> hits = <String>[];
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: AppUrls.apiBaseUrl,
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          hits.add(options.path);
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'success': true,
                'message': 'ok',
                'data': <String, dynamic>{
                  'items': <dynamic>[],
                  'page': 1,
                  'limit': 20,
                  'total': 0,
                },
              },
            ),
          );
        },
      ),
    );

    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    final ApiClient api = ApiClient(
      dio: dio,
      tokenReader: Get.find<AuthTokenReader>(),
    );
    Get.put(api);
    Get.put(UsersRepository(api));
    Get.put(FavoritesRepository(usersRepository: Get.find<UsersRepository>()));
    Get.put(TaxonomyRepository(api));
    Get.put(DiscoveryRepository(api));
    Get.put<LocationService>(_FakeLocationService(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    final HomeController controller = Get.put(HomeController());

    // Dio + Future.timeout need the real async zone under TestWidgetsFlutterBinding.
    await tester.runAsync(controller.loadRestaurants);

    expect(controller.isLoadingRestaurants.value, isFalse);
    expect(controller.restaurants, isEmpty);
    expect(controller.restaurantsError.value, AppStrings.restaurantsEmpty);
    expect(
      hits.where((String path) => path.contains('/discovery/restaurants')),
      isNotEmpty,
    );
    expect(
      hits.where(
        (String path) =>
            path.contains('/restaurants') &&
            !path.contains('/discovery/restaurants'),
      ),
      isEmpty,
    );

    Get.delete<HomeController>(force: true);
  });
}

class _FakeLocationService extends LocationService {
  @override
  Future<bool> isServiceEnabled() async => false;

  @override
  Future<LocationPermissionState> checkPermission() async =>
      LocationPermissionState.serviceDisabled;

  @override
  Future<LocationPermissionState> requestPermission() async =>
      LocationPermissionState.serviceDisabled;

  @override
  Future<UserLocationModel> getCurrentLocation() async {
    return const UserLocationModel(
      permissionStatus: LocationPermissionState.serviceDisabled,
      isServiceEnabled: false,
    );
  }

  @override
  Future<bool> openAppSettings() async => false;

  @override
  Future<bool> openLocationSettings() async => false;
}
