import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../model/restaurant_table_model.dart';
import '../model/table_status.dart';
import '../model/reservation_confirmation_model.dart';
import 'reservation_controller.dart';

class SelectTableController extends GetxController {
  final RxnString selectedTableId = RxnString();
  final RxBool showConfirmation = false.obs;
  final Rxn<ReservationConfirmationModel> confirmation =
      Rxn<ReservationConfirmationModel>();

  final List<RestaurantTableModel> floorPlanTables = const [
    RestaurantTableModel(
      id: AppStrings.tableIdW1,
      label: AppStrings.tableLabelW1,
      seatCount: 12,
      status: TableStatus.available,
      mapX: 228,
      mapY: 62,
      mapSize: AppDimensions.floorPlanLargeTableSize,
      description: AppStrings.availableTableDescription,
      isWindowSeat: true,
      isCategoryExample: true,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdR3,
      label: AppStrings.tableLabelR3,
      seatCount: 8,
      status: TableStatus.reserved,
      mapX: 234,
      mapY: 188,
      description: AppStrings.reservedTableNote,
      isCategoryExample: true,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdC2,
      label: AppStrings.tableLabelC2,
      seatCount: 6,
      status: TableStatus.cleaning,
      mapX: 234,
      mapY: 322,
      description: AppStrings.cleaningTableNote,
      isCategoryExample: true,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdA2,
      label: AppStrings.tableLabelA2,
      seatCount: 4,
      status: TableStatus.available,
      mapX: 158,
      mapY: 168,
      description: AppStrings.tableDescriptionA2,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdV5,
      label: AppStrings.tableLabelV5,
      seatCount: 2,
      status: TableStatus.available,
      mapX: 158,
      mapY: 252,
      description: AppStrings.tableDescriptionV5,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdB4,
      label: AppStrings.tableLabelB4,
      seatCount: 6,
      status: TableStatus.reserved,
      mapX: 348,
      mapY: 168,
      description: AppStrings.tableDescriptionB4,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdP6,
      label: AppStrings.tableLabelP6,
      seatCount: 10,
      status: TableStatus.available,
      mapX: 348,
      mapY: 252,
      description: AppStrings.tableDescriptionP6,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdM8,
      label: AppStrings.tableLabelM8,
      seatCount: 8,
      status: TableStatus.reserved,
      mapX: 448,
      mapY: 210,
      description: AppStrings.tableDescriptionM8,
    ),
    RestaurantTableModel(
      id: AppStrings.tableIdT7,
      label: AppStrings.tableLabelT7,
      seatCount: 4,
      status: TableStatus.cleaning,
      mapX: 448,
      mapY: 322,
      description: AppStrings.tableDescriptionT7,
    ),
  ];

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
      referenceCode: AppStrings.confirmationReferenceCode,
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
