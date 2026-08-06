import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/features/reviews/model/review_model.dart';

void main() {
  group('ReviewModel', () {
    test('parses submit-shaped payload with reviewId', () {
      final ReviewModel review = ReviewModel.fromSubmitData(
        <String, dynamic>{
          'reviewId': 'rev-1',
          'rating': 5,
          'comment': 'Wonderful evening, great service.',
          'reservationId': 'res-1',
        },
        reservationId: 'res-1',
        rating: 5,
        comment: 'Wonderful evening, great service.',
      );

      expect(review.reviewId, 'rev-1');
      expect(review.reservationId, 'res-1');
      expect(review.rating, 5);
      expect(review.comment, 'Wonderful evening, great service.');
    });

    test('fromJson reads nested restaurant and images', () {
      final ReviewModel review = ReviewModel.fromJson(<String, dynamic>{
        'id': 'rev-2',
        'rating': 4,
        'comment': 'Lovely night',
        'reservationId': 'res-2',
        'restaurant': <String, dynamic>{
          'id': 'rest-9',
          'name': 'Casa',
        },
        'images': <Map<String, dynamic>>[
          <String, dynamic>{
            'reviewImageId': 'img-1',
            'url': 'https://cdn.example/a.jpg',
          },
        ],
      });

      expect(review.reviewId, 'rev-2');
      expect(review.restaurantId, 'rest-9');
      expect(review.restaurantName, 'Casa');
      expect(review.images, hasLength(1));
      expect(review.images.first.reviewImageId, 'img-1');
    });
  });
}
