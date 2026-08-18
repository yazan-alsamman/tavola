import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/auth_token_reader.dart';
import '../model/conversation_message_model.dart';
import '../model/conversation_model.dart';

/// Customer Messaging APIs (Postman folder **13 - Messaging**).
///
/// - `GET /conversations`
/// - `POST /conversations`
/// - `GET /conversations/:id`
/// - `GET /conversations/:id/messages`
/// - `POST /conversations/:id/messages` (multipart `body`)
/// - `POST /conversations/:id/read`
/// - `POST /conversations/:id/close`
class ConversationsRepository {
  ConversationsRepository(this._apiClient, {AuthTokenReader? tokenReader})
    : _tokenReaderOverride = tokenReader;

  final ApiClient _apiClient;

  /// Optional override for tests; production uses [Get.find].
  final AuthTokenReader? _tokenReaderOverride;

  /// `GET /conversations?page=&pageSize=`.
  Future<List<ConversationModel>> listConversations({
    int page = AppDimensions.apiDefaultPage,
    int pageSize = AppDimensions.conversationsPageSize,
  }) async {
    await _ensureAuthenticated();
    final Map<String, dynamic> query = <String, dynamic>{
      AppUrls.conversationsPageQueryKey: page,
      AppUrls.conversationsPageSizeQueryKey: pageSize,
    };
    final ApiResponse<List<ConversationModel>> response = await _apiClient
        .get<List<ConversationModel>>(
          AppUrls.conversationsPath,
          queryParameters: query,
          parseData: _parseConversationItems,
        );
    return List<ConversationModel>.unmodifiable(response.data);
  }

  /// `POST /conversations` — StartConversationRequestDto.
  Future<ConversationModel> startConversation({
    required String restaurantId,
    String? branchId,
    String? reservationId,
    String? subject,
  }) async {
    await _ensureAuthenticated();
    final String rid = restaurantId.trim();
    if (rid.isEmpty) {
      throw StateError(AppStrings.invalidConversationPayload);
    }
    final Map<String, dynamic> body = <String, dynamic>{
      'restaurantId': rid,
    };
    final String? branch = branchId?.trim();
    if (branch != null && branch.isNotEmpty) {
      body['branchId'] = branch;
    }
    final String? reservation = reservationId?.trim();
    if (reservation != null && reservation.isNotEmpty) {
      body['reservationId'] = reservation;
    }
    final String? topic = subject?.trim();
    if (topic != null && topic.isNotEmpty) {
      body['subject'] = topic;
    }

    final ApiResponse<ConversationModel> response = await _apiClient
        .post<ConversationModel>(
          AppUrls.conversationsPath,
          data: body,
          parseData: _parseConversation,
        );
    return response.data;
  }

  /// `GET /conversations/:id`
  Future<ConversationModel> getConversation(String conversationId) async {
    await _ensureAuthenticated();
    final String id = conversationId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidConversationPayload);
    }
    final ApiResponse<ConversationModel> response = await _apiClient
        .get<ConversationModel>(
          AppUrls.conversationPath(id),
          parseData: _parseConversation,
        );
    return response.data;
  }

  /// `GET /conversations/:id/messages` (cursor pagination).
  Future<ConversationMessagesPage> listMessages(
    String conversationId, {
    int limit = AppDimensions.apiDefaultLimit,
    String? cursor,
  }) async {
    await _ensureAuthenticated();
    final String id = conversationId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidConversationPayload);
    }
    final Map<String, dynamic> query = <String, dynamic>{
      AppUrls.conversationsLimitQueryKey: limit,
    };
    final String? cursorValue = cursor?.trim();
    if (cursorValue != null && cursorValue.isNotEmpty) {
      query[AppUrls.conversationsCursorQueryKey] = cursorValue;
    }

    final ApiResponse<List<ConversationMessageModel>> response =
        await _apiClient.get<List<ConversationMessageModel>>(
          AppUrls.conversationMessagesPath(id),
          queryParameters: query,
          parseData: ConversationMessagesPage.parseItems,
        );
    return ConversationMessagesPage.fromItems(
      items: response.data,
      meta: response.meta,
      requestLimit: limit,
    );
  }

  /// `POST /conversations/:id/messages` — multipart field `body`.
  Future<ConversationMessageModel> sendMessage({
    required String conversationId,
    required String body,
    MultipartFile? attachment,
  }) async {
    await _ensureAuthenticated();
    final String id = conversationId.trim();
    final String text = body.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidConversationPayload);
    }
    if (text.isEmpty) {
      throw StateError(AppStrings.invalidConversationMessagePayload);
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      AppStrings.apiConversationMessageBodyField: text,
    };
    if (attachment != null) {
      payload[AppStrings.apiConversationMessageAttachmentField] = attachment;
    }
    final FormData formData = FormData.fromMap(payload);
    final ApiResponse<ConversationMessageModel> response = await _apiClient
        .postMultipart<ConversationMessageModel>(
          AppUrls.conversationMessagesPath(id),
          formData: formData,
          parseData: _parseMessage,
        );
    return response.data;
  }

  /// `POST /conversations/:id/read`
  Future<void> markRead(String conversationId) async {
    await _ensureAuthenticated();
    final String id = conversationId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidConversationPayload);
    }
    await _apiClient.post<Object?>(
      AppUrls.conversationReadPath(id),
      parseData: (Object? raw) => raw,
    );
  }

  /// `POST /conversations/:id/close`
  Future<ConversationModel?> closeConversation(String conversationId) async {
    await _ensureAuthenticated();
    final String id = conversationId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidConversationPayload);
    }
    final ApiResponse<ConversationModel?> response = await _apiClient
        .post<ConversationModel?>(
          AppUrls.conversationClosePath(id),
          parseData: (Object? raw) {
            if (raw is Map) {
              return ConversationModel.fromJson(
                Map<String, dynamic>.from(raw),
              );
            }
            return null;
          },
        );
    return response.data;
  }

  Future<bool> _hasAccessToken() => AuthAccessGuard.hasAccessToken(
        tokenReader: _tokenReaderOverride,
      );


  Future<void> _ensureAuthenticated() async {
    if (!await _hasAccessToken()) {
      throw ApiException.authRequired();
    }
  }

  static List<ConversationModel> _parseConversationItems(Object? raw) {
    final List<dynamic> items = _extractItems(raw);
    final List<ConversationModel> parsed = <ConversationModel>[];
    for (final dynamic item in items) {
      if (item is! Map) {
        continue;
      }
      try {
        parsed.add(
          ConversationModel.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (_) {
        // Skip malformed rows.
      }
    }
    return parsed;
  }

  static ConversationModel _parseConversation(Object? raw) {
    if (raw is! Map) {
      throw StateError(AppStrings.invalidConversationPayload);
    }
    return ConversationModel.fromJson(Map<String, dynamic>.from(raw));
  }

  static ConversationMessageModel _parseMessage(Object? raw) {
    if (raw is! Map) {
      throw StateError(AppStrings.invalidConversationMessagePayload);
    }
    return ConversationMessageModel.fromJson(Map<String, dynamic>.from(raw));
  }

  static List<dynamic> _extractItems(Object? raw) {
    if (raw is Map) {
      final Object? items =
          raw['items'] ?? raw['conversations'] ?? raw['results'];
      if (items is List) {
        return items;
      }
    }
    if (raw is List) {
      return raw;
    }
    return const <dynamic>[];
  }
}

/// Cursor page of conversation messages.
class ConversationMessagesPage {
  const ConversationMessagesPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<ConversationMessageModel> items;
  final bool hasMore;
  final String? nextCursor;

  factory ConversationMessagesPage.fromItems({
    required List<ConversationMessageModel> items,
    Map<String, dynamic>? meta,
    required int requestLimit,
  }) {
    final String nextCursor = ApiException.coerceString(
      meta?['nextCursor'] ?? meta?['cursor'] ?? meta?['next'],
    ).trim();
    final String? resolvedCursor = nextCursor.isNotEmpty ? nextCursor : null;

    final bool hasMore;
    if (meta?['hasMore'] is bool) {
      hasMore = meta!['hasMore'] as bool;
    } else if (resolvedCursor != null) {
      hasMore = true;
    } else {
      hasMore = items.length >= requestLimit;
    }

    return ConversationMessagesPage(
      items: List<ConversationMessageModel>.unmodifiable(items),
      hasMore: hasMore,
      nextCursor: resolvedCursor,
    );
  }

  static List<ConversationMessageModel> parseItems(Object? raw) {
    final List<dynamic> items;
    if (raw is Map) {
      final Object? nested =
          raw['items'] ?? raw['messages'] ?? raw['results'];
      items = nested is List ? nested : const <dynamic>[];
    } else if (raw is List) {
      items = raw;
    } else {
      items = const <dynamic>[];
    }

    final List<ConversationMessageModel> parsed = <ConversationMessageModel>[];
    for (final dynamic item in items) {
      if (item is! Map) {
        continue;
      }
      try {
        parsed.add(
          ConversationMessageModel.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (_) {
        // Skip malformed rows.
      }
    }
    return parsed;
  }
}
