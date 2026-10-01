import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/navigation/app_navigation.dart';
import '../../features/notifications/controller/notifications_badge_controller.dart';
import 'guest_login_button.dart';
import 'hoverable_button.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.onNotificationPressed});

  final VoidCallback? onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    // Profile HTTP is owned by Home progressive Stage 4 (and Profile tab).
    // Never kick `/users/me` from AppBar on the first Home frame — that raced
    // cuisine/occasion Discovery and caused Login→Home jank.

    // GetX forbids Obx with no observables — only wrap when locale is registered.
    if (Get.isRegistered<LocaleController>()) {
      return Obx(() {
        Get.find<LocaleController>().languageCode.value;
        return _buildAppBar();
      });
    }
    return _buildAppBar();
  }

  Widget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: AppDimensions.headerHeight,
      titleSpacing: AppDimensions.pagePadding,
      shape: const Border(
        bottom: BorderSide(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Symbols.restaurant,
            color: AppColors.primary,
            size: AppDimensions.headerLogoIconSize,
          ),
          const SizedBox(width: AppDimensions.smallSpacing),
          Text(AppStrings.splashTitle, style: AppTextStyles.headerLogo),
        ],
      ),
      actions: [
        const GuestLoginButton(),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            end: AppDimensions.pagePadding,
          ),
          child: HoverableButton(
            child: InkResponse(
              onTap: onNotificationPressed ?? _openNotifications,
              radius: AppDimensions.headerProfileSize / 2,
              child: SizedBox(
                width: AppDimensions.headerProfileSize,
                height: AppDimensions.headerProfileSize,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Symbols.notifications,
                      color: AppColors.primary,
                      size: AppDimensions.headerNotificationIconSize,
                    ),
                    if (Get.isRegistered<NotificationsBadgeController>())
                      Obx(() {
                        final int count =
                            Get.find<NotificationsBadgeController>()
                                .unreadCount
                                .value;
                        if (count <= 0) {
                          return const SizedBox.shrink();
                        }
                        final String label = count > 99
                            ? AppStrings.notificationBadgeOverflow
                            : '$count';
                        return PositionedDirectional(
                          top: AppDimensions.tinySpacing,
                          end: AppDimensions.tinySpacing,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: AppDimensions.notificationBadgeMinSize,
                              minHeight: AppDimensions.notificationBadgeMinSize,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions
                                  .notificationBadgePaddingHorizontal,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.all(
                                Radius.circular(AppDimensions.pillRadius),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              style: AppTextStyles.notificationBadge,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void _openNotifications() {
    AppNavigation.pushOnce(AppRoutes.notifications);
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.headerHeight);
}
