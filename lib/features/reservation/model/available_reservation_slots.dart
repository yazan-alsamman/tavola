import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import 'reservation_time_slot.dart';

/// `data.outcome` on `GET /reservations/available-slots`.
enum AvailableReservationSlotsOutcome {
  available,
  closed,
  noSuitableTable,
  noRemainingSlots,
}

/// `ReservationTimeSlotsResponseDto` — the inner `data` object.
///
/// [openingTime], [closingTime], and [intervalMinutes] are informational.
/// Bookable windows are only [slots].
class AvailableReservationSlots {
  const AvailableReservationSlots({
    required this.branchId,
    required this.date,
    required this.timezone,
    required this.outcome,
    required this.slots,
    this.dayOfWeek,
    this.openingTime,
    this.closingTime,
    this.intervalMinutes,
    this.durationMinutes,
  });

  final String branchId;
  final String date;
  final String timezone;
  final AvailableReservationSlotsOutcome outcome;
  final List<ReservationTimeSlot> slots;
  final int? dayOfWeek;
  final String? openingTime;
  final String? closingTime;
  final int? intervalMinutes;
  final int? durationMinutes;

  static AvailableReservationSlots parse(Object? raw) {
    if (raw is! Map) {
      throw const FormatException('Missing available reservation slots');
    }
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    final String timezone = ApiException.coerceString(json['timezone']);
    if (timezone.isEmpty) {
      throw const FormatException('Missing reservation slots timezone');
    }
    final Object? slotsRaw = json['slots'];
    if (slotsRaw is! List) {
      throw const FormatException('Missing reservation slots');
    }
    final List<ReservationTimeSlot> slots = <ReservationTimeSlot>[];
    for (final Object? entry in slotsRaw) {
      if (entry is! Map) {
        throw const FormatException('Invalid reservation time slot');
      }
      slots.add(ReservationTimeSlot.fromJson(Map<String, dynamic>.from(entry)));
    }
    return AvailableReservationSlots(
      branchId: ApiException.coerceString(json['branchId']),
      date: ApiException.coerceString(json['date']),
      timezone: timezone,
      outcome: _parseOutcome(json['outcome']),
      slots: slots,
      dayOfWeek: _optionalInt(json['dayOfWeek']),
      openingTime: ApiException.coerceOptionalString(json['openingTime']),
      closingTime: ApiException.coerceOptionalString(json['closingTime']),
      intervalMinutes: _optionalInt(json['intervalMinutes']),
      durationMinutes: _optionalInt(json['durationMinutes']),
    );
  }

  static AvailableReservationSlotsOutcome _parseOutcome(Object? raw) {
    final String value = ApiException.coerceString(raw);
    if (value == AppStrings.apiReservationSlotsOutcomeAvailable) {
      return AvailableReservationSlotsOutcome.available;
    }
    if (value == AppStrings.apiReservationSlotsOutcomeClosed) {
      return AvailableReservationSlotsOutcome.closed;
    }
    if (value == AppStrings.apiReservationSlotsOutcomeNoSuitableTable) {
      return AvailableReservationSlotsOutcome.noSuitableTable;
    }
    if (value == AppStrings.apiReservationSlotsOutcomeNoRemainingSlots) {
      return AvailableReservationSlotsOutcome.noRemainingSlots;
    }
    throw const FormatException('Unknown reservation slots outcome');
  }

  static int? _optionalInt(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim());
    }
    return null;
  }
}
