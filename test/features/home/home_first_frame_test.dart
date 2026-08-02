import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/api_response.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/controller/home_controller.dart';
import 'package:tavla/features/home/home_entry_warmup.dart';
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

  testWidgets(
    'HomeController hydrates cache sync then loads after first frame',
    (tester) async {
      Get.testMode = true;
      final _FakeTaxonomyRepository taxonomy = _FakeTaxonomyRepository();
      Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
      Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
      Get.put(UsersRepository(Get.find<ApiClient>()));
      Get.put(
        FavoritesRepository(usersRepository: Get.find<UsersRepository>()),
      );
      Get.put<TaxonomyRepository>(taxonomy);
      Get.put(DiscoveryRepository(Get.find<ApiClient>()));

      await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));

      final HomeController controller = Get.put(HomeController());

      expect(controller.didSchedulePostFrameLoads, isFalse);
      expect(taxonomy.fetchCuisineCallCount, 0);
      expect(controller.isLoadingCuisineCategories.value, isFalse);
      expect(controller.cuisineCategories, isNotEmpty);
      expect(controller.isLoadingOccasionCategories.value, isFalse);
      expect(controller.occasionCategoryItems, isNotEmpty);
      expect(controller.isLoadingRestaurants.value, isTrue);
      expect(controller.restaurantsError.value, isNull);

      await tester.pump();
      expect(controller.didSchedulePostFrameLoads, isTrue);
      // Stage 0 persists session; stage 1 taxonomy starts on the next hop.
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
      expect(taxonomy.fetchCuisineCallCount, greaterThan(0));
      expect(taxonomy.fetchOccasionCallCount, greaterThan(0));

      // Cancel remaining progressive hops (profile/favorites/location).
      Get.delete<HomeController>(force: true);
      await tester.pump();
    },
  );

  test('TaxonomyRepository serves memory cache on second fetch', () async {
    Get.testMode = true;
    final _CountingApiClient api = _CountingApiClient();
    final TaxonomyRepository repo = TaxonomyRepository(api);

    final List<CuisineCategoryModel> first = await repo
        .fetchCuisineCategories();
    final List<CuisineCategoryModel> second = await repo
        .fetchCuisineCategories();

    expect(api.getCount, 1);
    expect(identical(first, second), isTrue);
    expect(repo.cachedCuisineCategories, isNotNull);
  });
}

class _FakeTaxonomyRepository extends TaxonomyRepository {
  _FakeTaxonomyRepository() : super(_UnusedApiClient());

  int fetchCuisineCallCount = 0;
  int fetchOccasionCallCount = 0;

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
    fetchCuisineCallCount++;
    return cachedCuisineCategories!;
  }

  @override
  Future<List<OccasionCategoryModel>> fetchOccasionCategories({
    bool forceRefresh = false,
  }) async {
    fetchOccasionCallCount++;
    return cachedOccasionCategories!;
  }
}

class _UnusedApiClient extends ApiClient {
  _UnusedApiClient() : super(tokenReader: const EmptyAuthTokenReader());
}

class _CountingApiClient extends ApiClient {
  _CountingApiClient() : super(tokenReader: const EmptyAuthTokenReader());

  int getCount = 0;

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? raw) parseData,
    Options? options,
  }) async {
    getCount++;
    return ApiResponse<T>(
      success: true,
      message: 'ok',
      data: parseData(<String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'cuisineCategoryId': '1',
            'slug': 'italian',
            'name': 'Italian',
            'sortOrder': 1,
          },
        ],
      }),
    );
  }
}
