import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../details/controller/details_controller.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../../home/repository/restaurant_repository.dart';
import '../model/payment_transaction_model.dart';
import '../repository/profile_repository.dart';

class ProfileController extends GetxController {
  static const int paymentsSectionIndex = 1;
  static const int favoritesSectionIndex = 2;
  static const int settingsSectionIndex = 3;
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;

  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();
  final RestaurantRepository _restaurantRepository =
      Get.find<RestaurantRepository>();
  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();

  final RxInt selectedSectionIndex = 0.obs;
  final RxList<bool> notificationSettings = <bool>[].obs;
  final RxList<String> sections = <String>[].obs;
  final RxList<(String, String)> notificationOptions =
      <(String, String)>[].obs;
  final RxList<(String, String)> reservationDetails =
      <(String, String)>[].obs;
  final RxList<PaymentTransactionModel> paymentTransactions =
      <PaymentTransactionModel>[].obs;
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _favoritesRepository.ensureInitializedSync();
    notificationSettings.assignAll(
      _profileRepository.getNotificationSettings(),
    );
    reloadLocalizedData();
  }

  void reloadLocalizedData() {
    restaurants.assignAll(_restaurantRepository.getRestaurants());
    sections.assignAll(_profileRepository.getSections());
    notificationOptions.assignAll(_profileRepository.getNotificationOptions());
    reservationDetails.assignAll(
      _profileRepository.getReservationDetailLabels(),
    );
    paymentTransactions.assignAll(
      _profileRepository.getPaymentTransactions(),
    );
  }

  List<RestaurantModel> get featuredRestaurants {
    return restaurants.length >= AppDimensions.profileFeaturedRestaurantCount
        ? restaurants.sublist(0, AppDimensions.profileFeaturedRestaurantCount)
        : restaurants.toList();
  }

  List<RestaurantModel> get favoriteRestaurants {
    return _favoritesRepository.defaultFavoriteRestaurants(restaurants);
  }

  void selectSection(int index) {
    selectedSectionIndex.value = index;
  }

  void toggleNotification(int index, bool value) {
    notificationSettings[index] = value;
  }

  bool isFavorite(String id) {
    return _favoritesRepository.favoriteStates[id] ?? false;
  }

  void toggleFavorite(String id) {
    _favoritesRepository.toggleFavorite(id);
  }

  void openDetails(RestaurantModel restaurant) {
    DetailsController.open(restaurant);
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(
      index,
      currentIndex: profileNavigationIndex,
    );
  }
}
