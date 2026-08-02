import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'package:tavla/common/widgets/search_bar.dart';
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/localization/locale_controller.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/core/services/location_service.dart';
import 'package:tavla/features/auth/controller/auth_session_controller.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';
import 'package:tavla/features/home/view/home_screen.dart';
import 'package:tavla/features/location/model/location_permission_state.dart';
import 'package:tavla/features/location/model/user_location_model.dart';
import 'package:tavla/features/taxonomy/model/cuisine_category_model.dart';
import 'package:tavla/features/taxonomy/model/occasion_category_model.dart';
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

  testWidgets(
    'Home search bar keeps text after MediaQuery keyboard inset rebuild',
    (tester) async {
      _registerHomeGraph();

      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(),
          child: GetMaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();

      final Finder field = find.byType(TextField);
      expect(field, findsOneWidget);
      expect(find.byType(CustomSearchBar), findsOneWidget);

      await tester.enterText(field, 'Sakura');
      await tester.pump();

      final HomeController home = Get.find<HomeController>();
      expect(home.searchController.text, 'Sakura');
      expect(home.searchQuery.value, 'Sakura');

      // Simulate keyboard opening (common Home rebuild that previously
      // recreated an uncontrolled TextField and cleared focus/text).
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 300)),
          child: GetMaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();

      expect(home.searchController.text, 'Sakura');
      expect(find.text('Sakura'), findsOneWidget);
      expect(home.filteredRestaurants, isNotEmpty);
      expect(
        home.filteredRestaurants.every(
          (RestaurantModel item) => item.name.toLowerCase().contains('sakura'),
        ),
        isTrue,
      );

      // Let progressive discovery HTTP settle (mock interceptor) before dispose.
      await tester.pump(const Duration(milliseconds: 50));
      Get.delete<HomeController>(force: true);
      await tester.pump(const Duration(milliseconds: 50));
    },
  );
}

void _registerHomeGraph() {
  Get.put(AuthSessionController());
  Get.put<AuthTokenReader>(const EmptyAuthTokenReader());

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
                  <String, dynamic>{
                    'restaurantId': 'r2',
                    'name': 'Bella Vista',
                    'description': 'Italian',
                    'cuisineType': 'Italian',
                    'status': 'Active',
                    'averageRating': 4.6,
                  },
                ],
                'page': 1,
                'limit': 20,
                'total': 2,
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
  Get.put<LocationService>(_FakeLocationService(), permanent: true);
  Get.put(LocaleController());
  Get.put(HomeController())
    ..restaurants.assignAll(<RestaurantModel>[
      const RestaurantModel(
        id: 'r1',
        name: 'Sakura Sushi House',
        cuisine: 'Japanese',
        occasion: '',
        description: 'Japanese kitchen',
        imageUrl: '',
        location: 'Istanbul',
        availabilityLabel: 'Open now',
        isAvailable: true,
      ),
      const RestaurantModel(
        id: 'r2',
        name: 'Bella Vista',
        cuisine: 'Italian',
        occasion: '',
        description: 'Italian',
        imageUrl: '',
        location: 'Istanbul',
        availabilityLabel: 'Open now',
        isAvailable: true,
      ),
    ])
    ..isLoadingRestaurants.value = false;
}

class _FakeTaxonomyRepository extends TaxonomyRepository {
  _FakeTaxonomyRepository() : super(Get.find<ApiClient>());

  @override
  List<CuisineCategoryModel>? get cachedCuisineCategories =>
      const <CuisineCategoryModel>[
        CuisineCategoryModel(
          id: '1',
          slug: 'japanese',
          name: 'Japanese',
          sortOrder: 0,
        ),
      ];

  @override
  List<OccasionCategoryModel>? get cachedOccasionCategories =>
      const <OccasionCategoryModel>[
        OccasionCategoryModel(
          id: '1',
          slug: 'date',
          name: 'Date night',
          sortOrder: 0,
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
