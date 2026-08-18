import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../model/cuisine_category_model.dart';
import '../model/occasion_category_model.dart';

/// Remote taxonomy (cuisine + occasion categories).
///
/// In-memory caches let Home paint from warm data on the first frame after
/// an idle prefetch (Welcome / Login), without blocking route Bindings.
class TaxonomyRepository {
  TaxonomyRepository(this._apiClient);

  final ApiClient _apiClient;

  static const String cuisineCategoriesPath = AppUrls.cuisineCategoriesPath;
  static const String occasionCategoriesPath = AppUrls.occasionCategoriesPath;

  List<CuisineCategoryModel>? _cuisineCache;
  List<OccasionCategoryModel>? _occasionCache;
  Future<List<CuisineCategoryModel>>? _cuisineInFlight;
  Future<List<OccasionCategoryModel>>? _occasionInFlight;

  /// Sync snapshot for HomeController.onInit — null until first successful fetch.
  List<CuisineCategoryModel>? get cachedCuisineCategories => _cuisineCache;

  List<OccasionCategoryModel>? get cachedOccasionCategories => _occasionCache;

  /// Idle warm-up used by [HomeEntryWarmup] — dedupes concurrent callers.
  Future<void> prefetch() async {
    await Future.wait<void>(<Future<void>>[
      fetchCuisineCategories(),
      fetchOccasionCategories(),
    ]);
  }

  Future<List<CuisineCategoryModel>> fetchCuisineCategories({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cuisineCache != null) {
      return _cuisineCache!;
    }
    final Future<List<CuisineCategoryModel>>? inFlight = _cuisineInFlight;
    if (inFlight != null) {
      return inFlight;
    }
    final Future<List<CuisineCategoryModel>> request = _loadCuisineCategories();
    _cuisineInFlight = request;
    try {
      return await request;
    } finally {
      if (identical(_cuisineInFlight, request)) {
        _cuisineInFlight = null;
      }
    }
  }

  Future<List<OccasionCategoryModel>> fetchOccasionCategories({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _occasionCache != null) {
      return _occasionCache!;
    }
    final Future<List<OccasionCategoryModel>>? inFlight = _occasionInFlight;
    if (inFlight != null) {
      return inFlight;
    }
    final Future<List<OccasionCategoryModel>> request =
        _loadOccasionCategories();
    _occasionInFlight = request;
    try {
      return await request;
    } finally {
      if (identical(_occasionInFlight, request)) {
        _occasionInFlight = null;
      }
    }
  }

  Future<List<CuisineCategoryModel>> _loadCuisineCategories() async {
    final ApiResponse<List<CuisineCategoryModel>> response = await _apiClient
        .get<List<CuisineCategoryModel>>(
          cuisineCategoriesPath,
          options: ApiClient.skipAuthOptions(),
          parseData: _parseCuisineItems,
        );
    final List<CuisineCategoryModel> items =
        List<CuisineCategoryModel>.from(response.data)..sort(
          (CuisineCategoryModel a, CuisineCategoryModel b) =>
              a.sortOrder.compareTo(b.sortOrder),
        );
    final List<CuisineCategoryModel> cached =
        List<CuisineCategoryModel>.unmodifiable(items);
    _cuisineCache = cached;
    return cached;
  }

  Future<List<OccasionCategoryModel>> _loadOccasionCategories() async {
    final ApiResponse<List<OccasionCategoryModel>> response = await _apiClient
        .get<List<OccasionCategoryModel>>(
          occasionCategoriesPath,
          options: ApiClient.skipAuthOptions(),
          parseData: _parseOccasionItems,
        );
    final List<OccasionCategoryModel> items =
        List<OccasionCategoryModel>.from(response.data)..sort(
          (OccasionCategoryModel a, OccasionCategoryModel b) =>
              a.sortOrder.compareTo(b.sortOrder),
        );
    final List<OccasionCategoryModel> cached =
        List<OccasionCategoryModel>.unmodifiable(items);
    _occasionCache = cached;
    return cached;
  }

  static List<CuisineCategoryModel> _parseCuisineItems(Object? raw) {
    final List<dynamic> items = _extractItems(raw);
    final List<CuisineCategoryModel> parsed = <CuisineCategoryModel>[];
    for (final dynamic item in items) {
      if (item is! Map) {
        continue;
      }
      try {
        parsed.add(
          CuisineCategoryModel.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (_) {
        // Skip malformed rows — never fail the whole Home taxonomy load.
      }
    }
    return parsed;
  }

  static List<OccasionCategoryModel> _parseOccasionItems(Object? raw) {
    final List<dynamic> items = _extractItems(raw);
    final List<OccasionCategoryModel> parsed = <OccasionCategoryModel>[];
    for (final dynamic item in items) {
      if (item is! Map) {
        continue;
      }
      try {
        parsed.add(
          OccasionCategoryModel.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (_) {
        // Skip malformed rows — never fail the whole Home taxonomy load.
      }
    }
    return parsed;
  }

  static List<dynamic> _extractItems(Object? raw) {
    if (raw is Map) {
      final Object? items = raw['items'];
      if (items is List) {
        return items;
      }
    }
    if (raw is List) {
      return raw;
    }
    return const <dynamic>[];
  }
}
