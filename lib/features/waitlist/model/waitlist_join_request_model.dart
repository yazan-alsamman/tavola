class WaitlistJoinRequestModel {
  const WaitlistJoinRequestModel({
    required this.branchId,
    required this.partySize,
    required this.preferredDate,
    required this.preferredTimeFrom,
    this.preferredTimeTo,
    this.notes,
  });

  final String branchId;
  final int partySize;

  /// `YYYY-MM-DD`
  final String preferredDate;

  /// `HH:mm` (24h)
  final String preferredTimeFrom;
  final String? preferredTimeTo;
  final String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'branchId': branchId,
      'partySize': partySize,
      'preferredDate': preferredDate,
      'preferredTimeFrom': preferredTimeFrom,
      if (preferredTimeTo != null && preferredTimeTo!.trim().isNotEmpty)
        'preferredTimeTo': preferredTimeTo!.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}
