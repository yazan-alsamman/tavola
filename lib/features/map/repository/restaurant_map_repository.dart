import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../home/model/restaurant_model.dart';
import '../../home/repository/restaurant_repository.dart';
import '../model/restaurant_map_location.dart';

/// Provides map pin locations for restaurants.
class RestaurantMapRepository {
  RestaurantMapRepository({RestaurantRepository? restaurantRepository})
      : _restaurantRepository =
            restaurantRepository ?? Get.find<RestaurantRepository>();

  final RestaurantRepository _restaurantRepository;

  Future<List<RestaurantMapLocation>> fetchMapLocations() async {
    return getMapLocations();
  }

  List<RestaurantMapLocation> getMapLocations() {
    final List<RestaurantModel> restaurants =
        _restaurantRepository.getRestaurants();

    return [
      if (restaurants.isNotEmpty)
        RestaurantMapLocation(
          restaurant: restaurants.first,
          latitude: AppDimensions.mapInitialLatitude,
          longitude: AppDimensions.mapInitialLongitude,
        ),
      if (restaurants.length > 1)
        RestaurantMapLocation(
          restaurant: restaurants[1],
          latitude: AppDimensions.mapSecondRestaurantLatitude,
          longitude: AppDimensions.mapSecondRestaurantLongitude,
        ),
    ];
  }
}
