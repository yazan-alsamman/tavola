import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../model/restaurant_table_model.dart';
import '../model/table_status.dart';
import '../model/reservation_confirmation_model.dart';
import '../repository/table_repository.dart';
import 'reservation_controller.dart';

class SelectTableController extends GetxController {
  final TableRepository _tableRepository = Get.find<TableRepository>();

  final RxnString selectedTableId = RxnString();
  final RxBool showConfirmation = false.obs;
  final Rxn<ReservationConfirmationModel> confirmation =
      Rxn<ReservationConfirmationModel>();
  final RxList<RestaurantTableModel> floorPlanTables =
      <RestaurantTableModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    reloadLocalizedData();
  }

  void reloadLocalizedData() {
    final String? selectedId = selectedTableId.value;
    floorPlanTables.assignAll(_tableRepository.getFloorPlan());
    if (selectedId != null) {
      selectedTableId.value = selectedId;
    }
  }

  Future<void> ensureTablesLoaded() async {
    if (floorPlanTables.isNotEmpty) {
      return;
    }
    floorPlanTables.assignAll(await _tableRepository.fetchFloorPlan());
  }

  RestaurantTableModel? get selectedTable {
    final String? id = selectedTableId.value;
    if (id == null) {
      return null;
    }

    return floorPlanTables.firstWhereOrNull((table) => table.id == id);
  }

  bool get canConfirm =>
      selectedTable != null && selectedTable!.status == TableStatus.available;

  bool get showSelectedTableDetails => selectedTable != null;

  void selectTable(RestaurantTableModel table) {
    selectedTableId.value = table.id;
  }

  String descriptionFor(RestaurantTableModel table) {
    if (table.description != null) {
      return table.description!;
    }

    switch (table.status) {
      case TableStatus.available:
        return AppStrings.availableTableDescription;
      case TableStatus.reserved:
        return AppStrings.reservedTableNote;
      case TableStatus.cleaning:
        return AppStrings.cleaningTableNote;
    }
  }

  void confirmReservation() {
    if (!canConfirm) {
      Get.snackbar(
        AppStrings.selectYourTable,
        AppStrings.selectTablePrompt,
      );
      return;
    }

    final RestaurantTableModel table = selectedTable!;
    confirmation.value = ReservationConfirmationModel(
      restaurantName: _restaurantName(),
      guestsLabel: _guestsLabel(),
      dateLabel: _dateLabel(),
      tableLabel: _tableLabel(table),
      referenceCode: _tableRepository.getConfirmationReferenceCode(),
    );
    showConfirmation.value = true;
  }

  void dismissConfirmation() {
    showConfirmation.value = false;
    confirmation.value = null;
  }

  String _restaurantName() {
    if (Get.isRegistered<ReservationController>()) {
      return Get.find<ReservationController>().restaurantName.value;
    }

    return AppStrings.saffronHouse;
  }

  String _guestsLabel() {
    if (!Get.isRegistered<ReservationController>()) {
      return '2 ${AppStrings.guestPlural}';
    }

    final int count = Get.find<ReservationController>().dinerCount.value;
    final String guestWord =
        count == 1 ? AppStrings.guestSingular : AppStrings.guestPlural;
    return '$count $guestWord';
  }

  String _dateLabel() {
    if (!Get.isRegistered<ReservationController>()) {
      return '${AppStrings.weekdayNames[5]}, 12 ${AppStrings.monthNames[6]}${AppStrings.dateTimeSeparator}${AppStrings.timeSlotTwo}';
    }

    final ReservationController reservation =
        Get.find<ReservationController>();
    final DateTime day = reservation.selectedDay.value;
    final String weekday = AppStrings.weekdayNames[day.weekday - 1];
    final String month = AppStrings.monthNames[day.month - 1];
    final String time =
        reservation.timeSlots[reservation.selectedTimeSlotIndex.value];

    return '$weekday, ${day.day} $month${AppStrings.dateTimeSeparator}$time';
  }

  String _tableLabel(RestaurantTableModel table) {
    final StringBuffer label = StringBuffer(
      '${AppStrings.tablePrefix} ${table.label}',
    );

    if (table.isWindowSeat) {
      label.write('${AppStrings.dateTimeSeparator}${AppStrings.windowSeating}');
    }

    return label.toString();
  }

  static String seatsLabel(int count) => '$count${AppStrings.seatsSuffix}';

  static String seatCountText(int count) => '$count';

  static String formatCurrentTime(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.hour >= 12
        ? AppStrings.timePeriodPm
        : AppStrings.timePeriodAm;

    return '$hour:$minute $period';
  }

  static void open() {
    Get.toNamed(AppRoutes.selectTable);
  }
}
