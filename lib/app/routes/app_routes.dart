import 'package:get/get.dart';

import '../../core/utils/app_dependency.dart';
import '../../features/cuisine_preferences/controller/favorite_cuisines_controller.dart';
import '../../features/cuisine_preferences/view/favorite_cuisines_screen.dart';
import '../../features/details/controller/details_controller.dart';
import '../../features/details/controller/restaurant_menu_controller.dart';
import '../../features/details/view/details_screen.dart';
import '../../features/details/view/restaurant_menu_screen.dart';
import '../../features/concierge/controller/concierge_controller.dart';
import '../../features/concierge/view/concierge_screen.dart';
import '../../features/favorites/controller/favorites_controller.dart';
import '../../features/favorites/view/favorites_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/map/controller/restaurant_map_controller.dart';
import '../../features/map/view/restaurant_map_screen.dart';
import '../../features/notifications/controller/notifications_controller.dart';
import '../../features/notifications/view/notifications_screen.dart';
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
import '../../features/auth/controller/complete_registration_controller.dart';
import '../../features/auth/controller/login_controller.dart';
import '../../features/auth/controller/otp_controller.dart';
import '../../features/auth/controller/password_reset_controller.dart';
import '../../features/auth/controller/sign_up_controller.dart';
import '../../features/auth/view/complete_registration_screen.dart';
import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/otp_screen.dart';
import '../../features/auth/view/password_reset_screen.dart';
import '../../features/auth/view/sign_up_screen.dart';
import '../../features/splash/controller/splash_controller.dart';
import '../../features/splash/view/splash_screen.dart';
import '../../features/welcome/view/logout_transition_screen.dart';
import '../../features/welcome/view/welcome_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String favoriteCuisines = '/favorite-cuisines';
  static const String welcome = '/welcome';
  static const String logoutTransition = '/logout-transition';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String otp = '/otp';
  static const String completeRegistration = '/complete-registration';
  static const String passwordReset = '/password-reset';
  static const String home = '/home';
  static const String map = '/map';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String concierge = '/concierge';
  static const String profile = '/profile';
  static const String reservation = '/reservation';
  static const String selectRestaurant = '/select-restaurant';
  static const String selectTable = '/select-table';
  static const String details = '/details';
  static const String restaurantMenu = '/restaurant-menu';
  static const String initial = splash;

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        // Prefer the instance put in `main()`; never create a second Splash.
        AppDependency.putIfAbsent(SplashController.new);
      }),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        // Preview booking widgets need reservation/select-table repositories.
        AppDependency.ensureReservationFlowDependencies();
        AppDependency.putFresh(OnboardingController.new);
      }),
    ),
    GetPage(
      name: favoriteCuisines,
      page: () => const FavoriteCuisinesScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureTaxonomyRepository();
        AppDependency.putFresh(FavoriteCuisinesController.new);
      }),
    ),
    GetPage(
      name: welcome,
      page: () => const WelcomeScreen(),
      binding: BindingsBuilder(() {
        // Warm Login + SignUp before the first tap.
        // Permanent so offAllNamed(guest→home) does not dispose their
        // TextEditingControllers mid-transition (first-tap crash).
        // UsersRepository stays lazy — created after sign-in identity persist
        // or Home progressive Stage 4, never on Welcome open.
        AppDependency.putPermanentIfAbsent(LoginController.new);
        AppDependency.putPermanentIfAbsent(SignUpController.new);
      }),
    ),
    GetPage(
      name: logoutTransition,
      page: () => const LogoutTransitionScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        // LoginController only — UsersRepository is ensured after sign-in when
        // persisting identity (not on the Login screen open / submit critical path).
        AppDependency.putPermanentIfAbsent(LoginController.new);
      }),
    ),
    GetPage(
      name: signUp,
      page: () => const SignUpScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureAuthFeatureDependencies();
        final SignUpController controller = AppDependency.putPermanentIfAbsent(
          SignUpController.new,
        );
        controller.resetForEntry();
      }),
    ),
    GetPage(
      name: otp,
      page: () => const OtpScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureAuthFeatureDependencies();
        AppDependency.putFresh(OtpController.new);
      }),
    ),
    GetPage(
      name: completeRegistration,
      page: () => const CompleteRegistrationScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureAuthFeatureDependencies();
        AppDependency.putFresh(CompleteRegistrationController.new);
      }),
    ),
    GetPage(
      name: passwordReset,
      page: () => const PasswordResetScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureAuthFeatureDependencies();
        AppDependency.putFresh(PasswordResetController.new);
      }),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        // Prefer HomeController already created by GuestTransitionScreen
        // (or Splash prep). HomeScreen falls back to ensure on build.
      }),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureProfileDependencies();
        AppDependency.putPermanentIfAbsent(ProfileController.new);
      }),
    ),
    GetPage(
      name: concierge,
      page: () => const ConciergeScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureConciergeDependencies();
        AppDependency.putPermanentIfAbsent(ConciergeController.new);
      }),
    ),
    GetPage(
      name: map,
      page: () => const RestaurantMapScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureMapDependencies();
        AppDependency.putPermanentIfAbsent(RestaurantMapController.new);
      }),
    ),
    GetPage(
      name: favorites,
      page: () => const FavoritesScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureFavoritesScreenDependencies();
        AppDependency.putFresh(FavoritesController.new);
      }),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureNotificationsScreenDependencies();
        AppDependency.putFresh(NotificationsController.new);
      }),
    ),
    GetPage(
      name: reservation,
      page: () => const ReservationScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureReservationFlowDependencies();
        AppDependency.putFresh(ReservationController.new);
      }),
    ),
    GetPage(
      name: selectRestaurant,
      page: () => const SelectRestaurantScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureSelectRestaurantDependencies();
        AppDependency.putFresh(SelectRestaurantController.new);
      }),
    ),
    GetPage(
      name: selectTable,
      page: () => const SelectTableScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureReservationFlowDependencies();
        AppDependency.putFresh(SelectTableController.new);
      }),
    ),
    GetPage(
      name: details,
      page: () => const DetailsScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureDetailsDependencies();
        AppDependency.putFresh(DetailsController.new);
      }),
    ),
    GetPage(
      name: restaurantMenu,
      page: () => const RestaurantMenuScreen(),
      binding: BindingsBuilder(() {
        AppDependency.ensureDetailsDependencies();
        AppDependency.putFresh(RestaurantMenuController.new);
      }),
    ),
  ];
}
