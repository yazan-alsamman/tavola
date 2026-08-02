import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/navigation/app_navigation.dart';
import '../../features/auth/controller/auth_session_controller.dart';
import '../../features/notifications/controller/notifications_badge_controller.dart';
import '../../features/profile/controller/profile_controller.dart';
import 'app_safe_image.dart';
import 'guest_login_button.dart';
import 'hoverable_button.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.profileImagePath,
    this.onNotificationPressed,
    this.onProfilePressed,
  });

  final String? profileImagePath;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;

  @override
  Widget build(BuildContext context) {
    // Profile HTTP is owned by Home progressive Stage 4 (and Profile tab).
    // Never kick `/users/me` from AppBar on the first Home frame — that raced
    // cuisine/occasion Discovery and caused Login→Home jank.

    return Obx(() {
      if (Get.isRegistered<LocaleController>()) {
        Get.find<LocaleController>().languageCode.value;
      }
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
          HoverableButton(
            child: InkResponse(
              onTap: onNotificationPressed ?? _openNotifications,
              radius: AppDimensions.iconButtonSize / 2,
              child: SizedBox(
                width: AppDimensions.iconButtonSize,
                height: AppDimensions.iconButtonSize,
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
          const SizedBox(width: AppDimensions.smallSpacing),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: AppDimensions.pagePadding,
            ),
            child: HoverableButton(
              child: InkResponse(
                onTap: onProfilePressed ?? _openProfile,
                radius: AppDimensions.headerProfileSize / 2,
                child: Container(
                  width: AppDimensions.headerProfileSize,
                  height: AppDimensions.headerProfileSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Get.isRegistered<AuthSessionController>()
                      ? Obx(() {
                          Get.find<AuthSessionController>()
                              .observeSharedAvatarUrl();
                          return _buildProfileAvatar(profileImagePath);
                        })
                      : _buildProfileAvatar(profileImagePath),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  static Widget _buildProfileAvatar(String? profileImagePath) {
    final String imagePath = _resolveProfileImagePath(profileImagePath);
    if (imagePath.isEmpty) {
      return const Icon(
        Symbols.person,
        size: AppDimensions.headerProfileIconSize,
        color: AppColors.textLight,
      );
    }
    return AppSafeImage(
      path: imagePath,
      fit: BoxFit.cover,
      width: AppDimensions.headerProfileSize,
      height: AppDimensions.headerProfileSize,
      fallbackIcon: Symbols.person,
      fallbackIconSize: AppDimensions.headerProfileIconSize,
      backgroundColor: AppColors.primary,
      iconColor: AppColors.textLight,
    );
  }

  /// Only the user's uploaded/network avatar — never a demo asset.
  static String _resolveProfileImagePath(String? overridePath) {
    final String? override = overridePath?.trim();
    if (override != null && override.isNotEmpty) {
      return override;
    }

    // Prefer the shared session cache (survives Profile route dispose).
    if (Get.isRegistered<AuthSessionController>()) {
      final String? fromSession = Get.find<AuthSessionController>()
          .observeSharedAvatarUrl();
      if (fromSession != null && fromSession.isNotEmpty) {
        return fromSession;
      }
    }

    // Never touch a closed ProfileController — Explore / shell offAllNamed can
    // leave a stale registration briefly; reading Rx after onClose crashes.
    if (Get.isRegistered<ProfileController>()) {
      final ProfileController profile = Get.find<ProfileController>();
      if (!profile.isClosed) {
        final String? fromProfile = profile.profileAvatarUrl;
        if (fromProfile != null && fromProfile.isNotEmpty) {
          return fromProfile;
        }
      }
    }

    return '';
  }

  static void _openProfile() {
    AppNavigation.goShell(AppRoutes.profile);
  }

  static void _openNotifications() {
    AppNavigation.pushOnce(AppRoutes.notifications);
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.headerHeight);
}
