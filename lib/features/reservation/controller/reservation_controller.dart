import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../repository/reservation_availability_repository.dart';
import 'select_table_controller.dart';

class ReservationController extends GetxController {
  static const int minDiners = 1;
  static const int maxDiners = 12;

  final ReservationAvailabilityRepository _availabilityRepository =
      Get.find<ReservationAvailabilityRepository>();

  final RxInt dinerCount = 2.obs;
  final RxInt selectedTimeSlotIndex = 0.obs;
  final RxInt selectedDurationIndex = 0.obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final RxString restaurantName = ''.obs;
  final RxList<String> timeSlots = <String>[].obs;
  final RxList<String> durationOptions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final Object? args = Get.arguments;
    if (args is String && args.isNotEmpty) {
      restaurantName.value = args;
    } else {
      restaurantName.value =
          _availabilityRepository.getDefaultRestaurantName();
    }
    reloadLocalizedData();
  }

  void reloadLocalizedData() {
    timeSlots.assignAll(_availabilityRepository.getTimeSlots());
    durationOptions.assignAll(_availabilityRepository.getDurationOptions());
    if (restaurantName.value.isEmpty) {
      restaurantName.value =
          _availabilityRepository.getDefaultRestaurantName();
    }
  }

  void incrementDiners() {
    if (dinerCount.value < maxDiners) {
      dinerCount.value++;
    }
  }

  void decrementDiners() {
    if (dinerCount.value > minDiners) {
      dinerCount.value--;
    }
  }

  void selectTimeSlot(int index) {
    selectedTimeSlotIndex.value = index;
  }

  void selectDuration(int index) {
    selectedDurationIndex.value = index;
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  void onPageChanged(DateTime focused) {
    focusedDay.value = focused;
  }

  void proceedToSelectTable() {
    SelectTableController.open();
  }

  static void open() {
    Get.toNamed(AppRoutes.reservation);
  }
}
