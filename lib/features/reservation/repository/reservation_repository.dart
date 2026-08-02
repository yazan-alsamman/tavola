import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
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
///
/// There is no customer “list my reservations” endpoint yet, so bookings created
/// in-session are kept in [myReservations] for Profile cancel/reschedule UI.
class ReservationRepository {
  ReservationRepository(this._apiClient);

  final ApiClient _apiClient;

  static const String _reservationsPath = '/reservations';
  static const String _availabilityPath = '/reservations/availability';

  final RxList<CustomerReservationModel> myReservations =
      <CustomerReservationModel>[].obs;

  List<CustomerReservationModel> get activeReservations => myReservations
      .where((CustomerReservationModel item) => item.isActive)
      .toList(growable: false);

  List<CustomerReservationModel> get historyReservations => myReservations
      .where((CustomerReservationModel item) => !item.isActive)
      .toList(growable: false);

  /// Clears in-session bookings when the account/session changes.
  ///
  /// There is no customer list endpoint yet — Profile only shows bookings
  /// created in this process, so a prior account must never leak into the next.
  void clearSessionState() {
    myReservations.clear();
    myReservations.refresh();
  }

  /// Search Availability — tables with `isAvailable` for the booking window.
  Future<List<RestaurantTableModel>> searchAvailability(
    ReservationTimeWindow window,
  ) async {
    await _ensureAuthenticated();
    final ApiResponse<List<RestaurantTableModel>> response = await _apiClient
        .get<List<RestaurantTableModel>>(
          _availabilityPath,
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
          _reservationsPath,
          data: <String, dynamic>{
            'branchId': branchId,
            'tableId': tableId,
            'reservationStartTime': startTime.toUtc().toIso8601String(),
            'reservationEndTime': endTime.toUtc().toIso8601String(),
            'guests': guests,
            if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
          },
          options: Options(
            headers: <String, dynamic>{'Idempotency-Key': _newIdempotencyKey()},
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
          '$_reservationsPath/$reservationId/cancel',
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
          '$_reservationsPath/$reservationId/reschedule',
          data: data,
          parseData: (Object? raw) => _parseReservation(
            raw,
            restaurantName: _cachedName(reservationId),
            imageUrl: _cachedImage(reservationId),
          ),
        );
    _upsert(response.data);
    return response.data;
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
      );
    } else {
      myReservations.insert(0, reservation);
    }
    myReservations.refresh();
  }

  String _cachedName(String reservationId) {
    for (final CustomerReservationModel item in myReservations) {
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
    return '';
  }

  static List<RestaurantTableModel> _parseAvailabilityTables(Object? raw) {
    final List<dynamic> items = _extractItems(raw);
    return items
        .whereType<Map<String, dynamic>>()
        .map(RestaurantTableModel.fromJson)
        .where((RestaurantTableModel table) => table.id.isNotEmpty)
        .toList(growable: false);
  }

  static CustomerReservationModel _parseReservation(
    Object? raw, {
    String restaurantName = '',
    String imageUrl = '',
  }) {
    if (raw is Map<String, dynamic>) {
      if (raw['reservationId'] != null || raw['id'] != null) {
        final CustomerReservationModel model =
            CustomerReservationModel.fromJson(
              raw,
              restaurantName: restaurantName,
              imageUrl: imageUrl,
            );
        if (model.reservationId.isNotEmpty) {
          return model;
        }
      }
      final Object? nested = raw['reservation'] ?? raw['item'];
      if (nested is Map<String, dynamic>) {
        final CustomerReservationModel model =
            CustomerReservationModel.fromJson(
              nested,
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
    if (raw is Map<String, dynamic>) {
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
