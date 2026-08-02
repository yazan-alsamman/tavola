import '../../home/model/restaurant_model.dart';

/// Arguments for the restaurant details route.
class DetailsRouteArgs {
  const DetailsRouteArgs({required this.restaurant, this.showMenu = false});

  final RestaurantModel restaurant;

  /// When false, details show the restaurant page without the menu section.
  final bool showMenu;
}
