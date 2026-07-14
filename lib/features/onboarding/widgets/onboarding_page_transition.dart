import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

class OnboardingPageTransition extends StatelessWidget {
  const OnboardingPageTransition({
    required this.index,
    required this.pageController,
    required this.child,
    super.key,
  });

  final int index;
  final PageController pageController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (BuildContext context, Widget? child) {
        double page = index.toDouble();
        if (pageController.hasClients &&
            pageController.position.hasContentDimensions) {
          page = pageController.page ?? index.toDouble();
        }

        final double delta = (page - index).clamp(-1.0, 1.0);
        final double distance = delta.abs();
        final double opacity =
            (1.0 - (distance * AppDimensions.onboardingPageFadeFactor))
                .clamp(0.0, 1.0);
        final double scale =
            1.0 - (distance * AppDimensions.onboardingPageScaleFactor);
        final double slideX = delta * AppDimensions.onboardingPageSlideX;
        final double slideY = distance * AppDimensions.onboardingPageSlideY;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(slideX, slideY),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
