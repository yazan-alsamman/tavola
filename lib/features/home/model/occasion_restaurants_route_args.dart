import '../../taxonomy/model/occasion_category_model.dart';

/// Selected occasion already loaded from `GET /occasion-categories`.
class OccasionRestaurantsRouteArgs {
  const OccasionRestaurantsRouteArgs({required this.category});

  final OccasionCategoryModel category;
}
