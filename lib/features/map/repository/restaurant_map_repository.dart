import '../../discovery/repository/discovery_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../model/restaurant_map_location.dart';

/// Map pin locations from Discovery restaurants + branches.
///
/// Uses public Discovery APIs only (never admin `/restaurants`).
class RestaurantMapRepository {
  RestaurantMapRepository(this._discovery);

  final DiscoveryRepository _discovery;

  List<RestaurantMapLocation> _cached = const <RestaurantMapLocation>[];

  Future<List<RestaurantMapLocation>> fetchMapLocations() async {
    final List<RestaurantModel> restaurants = await _discovery
        .listRestaurants();
    final List<RestaurantMapLocation> locations = <RestaurantMapLocation>[];

    for (final RestaurantModel restaurant in restaurants) {
      if (restaurant.id.isEmpty) {
        continue;
      }
      try {
        final branches = await _discovery.listBranches(restaurant.id);
        for (final branch in branches) {
          if (!branch.hasCoordinates) {
            continue;
          }
          locations.add(
            RestaurantMapLocation(
              restaurant: restaurant.copyWith(
                location: branch.locationLabel.isNotEmpty
                    ? branch.locationLabel
                    : restaurant.location,
              ),
              latitude: branch.latitude!,
              longitude: branch.longitude!,
            ),
          );
        }
      } catch (_) {
        // Skip restaurants whose branches fail — keep other pins.
      }
    }

    _cached = List<RestaurantMapLocation>.unmodifiable(locations);
    return _cached;
  }

  List<RestaurantMapLocation> getMapLocations() {
    return _cached;
  }
}
