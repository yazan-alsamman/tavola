import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/view/home_screen.dart';
import 'package:tavla/features/location/controller/user_location_controller.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/taxonomy/model/cuisine_category_model.dart';
import 'package:tavla/features/taxonomy/model/occasion_category_model.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('HomeScreen loads Discovery restaurants catalog', (tester) async {
    Get.testMode = true;
    Get.put(AuthSessionController());
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());

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
                  'items': <dynamic>[
                    <String, dynamic>{
                      'restaurantId': 'r1',
                      'name': 'Sakura Sushi House',
                      'description': 'Japanese kitchen',
                      'cuisineType': 'Japanese',
                      'status': 'Active',
                      'averageRating': 4.4,
                    },
                  ],
                  'page': 1,
                  'limit': 20,
                  'total': 1,
                },
              },
            ),
          );
        },
      ),
    );

    final ApiClient api = ApiClient(
      dio: dio,
      tokenReader: Get.find<AuthTokenReader>(),
    );
    Get.put(api);
    Get.put(UsersRepository(api));
    Get.put(FavoritesRepository(usersRepository: Get.find<UsersRepository>()));
    Get.put(DiscoveryRepository(api));
    Get.put<TaxonomyRepository>(_FakeTaxonomyRepository());
    Get.put<LocationService>(_FakeLocationService());
    Get.put(
      UserLocationController(locationService: Get.find<LocationService>()),
    );
    Get.put(LocaleController());
    Get.put(HomeController());

    await tester.pumpWidget(const GetMaterialApp(home: HomeScreen()));
    await tester.pump();
    for (int i = 0; i < 24; i++) {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
    }

    expect(find.textContaining('Search'), findsOneWidget);
    expect(find.text(AppStrings.restaurantApiNotAvailable), findsNothing);

    final HomeController home = Get.find<HomeController>();
    expect(home.isLoadingCuisineCategories.value, isFalse);
    expect(home.isLoadingOccasionCategories.value, isFalse);
    expect(home.isLoadingRestaurants.value, isFalse);
    expect(home.restaurants, isNotEmpty);
    expect(home.restaurants.first.name, 'Sakura Sushi House');
    expect(home.restaurantFilters, isNotEmpty);
    expect(home.occasionCategoryItems, isNotEmpty);
    expect(
      hits.where((String path) => path.contains('/discovery/restaurants')),
      isNotEmpty,
    );

    Get.delete<HomeController>(force: true);
    await tester.pump();
  });
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
          slug: 'dinner',
          name: 'Dinner',
          sortOrder: 1,
        ),
      ];

  @override
  Future<List<CuisineCategoryModel>> fetchCuisineCategories({
    bool forceRefresh = false,
  }) async => cachedCuisineCategories!;

  @override
  Future<List<OccasionCategoryModel>> fetchOccasionCategories({
    bool forceRefresh = false,
  }) async => cachedOccasionCategories!;
}

class _UnusedApiClient extends ApiClient {
  _UnusedApiClient() : super(tokenReader: const EmptyAuthTokenReader());
}

class _FakeLocationService extends LocationService {
  @override
  Future<LocationPermissionState> checkPermission() async =>
      LocationPermissionState.granted;

  @override
  Future<LocationPermissionState> requestPermission() async =>
      LocationPermissionState.granted;

  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<UserLocationModel> getCurrentLocation() async {
    return const UserLocationModel(
      permissionStatus: LocationPermissionState.granted,
      isServiceEnabled: true,
    );
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}
