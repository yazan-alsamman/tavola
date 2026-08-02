import 'notification_item_model.dart';

/// Paginated notifications page (`data.items` + optional `meta`).
class NotificationsPageModel {
  const NotificationsPageModel({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasMore,
    this.total,
  });

  final List<NotificationItemModel> items;
  final int page;
  final int limit;
  final bool hasMore;
  final int? total;

  factory NotificationsPageModel.fromItems({
    required List<NotificationItemModel> items,
    Map<String, dynamic>? meta,
    required int requestPage,
    required int requestLimit,
  }) {
    final int page = _asInt(meta?['page'], fallback: requestPage);
    final int limit = _asInt(meta?['limit'], fallback: requestLimit);
    final int? total = _asIntOrNull(meta?['total'] ?? meta?['totalItems']);
    final int? totalPages = _asIntOrNull(
      meta?['totalPages'] ?? meta?['pageCount'],
    );

    final bool hasMore;
    if (meta?['hasMore'] is bool) {
      hasMore = meta!['hasMore'] as bool;
    } else if (totalPages != null) {
      hasMore = page < totalPages;
    } else if (total != null) {
      hasMore = page * limit < total;
    } else {
      hasMore = items.length >= requestLimit;
    }

    return NotificationsPageModel(
      items: items,
      page: page,
      limit: limit,
      hasMore: hasMore,
      total: total,
    );
  }

  static List<NotificationItemModel> parseItems(Object? data) {
    Object? rawList = data;
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      rawList = map['items'] ?? map['notifications'] ?? map['results'];
    }
    if (rawList is! List) {
      return const <NotificationItemModel>[];
    }

    final List<NotificationItemModel> items = <NotificationItemModel>[];
    for (final Object? entry in rawList) {
      if (entry is! Map) {
        continue;
      }
      try {
        items.add(
          NotificationItemModel.fromJson(Map<String, dynamic>.from(entry)),
        );
      } catch (_) {
        // Skip malformed rows; keep the rest of the page usable.
      }
    }
    return items;
  }

  static int _asInt(Object? raw, {required int fallback}) {
    return _asIntOrNull(raw) ?? fallback;
  }

  static int? _asIntOrNull(Object? raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim());
    }
    return null;
  }
}
