import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/cuisine_preferences/controller/favorite_cuisines_controller.dart';
import 'package:tavla/features/taxonomy/model/occasion_category_model.dart';
import 'package:tavla/features/taxonomy/repository/taxonomy_repository.dart';

class _HangingTaxonomyRepository extends TaxonomyRepository {
  _HangingTaxonomyRepository(super.apiClient);

  final Completer<List<OccasionCategoryModel>> _completer =
      Completer<List<OccasionCategoryModel>>();

  @override
  Future<List<OccasionCategoryModel>> fetchOccasionCategories({
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
  Future<List<OccasionCategoryModel>> fetchOccasionCategories({
    bool forceRefresh = false,
  }) async {
    throw Exception('network down');
  }
}

class _LiveTaxonomyRepository extends TaxonomyRepository {
  _LiveTaxonomyRepository(super.apiClient);

  @override
  Future<List<OccasionCategoryModel>> fetchOccasionCategories({
    bool forceRefresh = false,
  }) async {
    return const <OccasionCategoryModel>[
      OccasionCategoryModel(
        id: 'o1',
        slug: OccasionCategoryModel.slugDateNight,
        name: 'Date Night',
        sortOrder: 1,
      ),
      OccasionCategoryModel(
        id: 'o2',
        slug: OccasionCategoryModel.slugFamily,
        name: 'Family',
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

  test(
    'shows fallback occasion chips immediately when taxonomy hangs',
    () async {
      final _HangingTaxonomyRepository taxonomy = _HangingTaxonomyRepository(
        Get.find<ApiClient>(),
      );
      Get.put<TaxonomyRepository>(taxonomy);

      final FavoriteCuisinesController controller = FavoriteCuisinesController(
        taxonomyRepository: taxonomy,
      );
      controller.onInit();

      expect(controller.isLoadingOccasionCategories.value, isFalse);
      expect(controller.occasionOptions, isNotEmpty);
      expect(
        controller.occasionOptions.length,
        OccasionCategoryModel.fallbackItems().length,
      );
      expect(controller.occasionOptions.first.name, 'Date Night');

      taxonomy.completeWithError();
      await controller.loadOccasionCategories();
      expect(controller.isLoadingOccasionCategories.value, isFalse);
      expect(controller.occasionOptions, isNotEmpty);
    },
  );

  test('keeps fallback chips when taxonomy fails', () async {
    final TaxonomyRepository taxonomy = _FailingTaxonomyRepository(
      Get.find<ApiClient>(),
    );
    Get.put<TaxonomyRepository>(taxonomy);

    final FavoriteCuisinesController controller = FavoriteCuisinesController(
      taxonomyRepository: taxonomy,
    );
    controller.onInit();
    await controller.loadOccasionCategories();

    expect(controller.isLoadingOccasionCategories.value, isFalse);
    expect(controller.occasionOptions, isNotEmpty);
    expect(controller.occasionCategoriesError.value, isNull);
  });

  test(
    'replaces fallback with live occasion taxonomy when available',
    () async {
      final TaxonomyRepository taxonomy = _LiveTaxonomyRepository(
        Get.find<ApiClient>(),
      );
      Get.put<TaxonomyRepository>(taxonomy);

      final FavoriteCuisinesController controller = FavoriteCuisinesController(
        taxonomyRepository: taxonomy,
      );
      controller.onInit();
      await controller.loadOccasionCategories();

      expect(controller.occasionOptions.length, 2);
      expect(
        controller.occasionOptions.map((OccasionCategoryModel c) => c.name),
        <String>['Date Night', 'Family'],
      );
    },
  );

  test('toggle selection works on fallback occasion chips', () async {
    final TaxonomyRepository taxonomy = _FailingTaxonomyRepository(
      Get.find<ApiClient>(),
    );
    Get.put<TaxonomyRepository>(taxonomy);

    final FavoriteCuisinesController controller = FavoriteCuisinesController(
      taxonomyRepository: taxonomy,
    );
    controller.onInit();

    controller.toggleOccasion('Date Night');
    expect(controller.hasSelection, isTrue);
    expect(controller.isSelected('Date Night'), isTrue);

    controller.toggleOccasion('Date Night');
    expect(controller.hasSelection, isFalse);
  });
}
