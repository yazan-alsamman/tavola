import 'dart:async';

import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../../core/utils/post_frame_work.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../details/controller/details_controller.dart';
import '../../details/controller/restaurant_menu_controller.dart';
import '../../home/model/restaurant_model.dart';
import '../repository/favorites_repository.dart';

/// Favorites feature: `GET/POST/DELETE /users/me/favorites` only.
class FavoritesController extends GetxController {
  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();

  final RxBool isLoadingFavorites = true.obs;
  final RxnString favoritesError = RxnString();

  bool _postFrameLoadsStarted = false;

  @override
  void onInit() {
    super.onInit();
    PostFrameWork.schedule(() {
      if (isClosed || _postFrameLoadsStarted) {
        return;
      }
      _postFrameLoadsStarted = true;
      unawaited(loadFavorites());
    });
  }

  void reloadLocalizedData() {
    if (isClosed) {
      return;
    }
    // Favorite card labels rebuild via Obx + listedFavoriteRestaurants.
  }

  Future<void> loadFavorites() async {
    isLoadingFavorites.value = true;
    favoritesError.value = null;
    try {
      await _favoritesRepository.syncFavoritesFromApi();
      if (_favoritesRepository.syncError.value != null) {
        favoritesError.value = _favoritesRepository.syncError.value;
      }
    } finally {
      isLoadingFavorites.value = false;
    }
  }

  List<RestaurantModel> get favoriteRestaurants {
    return _favoritesRepository.listedFavoriteRestaurants();
  }

  bool isFavorite(String id) {
    return _favoritesRepository.isFavorite(id);
  }

  int watchFavorites() => _favoritesRepository.watchFavorites();

  Future<void> toggleFavorite(String id) async {
    if (!await AuthSessionController.requireSignInIfRegistered()) {
      return;
    }
    try {
      RestaurantModel? preview;
      for (final RestaurantModel item in favoriteRestaurants) {
        if (item.id == id) {
          preview = item;
          break;
        }
      }
      await _favoritesRepository.toggleFavorite(id, preview: preview);
    } catch (_) {
      Get.snackbar(AppStrings.favorites, AppStrings.networkUnexpectedError);
    }
  }

  void openDetails(RestaurantModel restaurant) {
    DetailsController.open(restaurant);
  }

  void openMenu(RestaurantModel restaurant) {
    RestaurantMenuController.open(restaurant);
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(
      index,
      currentIndex: BottomNavNavigation.homeIndex,
    );
  }
}
