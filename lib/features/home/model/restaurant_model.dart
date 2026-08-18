import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/media_url_resolver.dart';
import '../../details/repository/working_hours_mapper.dart';

class RestaurantModel {
  const RestaurantModel({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.occasion,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.availabilityLabel,
    required this.isAvailable,
    this.cuisineTags = const <String>[],
    this.occasionTags = const <String>[],
    this.hoursLabel = '',
    this.workingHours,
    this.averageRating,
    this.hasActiveOffer = false,
    this.priceLevel,
    this.hasMenu = false,
    this.status = '',
  });

  final String id;
  final String name;

  /// Primary cuisine label for the card (usually first assigned category).
  final String cuisine;

  /// Primary occasion label for filters/cards.
  final String occasion;
  final String description;
  final String imageUrl;
  final String location;
  final String availabilityLabel;
  final bool isAvailable;

  /// All cuisine category names from `GET .../cuisine-categories`.
  final List<String> cuisineTags;

  /// All occasion category names from `GET .../occasion-categories`.
  final List<String> occasionTags;

  /// Today's hours from discovery `workingHours` (e.g. `09:00 – 22:00`).
  final String hoursLabel;

  /// Raw discovery `workingHours` schedule (list or wrapped map).
  final Object? workingHours;

  /// Discovery `averageRating` when present.
  final double? averageRating;

  /// Discovery `hasActiveOffer` when present.
  final bool hasActiveOffer;

  /// Discovery `priceLevel` (1–5) when present.
  final int? priceLevel;

  /// Discovery `hasMenu` when present.
  final bool hasMenu;

  /// Discovery `status` raw value (e.g. `Active`).
  final String status;

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? cuisine,
    String? occasion,
    String? description,
    String? imageUrl,
    String? location,
    String? availabilityLabel,
    bool? isAvailable,
    List<String>? cuisineTags,
    List<String>? occasionTags,
    String? hoursLabel,
    Object? workingHours,
    double? averageRating,
    bool? hasActiveOffer,
    int? priceLevel,
    bool? hasMenu,
    String? status,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisine: cuisine ?? this.cuisine,
      occasion: occasion ?? this.occasion,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      availabilityLabel: availabilityLabel ?? this.availabilityLabel,
      isAvailable: isAvailable ?? this.isAvailable,
      cuisineTags: cuisineTags ?? this.cuisineTags,
      occasionTags: occasionTags ?? this.occasionTags,
      hoursLabel: hoursLabel ?? this.hoursLabel,
      workingHours: workingHours ?? this.workingHours,
      averageRating: averageRating ?? this.averageRating,
      hasActiveOffer: hasActiveOffer ?? this.hasActiveOffer,
      priceLevel: priceLevel ?? this.priceLevel,
      hasMenu: hasMenu ?? this.hasMenu,
      status: status ?? this.status,
    );
  }

  /// Maps `GET /discovery/restaurants` / `:id` (DiscoveryRestaurantResponseDto).
  factory RestaurantModel.fromDiscoveryJson(Map<String, dynamic> json) {
    final String status = ApiException.coerceString(json['status']);
    final bool isAvailable = status.isEmpty || status.toLowerCase() == 'active';

    final List<String> occasionTags = _readOccasionTags(json);
    final Object? workingHours = json['workingHours'];
    final String hoursLabel = WorkingHoursMapper.hasEntries(workingHours)
        ? WorkingHoursMapper.todayHoursLabel(
            workingHours,
            closedLabel: AppStrings.hoursClosed,
          )
        : '';
    return RestaurantModel(
      id: ApiException.coerceString(json['restaurantId'] ?? json['id']),
      name: ApiException.coerceString(json['name']),
      cuisine: _readCuisine(json),
      occasion: occasionTags.isNotEmpty ? occasionTags.first : '',
      description: ApiException.coerceString(json['description']),
      imageUrl: _readImageUrl(json),
      location: _readLocation(json),
      availabilityLabel: isAvailable
          ? AppStrings.openNow
          : AppStrings.hoursClosed,
      isAvailable: isAvailable,
      cuisineTags: _readCuisineTags(json),
      occasionTags: occasionTags,
      hoursLabel: hoursLabel,
      workingHours: workingHours,
      averageRating: _readAverageRating(json),
      hasActiveOffer: _readHasActiveOffer(json),
      priceLevel: _readPriceLevel(json),
      hasMenu: _readHasMenu(json),
      status: status,
    );
  }

  /// Maps `GET /users/me/favorites` list items (FavoriteListItemResponseDto).
  factory RestaurantModel.fromFavoriteJson(
    Map<String, dynamic> json, {
    required String availabilityLabel,
  }) {
    final String status = ApiException.coerceString(
      json['status'],
    ).toLowerCase();
    final bool isAvailable = status.isEmpty || status == 'active';
    final Object? cuisineRaw = json['cuisineType'] ?? json['cuisine'];
    final String cuisine = cuisineRaw is String
        ? cuisineRaw.trim()
        : ApiException.coerceString(cuisineRaw);

    return RestaurantModel(
      id: ApiException.coerceString(json['restaurantId'] ?? json['id']),
      name: ApiException.coerceString(json['name']),
      cuisine: cuisine,
      occasion: '',
      description: '',
      imageUrl: _readImageUrl(json),
      location: _readLocation(json),
      availabilityLabel: availabilityLabel,
      isAvailable: isAvailable,
    );
  }

  /// Parses API restaurant fields. Display labels are applied by the repository.
  factory RestaurantModel.fromJson(
    Map<String, dynamic> json, {
    required String availabilityLabel,
  }) {
    final String status = ApiException.coerceString(
      json['status'],
    ).toLowerCase();
    final bool isAvailable = status.isEmpty || status == 'active';

    return RestaurantModel(
      id: ApiException.coerceString(json['restaurantId'] ?? json['id']),
      name: ApiException.coerceString(json['name']),
      cuisine: _readCuisine(json),
      occasion: ApiException.coerceString(json['occasion']),
      description: ApiException.coerceString(json['description']),
      imageUrl: _readImageUrl(json),
      location: _readLocation(json),
      availabilityLabel: availabilityLabel,
      isAvailable: isAvailable,
    );
  }

  static String _readCuisine(Map<String, dynamic> json) {
    final Object? direct = json['cuisineType'] ?? json['cuisine'];
    final String fromDirect = ApiException.coerceString(direct);
    if (fromDirect.isNotEmpty) {
      return fromDirect;
    }
    final Object? categories = json['cuisineCategories'];
    if (categories is List && categories.isNotEmpty) {
      final Object? first = categories.first;
      if (first is Map) {
        final String name = ApiException.coerceString(
          Map<String, dynamic>.from(first)['name'],
        );
        if (name.isNotEmpty) {
          return name;
        }
      } else {
        final String asText = ApiException.coerceString(first);
        if (asText.isNotEmpty) {
          return asText;
        }
      }
    }
    return '';
  }

  static List<String> _readCuisineTags(Map<String, dynamic> json) {
    final List<String> fromCategories = _readCategoryNames(
      json['cuisineCategories'] ?? json['cuisines'],
    );
    if (fromCategories.isNotEmpty) {
      return fromCategories;
    }
    final String primary = _readCuisine(json);
    if (primary.isEmpty) {
      return const <String>[];
    }
    return <String>[primary];
  }

  static List<String> _readOccasionTags(Map<String, dynamic> json) {
    final List<String> fromCategories = _readCategoryNames(
      json['occasionCategories'] ??
          json['occasions'] ??
          json['occasionTags'] ??
          json['occasionCategoryNames'],
    );
    if (fromCategories.isNotEmpty) {
      return fromCategories;
    }
    final String direct = ApiException.coerceString(
      json['occasion'] ?? json['occasionType'],
    );
    if (direct.isEmpty) {
      return const <String>[];
    }
    return <String>[direct];
  }

  static List<String> _readCategoryNames(Object? raw) {
    if (raw is! List || raw.isEmpty) {
      return const <String>[];
    }
    final List<String> names = <String>[];
    for (final Object? item in raw) {
      if (item is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final String name = ApiException.coerceString(
          map['name'] ?? map['label'] ?? map['title'],
        );
        if (name.isNotEmpty && !names.contains(name)) {
          names.add(name);
        }
        continue;
      }
      final String asText = ApiException.coerceString(item);
      if (asText.isNotEmpty && !names.contains(asText)) {
        names.add(asText);
      }
    }
    return names;
  }

  static double? _readAverageRating(Map<String, dynamic> json) {
    final Object? raw = json['averageRating'];
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      return double.tryParse(raw.trim());
    }
    return null;
  }

  static bool _readHasActiveOffer(Map<String, dynamic> json) {
    return _readBoolFlag(json['hasActiveOffer']);
  }

  static bool _readHasMenu(Map<String, dynamic> json) {
    return _readBoolFlag(json['hasMenu']);
  }

  static bool _readBoolFlag(Object? raw) {
    if (raw is bool) {
      return raw;
    }
    if (raw is String) {
      final String normalized = raw.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    if (raw is num) {
      return raw != 0;
    }
    return false;
  }

  static int? _readPriceLevel(Map<String, dynamic> json) {
    final Object? raw = json['priceLevel'];
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim());
    }
    return null;
  }

  static String _readImageUrl(Map<String, dynamic> json) {
    for (final Object? candidate in <Object?>[
      json[AppStrings.apiMediaCoverImageUrlField],
      json[AppStrings.apiMediaImageUrlField],
      json[AppStrings.apiMediaLogoUrlField],
      json[AppStrings.apiMediaThumbnailUrlField],
      json[AppStrings.apiMediaCoverImageField],
      json[AppStrings.apiMediaLogoField],
      json['image'],
      json[AppStrings.apiMediaCoverImageIdField],
      json[AppStrings.apiMediaLogoIdField],
      json['imageId'],
      json['restaurantImage'],
    ]) {
      final String resolved = MediaUrlResolver.resolve(candidate);
      if (resolved.isNotEmpty) {
        return resolved;
      }
    }
    return '';
  }

  static String _readLocation(Map<String, dynamic> json) {
    for (final String key in const <String>[
      'location',
      'city',
      'address',
      'area',
    ]) {
      final String value = ApiException.coerceString(json[key]);
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}
