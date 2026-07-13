import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

class TornPaperClipper extends CustomClipper<Path> {
  const TornPaperClipper();

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double radius = AppDimensions.cardRadius;
    final double toothHeight = AppDimensions.confirmationTornToothHeight;
    final int toothCount = AppDimensions.confirmationTornToothCount;
    final double toothWidth = size.width / toothCount;
    final double tornBaseline = size.height - toothHeight;

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, tornBaseline);

    for (int index = toothCount; index >= 0; index--) {
      final double valleyX = toothWidth * index;
      final double peakX = valleyX - toothWidth / 2;

      if (index == toothCount) {
        path.lineTo(valleyX, tornBaseline);
      } else {
        path.lineTo(peakX, size.height);
        path.lineTo(valleyX, tornBaseline);
      }
    }

    path.lineTo(0, tornBaseline);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant TornPaperClipper oldClipper) => false;
}
