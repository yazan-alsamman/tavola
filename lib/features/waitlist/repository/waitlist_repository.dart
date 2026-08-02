import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/auth_token_reader.dart';
import '../model/waitlist_entry_model.dart';
import '../model/waitlist_join_request_model.dart';

/// Customer waitlist APIs (join + cancel only).
class WaitlistRepository {
  WaitlistRepository(this._apiClient);

  final ApiClient _apiClient;

  static const String waitlistPath = '/waitlist';

  /// Last joined entry id (for cancel from the same session).
  final RxnString lastEntryId = RxnString();

  Future<WaitlistEntryModel> join(WaitlistJoinRequestModel request) async {
    await _ensureAuthenticated();
    final ApiResponse<WaitlistEntryModel> response = await _apiClient
        .post<WaitlistEntryModel>(
          waitlistPath,
          data: request.toJson(),
          parseData: _parseEntry,
        );
    lastEntryId.value = response.data.entryId;
    return response.data;
  }

  Future<void> cancel(String entryId) async {
    await _ensureAuthenticated();
    final String id = entryId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidWaitlistPayload);
    }
    await _apiClient.postNoContent('$waitlistPath/$id/cancel');
    if (lastEntryId.value == id) {
      lastEntryId.value = null;
    }
  }

  Future<void> _ensureAuthenticated() async {
    if (!Get.isRegistered<AuthTokenReader>()) {
      throw ApiException.authRequired();
    }
    final String? access = await Get.find<AuthTokenReader>().readAccessToken();
    if (access == null || access.trim().isEmpty) {
      throw ApiException.authRequired();
    }
  }

  static WaitlistEntryModel _parseEntry(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return WaitlistEntryModel.fromJson(raw);
    }
    if (raw is Map) {
      return WaitlistEntryModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw StateError(AppStrings.invalidWaitlistPayload);
  }
}
