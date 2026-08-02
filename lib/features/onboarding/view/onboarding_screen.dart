import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/onboarding_booking_preview_page.dart';
import '../widgets/onboarding_confirmation_preview_page.dart';
import '../widgets/onboarding_dinemate_preview_page.dart';
import '../widgets/onboarding_page_indicator.dart';
import '../widgets/onboarding_page_transition.dart';
import '../widgets/onboarding_rewards_preview_page.dart';
import '../widgets/onboarding_welcome_page.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Obx(() {
          final bool isLastPage = controller.isLastPage;
          return Column(
            children: [
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  children: [
                    OnboardingPageTransition(
                      index: 0,
                      pageController: controller.pageController,
                      child: const OnboardingWelcomePage(),
                    ),
                    OnboardingPageTransition(
                      index: 1,
                      pageController: controller.pageController,
                      child: OnboardingBookingPreviewPage(
                        pageController: controller.pageController,
                      ),
                    ),
                    OnboardingPageTransition(
                      index: 2,
                      pageController: controller.pageController,
                      child: OnboardingConfirmationPreviewPage(
                        pageController: controller.pageController,
                      ),
                    ),
                    OnboardingPageTransition(
                      index: 3,
                      pageController: controller.pageController,
                      child: OnboardingRewardsPreviewPage(
                        pageController: controller.pageController,
                      ),
                    ),
                    OnboardingPageTransition(
                      index: 4,
                      pageController: controller.pageController,
                      child: OnboardingDinematePreviewPage(
                        pageController: controller.pageController,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: isLastPage
                        ? AppDimensions.compactSpacing
                        : AppDimensions.regularSpacing,
                  ),
                  OnboardingPageIndicator(
                    currentPage: controller.currentPage.value,
                  ),
                  SizedBox(
                    height: isLastPage
                        ? AppDimensions.smallSpacing
                        : AppDimensions.sectionSpacing,
                  ),
                  if (isLastPage)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.pagePadding,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: HoverableButton(
                          child: ElevatedButton(
                            onPressed: controller.completeOnboarding,
                            style: AppButtonStyles.filledHover(
                              ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: AppColors.textLight,
                                textStyle: AppTextStyles.onboardingGetStarted,
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
                              AppStrings.onboardingGetStarted,
                              style: AppTextStyles.onboardingGetStarted,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: AppDimensions.authFieldMinHeight),
                  SizedBox(
                    height: isLastPage
                        ? AppDimensions.compactSpacing
                        : AppDimensions.pagePadding,
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
