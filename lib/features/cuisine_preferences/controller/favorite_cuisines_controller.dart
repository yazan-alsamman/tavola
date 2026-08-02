import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/favorite_cuisines_preferences.dart';
import '../../taxonomy/model/cuisine_category_model.dart';
import '../../taxonomy/repository/taxonomy_repository.dart';

class FavoriteCuisinesController extends GetxController {
  final TaxonomyRepository _taxonomyRepository = Get.find<TaxonomyRepository>();

  final RxList<String> selectedCuisines = <String>[].obs;
  final RxList<CuisineCategoryModel> cuisineOptions =
      <CuisineCategoryModel>[].obs;
  final RxBool isLoadingCuisineCategories = false.obs;
  final RxnString cuisineCategoriesError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCuisineCategories();
  }

  Future<void> loadCuisineCategories() async {
    isLoadingCuisineCategories.value = true;
    cuisineCategoriesError.value = null;
    try {
      final List<CuisineCategoryModel> items = await _taxonomyRepository
          .fetchCuisineCategories();
      cuisineOptions.assignAll(items);
      selectedCuisines.removeWhere(
        (String cuisine) =>
            !items.any((CuisineCategoryModel item) => item.name == cuisine),
      );
    } on ApiException catch (error) {
      cuisineOptions.clear();
      cuisineCategoriesError.value = error.message;
    } catch (_) {
      cuisineOptions.clear();
      cuisineCategoriesError.value = AppStrings.networkUnexpectedError;
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
}
