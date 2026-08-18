import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/favorite_cuisines_preferences.dart';
import '../../taxonomy/model/cuisine_category_model.dart';
import '../../taxonomy/repository/taxonomy_repository.dart';

class FavoriteCuisinesController extends GetxController {
  FavoriteCuisinesController({TaxonomyRepository? taxonomyRepository})
    : _taxonomyRepository =
          taxonomyRepository ?? Get.find<TaxonomyRepository>();

  final TaxonomyRepository _taxonomyRepository;

  final RxList<String> selectedCuisines = <String>[].obs;
  final RxList<CuisineCategoryModel> cuisineOptions =
      <CuisineCategoryModel>[].obs;
  final RxBool isLoadingCuisineCategories = false.obs;
  final RxnString cuisineCategoriesError = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Always paint chips immediately — never block the educational screen on
    // a slow/unreachable `/cuisine-categories` call.
    _showFallbackOptions();
    unawaited(loadCuisineCategories());
  }

  Future<void> loadCuisineCategories() async {
    cuisineCategoriesError.value = null;
    final bool blockUi = cuisineOptions.isEmpty;
    if (blockUi) {
      isLoadingCuisineCategories.value = true;
    }

    try {
      final List<CuisineCategoryModel>? cached =
          _taxonomyRepository.cachedCuisineCategories;
      if (cached != null && cached.isNotEmpty) {
        cuisineOptions.assignAll(cached);
        _pruneInvalidSelections();
      }

      final List<CuisineCategoryModel> items = await _taxonomyRepository
          .fetchCuisineCategories()
          .timeout(AppDimensions.homeCatalogLoadTimeout);
      if (items.isNotEmpty) {
        cuisineOptions.assignAll(items);
        _pruneInvalidSelections();
        cuisineCategoriesError.value = null;
        return;
      }
      if (cuisineOptions.isEmpty) {
        _showFallbackOptions();
      }
    } on TimeoutException {
      if (cuisineOptions.isEmpty) {
        _showFallbackOptions();
      }
      // Keep chips usable; surface retry only when still empty.
      if (cuisineOptions.isEmpty) {
        cuisineCategoriesError.value = AppStrings.networkTimeoutError;
      }
    } on ApiException catch (error) {
      if (cuisineOptions.isEmpty) {
        _showFallbackOptions();
      }
      if (cuisineOptions.isEmpty) {
        cuisineCategoriesError.value = error.message;
      }
    } catch (_) {
      if (cuisineOptions.isEmpty) {
        _showFallbackOptions();
      }
      if (cuisineOptions.isEmpty) {
        cuisineCategoriesError.value = AppStrings.networkUnexpectedError;
      }
    } finally {
      isLoadingCuisineCategories.value = false;
    }
  }

  void toggleCuisine(String cuisine) {
    if (selectedCuisines.contains(cuisine)) {
      selectedCuisines.remove(cuisine);
      return;
    }
    selectedCuisines.add(cuisine);
  }

  bool isSelected(String cuisine) => selectedCuisines.contains(cuisine);

  bool get hasSelection => selectedCuisines.isNotEmpty;

  Future<void> skipForNow() => _finish();

  Future<void> confirm() => _finish();

  Future<void> _finish() async {
    await FavoriteCuisinesPreferences.markCompleted(
      selectedCuisines: selectedCuisines.toList(),
    );
    Get.offAllNamed(AppRoutes.welcome);
  }

  void _pruneInvalidSelections() {
    selectedCuisines.removeWhere(
      (String cuisine) =>
          !cuisineOptions.any(
            (CuisineCategoryModel item) => item.name == cuisine,
          ),
    );
  }

  void _showFallbackOptions() {
    cuisineOptions.assignAll(_fallbackCuisineOptions());
    _pruneInvalidSelections();
  }

  static List<CuisineCategoryModel> _fallbackCuisineOptions() {
    return List<CuisineCategoryModel>.generate(
      AppStrings.favoriteCuisineOptionKeys.length,
      (int index) {
        final String name = AppStrings.favoriteCuisineOptionKeys[index];
        final String slug = name
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), '-');
        return CuisineCategoryModel(
          id: 'fallback-$slug',
          slug: slug,
          name: name,
          sortOrder: index + 1,
        );
      },
      growable: false,
    );
  }
}
