import '../../../core/constants/app_strings.dart';

/// Local reservation option labels (durations). Time slots come from the API.
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

  /// Last-resort empty list — live slots load via [ReservationRepository].
  List<String> getTimeSlots() => const <String>[];

  List<String> getDurationOptions() {
    return List<String>.unmodifiable(_durationOptions);
  }

  String getDefaultRestaurantName() => '';

  static List<String> get _durationOptions => [
    AppStrings.durationOnePointFive,
    AppStrings.durationTwo,
    AppStrings.durationTwoPointFive,
  ];
}
