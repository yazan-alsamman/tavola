import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/auth_token_reader.dart';
import '../model/review_model.dart';
import '../model/reviews_page_model.dart';

/// Customer-facing Reviews APIs (Postman **10 - Reviews** + `/users/me/reviews`).
///
/// Owner-only reply and analytics summary are intentionally omitted.
class ReviewsRepository {
  ReviewsRepository(this._apiClient);

  final ApiClient _apiClient;

  /// In-memory map of the customer's reviews keyed by reservation id.
  final RxMap<String, ReviewModel> myReviewsByReservationId =
      <String, ReviewModel>{}.obs;

  /// `GET /users/me/reviews?page=&pageSize=`
  Future<ReviewsPageModel> fetchMyReviews({
    int page = AppDimensions.apiDefaultPage,
    int pageSize = AppDimensions.apiDefaultLimit,
  }) async {
    await _ensureAuthenticated();
    final ApiResponse<List<ReviewModel>> response = await _apiClient
        .get<List<ReviewModel>>(
          AppUrls.myReviewsPath,
          queryParameters: <String, dynamic>{
            AppUrls.reviewsPageQueryKey: page,
            AppUrls.reviewsPageSizeQueryKey: pageSize,
          },
          parseData: ReviewsPageModel.parseItems,
        );
    final ReviewsPageModel pageModel = ReviewsPageModel.fromItems(
      items: response.data,
      meta: response.meta,
      requestPage: page,
      requestPageSize: pageSize,
    );
    _mergeMyReviews(pageModel.items);
    return pageModel;
  }

  /// Loads every page of the customer's reviews into [myReviewsByReservationId].
  Future<void> syncMyReviews() async {
    if (!await _hasAccessToken()) {
      myReviewsByReservationId.clear();
      return;
    }
    myReviewsByReservationId.clear();
    int page = AppDimensions.apiDefaultPage;
    while (true) {
      final ReviewsPageModel result = await fetchMyReviews(page: page);
      if (!result.hasMore || result.items.isEmpty) {
        break;
      }
      page += 1;
      if (page > AppDimensions.reviewsMaxSyncPages) {
        break;
      }
    }
  }

  /// Public `GET /restaurants/:restaurantId/reviews?page=&pageSize=`
  Future<ReviewsPageModel> fetchRestaurantReviews({
    required String restaurantId,
    int page = AppDimensions.apiDefaultPage,
    int pageSize = AppDimensions.apiDefaultLimit,
  }) async {
    final String id = restaurantId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidReviewPayload);
    }
    final ApiResponse<List<ReviewModel>> response = await _apiClient
        .get<List<ReviewModel>>(
          AppUrls.restaurantReviewsPath(id),
          queryParameters: <String, dynamic>{
            AppUrls.reviewsPageQueryKey: page,
            AppUrls.reviewsPageSizeQueryKey: pageSize,
          },
          options: ApiClient.skipAuthOptions(),
          parseData: ReviewsPageModel.parseItems,
        );
    return ReviewsPageModel.fromItems(
      items: response.data,
      meta: response.meta,
      requestPage: page,
      requestPageSize: pageSize,
    );
  }

  /// Public `GET /reviews/:reviewId`
  Future<ReviewModel> fetchReview(String reviewId) async {
    final String id = reviewId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidReviewPayload);
    }
    final ApiResponse<ReviewModel> response = await _apiClient.get<ReviewModel>(
      AppUrls.reviewPath(id),
      options: ApiClient.skipAuthOptions(),
      parseData: _parseReview,
    );
    return response.data;
  }

  /// `POST /reviews` — body: reservationId, rating, comment.
  Future<ReviewModel> submitReview({
    required String reservationId,
    required int rating,
    required String comment,
  }) async {
    await _ensureAuthenticated();
    final String id = reservationId.trim();
    final String trimmedComment = comment.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidReviewPayload);
    }
    if (rating < AppDimensions.reviewMinRating ||
        rating > AppDimensions.reviewMaxRating) {
      throw StateError(AppStrings.invalidReviewRating);
    }

    final ApiResponse<ReviewModel> response = await _apiClient
        .post<ReviewModel>(
          AppUrls.reviewsPath,
          data: <String, dynamic>{
            AppStrings.apiReviewReservationIdField: id,
            AppStrings.apiReviewRatingField: rating,
            AppStrings.apiReviewCommentField: trimmedComment,
          },
          parseData: (Object? raw) => ReviewModel.fromSubmitData(
            raw,
            reservationId: id,
            rating: rating,
            comment: trimmedComment,
          ),
        );
    _upsertMyReview(response.data);
    return response.data;
  }

  /// `POST /reviews/:id/images` multipart field `file`.
  Future<ReviewImageModel> uploadReviewImage({
    required String reviewId,
    required String filePath,
    String? fileName,
  }) async {
    await _ensureAuthenticated();
    final String id = reviewId.trim();
    if (id.isEmpty || filePath.trim().isEmpty) {
      throw StateError(AppStrings.invalidReviewPayload);
    }

    final FormData formData = FormData.fromMap(<String, dynamic>{
      AppStrings.apiReviewImageUploadField: await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });
    final ApiResponse<ReviewImageModel> response = await _apiClient
        .postMultipart<ReviewImageModel>(
          AppUrls.reviewImagesPath(id),
          formData: formData,
          parseData: _parseReviewImage,
        );
    return response.data;
  }

  /// `DELETE /reviews/:id/images/:imageId`
  Future<void> deleteReviewImage({
    required String reviewId,
    required String reviewImageId,
  }) async {
    await _ensureAuthenticated();
    final String id = reviewId.trim();
    final String imageId = reviewImageId.trim();
    if (id.isEmpty || imageId.isEmpty) {
      throw StateError(AppStrings.invalidReviewPayload);
    }
    await _apiClient.deleteNoContent(AppUrls.reviewImagePath(id, imageId));
  }

  /// `DELETE /reviews/:id` soft-delete.
  Future<void> deleteReview(String reviewId) async {
    await _ensureAuthenticated();
    final String id = reviewId.trim();
    if (id.isEmpty) {
      throw StateError(AppStrings.invalidReviewPayload);
    }
    await _apiClient.deleteNoContent(AppUrls.reviewPath(id));
    myReviewsByReservationId.removeWhere(
      (_, ReviewModel review) => review.reviewId == id,
    );
  }

  ReviewModel? reviewForReservation(String reservationId) {
    final String id = reservationId.trim();
    if (id.isEmpty) {
      return null;
    }
    return myReviewsByReservationId[id];
  }

  void _mergeMyReviews(List<ReviewModel> items) {
    for (final ReviewModel review in items) {
      _upsertMyReview(review);
    }
  }

  void _upsertMyReview(ReviewModel review) {
    final String reservationId = review.reservationId.trim();
    if (reservationId.isEmpty) {
      return;
    }
    myReviewsByReservationId[reservationId] = review;
  }

  Future<bool> _hasAccessToken() async {
    if (Get.isRegistered<GuestModeReader>() &&
        Get.find<GuestModeReader>().isAnonymousGuest) {
      return false;
    }
    if (!Get.isRegistered<AuthTokenReader>()) {
      return false;
    }
    final String? access = await Get.find<AuthTokenReader>().readAccessToken();
    return access != null && access.trim().isNotEmpty;
  }

  Future<void> _ensureAuthenticated() async {
    if (!await _hasAccessToken()) {
      throw StateError(AppStrings.networkUnauthorizedError);
    }
  }

  static ReviewModel _parseReview(Object? raw) {
    if (raw is Map) {
      return ReviewModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw StateError(AppStrings.invalidReviewPayload);
  }

  static ReviewImageModel _parseReviewImage(Object? raw) {
    if (raw is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      final Object? nested = map['image'] ?? map['reviewImage'];
      if (nested is Map) {
        return ReviewImageModel.fromJson(Map<String, dynamic>.from(nested));
      }
      return ReviewImageModel.fromJson(map);
    }
    throw StateError(AppStrings.invalidReviewPayload);
  }
}
