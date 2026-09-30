import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Wall-clock conversion using the IANA zone name supplied by the API.
///
/// The app does not choose a zone or a fixed offset. An unknown name yields
/// null so callers can show an error instead of a guessed clock.
abstract final class BranchTimeZone {
  static bool _ready = false;

  static void ensureInitialized() {
    if (_ready) {
      return;
    }
    tzdata.initializeTimeZones();
    _ready = true;
  }

  static DateTime? wallTime(DateTime instant, String timeZoneName) {
    final String name = timeZoneName.trim();
    if (name.isEmpty) {
      return null;
    }
    ensureInitialized();
    try {
      final tz.Location location = tz.getLocation(name);
      return tz.TZDateTime.from(instant.toUtc(), location);
    } on tz.LocationNotFoundException {
      return null;
    }
  }
}
