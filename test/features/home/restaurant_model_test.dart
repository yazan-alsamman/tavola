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
}
