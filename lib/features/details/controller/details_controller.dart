import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../home/model/restaurant_model.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../model/menu_item_model.dart';
import '../model/opening_hours_day_model.dart';
import '../model/restaurant_detail_model.dart';

class DetailsController extends GetxController {
  late final RestaurantModel restaurant;
  late final RestaurantDetailModel detail;

  @override
  void onInit() {
    super.onInit();
    final Object? args = Get.arguments;
    if (args is RestaurantModel) {
      restaurant = args;
    } else {
      restaurant = _fallbackRestaurant;
    }
    detail = detailFor(restaurant.id);
  }

  RestaurantDetailModel detailFor(String restaurantId) {
    return _detailsById[restaurantId] ?? _detailsById[AppStrings.restaurantIdOne]!;
  }

  String ratingLabel(String rating) =>
      '${AppStrings.starSymbol}$rating';

  void openReservation() {
    if (Get.isRegistered<ReservationController>()) {
      Get.delete<ReservationController>(force: true);
    }

    Get.toNamed(AppRoutes.reservation, arguments: restaurant.name);
  }

  static void open(RestaurantModel restaurant) {
    Get.toNamed(AppRoutes.details, arguments: restaurant);
  }

  static RestaurantModel get _fallbackRestaurant => RestaurantModel(
        id: AppStrings.restaurantIdOne,
        name: AppStrings.saffronHouse,
        cuisine: AppStrings.indian,
        occasion: AppStrings.dinner,
        description: AppStrings.saffronDescription,
        imageUrl: '',
        location: AppStrings.oldTown,
        availabilityLabel: AppStrings.openNow,
        isAvailable: true,
      );

  static const List<OpeningHoursDayModel> _standardHours = [
    OpeningHoursDayModel(
      day: AppStrings.dayMondayToSaturday,
      hours: AppStrings.hoursWeekday,
    ),
    OpeningHoursDayModel(
      day: AppStrings.daySunday,
      hours: AppStrings.hoursClosed,
    ),
  ];

  static const List<OpeningHoursDayModel> _eveningHours = [
    OpeningHoursDayModel(
      day: AppStrings.dayMonday,
      hours: AppStrings.hoursClosed,
    ),
    OpeningHoursDayModel(
      day: AppStrings.dayTuesdayToThursday,
      hours: AppStrings.hoursLate,
    ),
    OpeningHoursDayModel(
      day: AppStrings.dayFridayToSaturday,
      hours: AppStrings.hoursWeekend,
    ),
    OpeningHoursDayModel(
      day: AppStrings.daySunday,
      hours: AppStrings.hoursWeekday,
    ),
  ];

  static final Map<String, RestaurantDetailModel> _detailsById = {
    AppStrings.restaurantIdOne: const RestaurantDetailModel(
      restaurantId: AppStrings.restaurantIdOne,
      rating: AppStrings.ratingSaffron,
      locationBlurb: AppStrings.locationBlurbSaffron,
      about: AppStrings.aboutSaffron,
      amenities: [
        AppStrings.amenityValet,
        AppStrings.amenityPrivateParking,
        AppStrings.amenityPrivateDining,
      ],
      openingHours: _standardHours,
      phone: AppStrings.phoneSaffron,
      menuItems: [
        MenuItemModel(
          name: AppStrings.menuSaffronOne,
          description: AppStrings.menuSaffronOneDesc,
          price: AppStrings.menuSaffronOnePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuSaffronTwo,
          description: AppStrings.menuSaffronTwoDesc,
          price: AppStrings.menuSaffronTwoPrice,
        ),
        MenuItemModel(
          name: AppStrings.menuSaffronThree,
          description: AppStrings.menuSaffronThreeDesc,
          price: AppStrings.menuSaffronThreePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuSaffronFour,
          description: AppStrings.menuSaffronFourDesc,
          price: AppStrings.menuSaffronFourPrice,
        ),
      ],
      locationNote: AppStrings.locationNoteSaffron,
    ),
    AppStrings.restaurantIdTwo: const RestaurantDetailModel(
      restaurantId: AppStrings.restaurantIdTwo,
      rating: AppStrings.ratingOtako,
      locationBlurb: AppStrings.locationBlurbOtako,
      about: AppStrings.aboutOtako,
      amenities: [
        AppStrings.amenityValet,
        AppStrings.amenityChefTable,
        AppStrings.amenityWineCellar,
      ],
      openingHours: _eveningHours,
      phone: AppStrings.phoneOtako,
      menuItems: [
        MenuItemModel(
          name: AppStrings.menuOtakoOne,
          description: AppStrings.menuOtakoOneDesc,
          price: AppStrings.menuOtakoOnePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuOtakoTwo,
          description: AppStrings.menuOtakoTwoDesc,
          price: AppStrings.menuOtakoTwoPrice,
        ),
        MenuItemModel(
          name: AppStrings.menuOtakoThree,
          description: AppStrings.menuOtakoThreeDesc,
          price: AppStrings.menuOtakoThreePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuOtakoFour,
          description: AppStrings.menuOtakoFourDesc,
          price: AppStrings.menuOtakoFourPrice,
        ),
      ],
      locationNote: AppStrings.locationNoteOtako,
    ),
    AppStrings.restaurantIdThree: const RestaurantDetailModel(
      restaurantId: AppStrings.restaurantIdThree,
      rating: AppStrings.ratingOlive,
      locationBlurb: AppStrings.locationBlurbOlive,
      about: AppStrings.aboutOlive,
      amenities: [
        AppStrings.amenityOutdoorTerrace,
        AppStrings.amenityStreetParking,
        AppStrings.amenityPetFriendly,
      ],
      openingHours: _standardHours,
      phone: AppStrings.phoneOlive,
      menuItems: [
        MenuItemModel(
          name: AppStrings.menuOliveOne,
          description: AppStrings.menuOliveOneDesc,
          price: AppStrings.menuOliveOnePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuOliveTwo,
          description: AppStrings.menuOliveTwoDesc,
          price: AppStrings.menuOliveTwoPrice,
        ),
        MenuItemModel(
          name: AppStrings.menuOliveThree,
          description: AppStrings.menuOliveThreeDesc,
          price: AppStrings.menuOliveThreePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuOliveFour,
          description: AppStrings.menuOliveFourDesc,
          price: AppStrings.menuOliveFourPrice,
        ),
      ],
      locationNote: AppStrings.locationNoteOlive,
    ),
    AppStrings.restaurantIdFour: const RestaurantDetailModel(
      restaurantId: AppStrings.restaurantIdFour,
      rating: AppStrings.ratingGolden,
      locationBlurb: AppStrings.locationBlurbGolden,
      about: AppStrings.aboutGolden,
      amenities: [
        AppStrings.amenityPrivateParking,
        AppStrings.amenityLiveMusic,
        AppStrings.amenityWheelchair,
      ],
      openingHours: _eveningHours,
      phone: AppStrings.phoneGolden,
      menuItems: [
        MenuItemModel(
          name: AppStrings.menuGoldenOne,
          description: AppStrings.menuGoldenOneDesc,
          price: AppStrings.menuGoldenOnePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuGoldenTwo,
          description: AppStrings.menuGoldenTwoDesc,
          price: AppStrings.menuGoldenTwoPrice,
        ),
        MenuItemModel(
          name: AppStrings.menuGoldenThree,
          description: AppStrings.menuGoldenThreeDesc,
          price: AppStrings.menuGoldenThreePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuGoldenFour,
          description: AppStrings.menuGoldenFourDesc,
          price: AppStrings.menuGoldenFourPrice,
        ),
      ],
      locationNote: AppStrings.locationNoteGolden,
    ),
    AppStrings.restaurantIdFive: const RestaurantDetailModel(
      restaurantId: AppStrings.restaurantIdFive,
      rating: AppStrings.ratingCedar,
      locationBlurb: AppStrings.locationBlurbCedar,
      about: AppStrings.aboutCedar,
      amenities: [
        AppStrings.amenityValet,
        AppStrings.amenityKidsFriendly,
        AppStrings.amenityPrivateDining,
      ],
      openingHours: _standardHours,
      phone: AppStrings.phoneCedar,
      menuItems: [
        MenuItemModel(
          name: AppStrings.menuCedarOne,
          description: AppStrings.menuCedarOneDesc,
          price: AppStrings.menuCedarOnePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuCedarTwo,
          description: AppStrings.menuCedarTwoDesc,
          price: AppStrings.menuCedarTwoPrice,
        ),
        MenuItemModel(
          name: AppStrings.menuCedarThree,
          description: AppStrings.menuCedarThreeDesc,
          price: AppStrings.menuCedarThreePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuCedarFour,
          description: AppStrings.menuCedarFourDesc,
          price: AppStrings.menuCedarFourPrice,
        ),
      ],
      locationNote: AppStrings.locationNoteCedar,
    ),
    AppStrings.restaurantIdSix: const RestaurantDetailModel(
      restaurantId: AppStrings.restaurantIdSix,
      rating: AppStrings.ratingAmber,
      locationBlurb: AppStrings.locationBlurbAmber,
      about: AppStrings.aboutAmber,
      amenities: [
        AppStrings.amenityRooftop,
        AppStrings.amenityValet,
        AppStrings.amenityWineCellar,
      ],
      openingHours: _eveningHours,
      phone: AppStrings.phoneAmber,
      menuItems: [
        MenuItemModel(
          name: AppStrings.menuAmberOne,
          description: AppStrings.menuAmberOneDesc,
          price: AppStrings.menuAmberOnePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuAmberTwo,
          description: AppStrings.menuAmberTwoDesc,
          price: AppStrings.menuAmberTwoPrice,
        ),
        MenuItemModel(
          name: AppStrings.menuAmberThree,
          description: AppStrings.menuAmberThreeDesc,
          price: AppStrings.menuAmberThreePrice,
        ),
        MenuItemModel(
          name: AppStrings.menuAmberFour,
          description: AppStrings.menuAmberFourDesc,
          price: AppStrings.menuAmberFourPrice,
        ),
      ],
      locationNote: AppStrings.locationNoteAmber,
    ),
  };
}
