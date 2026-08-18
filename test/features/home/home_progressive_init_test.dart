import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/api_response.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/core/utils/app_dependency.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/home_progressive_init.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/location/controller/user_location_controller.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/notifications/controller/notifications_badge_controller.dart';
import 'package:tavla/features/taxonomy/model/cuisine_category_model.dart';
import 'package:tavla/features/taxonomy/model/occasion_category_model.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HomeEntryWarmup.resetForTest();
  });

  tearDown(() {
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  testWidgets('Stage 1 ensureHomeController is taxonomy+discovery (sync)', (
    tester,
  ) async {
    Get.testMode = true;
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
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
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    Get.put<TaxonomyRepository>(_FakeTaxonomyRepository());
    Get.put(DiscoveryRepository(Get.find<ApiClient>()));
    Get.put<LocationService>(_FakeLocationService(), permanent: true);

    final Stopwatch stopwatch = Stopwatch()..start();
    final HomeController home = AppDependency.ensureHomeController();
    final int syncMs = stopwatch.elapsedMilliseconds;

    expect(home, isNotNull);
    expect(Get.isRegistered<TaxonomyRepository>(), isTrue);
    expect(Get.isRegistered<DiscoveryRepository>(), isTrue);
    expect(Get.isRegistered<HomeController>(), isTrue);
    expect(Get.isRegistered<FavoritesRepository>(), isFalse);
    expect(Get.isRegistered<UsersRepository>(), isFalse);
    expect(Get.isRegistered<NotificationsBadgeController>(), isFalse);
    expect(Get.isRegistered<UserLocationController>(), isFalse);
    expect(syncMs, lessThan(50));
    debugPrint(
      '[HomePerf] baseline Stage1 sync ensureHomeController: ${syncMs}ms',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpProgressiveStages(tester);
  });

  testWidgets('progressive stages register deps across frames', (tester) async {
    Get.testMode = true;
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        validateStatus: (int? status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
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
    Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
    Get.put<TaxonomyRepository>(_FakeTaxonomyRepository());
    Get.put(DiscoveryRepository(Get.find<ApiClient>()));
    Get.put<LocationService>(_FakeLocationService(), permanent: true);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            AppDependency.ensureHomeController();
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(Get.isRegistered<HomeController>(), isTrue);
    expect(Get.isRegistered<FavoritesRepository>(), isFalse);
    expect(Get.isRegistered<UserLocationController>(), isFalse);

    await _pumpProgressiveStages(tester);

    expect(Get.find<HomeController>().didSchedulePostFrameLoads, isTrue);
    expect(Get.isRegistered<UsersRepository>(), isTrue);
    expect(Get.isRegistered<FavoritesRepository>(), isTrue);
    expect(Get.isRegistered<NotificationsBadgeController>(), isTrue);
    expect(Get.isRegistered<UserLocationController>(), isTrue);
    expect(
      Get.find<HomeController>().progressiveStage.value,
      HomeProgressiveInit.stageComplete,
    );
  });
}

/// Advances frames + event-queue hops used by progressive stage chaining.
Future<void> _pumpProgressiveStages(WidgetTester tester) async {
  for (int i = 0; i < 20; i++) {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    if (Get.isRegistered<HomeController>() &&
        Get.find<HomeController>().progressiveStage.value >=
            HomeProgressiveInit.stageComplete &&
        Get.isRegistered<UserLocationController>()) {
      break;
    }
  }

  // Flush Special Offer nearby/offers Dio work started at the location stage.
  for (int i = 0; i < 60; i++) {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    if (!Get.isRegistered<HomeController>()) {
      break;
    }
    final HomeController home = Get.find<HomeController>();
    if (!home.isLoadingSpecialOffer.value &&
        (home.featuredOffer.value != null ||
            home.specialOfferError.value != null)) {
      break;
    }
  }
  await tester.pump(const Duration(milliseconds: 50));
}

class _FakeTaxonomyRepository extends TaxonomyRepository {
  _FakeTaxonomyRepository() : super(_UnusedApiClient());

  @override
  List<CuisineCategoryModel>? get cachedCuisineCategories =>
      const <CuisineCategoryModel>[
        CuisineCategoryModel(
          id: '1',
          slug: 'italian',
          name: 'Italian',
          sortOrder: 1,
        ),
      ];

  @override
  List<OccasionCategoryModel>? get cachedOccasionCategories =>
      const <OccasionCategoryModel>[
        OccasionCategoryModel(
          id: '1',
          slug: 'date',
          name: 'Date night',
          sortOrder: 1,
        ),
      ];

  @override
  Future<List<CuisineCategoryModel>> fetchCuisineCategories({
    bool forceRefresh = false,
  }) async {
    return cachedCuisineCategories!;
  }

  @override
  Future<List<OccasionCategoryModel>> fetchOccasionCategories({
    bool forceRefresh = false,
  }) async {
    return cachedOccasionCategories!;
  }
}

class _UnusedApiClient extends ApiClient {
  _UnusedApiClient() : super(tokenReader: const EmptyAuthTokenReader());

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? raw) parseData,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return ApiResponse<T>(
      success: true,
      message: 'ok',
      data: parseData(<String, dynamic>{}),
    );
  }
}

class _FakeLocationService extends LocationService {
  @override
  Future<bool> isServiceEnabled() async => false;

  @override
  Future<LocationPermissionState> checkPermission() async {
    return LocationPermissionState.serviceDisabled;
  }

  @override
  Future<LocationPermissionState> requestPermission() async {
    return LocationPermissionState.serviceDisabled;
  }

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
