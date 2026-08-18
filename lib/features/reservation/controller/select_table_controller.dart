import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/post_frame_work.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../waitlist/model/waitlist_entry_model.dart';
import '../../waitlist/model/waitlist_join_request_model.dart';
import '../../waitlist/repository/waitlist_repository.dart';
import '../model/customer_reservation_model.dart';
import '../model/restaurant_table_model.dart';
import '../model/table_status.dart';
import '../model/reservation_confirmation_model.dart';
import '../model/reservation_time_window.dart';
import '../repository/reservation_repository.dart';
import '../repository/table_repository.dart';
import 'reservation_controller.dart';

class SelectTableController extends GetxController {
  final TableRepository _tableRepository = Get.find<TableRepository>();
  final ReservationRepository _reservationRepository =
      Get.find<ReservationRepository>();
  final WaitlistRepository _waitlistRepository = Get.find<WaitlistRepository>();

  final RxnString selectedTableId = RxnString();
  final RxBool showConfirmation = false.obs;
  final Rxn<ReservationConfirmationModel> confirmation =
      Rxn<ReservationConfirmationModel>();
  final RxList<RestaurantTableModel> floorPlanTables =
      <RestaurantTableModel>[].obs;
  final RxBool isLoadingTables = false.obs;
  final RxBool isCreatingReservation = false.obs;
  final RxBool isJoiningWaitlist = false.obs;
  final RxnString tablesError = RxnString();
  final RxnString waitlistEntryId = RxnString();

  @override
  void onInit() {
    super.onInit();
    reloadLocalizedData();
    if (floorPlanTables.isNotEmpty) {
      isLoadingTables.value = false;
    } else {
      isLoadingTables.value = true;
    }
    PostFrameWork.schedule(() {
      if (isClosed) {
        return;
      }
      unawaited(loadTables());
    });
  }

  void reloadLocalizedData() {
    if (isClosed) {
      return;
    }
    final String? selectedId = selectedTableId.value;
    floorPlanTables.assignAll(_tableRepository.getFloorPlan());
    if (selectedId != null) {
      selectedTableId.value = selectedId;
    }
  }

  Future<void> loadTables() async {
    isLoadingTables.value = true;
    tablesError.value = null;
    try {
      final List<RestaurantTableModel> tables = await _loadTablesForContext();
      floorPlanTables.assignAll(tables);
      final String? selectedId = selectedTableId.value;
      if (selectedId != null &&
          floorPlanTables.every(
            (RestaurantTableModel table) => table.id != selectedId,
          )) {
        selectedTableId.value = null;
      }
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await _recoverTablesAfterAuthFailure(error);
        return;
      }
      floorPlanTables.clear();
      tablesError.value = error.message;
    } on StateError catch (error) {
      floorPlanTables.clear();
      tablesError.value = error.message;
    } catch (_) {
      floorPlanTables.clear();
      tablesError.value = AppStrings.networkUnexpectedError;
    } finally {
      isLoadingTables.value = false;
    }
  }

  /// Availability requires auth; keep a floor-plan preview and open Login
  /// instead of a blank screen with "session expired".
  Future<void> _recoverTablesAfterAuthFailure(ApiException error) async {
    final ReservationController? reservation = _reservationOrNull();
    try {
      final List<RestaurantTableModel> fallback = await _tableRepository
          .fetchFloorPlan(restaurantId: reservation?.restaurantId.value);
      floorPlanTables.assignAll(fallback);
      tablesError.value = null;
    } catch (_) {
      floorPlanTables.clear();
      tablesError.value = error.message == AppStrings.networkUnauthorizedError
          ? AppStrings.authSignInRequired
          : error.message;
    }
    if (Get.isRegistered<AuthSessionController>()) {
      unawaited(
        Get.find<AuthSessionController>().requireSignInForProtectedAction(),
      );
    }
  }

  Future<List<RestaurantTableModel>> _loadTablesForContext() async {
    final ReservationController? reservation = _reservationOrNull();
    if (reservation == null) {
      return _tableRepository.fetchFloorPlan();
    }

    await reservation.ensureBranchResolved();
    final ReservationTimeWindow? window = reservation.buildTimeWindow();
    if (window != null) {
      final AuthSessionController? session =
          Get.isRegistered<AuthSessionController>()
          ? Get.find<AuthSessionController>()
          : null;
      // Guests (or missing Bearer) must not hit authenticated availability —
      // that threw ApiException and looked like a session crash. Show the
      // floor-plan preview; confirmReservation will open Login.
      if (session == null || !await session.hasAccessToken()) {
        return _tableRepository.fetchFloorPlan(
          restaurantId: reservation.restaurantId.value,
        );
      }
      return _reservationRepository.searchAvailability(window);
    }

    return _tableRepository.fetchFloorPlan(
      restaurantId: reservation.restaurantId.value,
    );
  }

  Future<void> ensureTablesLoaded() async {
    if (floorPlanTables.isNotEmpty || isLoadingTables.value) {
      return;
    }
    await loadTables();
  }

  RestaurantTableModel? get selectedTable {
    final String? id = selectedTableId.value;
    if (id == null) {
      return null;
    }

    return floorPlanTables.firstWhereOrNull((table) => table.id == id);
  }

  bool get canConfirm =>
      selectedTable != null &&
      selectedTable!.status == TableStatus.available &&
      !isCreatingReservation.value;

  bool get showSelectedTableDetails => selectedTable != null;

  /// Floor has no bookable tables (empty plan or every table non-available).
  bool get tablesAreFull {
    if (isLoadingTables.value || tablesError.value != null) {
      return false;
    }
    final ReservationController? reservation = _reservationOrNull();
    if (reservation == null || reservation.restaurantId.value.trim().isEmpty) {
      return false;
    }
    return floorPlanTables.isEmpty ||
        floorPlanTables.every(
          (RestaurantTableModel table) => table.status != TableStatus.available,
        );
  }

  bool get canJoinWaitlist {
    if (isJoiningWaitlist.value || isCreatingReservation.value) {
      return false;
    }
    if (canCancelWaitlist) {
      return false;
    }
    return tablesAreFull;
  }

  bool get canCancelWaitlist {
    final String? id = waitlistEntryId.value?.trim();
    return id != null && id.isNotEmpty && !isJoiningWaitlist.value;
  }

  /// Show the simple waitlist card (join or leave).
  bool get showWaitlistCard => canJoinWaitlist || canCancelWaitlist;

  void selectTable(RestaurantTableModel table) {
    selectedTableId.value = table.id;
    _refreshSelectedTableDetails(table.id);
  }

  Future<void> _refreshSelectedTableDetails(String tableId) async {
    if (_restaurantId() == null) {
      return;
    }
    try {
      final RestaurantTableModel fresh = await _tableRepository.fetchTableById(
        tableId,
      );
      final int index = floorPlanTables.indexWhere(
        (RestaurantTableModel item) => item.id == fresh.id,
      );
      if (index >= 0) {
        floorPlanTables[index] = fresh;
      }
      if (selectedTableId.value == tableId) {
        selectedTableId.value = fresh.id;
      }
    } catch (_) {
      // Keep the list snapshot if get-by-id fails.
    }
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

  Future<void> confirmReservation() async {
    if (!canConfirm) {
      Get.snackbar(AppStrings.selectYourTable, AppStrings.selectTablePrompt);
      return;
    }

    final ReservationController? reservation = _reservationOrNull();
    final RestaurantTableModel table = selectedTable!;
    final bool hasBookingContext =
        reservation != null && reservation.restaurantId.value.trim().isNotEmpty;

    if (!hasBookingContext) {
      // Onboarding / preview only — never create a real reservation.
      _showLocalConfirmation(
        table,
        AppStrings.onboardingPreviewReferenceLabel,
      );
      return;
    }

    await reservation.ensureBranchResolved();
    final ReservationTimeWindow? window = reservation.buildTimeWindow();
    if (window == null) {
      Get.snackbar(
        AppStrings.confirmReservation,
        reservation.branchError.value ?? AppStrings.reservationWindowIncomplete,
      );
      return;
    }

    isCreatingReservation.value = true;
    try {
      final AuthSessionController session = Get.find<AuthSessionController>();
      if (!await session.requireSignInForProtectedAction()) {
        Get.snackbar(
          AppStrings.confirmReservation,
          AppStrings.authSignInRequired,
        );
        return;
      }

      final String? rescheduleId = reservation.rescheduleReservationId.value
          ?.trim();
      final CustomerReservationModel created;
      if (rescheduleId != null && rescheduleId.isNotEmpty) {
        created = await _reservationRepository.rescheduleReservation(
          reservationId: rescheduleId,
          tableId: table.id,
          startTime: window.startTime,
          endTime: window.endTime,
          guests: window.partySize,
        );
      } else {
        created = await _reservationRepository.createReservation(
          branchId: window.branchId,
          tableId: table.id,
          startTime: window.startTime,
          endTime: window.endTime,
          guests: window.partySize,
          restaurantId: reservation.restaurantId.value,
          restaurantName: reservation.restaurantName.value,
        );
      }
      _showLocalConfirmation(table, created.reservationId);
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().refreshReservations();
      }
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.confirmReservation, error.message);
      if (error.statusCode == 401 &&
          Get.isRegistered<AuthSessionController>()) {
        unawaited(
          Get.find<AuthSessionController>().requireSignInForProtectedAction(),
        );
      }
    } on StateError catch (error) {
      Get.snackbar(AppStrings.confirmReservation, error.message);
    } catch (_) {
      Get.snackbar(
        AppStrings.confirmReservation,
        AppStrings.reservationCreateFailed,
      );
    } finally {
      isCreatingReservation.value = false;
    }
  }

  Future<void> joinWaitlist() async {
    if (!canJoinWaitlist) {
      return;
    }

    final AuthSessionController session = Get.find<AuthSessionController>();
    if (!await session.requireSignInForProtectedAction()) {
      Get.snackbar(AppStrings.waitlistJoin, AppStrings.authSignInRequired);
      return;
    }

    final ReservationController? reservation = _reservationOrNull();
    if (reservation == null) {
      return;
    }

    await reservation.ensureBranchResolved();
    final ReservationTimeWindow? window = reservation.buildTimeWindow();
    if (window == null) {
      Get.snackbar(
        AppStrings.waitlistJoin,
        reservation.branchError.value ?? AppStrings.reservationWindowIncomplete,
      );
      return;
    }

    isJoiningWaitlist.value = true;
    try {
      final WaitlistEntryModel entry = await _waitlistRepository.join(
        WaitlistJoinRequestModel(
          branchId: window.branchId,
          partySize: window.partySize,
          preferredDate: _formatPreferredDate(window.startTime),
          preferredTimeFrom: _formatPreferredTime(window.startTime),
          preferredTimeTo: _formatPreferredTime(window.endTime),
        ),
      );
      waitlistEntryId.value = entry.entryId;
      Get.snackbar(AppStrings.waitlistJoin, AppStrings.waitlistJoinSuccess);
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.waitlistJoin, error.message);
    } on StateError catch (error) {
      Get.snackbar(AppStrings.waitlistJoin, error.message);
    } catch (_) {
      Get.snackbar(AppStrings.waitlistJoin, AppStrings.waitlistJoinFailed);
    } finally {
      isJoiningWaitlist.value = false;
    }
  }

  Future<void> cancelWaitlist() async {
    final String? entryId = waitlistEntryId.value?.trim();
    if (entryId == null || entryId.isEmpty) {
      return;
    }
    isJoiningWaitlist.value = true;
    try {
      await _waitlistRepository.cancel(entryId);
      waitlistEntryId.value = null;
      Get.snackbar(AppStrings.waitlistCancel, AppStrings.waitlistCancelSuccess);
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.waitlistCancel, error.message);
    } on StateError catch (error) {
      Get.snackbar(AppStrings.waitlistCancel, error.message);
    } catch (_) {
      Get.snackbar(AppStrings.waitlistCancel, AppStrings.waitlistCancelFailed);
    } finally {
      isJoiningWaitlist.value = false;
    }
  }

  static String _formatPreferredDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String _formatPreferredTime(DateTime value) {
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showLocalConfirmation(
    RestaurantTableModel table,
    String referenceCode,
  ) {
    confirmation.value = ReservationConfirmationModel(
      restaurantName: _restaurantName(),
      guestsLabel: _guestsLabel(),
      dateLabel: _dateLabel(),
      tableLabel: _tableLabel(table),
      referenceCode: referenceCode,
    );
    showConfirmation.value = true;
  }

  void dismissConfirmation() {
    showConfirmation.value = false;
    confirmation.value = null;
    AppNavigation.goShell(AppRoutes.profile);
    Future<void>.delayed(Duration.zero, () {
      if (!Get.isRegistered<ProfileController>()) {
        return;
      }
      final ProfileController profile = Get.find<ProfileController>();
      if (profile.isClosed) {
        return;
      }
      profile.selectSection(ProfileController.activeReservationsSectionIndex);
      profile.refreshReservations();
    });
  }

  ReservationController? _reservationOrNull() {
    if (!Get.isRegistered<ReservationController>()) {
      return null;
    }
    return Get.find<ReservationController>();
  }

  String _restaurantName() {
    final ReservationController? reservation = _reservationOrNull();
    if (reservation != null) {
      return reservation.restaurantName.value;
    }

    return '';
  }

  String? _restaurantId() {
    final ReservationController? reservation = _reservationOrNull();
    if (reservation == null) {
      return null;
    }
    final String id = reservation.restaurantId.value;
    return id.isEmpty ? null : id;
  }

  String _guestsLabel() {
    final ReservationController? reservation = _reservationOrNull();
    if (reservation == null) {
      return '${AppDimensions.reservationDefaultDinerCount} ${AppStrings.guestPlural}';
    }

    final int count = reservation.dinerCount.value;
    final String guestWord = count == 1
        ? AppStrings.guestSingular
        : AppStrings.guestPlural;
    return '$count $guestWord';
  }

  String _dateLabel() {
    final ReservationController? reservation = _reservationOrNull();
    if (reservation == null) {
      return '${AppStrings.weekdayNames[5]}, 12 ${AppStrings.monthNames[6]}${AppStrings.dateTimeSeparator}${AppStrings.timeSlotTwo}';
    }

    final DateTime day = reservation.selectedDay.value;
    final String weekday = AppStrings.weekdayNames[day.weekday - 1];
    final String month = AppStrings.monthNames[day.month - 1];
    final String time;
    if (reservation.timeSlots.isEmpty) {
      time = '';
    } else {
      final int index = reservation.selectedTimeSlotIndex.value.clamp(
        0,
        reservation.timeSlots.length - 1,
      );
      time = reservation.timeSlots[index];
    }

    if (time.isEmpty) {
      return '$weekday, ${day.day} $month';
    }
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
    AppNavigation.pushOnce(AppRoutes.selectTable);
  }
}
