import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../../core/utils/post_frame_work.dart';
import '../model/notification_item_model.dart';
import '../model/notifications_page_model.dart';
import '../repository/notifications_repository.dart';

/// Inbox screen controller: list, pagination, mark-read actions.
class NotificationsController extends GetxController {
  final NotificationsRepository _repository =
      Get.find<NotificationsRepository>();

  final RxList<NotificationItemModel> items = <NotificationItemModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isMarkingAll = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool requiresSignIn = false.obs;
  final RxBool hasMore = false.obs;

  int _page = AppDimensions.apiDefaultPage;
  bool _postFrameLoadsStarted = false;

  @override
  void onInit() {
    super.onInit();
    PostFrameWork.schedule(() {
      if (isClosed || _postFrameLoadsStarted) {
        return;
      }
      _postFrameLoadsStarted = true;
      unawaited(reload());
    });
  }

  Future<void> reload() async {
    isLoading.value = true;
    errorMessage.value = null;
    requiresSignIn.value = false;
    try {
      if (!await _hasAccessToken()) {
        items.clear();
        hasMore.value = false;
        requiresSignIn.value = true;
        return;
      }
      final NotificationsPageModel page = await _repository.fetchNotifications(
        page: AppDimensions.apiDefaultPage,
      );
      _page = page.page;
      items.assignAll(page.items);
      hasMore.value = page.hasMore;
      unawaited(_repository.fetchUnreadCount());
    } on ApiException catch (error) {
      items.clear();
      hasMore.value = false;
      errorMessage.value = error.message;
    } on StateError catch (error) {
      items.clear();
      hasMore.value = false;
      if (error.message == AppStrings.networkUnauthorizedError) {
        requiresSignIn.value = true;
      } else {
        errorMessage.value = error.message;
      }
    } catch (_) {
      items.clear();
      hasMore.value = false;
      errorMessage.value = AppStrings.networkUnexpectedError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value ||
        isLoadingMore.value ||
        !hasMore.value ||
        requiresSignIn.value) {
      return;
    }
    isLoadingMore.value = true;
    try {
      final int nextPage = _page + 1;
      final NotificationsPageModel page = await _repository.fetchNotifications(
        page: nextPage,
      );
      _page = page.page;
      items.addAll(page.items);
      hasMore.value = page.hasMore;
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.notificationsTitle, error.message);
    } catch (_) {
      Get.snackbar(
        AppStrings.notificationsTitle,
        AppStrings.networkUnexpectedError,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> markRead(NotificationItemModel item) async {
    if (item.isRead) {
      return;
    }
    final int index = items.indexWhere(
      (NotificationItemModel row) => row.id == item.id,
    );
    if (index >= 0) {
      items[index] = item.copyWith(isRead: true);
    }
    try {
      await _repository.markRead(item.id);
    } on ApiException catch (error) {
      if (index >= 0) {
        items[index] = item;
      }
      Get.snackbar(AppStrings.notificationsTitle, error.message);
    } catch (_) {
      if (index >= 0) {
        items[index] = item;
      }
      Get.snackbar(
        AppStrings.notificationsTitle,
        AppStrings.networkUnexpectedError,
      );
    }
  }

  Future<void> markAllRead() async {
    if (isMarkingAll.value ||
        items.every((NotificationItemModel i) => i.isRead)) {
      return;
    }
    isMarkingAll.value = true;
    final List<NotificationItemModel> snapshot =
        List<NotificationItemModel>.from(items);
    items.assignAll(
      items
          .map((NotificationItemModel item) => item.copyWith(isRead: true))
          .toList(growable: false),
    );
    try {
      await _repository.markAllRead();
    } on ApiException catch (error) {
      items.assignAll(snapshot);
      Get.snackbar(AppStrings.notificationsTitle, error.message);
    } catch (_) {
      items.assignAll(snapshot);
      Get.snackbar(
        AppStrings.notificationsTitle,
        AppStrings.networkUnexpectedError,
      );
    } finally {
      isMarkingAll.value = false;
    }
  }

  void openSignIn() {
    AppNavigation.pushOnce(AppRoutes.login);
  }

  Future<bool> _hasAccessToken() async {
    if (!Get.isRegistered<AuthTokenReader>()) {
      return false;
    }
    final String? access = await Get.find<AuthTokenReader>().readAccessToken();
    return access != null && access.trim().isNotEmpty;
  }
}
