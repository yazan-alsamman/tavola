import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../controller/concierge_controller.dart';
import '../widgets/concierge_composer.dart';
import '../widgets/concierge_message_card.dart';

class ConciergeScreen extends StatelessWidget {
  const ConciergeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ConciergeController controller = Get.find<ConciergeController>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.conciergeContentMaxWidth,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.online,
                                shape: BoxShape.circle,
                              ),
                              child: SizedBox.square(
                                dimension: AppDimensions.conciergeStatusDotSize,
                              ),
                            ),
                            SizedBox(width: AppDimensions.smallSpacing),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.conciergeTitle,
                                  style: AppTextStyles.conciergeTitle,
                                ),
                                SizedBox(height: AppDimensions.tinySpacing),
                                Text(
                                  AppStrings.conciergeStatus,
                                  style: AppTextStyles.conciergeStatus,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sectionSpacing),
                        const ConciergeMessageCard(
                          message: AppStrings.conciergeGreeting,
                        ),
                        const SizedBox(height: AppDimensions.smallSpacing),
                        const ConciergeMessageCard(
                          message: AppStrings.conciergeRecommendation,
                        ),
                        const SizedBox(height: AppDimensions.sectionSpacing),
                        HoverableButton(
                          child: ElevatedButton(
                            onPressed: controller.exploreGildedOlive,
                            style: AppButtonStyles.filledHover(
                              ElevatedButton.styleFrom(
                                textStyle: AppTextStyles.conciergeAction,
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      AppDimensions.buttonHorizontalPadding,
                                  vertical: AppDimensions.buttonVerticalPadding,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.pillRadius,
                                  ),
                                ),
                              ),
                            ),
                            child: const Text(AppStrings.exploreGildedOlive),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.conciergeContentMaxWidth,
                ),
                child: ConciergeComposer(
                  controller: controller.messageController,
                  onSend: controller.sendMessage,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: ConciergeController.chatNavigationIndex,
        onTap: controller.handleBottomNavigation,
      ),
    );
  }
}
