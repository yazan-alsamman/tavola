import '../../../core/network/api_exception.dart';

class OccasionCategoryModel {
  const OccasionCategoryModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  /// Canonical slugs from `GET /occasion-categories`.
  static const String slugDateNight = 'date-night';
  static const String slugBusinessLunch = 'business-lunch';
  static const String slugFamily = 'family';
  static const String slugBirthday = 'birthday';
  static const String slugGroupGathering = 'group-gathering';
  static const String slugCasual = 'casual';
  static const String slugFineDining = 'fine-dining';

  /// Local chips when `GET /occasion-categories` is slow or unavailable.
  static List<OccasionCategoryModel> fallbackItems() {
    const List<String> slugs = <String>[
      slugDateNight,
      slugBusinessLunch,
      slugFamily,
      slugBirthday,
      slugGroupGathering,
      slugCasual,
      slugFineDining,
    ];
    const List<String> names = <String>[
      'Date Night',
      'Business Lunch',
      'Family',
      'Birthday',
      'Group Gathering',
      'Casual',
      'Fine Dining',
    ];
    return List<OccasionCategoryModel>.generate(slugs.length, (int index) {
      return OccasionCategoryModel(
        id: 'fallback-${slugs[index]}',
        slug: slugs[index],
        name: names[index],
        sortOrder: index + 1,
      );
    }, growable: false);
  }

  final String id;
  final String slug;
  final String name;
  final int sortOrder;
  final String? createdAt;
  final String? updatedAt;

  factory OccasionCategoryModel.fromJson(Map<String, dynamic> json) {
    return OccasionCategoryModel(
      id: ApiException.coerceString(json['occasionCategoryId'] ?? json['id']),
      slug: ApiException.coerceString(json['slug']),
      name: ApiException.coerceString(json['name']),
      sortOrder: ApiException.coerceInt(json['sortOrder']),
      createdAt: ApiException.coerceOptionalString(json['createdAt']),
      updatedAt: ApiException.coerceOptionalString(json['updatedAt']),
    );
  }
}
