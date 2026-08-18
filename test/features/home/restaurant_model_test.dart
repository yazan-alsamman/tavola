import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/core/constants/app_urls.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';

void main() {
  test('RestaurantModel.fromJson maps list/detail fields', () {
    final RestaurantModel restaurant =
        RestaurantModel.fromJson(<String, dynamic>{
          'restaurantId': 'abc-123',
          'name': 'The Old Mill',
          'description': 'Modern Mediterranean.',
          'cuisineType': 'Mediterranean',
          'status': 'Active',
          'coverImageUrl': 'https://example.com/cover.jpg',
          'city': 'Dubai',
        }, availabilityLabel: 'Open now');

    expect(restaurant.id, 'abc-123');
    expect(restaurant.name, 'The Old Mill');
    expect(restaurant.cuisine, 'Mediterranean');
    expect(restaurant.description, 'Modern Mediterranean.');
    expect(restaurant.imageUrl, 'https://example.com/cover.jpg');
    expect(restaurant.location, 'Dubai');
    expect(restaurant.isAvailable, isTrue);
    expect(restaurant.availabilityLabel, 'Open now');
  });

  test('RestaurantModel.fromJson marks non-active as unavailable', () {
    final RestaurantModel restaurant = RestaurantModel.fromJson(
      <String, dynamic>{
        'restaurantId': 'xyz',
        'name': 'Closed Spot',
        'status': 'Inactive',
      },
      availabilityLabel: 'Booked',
    );

    expect(restaurant.isAvailable, isFalse);
    expect(restaurant.availabilityLabel, 'Booked');
  });

  test('RestaurantModel.fromDiscoveryJson maps occasion tags and media', () {
    final RestaurantModel restaurant = RestaurantModel.fromDiscoveryJson(
      <String, dynamic>{
        'restaurantId': 'rest-9',
        'name': 'Harbor House',
        'status': 'Active',
        'cuisineCategories': <Map<String, dynamic>>[
          <String, dynamic>{'name': 'Seafood'},
        ],
        'occasionCategories': <Map<String, dynamic>>[
          <String, dynamic>{'name': 'Anniversary'},
          <String, dynamic>{'name': 'Business'},
        ],
        'coverImageId': '11111111-1111-1111-1111-111111111111',
        'city': 'Abu Dhabi',
        'workingHours': <dynamic>[
          <String, dynamic>{
            'dayOfWeek': DateTime.now().weekday % 7,
            'openingTime': '09:00',
            'closingTime': '23:00',
          },
        ],
      },
    );

    expect(restaurant.occasion, 'Anniversary');
    expect(restaurant.occasionTags, <String>['Anniversary', 'Business']);
    expect(restaurant.cuisine, 'Seafood');
    expect(restaurant.hoursLabel, '09:00 – 23:00');
    expect(restaurant.workingHours, isNotNull);
    expect(
      restaurant.imageUrl,
      '${AppUrls.apiBaseUrl}${AppUrls.mediaFilePath('11111111-1111-1111-1111-111111111111')}',
    );
  });

  test('RestaurantModel.fromDiscoveryJson resolves relative media paths', () {
    final RestaurantModel restaurant = RestaurantModel.fromDiscoveryJson(
      <String, dynamic>{
        'restaurantId': 'rest-10',
        'name': 'Path Spot',
        'status': 'Active',
        'coverImageUrl': '/uploads/cover.jpg',
      },
    );

    expect(restaurant.imageUrl.startsWith('https://'), isTrue);
    expect(restaurant.imageUrl.endsWith('/uploads/cover.jpg'), isTrue);
  });
}
