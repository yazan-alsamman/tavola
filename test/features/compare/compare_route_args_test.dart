import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/features/compare/model/compare_route_args.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';

void main() {
  test('CompareRouteArgs keeps seed restaurant', () {
    const RestaurantModel seed = RestaurantModel(
      id: 'r1',
      name: 'Casa',
      cuisine: 'Italian',
      occasion: '',
      description: '',
      imageUrl: '',
      location: 'Dubai',
      availabilityLabel: 'Open now',
      isAvailable: true,
    );
    const CompareRouteArgs args = CompareRouteArgs(seedRestaurant: seed);
    expect(args.seedRestaurant?.id, 'r1');
  });
}
