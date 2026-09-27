import 'package:flutter_test/flutter_test.dart';

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

  test('discovery cover uses the signed coverImageUrl unchanged', () {
    const String signed =
        'https://media.example.com/object?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=scope&X-Amz-Date=20260927T120000Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=abc';
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
        'coverImageId': 'aa6da0ad-e204-4fc8-b4a4-90dc957d729d',
        'coverImageUrl': signed,
        'logoId': 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
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
    expect(restaurant.imageUrl, signed);
    expect(restaurant.imageUrl.contains('/files/'), isFalse);
  });

  test('null coverImageUrl stays empty even when coverImageId is set', () {
    final RestaurantModel restaurant =
        RestaurantModel.fromDiscoveryJson(<String, dynamic>{
          'restaurantId': 'rest-10',
          'name': 'No Cover',
          'status': 'Active',
          'coverImageId': '11111111-1111-4111-8111-111111111111',
          'coverImageUrl': null,
          'logoId': '22222222-2222-4222-8222-222222222222',
        });

    expect(restaurant.imageUrl, isEmpty);
  });

  test('a non-absolute coverImageUrl is not rewritten into an API path', () {
    final RestaurantModel restaurant =
        RestaurantModel.fromDiscoveryJson(<String, dynamic>{
          'restaurantId': 'rest-11',
          'name': 'Path Spot',
          'status': 'Active',
          'coverImageUrl': '/uploads/cover.jpg',
        });

    expect(restaurant.imageUrl, isEmpty);
  });
}
