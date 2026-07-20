import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';

/// Full-screen transition shown while the app locale is updating.
class LanguageSwitchOverlay extends StatefulWidget {
  const LanguageSwitchOverlay({
    super.key,
    required this.locale,
  });

  final Locale locale;

  @override
  State<LanguageSwitchOverlay> createState() => _LanguageSwitchOverlayState();
}

class _LanguageSwitchOverlayState extends State<LanguageSwitchOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: AppDimensions.languageSwitchIntroDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(
      begin: AppDimensions.languageSwitchInitialScale,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );
    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = widget.locale.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return PopScope(
      canPop: false,
      child: Directionality(
        textDirection: textDirection,
        child: Material(
          color: AppColors.scaffold,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, AppDimensions.splashGradientCenterY),
                radius: AppDimensions.splashGradientRadius,
                colors: [AppColors.surface, AppColors.scaffold],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.contentPadding,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: AppTextStyles.languageSwitchBrand,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.sectionSpacing),
                          Container(
                            width: AppDimensions.languageSwitchIconContainerSize,
                            height: AppDimensions.languageSwitchIconContainerSize,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.border,
                                width: AppDimensions.cardBorderWidth,
                              ),
                            ),
                            child: Icon(
                              Icons.translate_rounded,
                              color: AppColors.primary,
                              size: AppDimensions.languageSwitchIconSize,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sectionSpacing),
                          Text(
                            AppStrings.languageSwitchingTitleFor(widget.locale),
                            style: AppTextStyles.languageSwitchTitle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.smallSpacing),
                          Text(
                            AppStrings.languageSwitchingSubtitleFor(
                              widget.locale,
                            ),
                            style: AppTextStyles.languageSwitchSubtitle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.sectionSpacing),
                          SizedBox(
                            width: AppDimensions.languageSwitchProgressSize,
                            height: AppDimensions.languageSwitchProgressSize,
                            child: CircularProgressIndicator(
                              strokeWidth:
                                  AppDimensions.languageSwitchProgressStroke,
                              color: AppColors.primary,
                              backgroundColor: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
