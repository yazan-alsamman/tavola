import '../../../core/constants/app_strings.dart';

/// Provides reservation availability options (slots, durations).
class ReservationAvailabilityRepository {
  Future<List<String>> fetchTimeSlots() async {
    return getTimeSlots();
  }

  Future<List<String>> fetchDurationOptions() async {
    return getDurationOptions();
  }

  Future<String> fetchDefaultRestaurantName() async {
    return getDefaultRestaurantName();
  }

  List<String> getTimeSlots() {
    return List<String>.unmodifiable(_timeSlots);
  }

  List<String> getDurationOptions() {
    return List<String>.unmodifiable(_durationOptions);
  }

  String getDefaultRestaurantName() => AppStrings.saffronHouse;

  static List<String> get _timeSlots => [
        AppStrings.timeSlotOne,
        AppStrings.timeSlotTwo,
        AppStrings.timeSlotThree,
        AppStrings.timeSlotFour,
      ];

  static List<String> get _durationOptions => [
        AppStrings.durationOnePointFive,
        AppStrings.durationTwo,
        AppStrings.durationTwoPointFive,
      ];
}
