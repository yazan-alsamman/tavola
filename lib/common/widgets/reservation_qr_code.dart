import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Square reservation QR code using TAVOLA brand colors.
class ReservationQrCode extends StatelessWidget {
  const ReservationQrCode({
    required this.data,
    super.key,
    this.size = AppDimensions.onboardingQrCodeSize,
  });

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(AppDimensions.compactSpacing),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(
          AppDimensions.onboardingCodeFieldRadius,
        ),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: QrImageView(
        data: data,
        size: size - (AppDimensions.compactSpacing * 2),
        backgroundColor: AppColors.secondaryLight,
        eyeStyle: const QrEyeStyle(
          color: AppColors.primaryDark,
          eyeShape: QrEyeShape.square,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          color: AppColors.primaryDark,
          dataModuleShape: QrDataModuleShape.square,
        ),
      ),
    );
  }
}
