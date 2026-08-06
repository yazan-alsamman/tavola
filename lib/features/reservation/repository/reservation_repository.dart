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
import '../model/customer_reservation_model.dart';
import '../model/restaurant_table_model.dart';
import '../model/reservation_time_window.dart';

/// Customer reservation APIs:
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

  List<CustomerReservationModel> get activeReservations {
    if (_serverListsHydrated) {
      return upcomingReservations.toList(growable: false);
    }
    return myReservations
        .where((CustomerReservationModel item) => item.isActive)
        .toList(growable: false);
  }

  List<CustomerReservationModel> get historyReservations {
    if (_serverListsHydrated) {
      return historyReservationsList.toList(growable: false);
    }
    return myReservations
        .where((CustomerReservationModel item) => !item.isActive)
        .toList(growable: false);
  }

  /// Clears bookings when the account/session changes.
  void clearSessionState() {
    _serverListsHydrated = false;
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

  /// `GET /reservations/my`
  Future<List<CustomerReservationModel>> fetchMyReservations({
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
  }) async {
    await _ensureAuthenticated();
    final ApiResponse<List<CustomerReservationModel>> response =
        await _apiClient.get<List<CustomerReservationModel>>(
          AppUrls.reservationsMyPath,
          queryParameters: <String, dynamic>{'page': page, 'limit': limit},
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
          queryParameters: <String, dynamic>{'page': page, 'limit': limit},
          parseData: _parseReservationItems,
        );
    upcomingReservations.assignAll(response.data);
    _mergeIntoMyReservations(response.data);
    return response.data;
  }

  /// `GET /reservations/my/history`
  Future<List<CustomerReservationModel>> fetchMyHistory({
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
  }) async {
    await _ensureAuthenticated();
    final ApiResponse<List<CustomerReservationModel>> response =
        await _apiClient.get<List<CustomerReservationModel>>(
          AppUrls.reservationsMyHistoryPath,
          queryParameters: <String, dynamic>{'page': page, 'limit': limit},
          parseData: _parseReservationItems,
        );
    historyReservationsList.assignAll(response.data);
    _mergeIntoMyReservations(response.data);
    return response.data;
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

  /// Create Reservation — Confirm Reservation button.
  Future<CustomerReservationModel> createReservation({
    required String branchId,
    required String tableId,
    required DateTime startTime,
    required DateTime endTime,
    required int guests,
    String? notes,
    String restaurantId = '',
    String restaurantName = '',
    String imageUrl = '',
  }) async {
    await _ensureAuthenticated();
    final ApiResponse<CustomerReservationModel> response = await _apiClient
        .post<CustomerReservationModel>(
          AppUrls.reservationsPath,
          data: <String, dynamic>{
            'branchId': branchId,
            'tableId': tableId,
            'reservationStartTime': startTime.toUtc().toIso8601String(),
            'reservationEndTime': endTime.toUtc().toIso8601String(),
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
  }) async {
    await _ensureAuthenticated();
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tableId != null && tableId.trim().isNotEmpty) {
      data['tableId'] = tableId.trim();
    }
    if (startTime != null) {
      data['reservationStartTime'] = startTime.toUtc().toIso8601String();
    }
    if (endTime != null) {
      data['reservationEndTime'] = endTime.toUtc().toIso8601String();
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
    _upsert(response.data);
    if (response.data.isActive) {
      _upsertInto(upcomingReservations, response.data);
      historyReservationsList.removeWhere(
        (CustomerReservationModel item) =>
            item.reservationId == response.data.reservationId,
      );
      historyReservationsList.refresh();
    } else {
      _moveToHistory(response.data);
    }
    return response.data;
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
    final List<CustomerReservationModel> parsed =
        <CustomerReservationModel>[];
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
