import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../widgets/welcome_title_shine.dart';
import 'guest_transition_screen.dart';
import 'login_transition_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isActionInFlight = false;

  bool _beginAction() {
    if (_isActionInFlight) {
      return false;
    }
    if (mounted) {
      setState(() {
        _isActionInFlight = true;
      });
    } else {
      _isActionInFlight = true;
    }
    return true;
  }

  void _endAction() {
    if (mounted) {
      setState(() {
        _isActionInFlight = false;
      });
    }
  }

  /// Navigation only — no controllers, repositories, or bindings here.
  void _openLoginTransition() {
    if (!_beginAction()) {
      return;
    }
    try {
      Get.to<void>(
        () => const LoginTransitionScreen(),
        transition: Transition.fadeIn,
        duration: AppDimensions.welcomeTransitionEnterDuration,
      );
    } finally {
      scheduleMicrotask(_endAction);
    }
  }

  /// Navigation only — no controllers, repositories, or bindings here.
  void _openGuestTransition() {
    if (!_beginAction()) {
      return;
    }
    try {
      Get.to<void>(
        () => const GuestTransitionScreen(),
        transition: Transition.fadeIn,
        duration: AppDimensions.welcomeTransitionEnterDuration,
      );
    } finally {
      scheduleMicrotask(_endAction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImages.welcomeHero,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: AppDimensions.welcomeBottomGradientHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.primaryDark22,
                    AppColors.primaryDark75,
                  ],
                  stops: [
                    AppDimensions.welcomeBottomGradientStart,
                    AppDimensions.welcomeBottomGradientMid,
                    1.0,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: const Alignment(
                AppDimensions.welcomeTitleAlignX,
                AppDimensions.welcomeTitleAlignY,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.welcomeTitleOffsetY,
                ),
                child: SizedBox(
                  width: screenWidth * AppDimensions.welcomeTitleMaxWidthFactor,
                  child: TickerMode(
                    enabled: !_isActionInFlight,
                    child: const WelcomeTitleShine(),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: AppDimensions.pagePadding,
            end: AppDimensions.pagePadding,
            bottom: AppDimensions.pagePadding + bottomPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: HoverableButton(
                    child: ElevatedButton(
                      onPressed: _openLoginTransition,
                      style: AppButtonStyles.filledHover(
                        ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.textLight,
                          textStyle: AppTextStyles.welcomeButton,
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
                      child: Text(
                        AppStrings.loginSignUp,
                        style: AppTextStyles.welcomeButton,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.regularSpacing),
                SizedBox(
                  width: double.infinity,
                  child: HoverableButton(
                    child: ElevatedButton(
                      onPressed: _openGuestTransition,
                      style: AppButtonStyles.filledHover(
                        ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primaryDark,
                          textStyle: AppTextStyles.welcomeButton,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.buttonVerticalPadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                          ),
                        ),
                        idleBackground: AppColors.accent,
                        idleForeground: AppColors.primaryDark,
                      ),
                      child: Text(
                        AppStrings.continueAsGuest,
                        style: AppTextStyles.welcomeButton,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
