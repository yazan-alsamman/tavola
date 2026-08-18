import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../repository/notifications_repository.dart';

/// Fetches and caches `GET /notifications/identity-token` after sign-in.
///
/// The OneSignal native SDK is not bundled in this customer app build; the
/// identity JWT is still retrieved so a future SDK bind (or backend push
/// registration) can consume [cachedIdentityToken] without a second round-trip.
class PushIdentityService extends GetxService {
  PushIdentityService(this._repository);

  final NotificationsRepository _repository;

  final RxnString cachedIdentityToken = RxnString();
  final RxBool isSyncing = false.obs;
  final RxnString lastError = RxnString();

  /// Best-effort sync — never throws to callers on the auth/Home path.
  Future<void> syncIdentityToken() async {
    if (isSyncing.value) {
      return;
    }
    isSyncing.value = true;
    lastError.value = null;
    try {
      final String token = await _repository.fetchIdentityToken();
      if (token.trim().isEmpty) {
        throw StateError(AppStrings.invalidNotificationPayload);
      }
      cachedIdentityToken.value = token.trim();
    } on ApiException catch (error) {
      lastError.value = error.message;
      if (kDebugMode) {
        debugPrint('[PushIdentity] sync failed: ${error.message}');
      }
    } catch (error) {
      lastError.value = AppStrings.networkUnexpectedError;
      if (kDebugMode) {
        debugPrint('[PushIdentity] sync failed: $error');
      }
    } finally {
      isSyncing.value = false;
    }
  }

  void clear() {
    cachedIdentityToken.value = null;
    lastError.value = null;
  }
}
