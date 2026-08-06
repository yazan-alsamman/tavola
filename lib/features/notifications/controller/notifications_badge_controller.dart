import 'dart:async';

import 'package:get/get.dart';

import '../../../core/network/auth_token_reader.dart';
import '../../../core/utils/post_frame_work.dart';
import '../repository/notifications_repository.dart';

/// Permanent badge state for [CustomAppBar] unread indicator.
///
/// Refresh only after the first frame (never during build).
class NotificationsBadgeController extends GetxController {
  NotificationsBadgeController(this._repository);

  final NotificationsRepository _repository;

  RxInt get unreadCount => _repository.unreadCount;

  bool _refreshScheduled = false;

  /// Schedules a single post-frame unread-count refresh (Home/Profile entry).
  void scheduleRefresh() {
    if (_isAnonymousGuest) {
      return;
    }
    if (_refreshScheduled) {
      return;
    }
    _refreshScheduled = true;
    PostFrameWork.schedule(() {
      _refreshScheduled = false;
      if (isClosed || _isAnonymousGuest) {
        return;
      }
      unawaited(refreshUnreadCount());
    });
  }

  Future<void> refreshUnreadCount() async {
    if (_isAnonymousGuest) {
      unreadCount.value = 0;
      return;
    }
    try {
      await _repository.fetchUnreadCount();
    } catch (_) {
      // Badge stays at last known value; never block shell UI.
    }
  }

  bool get _isAnonymousGuest {
    if (Get.isRegistered<GuestModeReader>()) {
      return Get.find<GuestModeReader>().isAnonymousGuest;
    }
    return false;
  }
}
