import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../details/controller/details_controller.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/restaurant_model.dart';
import '../model/payment_transaction_model.dart';

class ProfileController extends GetxController {
  static const int paymentsSectionIndex = 1;
  static const int favoritesSectionIndex = 2;
  static const int settingsSectionIndex = 3;
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;

  final HomeController homeController = Get.find<HomeController>();

  final RxInt selectedSectionIndex = 0.obs;
  final RxList<bool> notificationSettings = <bool>[true, true, true, true].obs;

  final List<String> sections = const [
    AppStrings.reservations,
    AppStrings.payments,
    AppStrings.favorites,
    AppStrings.settings,
  ];

  final List<(String, String)> notificationOptions = const [
    (
      AppStrings.reservationReminderNotifications,
      AppStrings.reservationReminderDescription,
    ),
    (AppStrings.tablePreparedNotice, AppStrings.tablePreparedDescription),
    (AppStrings.lateArrivalInform, AppStrings.lateArrivalDescription),
    (
      AppStrings.promotionsConciergeEvents,
      AppStrings.promotionsConciergeDescription,
    ),
  ];

  final List<(String, String)> reservationDetails = const [
    (AppStrings.date, AppStrings.reservationDate),
    (AppStrings.time, AppStrings.reservationTime),
    (AppStrings.guests, AppStrings.reservationGuests),
  ];

  final List<PaymentTransactionModel> paymentTransactions = const [
    PaymentTransactionModel(
      restaurantName: AppStrings.oliveAndOak,
      date: AppStrings.paymentDateOne,
      amount: AppStrings.paymentAmountOne,
      status: AppStrings.paymentCompleted,
    ),
    PaymentTransactionModel(
      restaurantName: AppStrings.otakoSushi,
      date: AppStrings.paymentDateTwo,
      amount: AppStrings.paymentAmountTwo,
      status: AppStrings.paymentCompleted,
    ),
    PaymentTransactionModel(
      restaurantName: AppStrings.saffronHouse,
      date: AppStrings.paymentDateThree,
      amount: AppStrings.paymentAmountThree,
      status: AppStrings.paymentCompleted,
    ),
  ];

  List<RestaurantModel> get featuredRestaurants {
    final restaurants = homeController.restaurants;
    return restaurants.length >= AppDimensions.profileFeaturedRestaurantCount
        ? restaurants.sublist(0, AppDimensions.profileFeaturedRestaurantCount)
        : restaurants;
  }

  List<RestaurantModel> get favoriteRestaurants {
    return homeController.defaultFavoriteRestaurants;
  }

  void selectSection(int index) {
    selectedSectionIndex.value = index;
  }

  void toggleNotification(int index, bool value) {
    notificationSettings[index] = value;
  }

  bool isFavorite(String id) => homeController.isFavorite(id);

  void toggleFavorite(String id) {
    homeController.toggleFavorite(id);
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
