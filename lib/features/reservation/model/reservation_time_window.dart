class ReservationTimeWindow {
  const ReservationTimeWindow({
    required this.branchId,
    required this.startTime,
    required this.endTime,
    required this.partySize,
    this.originalStartTimeIso,
    this.originalEndTimeIso,
  });

  final String branchId;
  final DateTime startTime;
  final DateTime endTime;
  final int partySize;

  /// Exact `startTime` string from available-slots, when this window is one.
  final String? originalStartTimeIso;

  /// Exact `endTime` string from available-slots, when this window is one.
  final String? originalEndTimeIso;

  /// Value sent as `reservationStartTime`. Prefers the original API string.
  String get startTimeIso {
    final String? raw = originalStartTimeIso?.trim();
    if (raw != null && raw.isNotEmpty) {
      return raw;
    }
    return startTime.toUtc().toIso8601String();
  }

  /// Value sent as `reservationEndTime`. Prefers the original API string.
  String get endTimeIso {
    final String? raw = originalEndTimeIso?.trim();
    if (raw != null && raw.isNotEmpty) {
      return raw;
    }
    return endTime.toUtc().toIso8601String();
  }
}
