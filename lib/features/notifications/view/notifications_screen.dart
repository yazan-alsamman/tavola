import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/circle_back_button.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controller/notifications_controller.dart';
import '../model/notification_item_model.dart';
import '../widgets/notification_list_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationsController controller =
        Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: _NotificationsHeader(controller: controller),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
              ),
            );
          }

          if (controller.requiresSignIn.value) {
            return _CenteredMessage(
              message: AppStrings.notificationsSignInPrompt,
              actionLabel: AppStrings.login,
              onAction: controller.openSignIn,
            );
          }

          final String? error = controller.errorMessage.value;
          if (error != null && controller.items.isEmpty) {
            return _CenteredMessage(
              message: error,
              actionLabel: AppStrings.retry,
              onAction: controller.reload,
            );
          }

          if (controller.items.isEmpty) {
            return _CenteredMessage(
              message: AppStrings.notificationsEmpty,
              actionLabel: AppStrings.retry,
              onAction: controller.reload,
            );
          }

          return RefreshIndicator(
            onRefresh: controller.reload,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent -
                        AppDimensions.pagePadding) {
                  controller.loadMore();
                }
                return false;
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.pagePadding),
                itemCount:
                    controller.items.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppDimensions.regularSpacing),
                itemBuilder: (BuildContext context, int index) {
                  if (index >= controller.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppDimensions.pagePadding),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth:
                              AppDimensions.progressIndicatorStrokeWidth,
                        ),
                      ),
                    );
                  }
                  final NotificationItemModel item = controller.items[index];
                  return NotificationListTile(
                    item: item,
                    onTap: () => controller.markRead(item),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const _NotificationsHeader({required this.controller});

  final NotificationsController controller;

  @override
  Size get preferredSize => const Size.fromHeight(
        AppDimensions.notificationsHeaderHeightWithAction,
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool busy = controller.isMarkingAll.value;
      final bool showMarkAll = !controller.requiresSignIn.value &&
          controller.items.any((NotificationItemModel item) => !item.isRead);

      return Material(
        color: AppColors.surface,
        child: SafeArea(
          bottom: false,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: AppDimensions.cardBorderWidth,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.smallSpacing,
                AppDimensions.pagePadding,
                AppDimensions.regularSpacing,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: AppDimensions.circleBackButtonSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: CircleBackButton(onPressed: Get.back),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.circleBackButtonSize +
                                AppDimensions.smallSpacing,
                          ),
                          child: Text(
                            AppStrings.notificationsTitle.toUpperCase(),
                            style: AppTextStyles.notificationsTitle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showMarkAll) ...[
                    const SizedBox(height: AppDimensions.regularSpacing),
                    HoverableButton(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : controller.markAllRead,
                        icon: const Icon(
                          Symbols.done_all,
                          size: AppDimensions.smallIconSize,
                        ),
                        label: Text(
                          AppStrings.notificationsMarkAllRead.toUpperCase(),
                          style: AppTextStyles.authLinkEmphasis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                          side: const BorderSide(
                            color: AppColors.border,
                            width: AppDimensions.cardBorderWidth,
                          ),
                          backgroundColor: AppColors.surfaceAlt,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.regularSpacing,
                            vertical: AppDimensions.smallSpacing,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.pillRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.selectTableSubtitle,
            ),
            const SizedBox(height: AppDimensions.regularSpacing),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                textStyle: AppTextStyles.authLinkEmphasis,
              ),
              child: Text(actionLabel, style: AppTextStyles.authLinkEmphasis),
            ),
          ],
        ),
      ),
    );
  }
}
