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
import 'package:tavla/features/home/model/restaurant_model.dart';
import 'package:tavla/features/location/controller/user_location_controller.dart';
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
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().cancelProgressiveInit();
    }
    HomeEntryWarmup.resetForTest();
    Get.reset();
  });

  testWidgets('nearby uses lat/lng and binds published offer to Home card state', (
    WidgetTester tester,
  ) async {
    final List<RequestOptions> requests = <RequestOptions>[];
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
          requests.add(options);
          final String path = options.path;
          if (path.contains('/offers')) {
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
                        'offerId': 'off-1',
                        'restaurantId': 'rest-near',
                        'title': '20% Off Tuesday Dinners',
                        'description': 'Chef-selected prix fixe.',
                        'status': AppStrings.offerStatusPublished,
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
                  'items': <dynamic>[
                    <String, dynamic>{
                      'restaurantId': 'rest-near',
                      'name': 'Le Petit Bistro',
                      'status': 'Active',
                      'description': 'French',
                      'coverImageUrl': 'https://cdn.example/cover.jpg',
                      'hasActiveOffer': true,
                    },
                  ],
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
    Get.put(UserLocationController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    final HomeController controller = Get.put(HomeController());
    controller.cancelProgressiveInit();
    controller.restaurants.assignAll(const <RestaurantModel>[
      RestaurantModel(
        id: 'rest-catalog',
        name: 'Catalog Only',
        cuisine: 'Italian',
        occasion: '',
        description: '',
        imageUrl: '',
        location: '',
        availabilityLabel: 'Open',
        isAvailable: true,
      ),
    ]);

    await tester.runAsync(controller.loadSpecialOfferPromo);

    final RequestOptions nearby = requests.firstWhere(
      (RequestOptions item) =>
          item.path.contains(AppUrls.discoveryRestaurantsNearbyPath),
    );
    expect(nearby.queryParameters[AppUrls.nearbyLatitudeQueryKey], 25.2);
    expect(nearby.queryParameters[AppUrls.nearbyLongitudeQueryKey], 55.3);
    expect(
      nearby.queryParameters.containsKey(AppUrls.latitudeQueryKey),
      isFalse,
    );

    expect(controller.featuredOffer.value?.title, '20% Off Tuesday Dinners');
    expect(
      controller.featuredOffer.value?.description,
      'Chef-selected prix fixe.',
    );
    expect(controller.featuredOfferRestaurant.value?.id, 'rest-near');
    expect(controller.featuredOfferRestaurant.value?.hasActiveOffer, isTrue);
    expect(controller.isLoadingSpecialOffer.value, isFalse);
  });
}

class _FakeLocationService extends LocationService {
  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<LocationPermissionState> checkPermission() async =>
      LocationPermissionState.granted;

  @override
  Future<LocationPermissionState> requestPermission() async =>
      LocationPermissionState.granted;

  @override
  Future<UserLocationModel> getCurrentLocation() async {
    return const UserLocationModel(
      permissionStatus: LocationPermissionState.granted,
      isServiceEnabled: true,
      latitude: 25.2,
      longitude: 55.3,
    );
  }

  @override
  Future<bool> openAppSettings() async => false;

  @override
  Future<bool> openLocationSettings() async => false;
}
