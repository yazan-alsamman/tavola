import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/discovery/model/restaurant_offer_model.dart';

void main() {
  test('parses Discovery offer fields used by Home Special Offer card', () {
    final RestaurantOfferModel offer = RestaurantOfferModel.fromJson(
      <String, dynamic>{
        'offerId': 'off-20',
        'restaurantId': 'rest-1',
        'type': 'Promotion',
        'title': '20% Off Tuesday Dinners',
        'description': 'Valid all evening.',
        'discountType': 'Percentage',
        'discountValue': 20,
        'status': AppStrings.offerStatusPublished,
        'startsAt': '2026-01-01T00:00:00.000Z',
        'endsAt': '2026-12-31T23:59:59.000Z',
      },
    );

    expect(offer.offerId, 'off-20');
    expect(offer.restaurantId, 'rest-1');
    expect(offer.title, '20% Off Tuesday Dinners');
    expect(offer.description, 'Valid all evening.');
    expect(offer.discountValue, 20);
    expect(offer.isPublished, isTrue);
  });

  test('accepts id alias when offerId is absent', () {
    final RestaurantOfferModel offer = RestaurantOfferModel.fromJson(
      <String, dynamic>{
        'id': 'legacy-1',
        'title': 'Lunch Deal',
        'description': 'Half price',
        'status': 'Draft',
      },
    );

    expect(offer.offerId, 'legacy-1');
    expect(offer.isPublished, isFalse);
  });
}
