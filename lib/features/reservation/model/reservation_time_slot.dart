import '../../../core/network/api_exception.dart';

/// One bookable window from `GET /reservations/available-slots`.
///
/// [startTime] and [endTime] are the parsed instants. [startTimeIso] and
/// [endTimeIso] are the original ISO-8601 strings and are what later
/// availability and create requests send back.
class ReservationTimeSlot {
  const ReservationTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.startTimeIso,
    required this.endTimeIso,
  });

  final DateTime startTime;
  final DateTime endTime;
  final String startTimeIso;
  final String endTimeIso;

  factory ReservationTimeSlot.fromJson(Map<String, dynamic> json) {
    final String? startRaw = ApiException.coerceOptionalString(
      json['startTime'],
    );
    final String? endRaw = ApiException.coerceOptionalString(json['endTime']);
    final DateTime? start = _parseInstant(startRaw);
    final DateTime? end = _parseInstant(endRaw);
    if (startRaw == null || endRaw == null || start == null || end == null) {
      throw const FormatException('Invalid reservation time slot');
    }
    return ReservationTimeSlot(
      startTime: start,
      endTime: end,
      startTimeIso: startRaw,
      endTimeIso: endRaw,
    );
  }

  /// ISO-8601 instants only. Bare clock text is not a slot.
  static DateTime? _parseInstant(String? raw) {
    if (raw == null) {
      return null;
    }
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return null;
    }
    return parsed.toUtc();
  }
}
