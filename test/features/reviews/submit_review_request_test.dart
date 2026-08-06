import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/core/constants/app_strings.dart';

void main() {
  test('submit review body keys match Postman SubmitReviewRequestDto', () {
    const String reservationId = 'res-uuid';
    const int rating = 5;
    const String comment = 'Wonderful evening, great service.';

    final Map<String, dynamic> body = <String, dynamic>{
      AppStrings.apiReviewReservationIdField: reservationId,
      AppStrings.apiReviewRatingField: rating,
      AppStrings.apiReviewCommentField: comment,
    };

    expect(body, <String, dynamic>{
      'reservationId': reservationId,
      'rating': rating,
      'comment': comment,
    });
    expect(AppStrings.apiReviewImageUploadField, 'file');
  });
}
