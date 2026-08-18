import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/circle_back_button.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/active_sessions_controller.dart';
import '../model/auth_device_session_model.dart';

class ActiveSessionsScreen extends StatelessWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ActiveSessionsController controller =
        Get.find<ActiveSessionsController>();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: CircleBackButton(onPressed: Get.back),
                  ),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  Text(
                    AppStrings.manageDevices,
                    style: AppTextStyles.authScreenTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.regularSpacing),
                  Text(
                    AppStrings.manageDevicesDescription,
                    style: AppTextStyles.authInstruction,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.sessions.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
                    ),
                  );
                }

                final String? error = controller.errorMessage.value;
                if (error != null && controller.sessions.isEmpty) {
                  return _CenteredMessage(
                    message: error,
                    actionLabel: AppStrings.retry,
                    onAction: controller.loadSessions,
                  );
                }

                if (controller.sessions.isEmpty) {
                  return _CenteredMessage(
                    message: AppStrings.sessionsEmpty,
                    actionLabel: AppStrings.retry,
                    onAction: controller.loadSessions,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadSessions,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.pagePadding,
                      0,
                      AppDimensions.pagePadding,
                      AppDimensions.pagePadding,
                    ),
                    itemCount: controller.sessions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimensions.regularSpacing),
                    itemBuilder: (BuildContext context, int index) {
                      final AuthDeviceSessionModel session =
                          controller.sessions[index];
                      return _SessionCard(
                        session: session,
                        label: controller.deviceLabel(session),
                        isRevoking:
                            controller.revokingSessionId.value ==
                            session.sessionId,
                        onRevoke: () => controller.revokeSession(session),
                      );
                    },
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.pagePadding),
              child: Obx(() {
                final bool busy = controller.isLoggingOutAll.value ||
                    controller.revokingSessionId.value != null;
                final Widget button = ElevatedButton(
                  onPressed: busy ? null : controller.logOutAllDevices,
                  style: AppButtonStyles.filledHover(
                    ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.textLight,
                      textStyle: AppTextStyles.settingsItemTitle.copyWith(
                        color: AppColors.textLight,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.buttonVerticalPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                      ),
                    ),
                    idleBackground: AppColors.primaryDark,
                  ),
                  child: controller.isLoggingOutAll.value
                      ? const SizedBox(
                          width: AppDimensions.mediumIconSize,
                          height: AppDimensions.mediumIconSize,
                          child: CircularProgressIndicator(
                            strokeWidth:
                                AppDimensions.progressIndicatorStrokeWidth,
                            color: AppColors.textLight,
                          ),
                        )
                      : Text(
                          AppStrings.logOutAllDevices,
                          style: AppTextStyles.settingsItemTitle.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                );
                return SizedBox(
                  width: double.infinity,
                  child: HoverableButton(child: button),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.label,
    required this.isRevoking,
    required this.onRevoke,
  });

  final AuthDeviceSessionModel session;
  final String label;
  final bool isRevoking;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: AppColors.border,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.contentPadding,
          vertical: AppDimensions.buttonVerticalPadding,
        ),
        child: Row(
          children: [
            Icon(
              Symbols.devices,
              color: AppColors.primary,
              size: AppDimensions.settingsIconSize,
            ),
            const SizedBox(width: AppDimensions.smallSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.settingsItemTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (session.isCurrentSession) ...[
                    const SizedBox(height: AppDimensions.tinySpacing),
                    Text(
                      AppStrings.currentSessionLabel,
                      style: AppTextStyles.settingsItemBody.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ] else if (session.deviceType.trim().isNotEmpty &&
                      session.deviceName.trim().isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.tinySpacing),
                    Text(
                      session.deviceType.trim(),
                      style: AppTextStyles.settingsItemBody,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (!session.isCurrentSession) ...[
              const SizedBox(width: AppDimensions.smallSpacing),
              if (isRevoking)
                const SizedBox(
                  width: AppDimensions.mediumIconSize,
                  height: AppDimensions.mediumIconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
                  ),
                )
              else
                TextButton(
                  onPressed: onRevoke,
                  child: Text(
                    AppStrings.revokeSession,
                    style: AppTextStyles.settingsItemTitle.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
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
  final Future<void> Function() onAction;

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
              style: AppTextStyles.settingsItemBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.regularSpacing),
            HoverableButton(
              child: TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel,
                  style: AppTextStyles.settingsItemTitle.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
