import '../../../core/network/api_exception.dart';

/// A bookable start window validated via `GET /reservations/availability`
/// (`SearchAvailabilityQueryDto`: branchId + ISO start/end + partySize).
class ReservationAvailabilitySlotModel {
  const ReservationAvailabilitySlotModel({
    required this.startTime,
    required this.label,
    this.endTime,
  });

  final DateTime startTime;
  final DateTime? endTime;
  final String label;

  factory ReservationAvailabilitySlotModel.fromJson(
    Map<String, dynamic> json, {
    DateTime? day,
    String Function(DateTime start)? labelBuilder,
  }) {
    final DateTime? start = _readDateTime(
      json['reservationStartTime'] ??
          json['startTime'] ??
          json['windowStart'] ??
          json['start'] ??
          json['slotStart'] ??
          json['time'],
      day: day,
    );
    if (start == null) {
      throw FormatException('Missing availability slot start time');
    }
    final DateTime? end = _readDateTime(
      json['reservationEndTime'] ??
          json['endTime'] ??
          json['windowEnd'] ??
          json['end'] ??
          json['slotEnd'],
      day: day,
    );
    final String explicitLabel = _firstNonEmpty(<Object?>[
      json['label'],
      json['displayTime'],
      json['timeLabel'],
      json['displayLabel'],
    ]);
    final String label = explicitLabel.isNotEmpty
        ? explicitLabel
        : (labelBuilder?.call(start) ?? start.toIso8601String());
    return ReservationAvailabilitySlotModel(
      startTime: start,
      endTime: end,
      label: label,
    );
  }

  /// Parses flexible availability payloads into unique start times (sorted).
  static List<ReservationAvailabilitySlotModel> parseList(
    Object? data, {
    DateTime? day,
    String Function(DateTime start)? labelBuilder,
  }) {
    final List<Object?> candidates = _collectSlotEntries(data);
    final List<ReservationAvailabilitySlotModel> slots =
        <ReservationAvailabilitySlotModel>[];
    final Set<String> seenStarts = <String>{};

    for (final Object? entry in candidates) {
      ReservationAvailabilitySlotModel? slot;
      if (entry is Map) {
        try {
          slot = ReservationAvailabilitySlotModel.fromJson(
            Map<String, dynamic>.from(entry),
            day: day,
            labelBuilder: labelBuilder,
          );
        } catch (_) {
          slot = null;
        }
      } else {
        final DateTime? start = _readDateTime(entry, day: day);
        if (start != null) {
          final String label = labelBuilder?.call(start) ??
              start.toIso8601String();
          slot = ReservationAvailabilitySlotModel(
            startTime: start,
            label: label,
          );
        }
      }
      if (slot == null) {
        continue;
      }
      final String key = slot.startTime.toUtc().toIso8601String();
      if (!seenStarts.add(key)) {
        continue;
      }
      slots.add(slot);
    }

    slots.sort(
      (ReservationAvailabilitySlotModel a, ReservationAvailabilitySlotModel b) =>
          a.startTime.compareTo(b.startTime),
    );
    return slots;
  }

  static List<Object?> _collectSlotEntries(Object? data) {
    if (data == null) {
      return const <Object?>[];
    }
    if (data is List) {
      return List<Object?>.from(data);
    }
    if (data is! Map) {
      return const <Object?>[];
    }
    final Map<String, dynamic> map = Map<String, dynamic>.from(data);
    for (final String key in const <String>[
      'availableSlots',
      'slots',
      'timeSlots',
      'windows',
      'items',
      'availability',
      'results',
    ]) {
      final Object? value = map[key];
      if (value is List) {
        return _flattenNestedWindows(List<Object?>.from(value));
      }
    }
    // Single window object at root.
    if (_hasStartKey(map)) {
      return <Object?>[map];
    }
    return const <Object?>[];
  }

  static List<Object?> _flattenNestedWindows(List<Object?> raw) {
    final List<Object?> out = <Object?>[];
    for (final Object? entry in raw) {
      if (entry is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(entry);
        final Object? nested = map['windows'] ??
            map['slots'] ??
            map['availableSlots'] ??
            map['timeSlots'];
        if (nested is List) {
          out.addAll(List<Object?>.from(nested));
          continue;
        }
      }
      out.add(entry);
    }
    return out;
  }

  static bool _hasStartKey(Map<String, dynamic> map) {
    for (final String key in const <String>[
      'reservationStartTime',
      'startTime',
      'windowStart',
      'start',
      'slotStart',
      'time',
    ]) {
      if (map[key] != null) {
        return true;
      }
    }
    return false;
  }

  static DateTime? _readDateTime(Object? raw, {DateTime? day}) {
    if (raw == null) {
      return null;
    }
    if (raw is DateTime) {
      return raw;
    }
    if (raw is int) {
      // Seconds vs milliseconds epoch.
      if (raw > 9999999999) {
        return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true).toLocal();
      }
      return DateTime.fromMillisecondsSinceEpoch(raw * 1000, isUtc: true)
          .toLocal();
    }
    if (raw is num) {
      return _readDateTime(raw.toInt(), day: day);
    }
    final String text = ApiException.coerceString(raw).trim();
    if (text.isEmpty) {
      return null;
    }
    final DateTime? iso = DateTime.tryParse(text);
    if (iso != null) {
      return iso.isUtc ? iso.toLocal() : iso;
    }
    return _parseClockTime(text, day: day);
  }

  static DateTime? _parseClockTime(String text, {DateTime? day}) {
    final DateTime base = day ?? DateTime.now();
    final RegExp match = RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*([AaPp][Mm]))?$',
    );
    final Match? m = match.firstMatch(text.trim());
    if (m == null) {
      return null;
    }
    int hour = int.tryParse(m.group(1) ?? '') ?? -1;
    final int minute = int.tryParse(m.group(2) ?? '') ?? -1;
    if (hour < 0 || minute < 0 || minute > 59) {
      return null;
    }
    final String? period = m.group(3)?.toUpperCase();
    if (period != null) {
      if (hour > 12) {
        return null;
      }
      if (period == 'AM') {
        if (hour == 12) {
          hour = 0;
        }
      } else if (period == 'PM') {
        if (hour != 12) {
          hour += 12;
        }
      }
    } else if (hour > 23) {
      return null;
    }
    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  static String _firstNonEmpty(List<Object?> candidates) {
    for (final Object? raw in candidates) {
      final String value = ApiException.coerceString(raw).trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}
