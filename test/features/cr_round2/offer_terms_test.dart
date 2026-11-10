import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tavla/core/localization/app_translations.dart';
import 'package:tavla/features/discovery/model/offer_terms.dart';
import 'package:tavla/features/discovery/model/restaurant_offer_model.dart';

RestaurantOfferModel _offer(Map<String, dynamic> extra) {
  return RestaurantOfferModel.fromJson(<String, dynamic>{
    'offerId': 'off-1',
    'restaurantId': 'rest-1',
    'type': 'QuietDays',
    'title': 'Quiet Tuesday',
    'description': 'Midweek discount.',
    'discountType': 'Percentage',
    'discountValue': 15,
    'status': 'Published',
    'startsAt': '2026-11-01T00:00:00.000Z',
    // Local midnight, as the dashboard sets an end date.
    'endsAt': DateTime(2026, 12).toUtc().toIso8601String(),
    ...extra,
  });
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en');
  });

  test('parses ADR-047 booking conditions', () {
    final RestaurantOfferModel offer = _offer(<String, dynamic>{
      'daysOfWeek': <int>[2, 0, 2, 9],
      'startTime': '18:00',
      'endTime': '22:30:00',
      'minPartySize': 4,
      'branchIds': <String>['b-1'],
      'oncePerCustomer': true,
      'bookingCap': 50,
    });

    expect(offer.daysOfWeek, <int>[0, 2]);
    expect(offer.startTime, '18:00');
    expect(offer.endTime, '22:30');
    expect(offer.minPartySize, 4);
    expect(offer.coversBranch('b-1'), isTrue);
    expect(offer.coversBranch('b-2'), isFalse);
    expect(offer.oncePerCustomer, isTrue);
    expect(offer.bookingCap, 50);
  });

  test('an offer without conditions (older backend) has no limits', () {
    final RestaurantOfferModel offer = _offer(<String, dynamic>{});

    expect(offer.hasDayLimit, isFalse);
    expect(offer.hasHourLimit, isFalse);
    expect(offer.coversBranch('any'), isTrue);
    expect(OfferTerms.daysLabel(offer), 'Every day');
    expect(OfferTerms.hoursLabel(offer), 'All day');
    expect(OfferTerms.conditionLines(offer), <String>['Until 30/11/2026']);
  });

  test('describes days, hours, discount and conditions in English', () {
    final RestaurantOfferModel offer = _offer(<String, dynamic>{
      'daysOfWeek': <int>[0, 2],
      'startTime': '18:00',
      'endTime': '22:00',
      'minPartySize': 4,
      'oncePerCustomer': true,
    });

    expect(OfferTerms.discountLabel(offer), '15% off');
    expect(OfferTerms.daysLabel(offer), 'Sunday, Tuesday');
    expect(OfferTerms.hoursLabel(offer), '18:00 – 22:00');
    expect(OfferTerms.conditionLines(offer).take(2), <String>[
      'From 4 guests',
      'Once per customer',
    ]);
  });

  test('describes the offer in Arabic', () {
    Get.locale = const Locale('ar');
    final RestaurantOfferModel offer = _offer(<String, dynamic>{
      'discountType': 'FixedAmount',
      'discountValue': 5000,
      'daysOfWeek': <int>[0, 2],
      'minPartySize': 4,
    });

    expect(OfferTerms.discountLabel(offer), 'خصم 5000');
    expect(OfferTerms.daysLabel(offer), contains('، '));
    expect(OfferTerms.conditionLines(offer).first, 'من 4 أشخاص فأكثر');
  });

  test('an offer with no amount has no discount label', () {
    final RestaurantOfferModel offer = _offer(<String, dynamic>{
      'type': 'FreeItem',
      'discountValue': 0,
    });

    expect(OfferTerms.discountLabel(offer), isEmpty);
  });
}
