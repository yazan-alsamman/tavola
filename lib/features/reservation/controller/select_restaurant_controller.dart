import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_dependency.dart';
import '../../../core/utils/post_frame_work.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../model/reservation_route_args.dart';
import 'reservation_controller.dart';

class SelectRestaurantController extends GetxController {
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;

  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();
  final DiscoveryRepository _discoveryRepository =
      Get.find<DiscoveryRepository>();

  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxBool isLoadingRestaurants = true.obs;
  final RxnString restaurantsError = RxnString();

  bool _postFrameLoadsStarted = false;

  @override
  void onInit() {
    super.onInit();
    reloadLocalizedData();
    PostFrameWork.schedule(() {
      if (isClosed || _postFrameLoadsStarted) {
        return;
      }
      _postFrameLoadsStarted = true;
      unawaited(_favoritesRepository.ensureInitialized());
      unawaited(loadRestaurants());
    });
  }

  void reloadLocalizedData() {
    if (isClosed) {
      return;
    }
    final List<RestaurantModel>? cached =
        _discoveryRepository.cachedRestaurants;
    if (cached != null) {
      restaurants.assignAll(cached);
      isLoadingRestaurants.value = false;
      restaurantsError.value = cached.isEmpty
          ? AppStrings.restaurantsEmpty
          : null;
    }
  }

  Future<void> loadRestaurants() async {
    final bool showSpinner = restaurants.isEmpty;
    if (showSpinner) {
      isLoadingRestaurants.value = true;
    }
    restaurantsError.value = null;
    try {
      final List<RestaurantModel> items = await _discoveryRepository
          .listRestaurants(forceRefresh: true)
          .timeout(AppDimensions.homeCatalogLoadTimeout);
      restaurants.assignAll(items);
      if (items.isEmpty) {
        restaurantsError.value = AppStrings.restaurantsEmpty;
      }
    } on TimeoutException {
      if (restaurants.isEmpty) {
        restaurantsError.value = AppStrings.networkTimeoutError;
      }
    } on ApiException catch (error) {
      if (restaurants.isEmpty) {
        restaurantsError.value = error.message;
      }
    } catch (_) {
      if (restaurants.isEmpty) {
        restaurantsError.value = AppStrings.networkUnexpectedError;
      }
    } finally {
      isLoadingRestaurants.value = false;
    }
  }

  bool isFavorite(String id) {
    return _favoritesRepository.isFavorite(id);
  }

  /// Subscribe inside `Obx` so restaurant cards rebuild when favorites change.
  int watchFavorites() => _favoritesRepository.watchFavorites();

  Future<void> toggleFavorite(String id) async {
    if (!await AuthSessionController.requireSignInIfRegistered()) {
      return;
    }
    try {
      RestaurantModel? preview;
      for (final RestaurantModel item in restaurants) {
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

  Future<void> selectRestaurant(RestaurantModel restaurant) async {
    if (!restaurant.isAvailable) {
      Get.snackbar(
        AppStrings.selectYourRestaurant,
        AppStrings.selectRestaurantUnavailable,
      );
      return;
    }
    if (Get.isRegistered<AuthSessionController>() &&
        !await Get.find<AuthSessionController>()
            .requireSignInForProtectedAction()) {
      return;
    }

    if (Get.isRegistered<ReservationController>()) {
      Get.delete<ReservationController>(force: true);
    }

    AppNavigation.pushOnce(
      AppRoutes.reservation,
      arguments: ReservationRouteArgs(
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
      ),
    );
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(index, currentIndex: bookingNavigationIndex);
  }

  static void open() {
    AppDependency.ensureSelectRestaurantDependencies();
    AppNavigation.goShell(AppRoutes.selectRestaurant);
  }
}
