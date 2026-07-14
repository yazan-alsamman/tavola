import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/favorite_cuisines_preferences.dart';

class FavoriteCuisinesController extends GetxController {
  final RxList<String> selectedCuisines = <String>[].obs;

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
