import '../../home/model/restaurant_model.dart';

class RestaurantMapLocation {
  const RestaurantMapLocation({
    required this.restaurant,
    required this.latitude,
    required this.longitude,
  });

  final RestaurantModel restaurant;
  final double latitude;
  final double longitude;
}
