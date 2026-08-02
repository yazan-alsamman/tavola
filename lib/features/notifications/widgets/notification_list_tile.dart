import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/notification_item_model.dart';

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final NotificationItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isRead ? AppColors.surface : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.contentPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!item.isRead) ...[
                Container(
                  width: AppDimensions.notificationUnreadDotSize,
                  height: AppDimensions.notificationUnreadDotSize,
                  margin: const EdgeInsetsDirectional.only(
                    top: AppDimensions.compactSpacing,
                    end: AppDimensions.smallSpacing,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? item.body : item.title,
                      style: AppTextStyles.authLinkEmphasis,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.title.isNotEmpty && item.body.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        item.body,
                        style: AppTextStyles.selectTableSubtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
