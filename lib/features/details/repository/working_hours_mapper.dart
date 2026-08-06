import '../model/opening_hours_day_model.dart';

/// Maps API working-hours payloads into UI labels / open-now state.
///
/// Repository-layer helper — keeps [OpeningHoursDayModel] as pure data
/// (MVC: models represent data only).
class WorkingHoursMapper {
  WorkingHoursMapper._();

  /// Full week (0=Sunday … 6=Saturday) for Details HOURS UI.
  /// Missing days render as [closedLabel].
  static List<OpeningHoursDayModel> weekFromPayload(
    Object? raw, {
    required String Function(int dayOfWeek) dayLabel,
    required String closedLabel,
  }) {
    final Map<int, Map<String, dynamic>> byDay = _entriesByDay(raw);

    return List<OpeningHoursDayModel>.generate(7, (int dayOfWeek) {
      final Map<String, dynamic>? entry = byDay[dayOfWeek];
      if (entry == null) {
        return OpeningHoursDayModel(
          day: dayLabel(dayOfWeek),
          hours: closedLabel,
        );
      }
      return OpeningHoursDayModel.fromWorkingHoursEntry(
        entry,
        dayLabel: dayLabel,
        closedLabel: closedLabel,
      );
    });
  }

  /// Today's hours label (`Closed` when missing).
  static String todayHoursLabel(
    Object? raw, {
    required String closedLabel,
    DateTime? now,
  }) {
    final DateTime moment = now ?? DateTime.now();
    final Map<String, dynamic>? entry = _entriesByDay(
      raw,
    )[_apiDayOfWeek(moment)];
    if (entry == null) {
      return closedLabel;
    }
    final String opening = (entry['openingTime']?.toString() ?? '').trim();
    final String closing = (entry['closingTime']?.toString() ?? '').trim();
    if (opening.isEmpty || closing.isEmpty) {
      return closedLabel;
    }
    return '$opening – $closing';
  }

  /// Whether [now] falls inside today's opening/closing window.
  static bool isOpenNow(Object? raw, {DateTime? now}) {
    final DateTime moment = now ?? DateTime.now();
    final Map<String, dynamic>? entry = _entriesByDay(
      raw,
    )[_apiDayOfWeek(moment)];
    if (entry == null) {
      return false;
    }
    final Duration? opening = _parseClock(
      (entry['openingTime']?.toString() ?? '').trim(),
    );
    final Duration? closing = _parseClock(
      (entry['closingTime']?.toString() ?? '').trim(),
    );
    if (opening == null || closing == null) {
      return false;
    }
    final Duration current = Duration(
      hours: moment.hour,
      minutes: moment.minute,
      seconds: moment.second,
    );
    if (closing >= opening) {
      return current >= opening && current < closing;
    }
    // Overnight window (e.g. 18:00 – 02:00).
    return current >= opening || current < closing;
  }

  /// API `dayOfWeek`: 0 = Sunday … 6 = Saturday.
  static int _apiDayOfWeek(DateTime moment) => moment.weekday % 7;

  static Map<int, Map<String, dynamic>> _entriesByDay(Object? raw) {
    final Map<int, Map<String, dynamic>> byDay = <int, Map<String, dynamic>>{};
    for (final dynamic item in _extractEntries(raw)) {
      if (item is! Map) {
        continue;
      }
      final Map<String, dynamic> entry = Map<String, dynamic>.from(item);
      final int dayOfWeek = _coerceDayOfWeek(entry['dayOfWeek']);
      if (dayOfWeek < 0 || dayOfWeek > 6) {
        continue;
      }
      byDay[dayOfWeek] = entry;
    }
    return byDay;
  }

  static int _coerceDayOfWeek(Object? raw) {
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim()) ?? -1;
    }
    return -1;
  }

  static Duration? _parseClock(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final List<String> parts = value.split(':');
    if (parts.length < 2) {
      return null;
    }
    final int? hours = int.tryParse(parts[0]);
    final int? minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) {
      return null;
    }
    final int seconds = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  static List<dynamic> _extractEntries(Object? raw) {
    if (raw is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      for (final String key in const <String>['entries', 'items', 'hours']) {
        final Object? value = map[key];
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
}
