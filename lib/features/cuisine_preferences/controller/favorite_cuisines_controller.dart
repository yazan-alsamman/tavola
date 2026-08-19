import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/favorite_cuisines_preferences.dart';
import '../../taxonomy/model/occasion_category_model.dart';
import '../../taxonomy/repository/taxonomy_repository.dart';

class FavoriteCuisinesController extends GetxController {
  FavoriteCuisinesController({TaxonomyRepository? taxonomyRepository})
    : _taxonomyRepository =
          taxonomyRepository ?? Get.find<TaxonomyRepository>();

  final TaxonomyRepository _taxonomyRepository;

  final RxList<String> selectedOccasions = <String>[].obs;
  final RxList<OccasionCategoryModel> occasionOptions =
      <OccasionCategoryModel>[].obs;
  final RxBool isLoadingOccasionCategories = false.obs;
  final RxnString occasionCategoriesError = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Always paint chips immediately — never block first-launch on taxonomy.
    _showFallbackOptions();
    unawaited(loadOccasionCategories());
  }

  Future<void> loadOccasionCategories() async {
    occasionCategoriesError.value = null;
    final bool blockUi = occasionOptions.isEmpty;
    if (blockUi) {
      isLoadingOccasionCategories.value = true;
    }

    try {
      final List<OccasionCategoryModel>? cached =
          _taxonomyRepository.cachedOccasionCategories;
      if (cached != null && cached.isNotEmpty) {
        occasionOptions.assignAll(cached);
        _pruneInvalidSelections();
      }

      final List<OccasionCategoryModel> items = await _taxonomyRepository
          .fetchOccasionCategories()
          .timeout(AppDimensions.homeCatalogLoadTimeout);
      if (items.isNotEmpty) {
        occasionOptions.assignAll(items);
        _pruneInvalidSelections();
        occasionCategoriesError.value = null;
        return;
      }
      if (occasionOptions.isEmpty) {
        _showFallbackOptions();
      }
    } on TimeoutException {
      if (occasionOptions.isEmpty) {
        _showFallbackOptions();
      }
      if (occasionOptions.isEmpty) {
        occasionCategoriesError.value = AppStrings.networkTimeoutError;
      }
    } on ApiException catch (error) {
      if (occasionOptions.isEmpty) {
        _showFallbackOptions();
      }
      if (occasionOptions.isEmpty) {
        occasionCategoriesError.value = error.message;
      }
    } catch (_) {
      if (occasionOptions.isEmpty) {
        _showFallbackOptions();
      }
      if (occasionOptions.isEmpty) {
        occasionCategoriesError.value = AppStrings.networkUnexpectedError;
      }
    } finally {
      isLoadingOccasionCategories.value = false;
    }
  }

  void toggleOccasion(String occasion) {
    if (selectedOccasions.contains(occasion)) {
      selectedOccasions.remove(occasion);
      return;
    }
    selectedOccasions.add(occasion);
  }

  bool isSelected(String occasion) => selectedOccasions.contains(occasion);

  bool get hasSelection => selectedOccasions.isNotEmpty;

  Future<void> skipForNow() => _finish();

  Future<void> confirm() => _finish();

  Future<void> _finish() async {
    await FavoriteCuisinesPreferences.markCompleted(
      selectedCuisines: selectedOccasions.toList(),
    );
    Get.offAllNamed(AppRoutes.welcome);
  }

  void _pruneInvalidSelections() {
    selectedOccasions.removeWhere(
      (String occasion) => !occasionOptions.any(
        (OccasionCategoryModel item) =>
            item.name == occasion || item.slug == occasion,
      ),
    );
  }

  void _showFallbackOptions() {
    occasionOptions.assignAll(OccasionCategoryModel.fallbackItems());
    _pruneInvalidSelections();
  }
}
