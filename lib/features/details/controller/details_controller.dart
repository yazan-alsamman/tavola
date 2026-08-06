import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/post_frame_work.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../../reservation/model/reservation_route_args.dart';
import '../model/details_route_args.dart';
import '../model/restaurant_detail_model.dart';
import '../repository/restaurant_details_repository.dart';
import 'restaurant_menu_controller.dart';

class DetailsController extends GetxController {
  static const String detailsUpdateId = 'details';

  final RestaurantDetailsRepository _detailsRepository =
      Get.find<RestaurantDetailsRepository>();
  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();

  RestaurantModel? _restaurant;
  RestaurantDetailModel? _detail;
  bool _showMenu = false;
  bool _isLoadingDetails = false;
  String? _detailsError;
  bool _postFrameRefreshStarted = false;

  RestaurantModel get restaurant =>
      _restaurant ?? _detailsRepository.emptyRestaurant();

  RestaurantDetailModel get detail =>
      _detail ?? _detailsRepository.getDetails(restaurant.id);

  bool get showMenu => _showMenu;

  bool get hasRestaurant => _restaurant != null;

  bool get isLoadingDetails => _isLoadingDetails;

  String? get detailsError => _detailsError;

  @override
  void onInit() {
    super.onInit();
    // Sync bind so the first frame shows the correct restaurant (no fallback flash).
    _bindRouteArgumentsSync();
    PostFrameWork.schedule(() {
      if (isClosed || _postFrameRefreshStarted) {
        return;
      }
      _postFrameRefreshStarted = true;
      final String? id = _restaurant?.id;
      if (id == null || id.isEmpty) {
        return;
      }
      unawaited(_favoritesRepository.ensureInitialized());
      unawaited(_refreshDetails(id));
    });
  }

  /// Explicitly binds restaurant-specific data for the current Details visit.
  void loadRestaurant(RestaurantModel restaurant, {bool showMenu = false}) {
    _bindRestaurantSync(restaurant, showMenu: showMenu);
    update([detailsUpdateId]);
    unawaited(_favoritesRepository.ensureInitialized());
    unawaited(_refreshDetails(restaurant.id));
  }

  void _bindRouteArgumentsSync() {
    final Object? args = Get.arguments;
    if (args is DetailsRouteArgs) {
      _bindRestaurantSync(args.restaurant, showMenu: args.showMenu);
      return;
    }
    if (args is RestaurantModel) {
      _bindRestaurantSync(args, showMenu: false);
      return;
    }
    if (!hasRestaurant) {
      _bindRestaurantSync(
        _detailsRepository.emptyRestaurant(),
        showMenu: false,
      );
    }
  }

  void _bindRestaurantSync(
    RestaurantModel restaurant, {
    required bool showMenu,
  }) {
    _showMenu = showMenu;
    _detailsError = null;
    _restaurant = restaurant;
    _detail = _detailsRepository.getDetails(restaurant.id);
  }

  Future<void> _refreshDetails(String id) async {
    _isLoadingDetails = true;
    _detailsError = null;
    update([detailsUpdateId]);
    try {
      final RestaurantDetailModel freshDetail = await _detailsRepository
          .fetchDetails(id);
      final RestaurantModel base = _restaurant ?? restaurant;
      RestaurantModel merged = _withHeroImage(base, freshDetail);
      if (freshDetail.hasWorkingHours) {
        merged = merged.copyWith(
          hoursLabel: freshDetail.todayHoursLabel,
          availabilityLabel: freshDetail.isOpenNow
              ? AppStrings.openNow
              : AppStrings.hoursClosed,
          isAvailable: freshDetail.isOpenNow,
        );
      }
      _restaurant = merged;
      _detail = freshDetail;
    } on ApiException catch (error) {
      if (_detail == null ||
          _detail!.about == AppStrings.restaurantDetailsEmpty) {
        _detailsError = error.message;
      }
    } catch (_) {
      if (_detail == null ||
          _detail!.about == AppStrings.restaurantDetailsEmpty) {
        _detailsError = AppStrings.restaurantDetailsLoadError;
      }
    } finally {
      _isLoadingDetails = false;
      update([detailsUpdateId]);
    }
  }

  Future<void> retryLoadDetails() async {
    final String? id = _restaurant?.id;
    if (id == null || id.isEmpty) {
      return;
    }
    await _refreshDetails(id);
  }

  String ratingLabel(String rating) => '${AppStrings.starSymbol}$rating';

  void reloadLocalizedData() {
    if (isClosed) {
      return;
    }
    final RestaurantModel? current = _restaurant;
    if (current == null) {
      return;
    }

    _detail = _detailsRepository.getDetails(current.id);
    update([detailsUpdateId]);
  }

  Future<void> openReservation() async {
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

  void openMenu() {
    RestaurantMenuController.open(restaurant);
  }

  bool isFavorite(String id) => _favoritesRepository.isFavorite(id);

  int watchFavorites() => _favoritesRepository.watchFavorites();

  Future<void> toggleFavorite() async {
    final RestaurantModel current = restaurant;
    final String id = current.id.trim();
    if (id.isEmpty) {
      return;
    }
    if (!await AuthSessionController.requireSignInIfRegistered()) {
      return;
    }
    try {
      await _favoritesRepository.toggleFavorite(id, preview: current);
      update([detailsUpdateId]);
    } catch (_) {
      Get.snackbar(AppStrings.favorites, AppStrings.networkUnexpectedError);
    }
  }

  /// Opens restaurant details (payload via route args; Binding creates a fresh controller).
  static void open(RestaurantModel restaurant, {bool showMenu = false}) {
    AppNavigation.pushOnce(
      AppRoutes.details,
      arguments: DetailsRouteArgs(restaurant: restaurant, showMenu: showMenu),
    );
  }

  static RestaurantModel _withHeroImage(
    RestaurantModel restaurant,
    RestaurantDetailModel detail,
  ) {
    if (restaurant.imageUrl.trim().isNotEmpty) {
      return restaurant;
    }
    if (detail.galleryImageUrls.isEmpty) {
      return restaurant;
    }
    return RestaurantModel(
      id: restaurant.id,
      name: restaurant.name,
      cuisine: restaurant.cuisine,
      occasion: restaurant.occasion,
      description: restaurant.description,
      imageUrl: detail.galleryImageUrls.first,
      location: restaurant.location,
      availabilityLabel: restaurant.availabilityLabel,
      isAvailable: restaurant.isAvailable,
    );
  }
}
