import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../home/model/restaurant_model.dart';

/// Owns favorite state for the app. Controllers request toggles/reads only.
class FavoritesRepository extends GetxService {
  final RxMap<String, bool> favoriteStates = <String, bool>{}.obs;

  bool _initialized = false;

  static const List<String> _defaultFavoriteIds = [
    AppStrings.restaurantIdTwo,
    AppStrings.restaurantIdFive,
  ];

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    _seedDefaults();
  }

  void _seedDefaults() {
    if (_initialized) {
      return;
    }
    for (final String id in _defaultFavoriteIds) {
      favoriteStates[id] = true;
    }
    _initialized = true;
  }

  /// Synchronous init for controllers; prefer [ensureInitialized] for API.
  void ensureInitializedSync() => _seedDefaults();

  Future<List<String>> fetchDefaultFavoriteIds() async {
    return List<String>.unmodifiable(_defaultFavoriteIds);
  }

  bool isFavorite(String id) => favoriteStates[id] ?? false;

  void toggleFavorite(String id) {
    favoriteStates[id] = !isFavorite(id);
    favoriteStates.refresh();
  }

  List<RestaurantModel> defaultFavoriteRestaurants(
    List<RestaurantModel> restaurants,
  ) {
    return restaurants
        .where((restaurant) => _defaultFavoriteIds.contains(restaurant.id))
        .toList();
  }

  List<RestaurantModel> favoriteRestaurants(
    List<RestaurantModel> restaurants,
  ) {
    return restaurants
        .where((restaurant) => isFavorite(restaurant.id))
        .toList();
  }
}
