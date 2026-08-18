import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/post_frame_work.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../compare/controller/compare_controller.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../../reservation/model/reservation_route_args.dart';
import '../../reviews/model/review_model.dart';
import '../../reviews/model/reviews_page_model.dart';
import '../../reviews/repository/reviews_repository.dart';
import '../model/details_route_args.dart';
import '../model/restaurant_detail_model.dart';
import '../repository/restaurant_details_repository.dart';
import '../widgets/details_reviews_section.dart';
import 'restaurant_menu_controller.dart';

class DetailsController extends GetxController {
  static const String detailsUpdateId = 'details';
  static const String reviewsUpdateId = 'details_reviews';

  final RestaurantDetailsRepository _detailsRepository =
      Get.find<RestaurantDetailsRepository>();
  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();
  final ReviewsRepository _reviewsRepository = Get.find<ReviewsRepository>();

  RestaurantModel? _restaurant;
  RestaurantDetailModel? _detail;
  bool _showMenu = false;
  bool _isLoadingDetails = false;
  String? _detailsError;
  bool _postFrameRefreshStarted = false;

  List<ReviewModel> _reviews = const <ReviewModel>[];
  bool _isLoadingReviews = false;
  bool _isLoadingMoreReviews = false;
  String? _reviewsError;
  bool _hasMoreReviews = false;
  int _reviewsPage = AppDimensions.apiDefaultPage;
  int _reviewsRequestId = 0;

  RestaurantModel get restaurant =>
      _restaurant ?? _detailsRepository.emptyRestaurant();

  RestaurantDetailModel get detail =>
      _detail ?? _detailsRepository.getDetails(restaurant.id);

  bool get showMenu => _showMenu;

  bool get hasRestaurant => _restaurant != null;

  bool get isLoadingDetails => _isLoadingDetails;

  String? get detailsError => _detailsError;

  List<ReviewModel> get reviews => _reviews;

  bool get isLoadingReviews => _isLoadingReviews;

  bool get isLoadingMoreReviews => _isLoadingMoreReviews;

  String? get reviewsError => _reviewsError;

  bool get hasMoreReviews => _hasMoreReviews;

  @override
  void onInit() {
    super.onInit();
    // Sync bind so the first frame shows the correct restaurant (no fallback flash).
    _bindRouteArgumentsSync();
    PostFrameWork.schedule(() {
      if (isClosed || _postFrameRefreshStarted) {
        return;
      }
      _postFrameRefreshStarted = true;
      final String? id = _restaurant?.id;
      if (id == null || id.isEmpty) {
        return;
      }
      unawaited(_favoritesRepository.ensureInitialized());
      unawaited(_refreshDetails(id));
    });
  }

  /// Explicitly binds restaurant-specific data for the current Details visit.
  void loadRestaurant(RestaurantModel restaurant, {bool showMenu = false}) {
    _bindRestaurantSync(restaurant, showMenu: showMenu);
    update([detailsUpdateId, reviewsUpdateId]);
    unawaited(_favoritesRepository.ensureInitialized());
    unawaited(_refreshDetails(restaurant.id));
  }

  void _bindRouteArgumentsSync() {
    final Object? args = Get.arguments;
    if (args is DetailsRouteArgs) {
      _bindRestaurantSync(args.restaurant, showMenu: args.showMenu);
      return;
    }
    if (args is RestaurantModel) {
      _bindRestaurantSync(args, showMenu: false);
      return;
    }
    if (!hasRestaurant) {
      _bindRestaurantSync(
        _detailsRepository.emptyRestaurant(),
        showMenu: false,
      );
    }
  }

  void _bindRestaurantSync(
    RestaurantModel restaurant, {
    required bool showMenu,
  }) {
    _showMenu = showMenu;
    _detailsError = null;
    _restaurant = restaurant;
    _detail = _detailsRepository.getDetails(restaurant.id);
    _resetReviewsState();
  }

  void _resetReviewsState() {
    _reviews = const <ReviewModel>[];
    _isLoadingReviews = false;
    _isLoadingMoreReviews = false;
    _reviewsError = null;
    _hasMoreReviews = false;
    _reviewsPage = AppDimensions.apiDefaultPage;
    _reviewsRequestId += 1;
  }

  Future<void> _refreshDetails(String id) async {
    _isLoadingDetails = true;
    _detailsError = null;
    update([detailsUpdateId]);
    try {
      final RestaurantDetailModel freshDetail = await _detailsRepository
          .fetchDetails(id);
      final RestaurantModel base = _restaurant ?? restaurant;
      RestaurantModel merged = _withHeroImage(base, freshDetail);
      if (freshDetail.hasWorkingHours) {
        merged = merged.copyWith(
          hoursLabel: freshDetail.todayHoursLabel,
          availabilityLabel: freshDetail.isOpenNow
              ? AppStrings.openNow
              : AppStrings.hoursClosed,
          isAvailable: freshDetail.isOpenNow,
        );
      }
      _restaurant = merged;
      _detail = freshDetail;
    } on ApiException catch (error) {
      if (_detail == null ||
          _detail!.about == AppStrings.restaurantDetailsEmpty) {
        _detailsError = error.message;
      }
    } catch (_) {
      if (_detail == null ||
          _detail!.about == AppStrings.restaurantDetailsEmpty) {
        _detailsError = AppStrings.restaurantDetailsLoadError;
      }
    } finally {
      _isLoadingDetails = false;
      update([detailsUpdateId]);
      unawaited(_loadReviews(id, reset: true));
    }
  }

  Future<void> retryLoadDetails() async {
    final String? id = _restaurant?.id;
    if (id == null || id.isEmpty) {
      return;
    }
    await _refreshDetails(id);
  }

  Future<void> retryReviews() async {
    final String? id = _restaurant?.id;
    if (id == null || id.isEmpty) {
      return;
    }
    await _loadReviews(id, reset: true);
  }

  Future<void> loadMoreReviews() async {
    final String? id = _restaurant?.id;
    if (id == null || id.isEmpty || !_hasMoreReviews || _isLoadingMoreReviews) {
      return;
    }
    await _loadReviews(id, reset: false);
  }

  Future<void> _loadReviews(String restaurantId, {required bool reset}) async {
    final String id = restaurantId.trim();
    if (id.isEmpty) {
      return;
    }
    final int requestId = ++_reviewsRequestId;
    if (reset) {
      _isLoadingReviews = true;
      _isLoadingMoreReviews = false;
      _reviewsError = null;
      _reviewsPage = AppDimensions.apiDefaultPage;
      if (_reviews.isNotEmpty) {
        _reviews = const <ReviewModel>[];
      }
      update([reviewsUpdateId]);
    } else {
      _isLoadingMoreReviews = true;
      update([reviewsUpdateId]);
    }

    final int page = reset
        ? AppDimensions.apiDefaultPage
        : _reviewsPage + 1;

    try {
      final ReviewsPageModel pageModel = await _reviewsRepository
          .fetchRestaurantReviews(restaurantId: id, page: page);
      if (isClosed || requestId != _reviewsRequestId) {
        return;
      }
      if (reset) {
        _reviews = List<ReviewModel>.unmodifiable(pageModel.items);
      } else {
        _reviews = List<ReviewModel>.unmodifiable(<ReviewModel>[
          ..._reviews,
          ...pageModel.items,
        ]);
      }
      _reviewsPage = pageModel.page;
      _hasMoreReviews = pageModel.hasMore;
      _reviewsError = null;
    } on ApiException catch (error) {
      if (isClosed || requestId != _reviewsRequestId) {
        return;
      }
      if (reset && _reviews.isEmpty) {
        _reviewsError = error.message.isNotEmpty
            ? error.message
            : AppStrings.restaurantReviewsLoadError;
      } else {
        Get.snackbar(
          AppStrings.restaurantReviews,
          error.message.isNotEmpty
              ? error.message
              : AppStrings.restaurantReviewsLoadError,
        );
      }
    } catch (_) {
      if (isClosed || requestId != _reviewsRequestId) {
        return;
      }
      if (reset && _reviews.isEmpty) {
        _reviewsError = AppStrings.restaurantReviewsLoadError;
      } else {
        Get.snackbar(
          AppStrings.restaurantReviews,
          AppStrings.restaurantReviewsLoadError,
        );
      }
    } finally {
      if (!isClosed && requestId == _reviewsRequestId) {
        _isLoadingReviews = false;
        _isLoadingMoreReviews = false;
        update([reviewsUpdateId]);
      }
    }
  }

  Future<void> openReviewDetail(String reviewId) async {
    final String id = reviewId.trim();
    if (id.isEmpty) {
      return;
    }
    try {
      final ReviewModel review = await _reviewsRepository.fetchReview(id);
      if (isClosed) {
        return;
      }
      await DetailsReviewDetailSheet.show(review);
    } on ApiException catch (error) {
      Get.snackbar(
        AppStrings.restaurantReviews,
        error.message.isNotEmpty
            ? error.message
            : AppStrings.restaurantReviewsLoadError,
      );
    } catch (_) {
      Get.snackbar(
        AppStrings.restaurantReviews,
        AppStrings.restaurantReviewsLoadError,
      );
    }
  }

  String reviewCommentExcerpt(String comment) {
    final String trimmed = comment.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.length <= AppDimensions.reviewCommentExcerptMaxLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, AppDimensions.reviewCommentExcerptMaxLength)}'
        '${AppStrings.textEllipsis}';
  }

  String formatReviewDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    final DateTime local = value.toLocal();
    final String year = (local.year % 100).toString().padLeft(2, '0');
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '$year';
  }

  String ratingLabel(String rating) => '${AppStrings.starSymbol}$rating';

  void reloadLocalizedData() {
    if (isClosed) {
      return;
    }
    final RestaurantModel? current = _restaurant;
    if (current == null) {
      return;
    }

    _detail = _detailsRepository.getDetails(current.id);
    update([detailsUpdateId, reviewsUpdateId]);
  }

  Future<void> openReservation() async {
    if (Get.isRegistered<AuthSessionController>() &&
        !await Get.find<AuthSessionController>()
            .requireSignInForProtectedAction()) {
      return;
    }
    if (Get.isRegistered<ReservationController>()) {
      Get.delete<ReservationController>(force: true);
    }

    AppNavigation.pushOnce(
      AppRoutes.reservation,
      arguments: ReservationRouteArgs(
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
      ),
    );
  }

  void openMenu() {
    RestaurantMenuController.open(restaurant);
  }

  /// Opens Compare Restaurants with this restaurant as side A.
  void openCompare() {
    final RestaurantModel current = restaurant;
    if (current.id.trim().isEmpty) {
      return;
    }
    CompareController.open(seedRestaurant: current);
  }

  bool isFavorite(String id) => _favoritesRepository.isFavorite(id);

  int watchFavorites() => _favoritesRepository.watchFavorites();

  Future<void> toggleFavorite() async {
    final RestaurantModel current = restaurant;
    final String id = current.id.trim();
    if (id.isEmpty) {
      return;
    }
    if (!await AuthSessionController.requireSignInIfRegistered()) {
      return;
    }
    try {
      await _favoritesRepository.toggleFavorite(id, preview: current);
      update([detailsUpdateId]);
    } catch (_) {
      Get.snackbar(AppStrings.favorites, AppStrings.networkUnexpectedError);
    }
  }

  /// Opens restaurant details (payload via route args; Binding creates a fresh controller).
  static void open(RestaurantModel restaurant, {bool showMenu = false}) {
    AppNavigation.pushOnce(
      AppRoutes.details,
      arguments: DetailsRouteArgs(restaurant: restaurant, showMenu: showMenu),
    );
  }

  static RestaurantModel _withHeroImage(
    RestaurantModel restaurant,
    RestaurantDetailModel detail,
  ) {
    if (restaurant.imageUrl.trim().isNotEmpty) {
      return restaurant;
    }
    if (detail.galleryImageUrls.isEmpty) {
      return restaurant;
    }
    return RestaurantModel(
      id: restaurant.id,
      name: restaurant.name,
      cuisine: restaurant.cuisine,
      occasion: restaurant.occasion,
      description: restaurant.description,
      imageUrl: detail.galleryImageUrls.first,
      location: restaurant.location,
      availabilityLabel: restaurant.availabilityLabel,
      isAvailable: restaurant.isAvailable,
    );
  }
}
