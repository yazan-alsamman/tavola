import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Onboarding page shell: headline and hint appear first, then the preview
/// expands above while the copy settles beneath it.
class OnboardingAnimatedPageLayout extends StatefulWidget {
  const OnboardingAnimatedPageLayout({
    required this.headline,
    required this.preview,
    this.hint,
    this.headlineStyle,
    this.hintStyle,
    this.maxWidth = AppDimensions.onboardingSectionMaxWidth,
    this.contentTopOffset = 0,
    this.bottomSpacerFlex = 3,
    this.pageIndex,
    this.pageController,
    super.key,
  });

  final String headline;
  final String? hint;
  final TextStyle? headlineStyle;
  final TextStyle? hintStyle;
  final Widget preview;
  final double maxWidth;
  final double contentTopOffset;
  final int bottomSpacerFlex;
  final int? pageIndex;
  final PageController? pageController;

  @override
  State<OnboardingAnimatedPageLayout> createState() =>
      _OnboardingAnimatedPageLayoutState();
}

class _OnboardingAnimatedPageLayoutState extends State<OnboardingAnimatedPageLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _textOpacity;
  late final Animation<double> _previewSize;
  late final Animation<double> _previewOpacity;
  late final Animation<double> _spacingFactor;

  int? _lastAnimatedPage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDimensions.onboardingPageEntranceDuration,
    );

    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.14, curve: Curves.easeOut),
    );
    _previewSize = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 1.0, curve: Curves.easeInOutCubic),
    );
    _previewOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 0.88, curve: Curves.easeInOut),
    );
    _spacingFactor = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 1.0, curve: Curves.easeInOutCubic),
    );

    widget.pageController?.addListener(_handlePageScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryPlayAnimation());
  }

  void _tryPlayAnimation() {
    final PageController? controller = widget.pageController;
    final int? index = widget.pageIndex;
    if (controller == null || index == null) {
      _controller.forward();
      return;
    }
    if (!controller.hasClients) {
      return;
    }
    final double? page = controller.page;
    if (page == null || page.round() != index) {
      return;
    }
    _lastAnimatedPage = index;
    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant OnboardingAnimatedPageLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageController != widget.pageController) {
      oldWidget.pageController?.removeListener(_handlePageScroll);
      widget.pageController?.addListener(_handlePageScroll);
    }
  }

  void _handlePageScroll() {
    final PageController? controller = widget.pageController;
    final int? index = widget.pageIndex;
    if (controller == null || index == null || !controller.hasClients) {
      return;
    }

    final double? page = controller.page;
    if (page == null) {
      return;
    }

    if (page.round() == index) {
      if (_lastAnimatedPage != index) {
        _lastAnimatedPage = index;
        _controller.forward(from: 0);
      }
      return;
    }

    if (_lastAnimatedPage == index) {
      _lastAnimatedPage = null;
    }
  }

  @override
  void dispose() {
    widget.pageController?.removeListener(_handlePageScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle headlineStyle =
        widget.headlineStyle ?? AppTextStyles.onboardingBookHeadline;
    final TextStyle hintStyle =
        widget.hintStyle ?? AppTextStyles.onboardingBookHint;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePadding,
      ),
      child: Column(
        children: [
          const Spacer(flex: 2),
          if (widget.contentTopOffset > 0)
            SizedBox(height: widget.contentTopOffset),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxWidth),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizeTransition(
                        sizeFactor: _previewSize,
                        alignment: Alignment.topCenter,
                        child: FadeTransition(
                          opacity: _previewOpacity,
                          child: widget.preview,
                        ),
                      ),
                      SizedBox(
                        height: AppDimensions.regularSpacing *
                            _spacingFactor.value,
                      ),
                      FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.headline,
                              textAlign: TextAlign.center,
                              style: headlineStyle,
                            ),
                            if (widget.hint != null &&
                                widget.hint!.isNotEmpty) ...[
                              const SizedBox(
                                height: AppDimensions.smallSpacing,
                              ),
                              Text(
                                widget.hint!,
                                textAlign: TextAlign.center,
                                style: hintStyle,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Spacer(flex: widget.bottomSpacerFlex),
        ],
      ),
    );
  }
}
