import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../details/controller/details_controller.dart';
import '../../reservation/controller/select_restaurant_controller.dart';
import '../model/restaurant_model.dart';

class HomeController extends GetxController {
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;
  static const List<int> _defaultFavoriteIndexes = [1, 4];

  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxMap<String, bool> favoriteStates = <String, bool>{}.obs;
  final RxInt selectedFilterIndex = 0.obs;
  final RxnString selectedOccasion = RxnString();
  final List<String> restaurantFilters = const [
    AppStrings.allRestaurants,
    AppStrings.japanese,
    AppStrings.seafood,
    AppStrings.italian,
    AppStrings.barbecue,
  ];
  final List<String> occasionCategories = const [
    AppStrings.birthday,
    AppStrings.anniversary,
    AppStrings.business,
    AppStrings.social,
  ];

  @override
  void onInit() {
    super.onInit();
    restaurants.addAll([
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
    ]);

    for (final restaurant in defaultFavoriteRestaurants) {
      favoriteStates[restaurant.id] = true;
    }
  }

  void toggleFavorite(String id) {
    favoriteStates[id] = !(favoriteStates[id] ?? false);
    favoriteStates.refresh();
  }

  bool isFavorite(String id) => favoriteStates[id] ?? false;

  void selectOccasion(String occasion) {
    selectedOccasion.value = occasion;
  }

  void openReservation() {
    SelectRestaurantController.open();
  }

  void openDetails(RestaurantModel restaurant) {
    DetailsController.open(restaurant);
  }

  List<RestaurantModel> get defaultFavoriteRestaurants {
    return _defaultFavoriteIndexes
        .where((index) => index < restaurants.length)
        .map((index) => restaurants[index])
        .toList();
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(
      index,
      currentIndex: homeNavigationIndex,
    );
  }
}
