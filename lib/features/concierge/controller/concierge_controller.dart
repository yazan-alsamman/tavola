import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/app_confirm_dialog.dart';
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

class ConciergeController extends GetxController with WidgetsBindingObserver {
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
  bool _messagesRequestInFlight = false;
  bool _listRequestInFlight = false;
  bool _visibleRefreshInFlight = false;
  bool _openingFromNotification = false;
  Timer? _activeThreadRefreshTimer;
  String? _polledConversationId;
  RestaurantModel? _pendingRestaurantChat;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    PostFrameWork.schedule(() {
      if (isClosed || _postFrameLoadsStarted) {
        return;
      }
      _postFrameLoadsStarted = true;
      unawaited(reload());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _stopActiveThreadRefresh();
      return;
    }
    if (isClosed || !_postFrameLoadsStarted) {
      return;
    }
    unawaited(refreshVisibleChat());
    _syncActiveThreadRefresh();
  }

  /// One refresh when the chat route is shown again.
  ///
  /// The controller stays registered, so [onInit] does not run on later visits.
  /// The first visit is already covered by [reload].
  void onChatRouteOpened() {
    if (isClosed || !_postFrameLoadsStarted || _openingFromNotification) {
      _syncActiveThreadRefresh();
      return;
    }
    unawaited(refreshVisibleChat());
    _syncActiveThreadRefresh();
  }

  void onChatRouteClosed() {
    _stopActiveThreadRefresh();
  }

  /// Opens the conversation identified by the notification `data` object.
  ///
  /// Returns false when the payload has no conversation or restaurant id, or
  /// when that conversation cannot be loaded. Does not invent messages.
  Future<bool> openFromNotification({
    String conversationId = '',
    String restaurantId = '',
  }) async {
    final String conversation = conversationId.trim();
    final String restaurant = restaurantId.trim();
    if (conversation.isEmpty && restaurant.isEmpty) {
      return false;
    }
    if (!await _hasAccessToken()) {
      requiresSignIn.value = true;
      return false;
    }
    _openingFromNotification = true;
    try {
      if (conversation.isNotEmpty) {
        final ConversationModel loaded = await _repository.getConversation(
          conversation,
        );
        _upsertConversation(loaded);
        await openConversation(loaded);
        return true;
      }
      if (conversations.isEmpty) {
        final List<ConversationModel> items = await _repository
            .listConversations();
        conversations.assignAll(items);
      }
      ConversationModel? match;
      for (final ConversationModel item in conversations) {
        if (item.restaurantId.trim() == restaurant && item.isOpen) {
          match = item;
          break;
        }
      }
      if (match == null) {
        for (final ConversationModel item in conversations) {
          if (item.restaurantId.trim() == restaurant) {
            match = item;
            break;
          }
        }
      }
      if (match == null) {
        showConversationList.value = true;
        Get.snackbar(AppStrings.chat, AppStrings.conversationsEmpty);
        return false;
      }
      await openConversation(match);
      return true;
    } on ApiException catch (error) {
      showConversationList.value = true;
      Get.snackbar(AppStrings.chat, error.message);
      return false;
    } catch (_) {
      showConversationList.value = true;
      Get.snackbar(AppStrings.chat, AppStrings.conversationMessagesLoadFailed);
      return false;
    } finally {
      _openingFromNotification = false;
    }
  }

  void _upsertConversation(ConversationModel conversation) {
    final int index = conversations.indexWhere(
      (ConversationModel item) =>
          item.conversationId == conversation.conversationId,
    );
    if (index >= 0) {
      conversations[index] = conversation;
      return;
    }
    conversations.insert(0, conversation);
  }

  /// Reloads the open thread, or the inbox, with the existing GET endpoints.
  Future<void> refreshVisibleChat() async {
    if (isClosed ||
        !_postFrameLoadsStarted ||
        isSending.value ||
        _visibleRefreshInFlight) {
      return;
    }
    _visibleRefreshInFlight = true;
    try {
      if (!await _hasAccessToken()) {
        return;
      }
      final ConversationModel? active = activeConversation.value;
      if (showConversationList.value || active == null) {
        await _refreshConversationList();
        return;
      }
      await _loadMessages(
        active.conversationId,
        reset: true,
        keepVisible: messages.isNotEmpty,
        scrollToLatest: _isNearBottom(),
        reportError: false,
      );
    } finally {
      _visibleRefreshInFlight = false;
    }
  }

  Future<void> refreshActiveThread() async {
    final ConversationModel? active = activeConversation.value;
    if (active == null || showConversationList.value) {
      await reload();
      return;
    }
    await _loadMessages(
      active.conversationId,
      reset: true,
      keepVisible: messages.isNotEmpty,
    );
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

      if (_pendingRestaurantChat != null) {
        await _consumePendingRestaurantChat();
        return;
      }

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
    _syncActiveThreadRefresh();
  }

  void showAllConversations() {
    showConversationList.value = true;
    _stopActiveThreadRefresh();
    unawaited(_refreshConversationList());
  }

  /// Back arrow only: ask whether to end the open restaurant conversation.
  Future<void> leaveConversationFromBack() async {
    final ConversationModel? active = activeConversation.value;
    final bool canEnd =
        active != null &&
        !showConversationList.value &&
        active.isOpen &&
        active.restaurantId.trim().isNotEmpty;
    if (!canEnd) {
      showAllConversations();
      return;
    }
    final bool endConversation = await AppConfirmDialog.show(
      title: AppStrings.endConversationPrompt,
      icon: Symbols.chat,
    );
    if (isClosed) {
      return;
    }
    if (endConversation) {
      final bool closed = await closeActiveConversation();
      if (!closed || isClosed) {
        return;
      }
    }
    showAllConversations();
  }

  Future<void> _refreshConversationList() async {
    if (isClosed ||
        _listRequestInFlight ||
        isLoadingConversations.value ||
        !_postFrameLoadsStarted) {
      return;
    }
    if (!await _hasAccessToken()) {
      return;
    }
    _listRequestInFlight = true;
    try {
      final List<ConversationModel> items = await _repository
          .listConversations();
      if (isClosed) {
        return;
      }
      conversations.assignAll(items);
      final ConversationModel? active = activeConversation.value;
      if (active == null) {
        return;
      }
      for (final ConversationModel item in items) {
        if (item.conversationId == active.conversationId) {
          activeConversation.value = item;
          break;
        }
      }
    } catch (_) {
      // Keep the inbox already on screen.
    } finally {
      _listRequestInFlight = false;
    }
  }

  Future<void> _loadMessages(
    String conversationId, {
    required bool reset,
    bool keepVisible = false,
    bool scrollToLatest = true,
    bool reportError = true,
  }) async {
    if (_messagesRequestInFlight) {
      return;
    }
    _messagesRequestInFlight = true;
    if (reset) {
      if (!keepVisible) {
        isLoadingMessages.value = true;
        messages.clear();
      }
      _messagesCursor = null;
      _hasMoreMessages = false;
    }
    try {
      final ConversationMessagesPage page = await _repository.listMessages(
        conversationId,
        cursor: reset ? null : _messagesCursor,
      );
      final List<ConversationMessageModel> ordered = _deduped(
        _sortedChronologically(page.items),
        existingIds: reset
            ? const <String>[]
            : messages.map((ConversationMessageModel item) => item.messageId),
      );
      if (reset) {
        messages.assignAll(ordered);
      } else if (ordered.isNotEmpty) {
        messages.insertAll(0, ordered);
      }
      _messagesCursor = page.nextCursor;
      _hasMoreMessages = page.hasMore;
      if (reset && scrollToLatest) {
        _scrollToBottom();
      }
    } on ApiException catch (error) {
      if (reset && !keepVisible) {
        errorMessage.value = error.message;
      } else if (reportError) {
        Get.snackbar(AppStrings.chat, error.message);
      }
    } catch (_) {
      if (reset && !keepVisible) {
        errorMessage.value = AppStrings.conversationMessagesLoadFailed;
      } else if (reportError) {
        Get.snackbar(
          AppStrings.chat,
          AppStrings.conversationMessagesLoadFailed,
        );
      }
    } finally {
      _messagesRequestInFlight = false;
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

  /// Opens or starts the conversation for [restaurant] only (card/Details id).
  Future<void> openChatForRestaurant(RestaurantModel restaurant) async {
    final String id = restaurant.id.trim();
    if (id.isEmpty) {
      Get.snackbar(AppStrings.chat, AppStrings.invalidRestaurantPayload);
      return;
    }
    _pendingRestaurantChat = restaurant;
    if (!_postFrameLoadsStarted || isLoadingConversations.value) {
      return;
    }
    await _consumePendingRestaurantChat();
  }

  Future<void> _consumePendingRestaurantChat() async {
    final RestaurantModel? restaurant = _pendingRestaurantChat;
    _pendingRestaurantChat = null;
    if (restaurant == null) {
      return;
    }
    final String id = restaurant.id.trim();
    if (id.isEmpty) {
      Get.snackbar(AppStrings.chat, AppStrings.invalidRestaurantPayload);
      return;
    }

    ConversationModel? match;
    for (final ConversationModel item in conversations) {
      if (item.restaurantId.trim() == id && item.isOpen) {
        match = item;
        break;
      }
    }
    if (match == null) {
      for (final ConversationModel item in conversations) {
        if (item.restaurantId.trim() == id) {
          match = item;
          break;
        }
      }
    }
    if (match != null) {
      await openConversation(match);
      return;
    }
    await startConversationWithRestaurant(restaurant);
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

  Future<bool> closeActiveConversation() async {
    final ConversationModel? active = activeConversation.value;
    if (active == null || active.isClosed) {
      return false;
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
      return true;
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.chat, error.message);
      return false;
    } catch (_) {
      Get.snackbar(AppStrings.chat, AppStrings.conversationCloseFailed);
      return false;
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

  bool _isNearBottom() {
    if (!messagesScrollController.hasClients) {
      return true;
    }
    final double remaining =
        messagesScrollController.position.maxScrollExtent -
        messagesScrollController.position.pixels;
    return remaining <= AppDimensions.conciergeNearBottomSlop;
  }

  static List<ConversationMessageModel> _deduped(
    List<ConversationMessageModel> items, {
    required Iterable<String> existingIds,
  }) {
    final Set<String> seen = existingIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet();
    final List<ConversationMessageModel> unique = <ConversationMessageModel>[];
    for (final ConversationMessageModel item in items) {
      final String id = item.messageId.trim();
      if (id.isEmpty || seen.add(id)) {
        unique.add(item);
      }
    }
    return unique;
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

  void _syncActiveThreadRefresh() {
    final String? conversationId = _directRestaurantConversationId();
    if (conversationId == null) {
      _stopActiveThreadRefresh();
      return;
    }
    if (_polledConversationId == conversationId &&
        _activeThreadRefreshTimer != null) {
      return;
    }
    _stopActiveThreadRefresh();
    _polledConversationId = conversationId;
    _activeThreadRefreshTimer = Timer.periodic(
      AppDimensions.conciergeActiveThreadRefreshInterval,
      (_) => unawaited(_pollActiveThread()),
    );
  }

  Future<void> _pollActiveThread() async {
    final String? conversationId = _directRestaurantConversationId();
    if (conversationId == null || conversationId != _polledConversationId) {
      _stopActiveThreadRefresh();
      return;
    }
    if (isSending.value || _messagesRequestInFlight) {
      return;
    }
    await _loadMessages(
      conversationId,
      reset: true,
      keepVisible: messages.isNotEmpty,
      scrollToLatest: _isNearBottom(),
      reportError: false,
    );
  }

  /// Restaurant thread on the chat route only. Inbox and other screens do not poll.
  String? _directRestaurantConversationId() {
    if (isClosed || showConversationList.value) {
      return null;
    }
    if (Get.currentRoute != AppRoutes.concierge) {
      return null;
    }
    final ConversationModel? active = activeConversation.value;
    if (active == null ||
        active.isClosed ||
        active.restaurantId.trim().isEmpty) {
      return null;
    }
    return active.conversationId;
  }

  void _stopActiveThreadRefresh() {
    _activeThreadRefreshTimer?.cancel();
    _activeThreadRefreshTimer = null;
    _polledConversationId = null;
  }

  @override
  void onClose() {
    _stopActiveThreadRefresh();
    WidgetsBinding.instance.removeObserver(this);
    messageController.dispose();
    messagesScrollController.dispose();
    super.onClose();
  }
}
