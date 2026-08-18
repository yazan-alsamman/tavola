import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/details/controller/details_controller.dart';
import 'package:tavla/features/details/model/restaurant_detail_model.dart';
import 'package:tavla/features/details/repository/restaurant_details_repository.dart';
import 'package:tavla/features/discovery/repository/discovery_repository.dart';
import 'package:tavla/features/favorites/repository/favorites_repository.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';
import 'package:tavla/features/reviews/model/review_model.dart';
import 'package:tavla/features/reviews/model/reviews_page_model.dart';
import 'package:tavla/features/reviews/repository/reviews_repository.dart';
import 'package:tavla/features/users/repository/users_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('DetailsController loads public restaurant reviews', () async {
    Get.testMode = true;
    Get.put<AuthTokenReader>(const EmptyAuthTokenReader());
    Get.put(ApiClient(tokenReader: Get.find<AuthTokenReader>()));
    Get.put<RestaurantDetailsRepository>(_FakeDetailsRepository());
    Get.put<FavoritesRepository>(_FakeFavoritesRepository());
    final _FakeReviewsRepository reviews = _FakeReviewsRepository()
      ..page = const ReviewsPageModel(
        items: <ReviewModel>[
          ReviewModel(
            reviewId: 'rev-1',
            rating: 5,
            comment: 'Excellent service and ambience.',
          ),
        ],
        page: 1,
        pageSize: 20,
        hasMore: false,
      );
    Get.put<ReviewsRepository>(reviews);

    final DetailsController controller = Get.put(DetailsController());
    controller.loadRestaurant(
      RestaurantModel(
        id: 'rest-1',
        name: 'Casa',
        cuisine: 'Italian',
        occasion: 'Dinner',
        description: '',
        imageUrl: '',
        location: 'Dubai',
        availabilityLabel: 'Open now',
        isAvailable: true,
      ),
    );

    // Details refresh loads reviews in `finally`; drain microtasks.
    await pumpEventQueue();

    expect(controller.reviews, hasLength(1));
    expect(controller.reviews.first.reviewId, 'rev-1');
    expect(controller.isLoadingReviews, isFalse);
    expect(controller.reviewsError, isNull);
    expect(controller.hasMoreReviews, isFalse);
    expect(controller.reviewCommentExcerpt('a' * 200).endsWith('…'), isTrue);

    reviews.page = const ReviewsPageModel(
      items: <ReviewModel>[
        ReviewModel(reviewId: 'rev-1', rating: 5, comment: 'Excellent'),
        ReviewModel(reviewId: 'rev-2', rating: 4, comment: 'Nice'),
      ],
      page: 1,
      pageSize: 20,
      hasMore: true,
    );
    await controller.retryReviews();
    expect(controller.reviews, hasLength(2));
    expect(controller.hasMoreReviews, isTrue);
  });
}

class _FakeReviewsRepository extends ReviewsRepository {
  _FakeReviewsRepository() : super(ApiClient());

  ReviewsPageModel page = const ReviewsPageModel(
    items: <ReviewModel>[],
    page: 1,
    pageSize: 20,
    hasMore: false,
  );

  @override
  Future<ReviewsPageModel> fetchRestaurantReviews({
    required String restaurantId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return this.page;
  }
}

class _FakeDetailsRepository extends RestaurantDetailsRepository {
  _FakeDetailsRepository()
    : super(DiscoveryRepository(ApiClient()), ApiClient());

  @override
  Future<RestaurantDetailModel> fetchDetails(String restaurantId) async {
    return getDetails(restaurantId);
  }
}

class _FakeFavoritesRepository extends FavoritesRepository {
  _FakeFavoritesRepository()
    : super(usersRepository: _FakeUsersRepository());

  @override
  Future<void> ensureInitialized() async {}

  @override
  bool isFavorite(String id) => false;

  @override
  int watchFavorites() => 0;
}

class _FakeUsersRepository extends UsersRepository {
  _FakeUsersRepository() : super(ApiClient());
}
