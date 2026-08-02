import 'package:get/get.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/auth_token_reader.dart';
import '../model/notification_item_model.dart';
import '../model/notifications_page_model.dart';

/// Customer notifications under `/notifications` (ownership-only JWT scope).
class NotificationsRepository {
  NotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  static const String notificationsPath = '/notifications';
  static const String unreadCountPath = '/notifications/unread-count';
  static const String readAllPath = '/notifications/read-all';
  static const String identityTokenPath = '/notifications/identity-token';

  /// Last successful unread badge count (shared with app-bar badge).
  final RxInt unreadCount = 0.obs;

  Future<NotificationsPageModel> fetchNotifications({
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
    bool? unread,
  }) async {
    await _ensureAuthenticated();
    final ApiResponse<List<NotificationItemModel>> response = await _apiClient
        .get<List<NotificationItemModel>>(
          notificationsPath,
          queryParameters: <String, dynamic>{
            'page': page,
            'limit': limit,
            'unread': ?unread,
          },
          parseData: NotificationsPageModel.parseItems,
        );
    return NotificationsPageModel.fromItems(
      items: response.data,
      meta: response.meta,
      requestPage: page,
      requestLimit: limit,
    );
  }

  Future<int> fetchUnreadCount() async {
    if (!await _hasAccessToken()) {
      unreadCount.value = 0;
      return 0;
    }
    final ApiResponse<int> response = await _apiClient.get<int>(
      unreadCountPath,
      parseData: _parseUnreadCount,
    );
    unreadCount.value = response.data;
    return response.data;
  }

  Future<void> markRead(String notificationId) async {
    await _ensureAuthenticated();
    final String id = notificationId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidNotificationPayload);
    }
    await _apiClient.patch<Object?>(
      '$notificationsPath/$id/read',
      parseData: (Object? raw) => raw,
    );
    if (unreadCount.value > 0) {
      unreadCount.value = unreadCount.value - 1;
    }
  }

  Future<void> markAllRead() async {
    await _ensureAuthenticated();
    await _apiClient.patch<Object?>(
      readAllPath,
      parseData: (Object? raw) => raw,
    );
    unreadCount.value = 0;
  }

  /// OneSignal identity token for future SDK wiring (repo-only in v1).
  Future<String> fetchIdentityToken() async {
    await _ensureAuthenticated();
    final ApiResponse<String> response = await _apiClient.get<String>(
      identityTokenPath,
      parseData: _parseIdentityToken,
    );
    return response.data;
  }

  Future<bool> _hasAccessToken() async {
    if (!Get.isRegistered<AuthTokenReader>()) {
      return false;
    }
    final String? access = await Get.find<AuthTokenReader>().readAccessToken();
    return access != null && access.trim().isNotEmpty;
  }

  Future<void> _ensureAuthenticated() async {
    if (!await _hasAccessToken()) {
      throw StateError(AppStrings.networkUnauthorizedError);
    }
  }

  static int _parseUnreadCount(Object? raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      final Object? count =
          map['count'] ?? map['unreadCount'] ?? map['unread'] ?? map['total'];
      if (count is int) {
        return count;
      }
      if (count is num) {
        return count.toInt();
      }
      if (count is String) {
        return int.tryParse(count.trim()) ?? 0;
      }
    }
    if (raw is String) {
      return int.tryParse(raw.trim()) ?? 0;
    }
    return 0;
  }

  static String _parseIdentityToken(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    if (raw is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      final Object? token =
          map['token'] ??
          map['identityToken'] ??
          map['onesignalToken'] ??
          map['jwt'];
      if (token is String && token.trim().isNotEmpty) {
        return token.trim();
      }
    }
    throw StateError(AppStrings.invalidNotificationPayload);
  }
}
