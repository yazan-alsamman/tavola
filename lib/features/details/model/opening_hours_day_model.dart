/// One day row for the Details Hours card (display data only).
class OpeningHoursDayModel {
  const OpeningHoursDayModel({required this.day, required this.hours});

  final String day;
  final String hours;

  factory OpeningHoursDayModel.fromWorkingHoursEntry(
    Map<String, dynamic> json, {
    required String Function(int dayOfWeek) dayLabel,
    required String closedLabel,
  }) {
    final int dayOfWeek = _coerceDayOfWeek(json['dayOfWeek']);
    final String opening = (json['openingTime']?.toString() ?? '').trim();
    final String closing = (json['closingTime']?.toString() ?? '').trim();
    final String hours;
    if (opening.isEmpty || closing.isEmpty) {
      hours = closedLabel;
    } else {
      hours = '$opening – $closing';
    }
    return OpeningHoursDayModel(
      day: dayLabel(dayOfWeek < 0 ? 0 : dayOfWeek),
      hours: hours,
    );
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
}
