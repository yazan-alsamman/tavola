import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import 'select_table_controller.dart';

class ReservationController extends GetxController {
  static const int minDiners = 1;
  static const int maxDiners = 12;

  final RxInt dinerCount = 2.obs;
  final RxInt selectedTimeSlotIndex = 0.obs;
  final RxInt selectedDurationIndex = 0.obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final RxString restaurantName = AppStrings.saffronHouse.obs;

  @override
  void onInit() {
    super.onInit();
    final Object? args = Get.arguments;
    if (args is String && args.isNotEmpty) {
      restaurantName.value = args;
    }
  }

  final List<String> timeSlots = const [
    AppStrings.timeSlotOne,
    AppStrings.timeSlotTwo,
    AppStrings.timeSlotThree,
    AppStrings.timeSlotFour,
  ];

  final List<String> durationOptions = const [
    AppStrings.durationOnePointFive,
    AppStrings.durationTwo,
    AppStrings.durationTwoPointFive,
  ];

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
