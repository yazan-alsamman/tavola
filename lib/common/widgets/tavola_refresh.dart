import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Branded pull-to-refresh used on every content page.
class TavolaRefresh extends StatelessWidget {
  const TavolaRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
      displacement: AppDimensions.regularSpacing,
      edgeOffset: AppDimensions.smallSpacing,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

/// Circular refresh used where a map pan would fight a pull gesture.
class TavolaRefreshButton extends StatelessWidget {
  const TavolaRefreshButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: AppDimensions.mapErrorCardElevation,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: loading ? null : onPressed,
        child: SizedBox(
          width: AppDimensions.iconButtonSize,
          height: AppDimensions.iconButtonSize,
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(AppDimensions.smallSpacing),
                  child: CircularProgressIndicator(
                    strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(Symbols.refresh, color: AppColors.primary),
        ),
      ),
    );
  }
}
