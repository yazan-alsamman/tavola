import '../../home/model/restaurant_model.dart';

/// Route payload for [AppRoutes.compareRestaurants].
class CompareRouteArgs {
  const CompareRouteArgs({this.seedRestaurant});

  /// Restaurant A when opening Compare from Details.
  final RestaurantModel? seedRestaurant;
}
