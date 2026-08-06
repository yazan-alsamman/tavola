import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/bottom_nav_bar.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../../core/utils/app_dependency.dart';
import '../controller/concierge_controller.dart';
import '../model/conversation_message_model.dart';
import '../model/conversation_model.dart';
import '../widgets/concierge_composer.dart';
import '../widgets/concierge_message_card.dart';
import '../widgets/concierge_start_conversation_sheet.dart';

class ConciergeScreen extends StatelessWidget {
  const ConciergeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ConciergeController controller = Get.isRegistered<ConciergeController>()
        ? Get.find<ConciergeController>()
        : AppDependency.putPermanentIfAbsent(ConciergeController.new);
    final bool isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      resizeToAvoidBottomInset: true,
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
                  child: Obx(() {
                    if (controller.isLoadingConversations.value &&
                        controller.conversations.isEmpty &&
                        controller.activeConversation.value == null) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth:
                              AppDimensions.progressIndicatorStrokeWidth,
                        ),
                      );
                    }

                    if (controller.requiresSignIn.value) {
                      return _CenteredMessage(
                        message: AppStrings.conversationsSignInPrompt,
                        actionLabel: AppStrings.login,
                        onAction: controller.openSignIn,
                      );
                    }

                    final String? error = controller.errorMessage.value;
                    if (error != null &&
                        controller.conversations.isEmpty &&
                        controller.messages.isEmpty) {
                      return _CenteredMessage(
                        message: error,
                        actionLabel: AppStrings.retry,
                        onAction: controller.reload,
                      );
                    }

                    if (controller.showConversationList.value ||
                        controller.activeConversation.value == null) {
                      return _ConversationsListBody(controller: controller);
                    }

                    return _ConversationThreadBody(controller: controller);
                  }),
                ),
              ),
            ),
            Obx(() {
              final ConversationModel? active =
                  controller.activeConversation.value;
              final bool inThread =
                  !controller.requiresSignIn.value &&
                  active != null &&
                  !controller.showConversationList.value;

              if (!inThread) {
                return const SizedBox.shrink();
              }

              if (active.isClosed) {
                return _ClosedConversationFooter(
                  onChatAnother: () => ConciergeStartConversationSheet.open(
                    controller,
                    excludeRestaurantId: active.restaurantId,
                  ),
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.conciergeContentMaxWidth,
                  ),
                  child: ConciergeComposer(
                    controller: controller.messageController,
                    enabled: !controller.isSending.value,
                    onSend: controller.isSending.value
                        ? () {}
                        : controller.sendMessage,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: isKeyboardOpen
          ? null
          : BottomNavBar(
              currentIndex: ConciergeController.chatNavigationIndex,
              onTap: controller.handleBottomNavigation,
            ),
    );
  }
}

class _ConversationsListBody extends StatelessWidget {
  const _ConversationsListBody({required this.controller});

  final ConciergeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ConciergeBrandHeader(),
          const SizedBox(height: AppDimensions.sectionSpacing),
          Expanded(
            child: Obx(() {
              if (controller.conversations.isEmpty) {
                return _CenteredMessage(
                  message: AppStrings.conversationsEmpty,
                  actionLabel: AppStrings.conversationsStartNew,
                  onAction: () =>
                      ConciergeStartConversationSheet.open(controller),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.reload,
                child: ListView.separated(
                  itemCount: controller.conversations.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppDimensions.smallSpacing),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == controller.conversations.length) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: AppDimensions.regularSpacing,
                          bottom: AppDimensions.sectionSpacing,
                        ),
                        child: HoverableButton(
                          child: OutlinedButton.icon(
                            onPressed: controller.isStarting.value
                                ? null
                                : () => ConciergeStartConversationSheet.open(
                                    controller,
                                  ),
                            icon: const Icon(Symbols.add_comment),
                            label: Text(AppStrings.conversationsStartNew),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryDark,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.buttonVerticalPadding,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.cardRadius,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final ConversationModel item =
                        controller.conversations[index];
                    return _ConversationListTile(
                      conversation: item,
                      onTap: () => controller.openConversation(item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ConversationThreadBody extends StatelessWidget {
  const _ConversationThreadBody({required this.controller});

  final ConciergeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ConversationModel? active = controller.activeConversation.value;
      if (active == null) {
        return const SizedBox.shrink();
      }
      final bool online = active.isOpen;

      final bool canOpenRestaurant = active.restaurantId.isNotEmpty;

      return Column(
        children: [
          _ThreadHeader(
            title: active.displayTitle,
            statusLabel: active.displayStatus,
            isOpen: online,
            onBack: controller.showAllConversations,
            onClose: active.isOpen
                ? controller.closeActiveConversation
                : null,
            onRestaurant: canOpenRestaurant
                ? controller.openActiveRestaurantDetails
                : null,
          ),
          Expanded(
            child: controller.isLoadingMessages.value &&
                    controller.messages.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: AppDimensions.progressIndicatorStrokeWidth,
                    ),
                  )
                : ListView.builder(
                    controller: controller.messagesScrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.pagePadding,
                      AppDimensions.regularSpacing,
                      AppDimensions.pagePadding,
                      AppDimensions.sectionSpacing,
                    ),
                    itemCount: controller.messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ConversationMessageModel message =
                          controller.messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.smallSpacing,
                        ),
                        child: ConciergeMessageCard(
                          message: message.body,
                          isFromCustomer: message.isFromCustomer,
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}

class _ConciergeBrandHeader extends StatelessWidget {
  const _ConciergeBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.online,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: AppDimensions.conciergeStatusDotSize,
          ),
        ),
        const SizedBox(width: AppDimensions.smallSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.conciergeTitle,
                style: AppTextStyles.conciergeTitle,
              ),
              const SizedBox(height: AppDimensions.tinySpacing),
              Text(
                AppStrings.conciergeStatus,
                style: AppTextStyles.conciergeStatus,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreadHeader extends StatelessWidget {
  const _ThreadHeader({
    required this.title,
    required this.statusLabel,
    required this.isOpen,
    required this.onBack,
    this.onClose,
    this.onRestaurant,
  });

  final String title;
  final String statusLabel;
  final bool isOpen;
  final VoidCallback onBack;
  final VoidCallback? onClose;
  final VoidCallback? onRestaurant;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.smallSpacing,
          vertical: AppDimensions.smallSpacing,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              tooltip: AppStrings.conversationsBackToList,
              icon: const Icon(Symbols.arrow_back),
              color: AppColors.textPrimary,
            ),
            Material(
              color: AppColors.surfaceAlt,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRestaurant,
                child: SizedBox.square(
                  dimension: AppDimensions.conciergeHeaderAvatarSize,
                  child: Icon(
                    Symbols.restaurant,
                    color: AppColors.primaryDark,
                    size: AppDimensions.mediumIconSize,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.smallSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.conciergeMessage.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.tinySpacing),
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: isOpen ? AppColors.online : AppColors.disabled,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox.square(
                          dimension: AppDimensions.conciergeStatusDotSize,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.tinySpacing),
                      Flexible(
                        child: Text(
                          statusLabel,
                          style: AppTextStyles.conciergeStatus.copyWith(
                            color: isOpen
                                ? AppColors.online
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onClose != null)
              TextButton(
                onPressed: onClose,
                child: Text(
                  AppStrings.conversationsCloseAction,
                  style: AppTextStyles.authLinkEmphasis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClosedConversationFooter extends StatelessWidget {
  const _ClosedConversationFooter({required this.onChatAnother});

  final VoidCallback onChatAnother;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.conversationsClosedBanner,
                style: AppTextStyles.conciergeMessage.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.tinySpacing),
              Text(
                AppStrings.conversationsClosedHint,
                style: AppTextStyles.conciergeStatus.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.regularSpacing),
              HoverableButton(
                child: ElevatedButton.icon(
                  onPressed: onChatAnother,
                  icon: const Icon(Symbols.forum),
                  label: Text(
                    AppStrings.conversationsChatAnotherRestaurant,
                    style: AppTextStyles.conciergeAction.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  style: AppButtonStyles.filledHover(
                    ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.textLight,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationListTile extends StatelessWidget {
  const _ConversationListTile({
    required this.conversation,
    required this.onTap,
  });

  final ConversationModel conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isOpen = conversation.isOpen;
    return HoverableButton(
      child: Material(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          side: const BorderSide(
            color: AppColors.border,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.contentPadding),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: AppDimensions.conciergeHeaderAvatarSize,
                    child: Icon(
                      Symbols.restaurant,
                      color: AppColors.primaryDark,
                      size: AppDimensions.mediumIconSize,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.regularSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.displayTitle,
                        style: AppTextStyles.conciergeMessage.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        conversation.lastMessagePreview.isNotEmpty
                            ? conversation.lastMessagePreview
                            : conversation.displayStatus,
                        style: AppTextStyles.conciergeStatus.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: isOpen
                                  ? AppColors.online
                                  : AppColors.disabled,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox.square(
                              dimension: AppDimensions.conciergeStatusDotSize,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.tinySpacing),
                          Text(
                            conversation.displayStatus,
                            style: AppTextStyles.conciergeStatus.copyWith(
                              color: isOpen
                                  ? AppColors.online
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (conversation.unreadCount > 0)
                  Container(
                    margin: const EdgeInsetsDirectional.only(
                      start: AppDimensions.smallSpacing,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.smallSpacing,
                      vertical: AppDimensions.tinySpacing,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.pillRadius,
                      ),
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: AppTextStyles.conciergeStatus.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _ConciergeBrandHeader(),
          const SizedBox(height: AppDimensions.sectionSpacing),
          Text(
            message,
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          HoverableButton(
            child: ElevatedButton(
              onPressed: onAction,
              style: AppButtonStyles.filledHover(
                ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.textLight,
                  textStyle: AppTextStyles.conciergeAction,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.buttonHorizontalPadding,
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
                actionLabel,
                style: AppTextStyles.conciergeAction.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
