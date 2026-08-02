import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_dependency.dart';
import '../controller/user_location_controller.dart';
import '../model/location_permission_state.dart';

/// Compact location status row for Home (and similar surfaces).
///
/// All actions go through [UserLocationController] — no geolocator in the view.
/// When location is still in a later progressive-init stage, paints the same
/// initial unknown-state chrome so the first Home frame never blocks on GPS.
/// Tapping Enable still registers the stack immediately (never a no-op).
class UserLocationStatusBar extends StatefulWidget {
  const UserLocationStatusBar({super.key});

  @override
  State<UserLocationStatusBar> createState() => _UserLocationStatusBarState();
}

class _UserLocationStatusBarState extends State<UserLocationStatusBar> {
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserLocationController>()) {
      return _LocationStatusRow(
        loading: false,
        status: LocationPermissionState.unknown,
        statusLabel: AppStrings.locationEnablePrompt,
        actionLabel: AppStrings.locationEnableAction,
        onPressed: _enableBeforeStackReady,
      );
    }

    final UserLocationController controller =
        Get.find<UserLocationController>();

    return Obx(() {
      final bool loading = controller.isLoading.value;
      final String? actionLabel = controller.primaryActionLabel;

      return _LocationStatusRow(
        loading: loading,
        status: controller.permissionStatus,
        statusLabel: controller.statusLabel,
        actionLabel: actionLabel,
        onPressed: loading
            ? null
            : () {
                unawaited(controller.handlePrimaryAction());
              },
      );
    });
  }

  /// Progressive Home paints this chrome before Stage 8. Enable must still
  /// register [UserLocationController] and request permission — never `() {}`.
  void _enableBeforeStackReady() {
    AppDependency.ensureLocationStack();
    if (!mounted) {
      return;
    }
    setState(() {});
    if (!Get.isRegistered<UserLocationController>()) {
      return;
    }
    unawaited(Get.find<UserLocationController>().handlePrimaryAction());
  }
}

class _LocationStatusRow extends StatelessWidget {
  const _LocationStatusRow({
    required this.loading,
    required this.status,
    required this.statusLabel,
    required this.actionLabel,
    required this.onPressed,
  });

  final bool loading;
  final LocationPermissionState status;
  final String statusLabel;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.locationStatusMinHeight,
      ),
      child: Row(
        children: [
          Icon(
            _iconFor(status, loading: loading),
            color: AppColors.primary,
            size: AppDimensions.locationStatusIconSize,
          ),
          const SizedBox(width: AppDimensions.compactSpacing),
          Expanded(
            child: loading
                ? Row(
                    children: [
                      const SizedBox(
                        width: AppDimensions.smallIconSize,
                        height: AppDimensions.smallIconSize,
                        child: CircularProgressIndicator(
                          strokeWidth:
                              AppDimensions.progressIndicatorStrokeWidth,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.compactSpacing),
                      Expanded(
                        child: Text(
                          statusLabel,
                          style: AppTextStyles.locationLabel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(
                    statusLabel,
                    style: AppTextStyles.locationLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: AppDimensions.compactSpacing),
            HoverableButton(
              child: TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  textStyle: AppTextStyles.authLinkEmphasis,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.compactHorizontalPadding,
                    vertical: AppDimensions.tinySpacing,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.authLinkEmphasis,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconFor(LocationPermissionState status, {required bool loading}) {
    if (loading) {
      return Symbols.my_location;
    }
    switch (status) {
      case LocationPermissionState.granted:
        return Symbols.location_on;
      case LocationPermissionState.serviceDisabled:
        return Symbols.location_off;
      case LocationPermissionState.denied:
      case LocationPermissionState.deniedForever:
      case LocationPermissionState.restricted:
        return Symbols.location_disabled;
      case LocationPermissionState.unknown:
        return Symbols.add_location_alt;
    }
  }
}
