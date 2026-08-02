import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';

class WaitlistEntryModel {
  const WaitlistEntryModel({required this.entryId, this.status});

  final String entryId;
  final String? status;

  factory WaitlistEntryModel.fromJson(Map<String, dynamic> json) {
    final String entryId = _firstNonEmpty(<Object?>[
      json['entryId'],
      json['id'],
      json['waitlistEntryId'],
    ]);
    if (entryId.isEmpty) {
      throw StateError(AppStrings.invalidWaitlistPayload);
    }
    final String status = ApiException.coerceMessage(json['status']).trim();
    return WaitlistEntryModel(
      entryId: entryId,
      status: status.isEmpty ? null : status,
    );
  }

  static String _firstNonEmpty(List<Object?> candidates) {
    for (final Object? raw in candidates) {
      final String value = ApiException.coerceMessage(raw).trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}
