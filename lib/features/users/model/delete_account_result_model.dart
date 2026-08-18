import '../../../core/network/api_exception.dart';

/// `DELETE /users/me` success payload (`DeleteAccountResponseDto`).
class DeleteAccountResultModel {
  const DeleteAccountResultModel({
    required this.scheduledAnonymizationAt,
    this.message = '',
  });

  final String scheduledAnonymizationAt;
  final String message;

  factory DeleteAccountResultModel.fromJson(
    Map<String, dynamic> json, {
    String message = '',
  }) {
    return DeleteAccountResultModel(
      scheduledAnonymizationAt: ApiException.coerceString(
        json['scheduledAnonymizationAt'],
      ),
      message: message.trim(),
    );
  }
}
