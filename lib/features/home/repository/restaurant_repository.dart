import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_strings.dart';
import '../model/restaurant_model.dart';

/// Provides restaurant catalog data. Swap mock body for API calls later.
class RestaurantRepository {
  Future<List<RestaurantModel>> fetchRestaurants() async {
    return getRestaurants();
  }

  Future<RestaurantModel?> fetchRestaurantById(String id) async {
    return getRestaurantById(id);
  }

  Future<List<String>> fetchFilters() async {
    return getFilters();
  }

  Future<List<String>> fetchOccasionCategories() async {
    return getOccasionCategories();
  }

  List<RestaurantModel> getRestaurants() {
    return List<RestaurantModel>.unmodifiable(_restaurants);
  }

  RestaurantModel? getRestaurantById(String id) {
    for (final RestaurantModel restaurant in _restaurants) {
      if (restaurant.id == id) {
        return restaurant;
      }
    }
    return null;
  }

  List<String> getFilters() {
    return List<String>.unmodifiable(_filters);
  }

  List<String> getOccasionCategories() {
    return List<String>.unmodifiable(_occasionCategories);
  }

  static List<RestaurantModel> get _restaurants => [
    RestaurantModel(
      id: AppStrings.restaurantIdOne,
      name: AppStrings.saffronHouse,
      cuisine: AppStrings.indian,
      occasion: AppStrings.dinner,
      description: AppStrings.saffronDescription,
      imageUrl: AppImages.r1,
      location: AppStrings.oldTown,
      availabilityLabel: AppStrings.openNow,
      isAvailable: true,
    ),
    RestaurantModel(
      id: AppStrings.restaurantIdTwo,
      name: AppStrings.otakoSushi,
      cuisine: AppStrings.sushi,
      occasion: AppStrings.lunch,
      description: AppStrings.otakoDescription,
      imageUrl: AppImages.r3,
      location: AppStrings.marinaBay,
      availabilityLabel: AppStrings.openNow,
      isAvailable: true,
    ),
    RestaurantModel(
      id: AppStrings.restaurantIdThree,
      name: AppStrings.oliveAndOak,
      cuisine: AppStrings.mediterranean,
      occasion: AppStrings.brunch,
      description: AppStrings.oliveDescription,
      imageUrl: AppImages.r4,
      location: AppStrings.gardenStreet,
      availabilityLabel: AppStrings.booked,
      isAvailable: false,
    ),
    RestaurantModel(
      id: AppStrings.restaurantIdFour,
      name: AppStrings.goldenLantern,
      cuisine: AppStrings.asian,
      occasion: AppStrings.dinner,
      description: AppStrings.goldenDescription,
      imageUrl: AppImages.r2,
      location: AppStrings.northDistrict,
      availabilityLabel: AppStrings.openNow,
      isAvailable: true,
    ),
    RestaurantModel(
      id: AppStrings.restaurantIdFive,
      name: AppStrings.cedarTable,
      cuisine: AppStrings.contemporary,
      occasion: AppStrings.dinner,
      description: AppStrings.cedarDescription,
      imageUrl: AppImages.r6,
      location: AppStrings.elmAvenue,
      availabilityLabel: AppStrings.openNow,
      isAvailable: true,
    ),
    RestaurantModel(
      id: AppStrings.restaurantIdSix,
      name: AppStrings.amberTerrace,
      cuisine: AppStrings.steakhouse,
      occasion: AppStrings.dinner,
      description: AppStrings.amberDescription,
      imageUrl: AppImages.r5,
      location: AppStrings.hillview,
      availabilityLabel: AppStrings.limited,
      isAvailable: false,
    ),
  ];

  static List<String> get _filters => [
        AppStrings.allRestaurants,
        AppStrings.japanese,
        AppStrings.seafood,
        AppStrings.italian,
        AppStrings.barbecue,
      ];

  static List<String> get _occasionCategories => [
        AppStrings.birthday,
        AppStrings.anniversary,
        AppStrings.business,
        AppStrings.social,
      ];
}
