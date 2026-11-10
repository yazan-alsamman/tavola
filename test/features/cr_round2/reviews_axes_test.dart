import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/core/network/api_client.dart';
import 'package:tavla/core/network/auth_token_reader.dart';
import 'package:tavla/features/reviews/model/review_model.dart';
import 'package:tavla/features/reviews/repository/reviews_repository.dart';

const ReviewAxesModel _axes = ReviewAxesModel(
  service: ReviewAxisModel(rating: 5, comment: ' Quick '),
  place: ReviewAxisModel(rating: 4),
  food: ReviewAxisModel(rating: 4, comment: 'Great'),
);

Map<String, dynamic> _reviewJson({bool open = false}) => <String, dynamic>{
  'reviewId': 'rev-1',
  'restaurantId': 'rest-1',
  'reservationId': 'res-1',
  'rating': 4,
  'score': 4.33,
  'comment': 'Lovely',
  'axes': <String, dynamic>{
    'service': <String, dynamic>{'rating': 5, 'comment': 'Quick'},
    'place': <String, dynamic>{'rating': 4, 'comment': null},
    'food': <String, dynamic>{'rating': 4, 'comment': 'Great'},
  },
  'openForRerating': open,
  'images': <Object>[],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses the three axes and the re-rate flag', () {
    final ReviewModel review = ReviewModel.fromJson(_reviewJson(open: true));

    expect(review.axes?.service.rating, 5);
    expect(review.axes?.service.comment, 'Quick');
    expect(review.axes?.place.comment, isEmpty);
    expect(review.openForRerating, isTrue);
  });

  test('a single-rating review (app 1.0.2) has no axes', () {
    final ReviewModel review = ReviewModel.fromJson(<String, dynamic>{
      'reviewId': 'rev-1',
      'rating': 3,
      'axes': null,
    });

    expect(review.axes, isNull);
    expect(review.openForRerating, isFalse);
  });

  test('axes serialise to the ADR-045 body and round like the server', () {
    expect(_axes.roundedAverage, 4);
    expect(_axes.toJson(), <String, dynamic>{
      'service': <String, dynamic>{'rating': 5, 'comment': 'Quick'},
      'place': <String, dynamic>{'rating': 4},
      'food': <String, dynamic>{'rating': 4, 'comment': 'Great'},
    });
  });

  group('requests', () {
    late List<RequestOptions> requests;

    setUp(() {
      Get.testMode = true;
      Get.reset();
      requests = <RequestOptions>[];
      final Dio dio = Dio(BaseOptions(baseUrl: AppUrls.apiBaseUrl));
      Get.put<AuthTokenReader>(const _TokenReader());
      Get.put(ApiClient(dio: dio, tokenReader: Get.find<AuthTokenReader>()));
      dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                requests.add(options);
                handler.resolve(
                  Response<dynamic>(
                    requestOptions: options,
                    statusCode: 200,
                    data: <String, dynamic>{
                      'success': true,
                      'message': 'ok',
                      'data': _reviewJson(),
                    },
                  ),
                );
              },
        ),
      );
    });
    tearDown(Get.reset);

    test('submit sends axes, comment and private note, not rating', () async {
      final ReviewsRepository repo = ReviewsRepository(Get.find<ApiClient>());
      final ReviewModel review = await repo.submitReview(
        reservationId: 'res-1',
        rating: _axes.roundedAverage,
        comment: ' Lovely ',
        axes: _axes,
        privateNote: 'Music too loud',
      );

      final RequestOptions request = requests.single;
      expect(request.method, 'POST');
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        request.data as Map,
      );
      expect(body['reservationId'], 'res-1');
      expect(body.containsKey('rating'), isFalse);
      expect(body['axes'], _axes.toJson());
      expect(body['comment'], 'Lovely');
      expect(body['privateNote'], 'Music too loud');
      expect(review.axes, isNotNull);
      expect(repo.reviewForReservation('res-1')?.reviewId, 'rev-1');
    });

    test('rate again is PUT /reviews/:id without reservationId', () async {
      final ReviewsRepository repo = ReviewsRepository(Get.find<ApiClient>());
      await repo.rerateReview(
        reviewId: 'rev-1',
        reservationId: 'res-1',
        rating: _axes.roundedAverage,
        comment: 'Better now',
        axes: _axes,
      );

      final RequestOptions request = requests.single;
      expect(request.method, 'PUT');
      expect(request.path, AppUrls.reviewPath('rev-1'));
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        request.data as Map,
      );
      expect(body.containsKey('reservationId'), isFalse);
      expect(body.containsKey('privateNote'), isFalse);
      expect(body['axes'], _axes.toJson());
      expect(repo.reviewForReservation('res-1')?.openForRerating, isFalse);
    });

    test('rejects an axis outside 1-5 before calling the API', () async {
      final ReviewsRepository repo = ReviewsRepository(Get.find<ApiClient>());
      expect(
        () => repo.submitReview(
          reservationId: 'res-1',
          rating: 3,
          comment: '',
          axes: const ReviewAxesModel(
            service: ReviewAxisModel(rating: 0),
            place: ReviewAxisModel(rating: 5),
            food: ReviewAxisModel(rating: 5),
          ),
        ),
        throwsStateError,
      );
      expect(requests, isEmpty);
    });
  });
}

class _TokenReader implements AuthTokenReader {
  const _TokenReader();

  @override
  Future<String?> readAccessToken() async => 'access';
}
