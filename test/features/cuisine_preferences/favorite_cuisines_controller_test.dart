import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/cuisine_preferences/controller/favorite_cuisines_controller.dart';
import 'package:tavla/features/taxonomy/model/cuisine_category_model.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';

class _HangingTaxonomyRepository extends TaxonomyRepository {
  _HangingTaxonomyRepository(super.apiClient);

  final Completer<List<CuisineCategoryModel>> _completer =
      Completer<List<CuisineCategoryModel>>();

  @override
  Future<List<CuisineCategoryModel>> fetchCuisineCategories({
    bool forceRefresh = false,
  }) {
    return _completer.future;
  }

  void completeWithError() {
    if (!_completer.isCompleted) {
      _completer.completeError(TimeoutException('taxonomy hang'));
    }
  }
}

class _FailingTaxonomyRepository extends TaxonomyRepository {
  _FailingTaxonomyRepository(super.apiClient);

  @override
  Future<List<CuisineCategoryModel>> fetchCuisineCategories({
    bool forceRefresh = false,
  }) async {
    throw Exception('network down');
  }
}

class _LiveTaxonomyRepository extends TaxonomyRepository {
  _LiveTaxonomyRepository(super.apiClient);

  @override
  Future<List<CuisineCategoryModel>> fetchCuisineCategories({
    bool forceRefresh = false,
  }) async {
    return const <CuisineCategoryModel>[
      CuisineCategoryModel(
        id: 'c1',
        slug: 'italian',
        name: 'Italian',
        sortOrder: 1,
      ),
      CuisineCategoryModel(
        id: 'c2',
        slug: 'japanese',
        name: 'Japanese',
        sortOrder: 2,
      ),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
  });

  tearDown(Get.reset);

  test('shows fallback chips immediately when taxonomy hangs', () async {
    final _HangingTaxonomyRepository taxonomy = _HangingTaxonomyRepository(
      Get.find<ApiClient>(),
    );
    Get.put<TaxonomyRepository>(taxonomy);

    final FavoriteCuisinesController controller = FavoriteCuisinesController(
      taxonomyRepository: taxonomy,
    );
    controller.onInit();

    expect(controller.isLoadingCuisineCategories.value, isFalse);
    expect(controller.cuisineOptions, isNotEmpty);
    expect(
      controller.cuisineOptions.length,
      AppStrings.favoriteCuisineOptionKeys.length,
    );
    expect(controller.cuisineOptions.first.name, 'American');

    taxonomy.completeWithError();
    await controller.loadCuisineCategories();
    expect(controller.isLoadingCuisineCategories.value, isFalse);
    expect(controller.cuisineOptions, isNotEmpty);
  });

  test('keeps fallback chips when taxonomy fails', () async {
    final TaxonomyRepository taxonomy = _FailingTaxonomyRepository(
      Get.find<ApiClient>(),
    );
    Get.put<TaxonomyRepository>(taxonomy);

    final FavoriteCuisinesController controller = FavoriteCuisinesController(
      taxonomyRepository: taxonomy,
    );
    controller.onInit();
    await controller.loadCuisineCategories();

    expect(controller.isLoadingCuisineCategories.value, isFalse);
    expect(controller.cuisineOptions, isNotEmpty);
    expect(controller.cuisineCategoriesError.value, isNull);
  });

  test('replaces fallback with live taxonomy when available', () async {
    final TaxonomyRepository taxonomy = _LiveTaxonomyRepository(
      Get.find<ApiClient>(),
    );
    Get.put<TaxonomyRepository>(taxonomy);

    final FavoriteCuisinesController controller = FavoriteCuisinesController(
      taxonomyRepository: taxonomy,
    );
    controller.onInit();
    await controller.loadCuisineCategories();

    expect(controller.cuisineOptions.length, 2);
    expect(
      controller.cuisineOptions.map((CuisineCategoryModel c) => c.name),
      <String>['Italian', 'Japanese'],
    );
  });

  test('toggle selection works on fallback chips', () async {
    final TaxonomyRepository taxonomy = _FailingTaxonomyRepository(
      Get.find<ApiClient>(),
    );
    Get.put<TaxonomyRepository>(taxonomy);

    final FavoriteCuisinesController controller = FavoriteCuisinesController(
      taxonomyRepository: taxonomy,
    );
    controller.onInit();

    controller.toggleCuisine('Italian');
    expect(controller.hasSelection, isTrue);
    expect(controller.isSelected('Italian'), isTrue);

    controller.toggleCuisine('Italian');
    expect(controller.hasSelection, isFalse);
  });
}
