import 'review_model.dart';

/// Paginated reviews page (`data.items` / list + optional `meta`).
class ReviewsPageModel {
  const ReviewsPageModel({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    this.total,
  });

  final List<ReviewModel> items;
  final int page;
  final int pageSize;
  final bool hasMore;
  final int? total;

  factory ReviewsPageModel.fromItems({
    required List<ReviewModel> items,
    Map<String, dynamic>? meta,
    required int requestPage,
    required int requestPageSize,
  }) {
    final int page = _asInt(
      meta?['page'],
      fallback: requestPage,
    );
    final int pageSize = _asInt(
      meta?['pageSize'] ?? meta?['limit'],
      fallback: requestPageSize,
    );
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
      hasMore = page * pageSize < total;
    } else {
      hasMore = items.length >= requestPageSize;
    }

    return ReviewsPageModel(
      items: items,
      page: page,
      pageSize: pageSize,
      hasMore: hasMore,
      total: total,
    );
  }

  static List<ReviewModel> parseItems(Object? data) {
    Object? rawList = data;
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      rawList = map['items'] ?? map['reviews'] ?? map['results'];
    }
    if (rawList is! List) {
      return const <ReviewModel>[];
    }

    final List<ReviewModel> items = <ReviewModel>[];
    for (final Object? entry in rawList) {
      if (entry is! Map) {
        continue;
      }
      try {
        final ReviewModel review = ReviewModel.fromJson(
          Map<String, dynamic>.from(entry),
        );
        if (review.hasId || review.reservationId.isNotEmpty) {
          items.add(review);
        }
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
