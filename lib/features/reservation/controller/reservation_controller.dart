import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../branches/model/branch_model.dart';
import '../../branches/repository/branch_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../model/reservation_availability_slot_model.dart';
import '../model/reservation_route_args.dart';
import '../model/reservation_time_window.dart';
import '../repository/reservation_availability_repository.dart';
import '../repository/reservation_repository.dart';
import 'select_table_controller.dart';

class ReservationController extends GetxController {
  static const int minDiners = 1;
  static const int maxDiners = 12;

  final ReservationAvailabilityRepository _availabilityRepository =
      Get.find<ReservationAvailabilityRepository>();
  final BranchRepository _branchRepository = Get.find<BranchRepository>();
  final ReservationRepository _reservationRepository =
      Get.find<ReservationRepository>();

  final RxInt dinerCount = AppDimensions.reservationDefaultDinerCount.obs;
  final RxInt selectedTimeSlotIndex = 0.obs;
  final RxInt selectedDurationIndex = 0.obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final RxString restaurantId = ''.obs;
  final RxString restaurantName = ''.obs;
  final RxString branchId = ''.obs;
  final RxnString rescheduleReservationId = RxnString();
  final RxList<ReservationAvailabilitySlotModel> availabilitySlots =
      <ReservationAvailabilitySlotModel>[].obs;
  final RxList<String> timeSlots = <String>[].obs;
  final RxList<String> durationOptions = <String>[].obs;
  final RxBool isResolvingBranch = false.obs;
  final RxBool isSearchingAvailability = false.obs;
  final RxBool isLoadingSlots = false.obs;
  final RxnString branchError = RxnString();
  final RxnString slotsError = RxnString();

  Worker? _dayWorker;
  Worker? _dinerWorker;
  Worker? _durationWorker;
  int _slotsRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    final Object? args = Get.arguments;
    if (args is ReservationRouteArgs) {
      restaurantId.value = args.restaurantId;
      restaurantName.value = args.restaurantName;
      final String? rescheduleId = args.rescheduleReservationId?.trim();
      rescheduleReservationId.value =
          (rescheduleId != null && rescheduleId.isNotEmpty)
          ? rescheduleId
          : null;
    } else if (args is RestaurantModel) {
      restaurantId.value = args.id;
      restaurantName.value = args.name;
    } else if (args is String && args.isNotEmpty) {
      restaurantName.value = args;
    } else if (restaurantName.value.isEmpty) {
      restaurantName.value = _availabilityRepository.getDefaultRestaurantName();
    }
    durationOptions.assignAll(_availabilityRepository.getDurationOptions());
    _dayWorker = ever<DateTime>(selectedDay, (_) {
      unawaited(loadAvailabilitySlots());
    });
    _dinerWorker = ever<int>(dinerCount, (_) {
      unawaited(loadAvailabilitySlots());
    });
    _durationWorker = ever<int>(selectedDurationIndex, (_) {
      unawaited(loadAvailabilitySlots());
    });
    if (restaurantId.value.isNotEmpty) {
      unawaited(_resolveBranchAndLoadSlots());
    }
  }

  @override
  void onClose() {
    _dayWorker?.dispose();
    _dinerWorker?.dispose();
    _durationWorker?.dispose();
    super.onClose();
  }

  void reloadLocalizedData() {
    if (isClosed) {
      return;
    }
    durationOptions.assignAll(_availabilityRepository.getDurationOptions());
    if (restaurantName.value.isEmpty) {
      restaurantName.value = _availabilityRepository.getDefaultRestaurantName();
    }
    _syncTimeSlotLabels();
  }

  Future<void> _resolveBranchAndLoadSlots() async {
    await ensureBranchResolved();
    await loadAvailabilitySlots();
  }

  Future<void> ensureBranchResolved() async {
    if (branchId.value.isNotEmpty || restaurantId.value.isEmpty) {
      return;
    }
    isResolvingBranch.value = true;
    branchError.value = null;
    try {
      final BranchModel? branch = await _branchRepository.resolvePrimaryBranch(
        restaurantId.value,
      );
      final String id = branch?.id.trim() ?? '';
      if (id.isEmpty) {
        branchError.value = AppStrings.tablesNoBranchAvailable;
        return;
      }
      branchId.value = id;
    } on ApiException catch (error) {
      branchError.value = error.message;
    } catch (_) {
      branchError.value = AppStrings.networkUnexpectedError;
    } finally {
      isResolvingBranch.value = false;
    }
  }

  Future<void> loadAvailabilitySlots() async {
    final String bid = branchId.value.trim();
    if (bid.isEmpty) {
      availabilitySlots.clear();
      timeSlots.clear();
      slotsError.value = null;
      isLoadingSlots.value = false;
      return;
    }

    final int requestId = ++_slotsRequestId;
    isLoadingSlots.value = true;
    slotsError.value = null;
    try {
      final List<ReservationAvailabilitySlotModel> slots =
          await _reservationRepository.fetchAvailabilitySlots(
            branchId: bid,
            date: selectedDay.value,
            partySize: dinerCount.value,
            experienceDuration: _selectedDuration(),
            labelBuilder: formatSlotLabel,
          );
      if (isClosed || requestId != _slotsRequestId) {
        return;
      }
      availabilitySlots.assignAll(slots);
      _syncTimeSlotLabels();
      if (selectedTimeSlotIndex.value >= timeSlots.length) {
        selectedTimeSlotIndex.value = 0;
      }
    } on ApiException catch (error) {
      if (isClosed || requestId != _slotsRequestId) {
        return;
      }
      availabilitySlots.clear();
      timeSlots.clear();
      slotsError.value = error.message.isNotEmpty
          ? error.message
          : AppStrings.reservationSlotsLoadError;
    } catch (_) {
      if (isClosed || requestId != _slotsRequestId) {
        return;
      }
      availabilitySlots.clear();
      timeSlots.clear();
      slotsError.value = AppStrings.reservationSlotsLoadError;
    } finally {
      if (!isClosed && requestId == _slotsRequestId) {
        isLoadingSlots.value = false;
      }
    }
  }

  void _syncTimeSlotLabels() {
    timeSlots.assignAll(
      availabilitySlots
          .map(
            (ReservationAvailabilitySlotModel slot) =>
                slot.label.trim().isNotEmpty
                ? slot.label
                : formatSlotLabel(slot.startTime),
          )
          .toList(growable: false),
    );
  }

  static String formatSlotLabel(DateTime value) {
    final DateTime local = value.toLocal();
    final int hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final String minute = local.minute.toString().padLeft(2, '0');
    final String period = local.hour >= 12
        ? AppStrings.timePeriodPm
        : AppStrings.timePeriodAm;
    return '$hour:$minute $period';
  }

  ReservationTimeWindow? buildTimeWindow() {
    final String resolvedBranchId = branchId.value.trim();
    if (resolvedBranchId.isEmpty) {
      return null;
    }
    if (availabilitySlots.isEmpty) {
      return null;
    }

    final DateTime start = _selectedStartTime();
    final DateTime end = start.add(_selectedDuration());
    return ReservationTimeWindow(
      branchId: resolvedBranchId,
      startTime: start,
      endTime: end,
      partySize: dinerCount.value,
    );
  }

  DateTime _selectedStartTime() {
    final int index = selectedTimeSlotIndex.value.clamp(
      0,
      availabilitySlots.length - 1,
    );
    return availabilitySlots[index].startTime;
  }

  Duration _selectedDuration() {
    final int index = selectedDurationIndex.value.clamp(
      0,
      AppDimensions.reservationDurationHours.length - 1,
    );
    final double hours = AppDimensions.reservationDurationHours[index];
    final int minutes = (hours * 60).round();
    return Duration(minutes: minutes);
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
    if (index < 0 || index >= timeSlots.length) {
      return;
    }
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

  Future<void> proceedToSelectTable() async {
    final AuthSessionController session = Get.find<AuthSessionController>();
    if (!await session.requireSignInForProtectedAction()) {
      Get.snackbar(AppStrings.nextSelectTable, AppStrings.authSignInRequired);
      return;
    }

    await ensureBranchResolved();
    if (availabilitySlots.isEmpty && slotsError.value == null) {
      await loadAvailabilitySlots();
    }
    if (availabilitySlots.isEmpty) {
      Get.snackbar(
        AppStrings.nextSelectTable,
        slotsError.value ?? AppStrings.reservationSlotsEmpty,
      );
      return;
    }

    final ReservationTimeWindow? window = buildTimeWindow();
    if (window == null) {
      Get.snackbar(
        AppStrings.nextSelectTable,
        branchError.value ?? AppStrings.reservationWindowIncomplete,
      );
      return;
    }

    isSearchingAvailability.value = true;
    try {
      // Prefetch Search Availability before opening Select Table.
      await _reservationRepository.searchAvailability(window);
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.nextSelectTable, error.message);
      if (error.statusCode == 401) {
        await session.requireSignInForProtectedAction();
      }
      return;
    } catch (_) {
      Get.snackbar(
        AppStrings.nextSelectTable,
        AppStrings.reservationAvailabilityFailed,
      );
      return;
    } finally {
      isSearchingAvailability.value = false;
    }

    SelectTableController.open();
  }

  static void open() {
    AppNavigation.pushOnce(AppRoutes.reservation);
  }
}
