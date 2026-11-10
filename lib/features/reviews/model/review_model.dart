import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/media_url_resolver.dart';

/// Review image from submit / list / get payloads.
class ReviewImageModel {
  const ReviewImageModel({required this.reviewImageId, required this.url});

  final String reviewImageId;
  final String url;

  factory ReviewImageModel.fromJson(Map<String, dynamic> json) {
    return ReviewImageModel(
      reviewImageId: _firstNonEmpty(<Object?>[
        json['reviewImageId'],
        json['imageId'],
        json['id'],
      ]),
      url: MediaUrlResolver.resolve(
        json['url'] ??
            json['imageUrl'] ??
            json['src'] ??
            json['fileId'] ??
            json['imageId'],
      ),
    );
  }

  static String _firstNonEmpty(List<Object?> candidates) {
    for (final Object? raw in candidates) {
      final String value = ApiException.coerceString(raw).trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}

/// Stars and an optional comment for one axis (backend ADR-045).
class ReviewAxisModel {
  const ReviewAxisModel({required this.rating, this.comment = ''});

  final int rating;
  final String comment;

  Map<String, dynamic> toJson() => <String, dynamic>{
    AppStrings.apiReviewRatingField: rating,
    if (comment.trim().isNotEmpty)
      AppStrings.apiReviewCommentField: comment.trim(),
  };

  static ReviewAxisModel? fromJson(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
    final int rating = ReviewModel._readRating(map['rating']);
    if (rating <= 0) {
      return null;
    }
    return ReviewAxisModel(
      rating: rating,
      comment: ApiException.coerceString(map['comment']).trim(),
    );
  }
}

/// Service, place and food: the three axes a guest rates (backend ADR-045).
class ReviewAxesModel {
  const ReviewAxesModel({
    required this.service,
    required this.place,
    required this.food,
  });

  final ReviewAxisModel service;
  final ReviewAxisModel place;
  final ReviewAxisModel food;

  List<ReviewAxisModel> get all => <ReviewAxisModel>[service, place, food];

  /// Whole stars of the average, as the backend derives `rating`.
  int get roundedAverage =>
      ((service.rating + place.rating + food.rating) / 3).round();

  Map<String, dynamic> toJson() => <String, dynamic>{
    AppStrings.apiReviewAxisService: service.toJson(),
    AppStrings.apiReviewAxisPlace: place.toJson(),
    AppStrings.apiReviewAxisFood: food.toJson(),
  };

  static ReviewAxesModel? fromJson(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
    final ReviewAxisModel? service = ReviewAxisModel.fromJson(
      map[AppStrings.apiReviewAxisService],
    );
    final ReviewAxisModel? place = ReviewAxisModel.fromJson(
      map[AppStrings.apiReviewAxisPlace],
    );
    final ReviewAxisModel? food = ReviewAxisModel.fromJson(
      map[AppStrings.apiReviewAxisFood],
    );
    if (service == null || place == null || food == null) {
      return null;
    }
    return ReviewAxesModel(service: service, place: place, food: food);
  }
}

/// Customer/public review DTO from Reviews endpoints.
class ReviewModel {
  const ReviewModel({
    required this.reviewId,
    required this.rating,
    this.reservationId = '',
    this.restaurantId = '',
    this.restaurantName = '',
    this.comment = '',
    this.images = const <ReviewImageModel>[],
    this.createdAt,
    this.axes,
    this.openForRerating = false,
  });

  final String reviewId;
  final int rating;
  final String reservationId;
  final String restaurantId;
  final String restaurantName;
  final String comment;
  final List<ReviewImageModel> images;
  final DateTime? createdAt;

  /// Null for a single-rating review (app 1.0.2 and older reviews).
  final ReviewAxesModel? axes;

  /// The restaurant reopened this review; its guest may rate again (PUT).
  final bool openForRerating;

  bool get hasId => reviewId.trim().isNotEmpty;

  ReviewModel copyWith({
    String? reviewId,
    int? rating,
    String? reservationId,
    String? restaurantId,
    String? restaurantName,
    String? comment,
    List<ReviewImageModel>? images,
    DateTime? createdAt,
    ReviewAxesModel? axes,
    bool? openForRerating,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      rating: rating ?? this.rating,
      reservationId: reservationId ?? this.reservationId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      axes: axes ?? this.axes,
      openForRerating: openForRerating ?? this.openForRerating,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final String reviewId = _firstNonEmpty(<Object?>[
      json['reviewId'],
      json['id'],
    ]);
    final Object? restaurantRaw = json['restaurant'];
    String restaurantId = _firstNonEmpty(<Object?>[json['restaurantId']]);
    String restaurantName = _firstNonEmpty(<Object?>[json['restaurantName']]);
    if (restaurantRaw is Map) {
      final Map<String, dynamic> restaurant = Map<String, dynamic>.from(
        restaurantRaw,
      );
      if (restaurantId.isEmpty) {
        restaurantId = _firstNonEmpty(<Object?>[
          restaurant['restaurantId'],
          restaurant['id'],
        ]);
      }
      if (restaurantName.isEmpty) {
        restaurantName = _firstNonEmpty(<Object?>[
          restaurant['name'],
          restaurant['restaurantName'],
        ]);
      }
    }

    return ReviewModel(
      reviewId: reviewId,
      rating: _readRating(json['rating']),
      reservationId: _firstNonEmpty(<Object?>[json['reservationId']]),
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      comment: _firstNonEmpty(<Object?>[
        json['comment'],
        json['body'],
        json['text'],
      ]),
      images: _parseImages(json['images'] ?? json['reviewImages']),
      createdAt: _asDateTime(
        json['createdAt'] ?? json['created_at'] ?? json['submittedAt'],
      ),
      axes: ReviewAxesModel.fromJson(json[AppStrings.apiReviewAxesField]),
      openForRerating: json['openForRerating'] == true,
    );
  }

  /// Parses `POST /reviews` success `data` (`reviewId` at root or nested).
  factory ReviewModel.fromSubmitData(
    Object? raw, {
    required String reservationId,
    required int rating,
    required String comment,
  }) {
    if (raw is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      final Object? nested = map['review'];
      final Map<String, dynamic> source = nested is Map
          ? Map<String, dynamic>.from(nested)
          : map;
      final ReviewModel parsed = ReviewModel.fromJson(source);
      return parsed.copyWith(
        reservationId: parsed.reservationId.isNotEmpty
            ? parsed.reservationId
            : reservationId,
        rating: parsed.rating > 0 ? parsed.rating : rating,
        comment: parsed.comment.isNotEmpty ? parsed.comment : comment,
      );
    }
    return ReviewModel(
      reviewId: ApiException.coerceString(raw),
      rating: rating,
      reservationId: reservationId,
      comment: comment,
    );
  }

  static List<ReviewImageModel> _parseImages(Object? raw) {
    if (raw is! List) {
      return const <ReviewImageModel>[];
    }
    final List<ReviewImageModel> images = <ReviewImageModel>[];
    for (final Object? entry in raw) {
      if (entry is! Map) {
        continue;
      }
      final ReviewImageModel image = ReviewImageModel.fromJson(
        Map<String, dynamic>.from(entry),
      );
      if (image.reviewImageId.isEmpty && image.url.isEmpty) {
        continue;
      }
      images.add(image);
    }
    return images;
  }

  static int _readRating(Object? raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim()) ?? 0;
    }
    return 0;
  }

  static DateTime? _asDateTime(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw.trim());
  }

  static String _firstNonEmpty(List<Object?> candidates) {
    for (final Object? raw in candidates) {
      final String value = ApiException.coerceString(raw).trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}
