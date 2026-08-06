import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../../core/utils/app_dependency.dart';
import '../../../core/utils/post_frame_work.dart';
import '../../details/controller/details_controller.dart';
import '../../discovery/repository/discovery_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../model/conversation_message_model.dart';
import '../model/conversation_model.dart';
import '../repository/conversations_repository.dart';

class ConciergeController extends GetxController {
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;

  ConversationsRepository get _repository =>
      Get.find<ConversationsRepository>();

  final TextEditingController messageController = TextEditingController();
  final ScrollController messagesScrollController = ScrollController();

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<ConversationMessageModel> messages =
      <ConversationMessageModel>[].obs;
  final Rxn<ConversationModel> activeConversation = Rxn<ConversationModel>();

  final RxBool isLoadingConversations = true.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isStarting = false.obs;
  final RxBool requiresSignIn = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool showConversationList = true.obs;

  String? _messagesCursor;
  bool _hasMoreMessages = false;
  bool _postFrameLoadsStarted = false;

  @override
  void onInit() {
    super.onInit();
    PostFrameWork.schedule(() {
      if (isClosed || _postFrameLoadsStarted) {
        return;
      }
      _postFrameLoadsStarted = true;
      unawaited(reload());
    });
  }

  Future<void> reload() async {
    isLoadingConversations.value = true;
    errorMessage.value = null;
    requiresSignIn.value = false;
    try {
      if (!await _hasAccessToken()) {
        conversations.clear();
        messages.clear();
        activeConversation.value = null;
        showConversationList.value = true;
        requiresSignIn.value = true;
        return;
      }

      final List<ConversationModel> items = await _repository
          .listConversations();
      conversations.assignAll(items);

      if (items.isEmpty) {
        activeConversation.value = null;
        messages.clear();
        showConversationList.value = true;
        return;
      }

      // Prefer an open conversation; otherwise the most recent row.
      final ConversationModel preferred = items.firstWhere(
        (ConversationModel item) => item.isOpen,
        orElse: () => items.first,
      );
      await openConversation(preferred);
    } on ApiException catch (error) {
      conversations.clear();
      errorMessage.value = error.message;
    } on StateError catch (error) {
      conversations.clear();
      if (error.message == AppStrings.networkUnauthorizedError) {
        requiresSignIn.value = true;
      } else {
        errorMessage.value = error.message;
      }
    } catch (_) {
      conversations.clear();
      errorMessage.value = AppStrings.conversationsLoadFailed;
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<void> openConversation(ConversationModel conversation) async {
    activeConversation.value = conversation;
    showConversationList.value = false;
    await _loadMessages(conversation.conversationId, reset: true);
    unawaited(_markReadQuietly(conversation.conversationId));
  }

  void showAllConversations() {
    showConversationList.value = true;
  }

  Future<void> _loadMessages(
    String conversationId, {
    required bool reset,
  }) async {
    if (reset) {
      isLoadingMessages.value = true;
      messages.clear();
      _messagesCursor = null;
      _hasMoreMessages = false;
    }
    try {
      final ConversationMessagesPage page = await _repository.listMessages(
        conversationId,
        cursor: reset ? null : _messagesCursor,
      );
      final List<ConversationMessageModel> ordered = _sortedChronologically(
        page.items,
      );
      if (reset) {
        messages.assignAll(ordered);
      } else {
        messages.insertAll(0, ordered);
      }
      _messagesCursor = page.nextCursor;
      _hasMoreMessages = page.hasMore;
      if (reset) {
        _scrollToBottom();
      }
    } on ApiException catch (error) {
      if (reset) {
        errorMessage.value = error.message;
      } else {
        Get.snackbar(AppStrings.chat, error.message);
      }
    } catch (_) {
      if (reset) {
        errorMessage.value = AppStrings.conversationMessagesLoadFailed;
      } else {
        Get.snackbar(
          AppStrings.chat,
          AppStrings.conversationMessagesLoadFailed,
        );
      }
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> loadOlderMessages() async {
    final ConversationModel? active = activeConversation.value;
    if (active == null ||
        !_hasMoreMessages ||
        isLoadingMessages.value ||
        isSending.value) {
      return;
    }
    await _loadMessages(active.conversationId, reset: false);
  }

  Future<void> sendMessage() async {
    final String text = messageController.text.trim();
    if (text.isEmpty || isSending.value) {
      return;
    }
    if (!await _hasAccessToken()) {
      requiresSignIn.value = true;
      return;
    }

    ConversationModel? active = activeConversation.value;
    if (active == null || active.isClosed) {
      Get.snackbar(AppStrings.chat, AppStrings.conversationsEmpty);
      return;
    }

    isSending.value = true;
    errorMessage.value = null;
    try {
      final ConversationMessageModel sent = await _repository.sendMessage(
        conversationId: active.conversationId,
        body: text,
      );
      messageController.clear();
      messages.add(
        sent.body.trim().isEmpty
            ? ConversationMessageModel(
                messageId: sent.messageId,
                body: text,
                conversationId: active.conversationId,
                senderType: AppStrings.conversationSenderCustomer,
                createdAt: sent.createdAt ?? DateTime.now(),
              )
            : sent,
      );
      activeConversation.value = active.copyWith(
        lastMessagePreview: text,
        lastMessageAt: DateTime.now(),
      );
      _scrollToBottom();
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.chat, error.message);
    } catch (_) {
      Get.snackbar(AppStrings.chat, AppStrings.conversationSendFailed);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> startConversationWithRestaurant(
    RestaurantModel restaurant,
  ) async {
    if (isStarting.value) {
      return;
    }
    if (!await _hasAccessToken()) {
      requiresSignIn.value = true;
      return;
    }
    isStarting.value = true;
    errorMessage.value = null;
    try {
      final ConversationModel created = await _repository.startConversation(
        restaurantId: restaurant.id,
        subject: restaurant.name,
      );
      conversations.insert(0, created);
      await openConversation(created);
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.chat, error.message);
    } catch (_) {
      Get.snackbar(AppStrings.chat, AppStrings.conversationStartFailed);
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> closeActiveConversation() async {
    final ConversationModel? active = activeConversation.value;
    if (active == null || active.isClosed) {
      return;
    }
    try {
      final ConversationModel? closed = await _repository.closeConversation(
        active.conversationId,
      );
      final ConversationModel updated =
          closed ??
          active.copyWith(status: AppStrings.conversationStatusClosed);
      activeConversation.value = updated;
      final int index = conversations.indexWhere(
        (ConversationModel item) =>
            item.conversationId == updated.conversationId,
      );
      if (index >= 0) {
        conversations[index] = updated;
      }
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.chat, error.message);
    } catch (_) {
      Get.snackbar(AppStrings.chat, AppStrings.conversationCloseFailed);
    }
  }

  Future<List<RestaurantModel>> loadRestaurantsForNewChat({
    String? excludeRestaurantId,
  }) async {
    if (!await _hasAccessToken()) {
      requiresSignIn.value = true;
      return const <RestaurantModel>[];
    }
    AppDependency.ensureDiscoveryRepository();
    final List<RestaurantModel> items = await Get.find<DiscoveryRepository>()
        .listRestaurants();
    final String excluded = excludeRestaurantId?.trim() ?? '';
    if (excluded.isEmpty) {
      return items;
    }
    return items
        .where((RestaurantModel item) => item.id != excluded)
        .toList(growable: false);
  }

  void openActiveRestaurantDetails() {
    final ConversationModel? active = activeConversation.value;
    if (active == null || active.restaurantId.trim().isEmpty) {
      return;
    }
    DetailsController.open(
      RestaurantModel(
        id: active.restaurantId,
        name: active.restaurantName.isNotEmpty
            ? active.restaurantName
            : active.displayTitle,
        cuisine: '',
        occasion: '',
        description: '',
        imageUrl: '',
        location: '',
        availabilityLabel: AppStrings.openNow,
        isAvailable: true,
      ),
    );
  }

  void openSignIn() {
    AppNavigation.pushOnce(AppRoutes.login);
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(index, currentIndex: chatNavigationIndex);
  }

  Future<void> _markReadQuietly(String conversationId) async {
    try {
      await _repository.markRead(conversationId);
      final int index = conversations.indexWhere(
        (ConversationModel item) => item.conversationId == conversationId,
      );
      if (index >= 0 && conversations[index].unreadCount > 0) {
        conversations[index] = conversations[index].copyWith(unreadCount: 0);
      }
      final ConversationModel? active = activeConversation.value;
      if (active != null && active.conversationId == conversationId) {
        activeConversation.value = active.copyWith(unreadCount: 0);
      }
    } catch (_) {
      // Read receipts are best-effort.
    }
  }

  Future<bool> _hasAccessToken() => AuthAccessGuard.hasAccessToken();


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!messagesScrollController.hasClients) {
        return;
      }
      messagesScrollController.animateTo(
        messagesScrollController.position.maxScrollExtent,
        duration: AppDimensions.hoverDuration,
        curve: Curves.easeOut,
      );
    });
  }

  static List<ConversationMessageModel> _sortedChronologically(
    List<ConversationMessageModel> items,
  ) {
    final List<ConversationMessageModel> copy =
        List<ConversationMessageModel>.from(items);
    copy.sort((ConversationMessageModel a, ConversationMessageModel b) {
      final DateTime? left = a.createdAt;
      final DateTime? right = b.createdAt;
      if (left == null && right == null) {
        return 0;
      }
      if (left == null) {
        return -1;
      }
      if (right == null) {
        return 1;
      }
      return left.compareTo(right);
    });
    return copy;
  }

  @override
  void onClose() {
    messageController.dispose();
    messagesScrollController.dispose();
    super.onClose();
  }
}
