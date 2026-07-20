import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/image_source.dart';

/// Loads an asset or network image and shows an icon when missing or broken.
class AppSafeImage extends StatelessWidget {
  const AppSafeImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.package,
    this.fallbackIcon = Icons.restaurant_rounded,
    this.fallbackIconSize = AppDimensions.imageFallbackIconSize,
    this.backgroundColor = AppColors.surfaceAlt,
    this.iconColor = AppColors.textSecondary,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? package;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    if (path.trim().isEmpty) {
      return _buildFallback();
    }

    if (path.isNetworkImage) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    return Image.asset(
      path,
      package: package,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return ColoredBox(
      color: backgroundColor,
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Icon(
            fallbackIcon,
            size: fallbackIconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
