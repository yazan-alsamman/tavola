import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../../core/utils/app_dependency.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../model/available_reservation_slots.dart';
import '../model/customer_reservation_model.dart';
import '../model/restaurant_table_model.dart';
import '../model/reservation_time_window.dart';

/// Customer reservation APIs:
/// - `GET /reservations/available-slots`
/// - `GET /reservations/availability`
/// - `POST /reservations`
/// - `POST /reservations/:id/cancel`
/// - `POST /reservations/:id/reschedule`
/// - `GET /reservations/my`
/// - `GET /reservations/my/upcoming`
/// - `GET /reservations/my/history`
/// - `GET /reservations/my/:reservationId`
class ReservationRepository {
  ReservationRepository(this._apiClient);

  final ApiClient _apiClient;
  static const String _pageQueryKey = AppUrls.reservationsPageQueryKey;
  static const String _pageSizeQueryKey = AppUrls.reservationsPageSizeQueryKey;
  static const String _limitQueryKey = AppUrls.reservationsLimitQueryKey;

  /// Combined in-session cache (create/cancel + last API sync).
  final RxList<CustomerReservationModel> myReservations =
      <CustomerReservationModel>[].obs;

  /// Server upcoming (`GET /reservations/my/upcoming`).
  final RxList<CustomerReservationModel> upcomingReservations =
      <CustomerReservationModel>[].obs;

  /// Server history (`GET /reservations/my/history`).
  final RxList<CustomerReservationModel> historyReservationsList =
      <CustomerReservationModel>[].obs;

  bool _serverListsHydrated = false;
  bool _historyLoaded = false;

  List<CustomerReservationModel> get activeReservations {
    if (_serverListsHydrated) {
      return upcomingReservations.toList(growable: false);
    }
    return myReservations
        .where((CustomerReservationModel item) => item.isActive)
        .toList(growable: false);
  }

  List<CustomerReservationModel> get historyReservations {
    if (_serverListsHydrated || _historyLoaded) {
      return historyReservationsList.toList(growable: false);
    }
    return myReservations
        .where((CustomerReservationModel item) => !item.isActive)
        .toList(growable: false);
  }

  /// Clears bookings when the account/session changes.
  void clearSessionState() {
    _serverListsHydrated = false;
    _historyLoaded = false;
    myReservations.clear();
    upcomingReservations.clear();
    historyReservationsList.clear();
    myReservations.refresh();
    upcomingReservations.refresh();
    historyReservationsList.refresh();
  }

  /// Search Availability — tables with `isAvailable` for the booking window.
  Future<List<RestaurantTableModel>> searchAvailability(
    ReservationTimeWindow window,
  ) async {
    await _ensureAuthenticated();
    final ApiResponse<List<RestaurantTableModel>> response = await _apiClient
        .get<List<RestaurantTableModel>>(
          AppUrls.reservationsAvailabilityPath,
          queryParameters: <String, dynamic>{
            'branchId': window.branchId,
            'reservationStartTime': window.startTimeIso,
            'reservationEndTime': window.endTimeIso,
            'partySize': window.partySize,
          },
          parseData: _parseAvailabilityTables,
        );
    return response.data;
  }

  /// `GET /reservations/available-slots`
  ///
  /// Query: `branchId`, `date` (`YYYY-MM-DD`), `partySize`, and
  /// `durationMinutes` when the reservation flow has a selected duration.
  /// The returned [AvailableReservationSlots.slots] are the only bookable
  /// windows. This method does not build or filter candidate times.
  Future<AvailableReservationSlots> fetchAvailableSlots({
    required String branchId,
    required DateTime date,
    required int partySize,
    int? durationMinutes,
  }) async {
    await _ensureAuthenticated();
    final String bid = branchId.trim();
    if (bid.isEmpty) {
      throw ApiException(message: AppStrings.reservationWindowIncomplete);
    }
    final Map<String, dynamic> query = <String, dynamic>{
      'branchId': bid,
      'date': _reservationDateQuery(date),
      'partySize': partySize,
    };
    if (durationMinutes != null) {
      query['durationMinutes'] = durationMinutes;
    }
    final ApiResponse<AvailableReservationSlots> response = await _apiClient
        .get<AvailableReservationSlots>(
          AppUrls.reservationsAvailableSlotsPath,
          queryParameters: query,
          parseData: (Object? raw) {
            try {
              return AvailableReservationSlots.parse(raw);
            } on FormatException {
              throw ApiException(message: AppStrings.reservationSlotsLoadError);
            }
          },
        );
    return response.data;
  }

  static String _reservationDateQuery(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static String _reservationInstant(DateTime? instant, String? originalIso) {
    final String? raw = originalIso?.trim();
    if (raw != null && raw.isNotEmpty) {
      return raw;
    }
    if (instant == null) {
      throw ApiException(message: AppStrings.reservationWindowIncomplete);
    }
    return instant.toUtc().toIso8601String();
  }

  /// `GET /reservations/my`
  Future<List<CustomerReservationModel>> fetchMyReservations({
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
  }) async {
    await _ensureAuthenticated();
    final ApiResponse<List<CustomerReservationModel>> response =
        await _apiClient.get<List<CustomerReservationModel>>(
          AppUrls.reservationsMyPath,
          queryParameters: <String, dynamic>{
            _pageQueryKey: page,
            _limitQueryKey: limit,
          },
          parseData: _parseReservationItems,
        );
    return response.data;
  }

  /// `GET /reservations/my/upcoming`
  Future<List<CustomerReservationModel>> fetchMyUpcoming({
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
  }) async {
    await _ensureAuthenticated();
    final ApiResponse<List<CustomerReservationModel>> response =
        await _apiClient.get<List<CustomerReservationModel>>(
          AppUrls.reservationsMyUpcomingPath,
          queryParameters: <String, dynamic>{
            _pageQueryKey: page,
            _limitQueryKey: limit,
          },
          parseData: _parseReservationItems,
        );
    final List<CustomerReservationModel> covered = await _withDiscoveryCovers(
      response.data,
    );
    upcomingReservations.assignAll(covered);
    _mergeIntoMyReservations(covered);
    return covered;
  }

  /// `GET /reservations/my/history`
  ///
  /// Every row the history endpoint returns is kept, for any status.
  /// Pages continue while a page is full, newest reservation date first.
  Future<List<CustomerReservationModel>> fetchMyHistory({
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.reservationsHistoryPageLimit,
  }) async {
    await _ensureAuthenticated();
    final int pageSize = limit < 1
        ? AppDimensions.reservationsHistoryPageLimit
        : limit;
    final List<CustomerReservationModel> collected =
        <CustomerReservationModel>[];
    final Set<String> seenIds = <String>{};
    int nextPage = page < 1 ? AppDimensions.apiDefaultPage : page;
    final int lastPage =
        nextPage + AppDimensions.reservationsHistoryMaxPages - 1;
    while (nextPage <= lastPage) {
      final ApiResponse<List<CustomerReservationModel>> response =
          await _apiClient.get<List<CustomerReservationModel>>(
            AppUrls.reservationsMyHistoryPath,
            queryParameters: <String, dynamic>{
              _pageQueryKey: nextPage,
              _limitQueryKey: pageSize,
              AppUrls.reservationsSortQueryKey:
                  AppStrings.apiReservationsSortReservationDate,
              AppUrls.reservationsOrderQueryKey:
                  AppStrings.apiReservationsOrderDesc,
            },
            parseData: _parseReservationItems,
          );
      final List<CustomerReservationModel> covered = await _withDiscoveryCovers(
        response.data,
      );
      for (final CustomerReservationModel item in covered) {
        if (seenIds.add(item.reservationId)) {
          collected.add(item);
        }
      }
      if (covered.length < pageSize) {
        break;
      }
      nextPage += 1;
    }
    historyReservationsList.assignAll(collected);
    _historyLoaded = true;
    _mergeIntoMyReservations(collected);
    return collected;
  }

  /// Loads upcoming + history for Profile tabs (parallel).
  Future<void> syncProfileReservations() async {
    await _ensureAuthenticated();
    await Future.wait<void>(<Future<void>>[
      fetchMyUpcoming(),
      fetchMyHistory(),
    ]);
    _serverListsHydrated = true;
  }

  /// `GET /reservations?page=&pageSize=` (customer list alias).
  Future<List<CustomerReservationModel>> fetchReservations({
    int page = AppDimensions.apiDefaultPage,
    int pageSize = AppDimensions.apiDefaultLimit,
  }) async {
    await _ensureAuthenticated();
    final ApiResponse<List<CustomerReservationModel>> response =
        await _apiClient.get<List<CustomerReservationModel>>(
          AppUrls.reservationsPath,
          queryParameters: <String, dynamic>{
            _pageQueryKey: page,
            _pageSizeQueryKey: pageSize,
          },
          parseData: _parseReservationItems,
        );
    return response.data;
  }

  /// `GET /reservations/my/:reservationId`
  Future<CustomerReservationModel> fetchMyReservationById(
    String reservationId,
  ) async {
    await _ensureAuthenticated();
    final String id = reservationId.trim();
    if (id.isEmpty) {
      throw ApiException(message: AppStrings.invalidReservationPayload);
    }
    final ApiResponse<CustomerReservationModel> response = await _apiClient
        .get<CustomerReservationModel>(
          AppUrls.reservationsMyDetailPath(id),
          parseData: (Object? raw) => _parseReservation(
            raw,
            restaurantName: _cachedName(id),
            imageUrl: _cachedImage(id),
          ),
        );
    _upsert(response.data);
    return response.data;
  }

  /// `GET /reservations/:reservationId` (customer detail alias).
  Future<CustomerReservationModel> fetchReservationById(
    String reservationId,
  ) async {
    await _ensureAuthenticated();
    final String id = reservationId.trim();
    if (id.isEmpty) {
      throw ApiException(message: AppStrings.invalidReservationPayload);
    }
    final ApiResponse<CustomerReservationModel> response = await _apiClient
        .get<CustomerReservationModel>(
          AppUrls.reservationsDetailPath(id),
          parseData: (Object? raw) => _parseReservation(
            raw,
            restaurantName: _cachedName(id),
            imageUrl: _cachedImage(id),
          ),
        );
    _upsert(response.data);
    return response.data;
  }

  /// Create Reservation — Confirm Reservation button.
  Future<CustomerReservationModel> createReservation({
    required String branchId,
    required String tableId,
    required DateTime startTime,
    required DateTime endTime,
    required int guests,
    int? tableCapacity,
    String? notes,
    String restaurantId = '',
    String restaurantName = '',
    String imageUrl = '',
    String? startTimeIso,
    String? endTimeIso,
  }) async {
    await _ensureAuthenticated();
    final ApiResponse<CustomerReservationModel> response = await _apiClient
        .post<CustomerReservationModel>(
          AppUrls.reservationsPath,
          data: <String, dynamic>{
            'branchId': branchId,
            'tableId': tableId,
            'reservationStartTime': _reservationInstant(
              startTime,
              startTimeIso,
            ),
            'reservationEndTime': _reservationInstant(endTime, endTimeIso),
            'guests': guests,
            if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
          },
          options: Options(
            headers: <String, dynamic>{
              AppStrings.apiIdempotencyKeyHeader: _newIdempotencyKey(),
            },
          ),
          parseData: (Object? raw) => _parseReservation(
            raw,
            restaurantName: restaurantName,
            imageUrl: imageUrl,
          ),
        );
    final CustomerReservationModel created = response.data.copyWith(
      restaurantId: restaurantId.isNotEmpty
          ? restaurantId
          : response.data.restaurantId,
      restaurantName: restaurantName.isNotEmpty
          ? restaurantName
          : response.data.restaurantName,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : response.data.imageUrl,
      guests: CustomerReservationModel.partySizeFromReservation(
        requested: guests,
        returned: response.data.guests,
        tableCapacity: tableCapacity,
      ),
    );
    _upsert(created);
    if (created.isActive) {
      _upsertInto(upcomingReservations, created);
    } else {
      _upsertInto(historyReservationsList, created);
    }
    return created;
  }

  /// `POST /reservations/:id/cancel`
  Future<CustomerReservationModel> cancelReservation({
    required String reservationId,
    String? reason,
  }) async {
    await _ensureAuthenticated();
    final ApiResponse<CustomerReservationModel> response = await _apiClient
        .post<CustomerReservationModel>(
          AppUrls.reservationsCancelPath(reservationId),
          data: <String, dynamic>{
            if (reason != null && reason.trim().isNotEmpty)
              'reason': reason.trim(),
          },
          parseData: (Object? raw) => _parseReservation(
            raw,
            restaurantName: _cachedName(reservationId),
            imageUrl: _cachedImage(reservationId),
          ),
        );
    _upsert(response.data);
    _moveToHistory(response.data);
    return response.data;
  }

  /// `POST /reservations/:id/reschedule`
  Future<CustomerReservationModel> rescheduleReservation({
    required String reservationId,
    String? tableId,
    DateTime? startTime,
    DateTime? endTime,
    int? guests,
    int? tableCapacity,
    String? startTimeIso,
    String? endTimeIso,
  }) async {
    await _ensureAuthenticated();
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tableId != null && tableId.trim().isNotEmpty) {
      data['tableId'] = tableId.trim();
    }
    if (startTime != null ||
        (startTimeIso != null && startTimeIso.trim().isNotEmpty)) {
      data['reservationStartTime'] = _reservationInstant(
        startTime,
        startTimeIso,
      );
    }
    if (endTime != null ||
        (endTimeIso != null && endTimeIso.trim().isNotEmpty)) {
      data['reservationEndTime'] = _reservationInstant(endTime, endTimeIso);
    }
    if (guests != null) {
      data['guests'] = guests;
    }
    if (data.isEmpty) {
      throw ArgumentError(AppStrings.invalidReservationPayload);
    }

    final ApiResponse<CustomerReservationModel> response = await _apiClient
        .post<CustomerReservationModel>(
          AppUrls.reservationsReschedulePath(reservationId),
          data: data,
          parseData: (Object? raw) => _parseReservation(
            raw,
            restaurantName: _cachedName(reservationId),
            imageUrl: _cachedImage(reservationId),
          ),
        );
    final int? requestedGuests = guests;
    final CustomerReservationModel rescheduled = requestedGuests == null
        ? response.data
        : response.data.copyWith(
            guests: CustomerReservationModel.partySizeFromReservation(
              requested: requestedGuests,
              returned: response.data.guests,
              tableCapacity: tableCapacity,
            ),
          );
    _upsert(rescheduled);
    if (rescheduled.isActive) {
      _upsertInto(upcomingReservations, rescheduled);
      historyReservationsList.removeWhere(
        (CustomerReservationModel item) =>
            item.reservationId == rescheduled.reservationId,
      );
      historyReservationsList.refresh();
    } else {
      _moveToHistory(rescheduled);
    }
    return rescheduled;
  }

  void _moveToHistory(CustomerReservationModel reservation) {
    upcomingReservations.removeWhere(
      (CustomerReservationModel item) =>
          item.reservationId == reservation.reservationId,
    );
    upcomingReservations.refresh();
    _upsertInto(historyReservationsList, reservation);
  }

  void _mergeIntoMyReservations(List<CustomerReservationModel> items) {
    for (final CustomerReservationModel item in items) {
      _upsert(item);
    }
  }

  void _upsert(CustomerReservationModel reservation) {
    if (reservation.reservationId.isEmpty) {
      return;
    }
    final int index = myReservations.indexWhere(
      (CustomerReservationModel item) =>
          item.reservationId == reservation.reservationId,
    );
    if (index >= 0) {
      final CustomerReservationModel previous = myReservations[index];
      myReservations[index] = reservation.copyWith(
        restaurantName: reservation.restaurantName.isNotEmpty
            ? reservation.restaurantName
            : previous.restaurantName,
        imageUrl: reservation.imageUrl.isNotEmpty
            ? reservation.imageUrl
            : previous.imageUrl,
        branchName: reservation.branchName.isNotEmpty
            ? reservation.branchName
            : previous.branchName,
      );
    } else {
      myReservations.insert(0, reservation);
    }
    myReservations.refresh();
  }

  void _upsertInto(
    RxList<CustomerReservationModel> list,
    CustomerReservationModel reservation,
  ) {
    if (reservation.reservationId.isEmpty) {
      return;
    }
    final int index = list.indexWhere(
      (CustomerReservationModel item) =>
          item.reservationId == reservation.reservationId,
    );
    if (index >= 0) {
      list[index] = reservation;
    } else {
      list.insert(0, reservation);
    }
    list.refresh();
  }

  String _cachedName(String reservationId) {
    for (final CustomerReservationModel item in myReservations) {
      if (item.reservationId == reservationId) {
        return item.restaurantName;
      }
    }
    for (final CustomerReservationModel item in upcomingReservations) {
      if (item.reservationId == reservationId) {
        return item.restaurantName;
      }
    }
    for (final CustomerReservationModel item in historyReservationsList) {
      if (item.reservationId == reservationId) {
        return item.restaurantName;
      }
    }
    return '';
  }

  String _cachedImage(String reservationId) {
    for (final CustomerReservationModel item in myReservations) {
      if (item.reservationId == reservationId) {
        return item.imageUrl;
      }
    }
    for (final CustomerReservationModel item in upcomingReservations) {
      if (item.reservationId == reservationId) {
        return item.imageUrl;
      }
    }
    for (final CustomerReservationModel item in historyReservationsList) {
      if (item.reservationId == reservationId) {
        return item.imageUrl;
      }
    }
    return '';
  }

  static List<RestaurantTableModel> _parseAvailabilityTables(Object? raw) {
    final List<dynamic> items = _extractItems(raw);
    return items
        .whereType<Map>()
        .map(
          (Map item) =>
              RestaurantTableModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((RestaurantTableModel table) => table.id.isNotEmpty)
        .toList(growable: false);
  }

  static List<CustomerReservationModel> _parseReservationItems(Object? raw) {
    final List<dynamic> items = _extractItems(raw);
    final List<CustomerReservationModel> parsed = <CustomerReservationModel>[];
    for (final dynamic item in items) {
      if (item is! Map) {
        continue;
      }
      try {
        final CustomerReservationModel model =
            CustomerReservationModel.fromJson(Map<String, dynamic>.from(item));
        if (model.reservationId.isNotEmpty) {
          parsed.add(model);
        }
      } catch (_) {
        // Skip malformed rows.
      }
    }
    return parsed;
  }

  static CustomerReservationModel _parseReservation(
    Object? raw, {
    String restaurantName = '',
    String imageUrl = '',
  }) {
    if (raw is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      if (map['reservationId'] != null || map['id'] != null) {
        final CustomerReservationModel model =
            CustomerReservationModel.fromJson(
              map,
              restaurantName: restaurantName,
              imageUrl: imageUrl,
            );
        if (model.reservationId.isNotEmpty) {
          return model;
        }
      }
      final Object? nested = map['reservation'] ?? map['item'];
      if (nested is Map) {
        final CustomerReservationModel model =
            CustomerReservationModel.fromJson(
              Map<String, dynamic>.from(nested),
              restaurantName: restaurantName,
              imageUrl: imageUrl,
            );
        if (model.reservationId.isNotEmpty) {
          return model;
        }
      }
    }
    throw ApiException(message: AppStrings.invalidReservationPayload);
  }

  static List<dynamic> _extractItems(Object? raw) {
    if (raw is Map) {
      for (final String key in const <String>[
        'items',
        'tables',
        'availability',
      ]) {
        final Object? value = raw[key];
        if (value is List) {
          return value;
        }
      }
    }
    if (raw is List) {
      return raw;
    }
    return const <dynamic>[];
  }

  static String _newIdempotencyKey() {
    final Random random = Random.secure();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < 16; i++) {
      buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  /// `restaurantImage` on `/reservations/my*` is a cover file id, not a signed
  /// URL. Last Reservations (and upcoming cards) need the public discovery cover.
  Future<List<CustomerReservationModel>> _withDiscoveryCovers(
    List<CustomerReservationModel> items,
  ) async {
    final List<int> missing = <int>[];
    for (int index = 0; index < items.length; index++) {
      if (_needsPublicCover(items[index])) {
        missing.add(index);
      }
    }
    if (missing.isEmpty) {
      return items;
    }
    if (!Get.isRegistered<DiscoveryRepository>()) {
      if (!Get.isRegistered<ApiClient>()) {
        return items;
      }
      AppDependency.ensureDiscoveryRepository();
    }
    if (!Get.isRegistered<DiscoveryRepository>()) {
      return items;
    }
    final DiscoveryRepository discovery = Get.find<DiscoveryRepository>();
    final Map<String, String> covers = <String, String>{};
    final List<CustomerReservationModel> covered =
        List<CustomerReservationModel>.of(items);
    for (final int index in missing) {
      final CustomerReservationModel item = covered[index];
      final String restaurantId = item.restaurantId.trim();
      if (!covers.containsKey(restaurantId)) {
        try {
          final discovered = await discovery.getRestaurantById(restaurantId);
          covers[restaurantId] = discovered.imageUrl.trim();
        } catch (_) {
          covers[restaurantId] = '';
        }
      }
      final String cover = covers[restaurantId] ?? '';
      if (cover.isNotEmpty) {
        covered[index] = item.copyWith(imageUrl: cover);
      }
    }
    return covered;
  }

  bool _needsPublicCover(CustomerReservationModel item) {
    if (item.restaurantId.trim().isEmpty) {
      return false;
    }
    final String url = item.imageUrl.trim();
    if (url.isEmpty) {
      return true;
    }
    final bool absolute =
        url.startsWith(AppStrings.apiHttpSchemePrefix) ||
        url.startsWith(AppStrings.apiHttpsSchemePrefix);
    if (!absolute) {
      return true;
    }
    return url.contains('${AppUrls.mediaFilesPath}/');
  }

  Future<void> _ensureAuthenticated() async {
    if (!Get.isRegistered<AuthTokenReader>()) {
      throw ApiException.authRequired();
    }
    final String? access = await Get.find<AuthTokenReader>().readAccessToken();
    if (access == null || access.trim().isEmpty) {
      throw ApiException.authRequired();
    }
  }
}
