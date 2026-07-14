import 'package:get/get.dart';

import '../../features/cuisine_preferences/controller/favorite_cuisines_controller.dart';
import '../../features/cuisine_preferences/view/favorite_cuisines_screen.dart';
import '../../features/details/controller/details_controller.dart';
import '../../features/details/view/details_screen.dart';
import '../../features/concierge/controller/concierge_controller.dart';
import '../../features/concierge/view/concierge_screen.dart';
import '../../features/favorites/controller/favorites_controller.dart';
import '../../features/favorites/view/favorites_screen.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/map/controller/restaurant_map_controller.dart';
import '../../features/map/view/restaurant_map_screen.dart';
import '../../features/onboarding/controller/onboarding_controller.dart';
import '../../features/onboarding/view/onboarding_screen.dart';
import '../../features/profile/controller/profile_controller.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/reservation/controller/reservation_controller.dart';
import '../../features/reservation/controller/select_restaurant_controller.dart';
import '../../features/reservation/controller/select_table_controller.dart';
import '../../features/reservation/view/reservation_screen.dart';
import '../../features/reservation/view/select_restaurant_screen.dart';
import '../../features/reservation/view/select_table_screen.dart';
import '../../features/auth/controller/login_controller.dart';
import '../../features/auth/controller/otp_controller.dart';
import '../../features/auth/controller/sign_up_controller.dart';
import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/otp_screen.dart';
import '../../features/auth/view/sign_up_screen.dart';
import '../../features/splash/controller/splash_controller.dart';
import '../../features/splash/view/splash_screen.dart';
import '../../features/welcome/controller/welcome_controller.dart';
import '../../features/welcome/view/welcome_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String favoriteCuisines = '/favorite-cuisines';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String map = '/map';
  static const String favorites = '/favorites';
  static const String concierge = '/concierge';
  static const String profile = '/profile';
  static const String reservation = '/reservation';
  static const String selectRestaurant = '/select-restaurant';
  static const String selectTable = '/select-table';
  static const String details = '/details';
  static const String initial = splash;

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(
      name: favoriteCuisines,
      page: () => const FavoriteCuisinesScreen(),
      binding: BindingsBuilder(() {
        Get.put(FavoriteCuisinesController());
      }),
    ),
    GetPage(
      name: welcome,
      page: () => const WelcomeScreen(),
      binding: BindingsBuilder(() {
        Get.put(WelcomeController());
      }),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),
    GetPage(
      name: signUp,
      page: () => const SignUpScreen(),
      binding: BindingsBuilder(() {
        Get.put(SignUpController());
      }),
    ),
    GetPage(
      name: otp,
      page: () => const OtpScreen(),
      binding: BindingsBuilder(() {
        Get.put(OtpController());
      }),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
      }),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<HomeController>()) {
          Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
        }
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: concierge,
      page: () => const ConciergeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ConciergeController>(() => ConciergeController());
      }),
    ),
    GetPage(
      name: map,
      page: () => const RestaurantMapScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<HomeController>()) {
          Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
        }
        Get.lazyPut<RestaurantMapController>(() => RestaurantMapController());
      }),
    ),
    GetPage(
      name: favorites,
      page: () => const FavoritesScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<HomeController>()) {
          Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
        }
        Get.lazyPut<FavoritesController>(() => FavoritesController());
      }),
    ),
    GetPage(
      name: reservation,
      page: () => const ReservationScreen(),
      binding: BindingsBuilder(() {
        if (Get.isRegistered<ReservationController>()) {
          Get.delete<ReservationController>(force: true);
        }
        Get.put(ReservationController());
      }),
    ),
    GetPage(
      name: selectRestaurant,
      page: () => const SelectRestaurantScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<HomeController>()) {
          Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
        }
        Get.lazyPut<SelectRestaurantController>(
          () => SelectRestaurantController(),
        );
      }),
    ),
    GetPage(
      name: selectTable,
      page: () => const SelectTableScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SelectTableController>(() => SelectTableController());
      }),
    ),
    GetPage(
      name: details,
      page: () => const DetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DetailsController>(() => DetailsController(), fenix: true);
      }),
    ),
  ];
}
