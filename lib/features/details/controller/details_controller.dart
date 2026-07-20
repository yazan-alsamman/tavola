import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../home/model/restaurant_model.dart';
import '../../home/repository/restaurant_repository.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../model/restaurant_detail_model.dart';
import '../repository/restaurant_details_repository.dart';

class DetailsController extends GetxController {
  static const String detailsUpdateId = 'details';

  final RestaurantDetailsRepository _detailsRepository =
      Get.find<RestaurantDetailsRepository>();

  RestaurantModel? _restaurant;
  RestaurantDetailModel? _detail;

  RestaurantModel get restaurant =>
      _restaurant ?? _detailsRepository.getFallbackRestaurant();

  RestaurantDetailModel get detail =>
      _detail ?? _detailsRepository.getDetails(restaurant.id);

  bool get hasRestaurant => _restaurant != null;

  /// Explicitly binds restaurant-specific data for the current Details visit.
  void loadRestaurant(RestaurantModel restaurant) {
    if (_restaurant?.id == restaurant.id && _detail != null) {
      return;
    }

    _restaurant = restaurant;
    _detail = _detailsRepository.getDetails(restaurant.id);
    update([detailsUpdateId]);
  }

  @override
  void onReady() {
    super.onReady();
    _loadFromRouteArgumentsIfNeeded();
  }

  void _loadFromRouteArgumentsIfNeeded() {
    if (hasRestaurant) {
      return;
    }

    final Object? args = Get.arguments;
    if (args is RestaurantModel) {
      loadRestaurant(args);
      return;
    }

    loadRestaurant(_detailsRepository.getFallbackRestaurant());
  }

  String ratingLabel(String rating) => '${AppStrings.starSymbol}$rating';

  void reloadLocalizedData() {
    final RestaurantModel? current = _restaurant;
    if (current == null) {
      return;
    }

    if (Get.isRegistered<RestaurantRepository>()) {
      final RestaurantModel? fresh =
          Get.find<RestaurantRepository>().getRestaurantById(current.id);
      if (fresh != null) {
        _restaurant = fresh;
      }
    }

    _detail = _detailsRepository.getDetails(current.id);
    update([detailsUpdateId]);
  }

  void openReservation() {
    if (Get.isRegistered<ReservationController>()) {
      Get.delete<ReservationController>(force: true);
    }

    Get.toNamed(AppRoutes.reservation, arguments: restaurant.name);
  }

  /// Opens Details and always applies [restaurant] via [loadRestaurant].
  static void open(RestaurantModel restaurant) {
    if (Get.isRegistered<DetailsController>()) {
      Get.find<DetailsController>().loadRestaurant(restaurant);
    }

    Get.toNamed(AppRoutes.details, arguments: restaurant);
  }
}
