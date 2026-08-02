class ReservationTimeWindow {
  const ReservationTimeWindow({
    required this.branchId,
    required this.startTime,
    required this.endTime,
    required this.partySize,
  });

  final String branchId;
  final DateTime startTime;
  final DateTime endTime;
  final int partySize;

  String get startTimeIso => startTime.toUtc().toIso8601String();

  String get endTimeIso => endTime.toUtc().toIso8601String();
}
