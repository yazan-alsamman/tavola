import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_images.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import 'guest_login_button.dart';
import 'hoverable_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.profileImage,
    this.onNotificationPressed,
    this.onProfilePressed,
  });

  final ImageProvider<Object>? profileImage;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;

  @override
  Widget build(BuildContext context) {
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
            Icons.restaurant,
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
            onTap: onNotificationPressed,
            radius: AppDimensions.iconButtonSize / 2,
            child: const SizedBox(
              width: AppDimensions.iconButtonSize,
              height: AppDimensions.iconButtonSize,
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
                size: AppDimensions.headerNotificationIconSize,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.smallSpacing),
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.pagePadding),
          child: HoverableButton(
            child: InkResponse(
              onTap: onProfilePressed,
              radius: AppDimensions.headerProfileSize / 2,
              child: Container(
                width: AppDimensions.headerProfileSize,
                height: AppDimensions.headerProfileSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimensions.headerProfileBorderWidth,
                  ),
                  image: DecorationImage(
                    image:
                        profileImage ??
                        const AssetImage(AppImages.profileAvatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.headerHeight);
}
