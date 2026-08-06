import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../../core/network/customer_identity_payload.dart';
import '../../../core/network/secure_auth_token_store.dart';
import '../../home/model/restaurant_model.dart';
import '../model/user_preferences_model.dart';
import '../model/user_profile_model.dart';

/// Users self-service APIs under `/users/me` (Profile + Favorites).
///
/// - `GET/PATCH /users/me`
/// - `GET/PATCH /users/me/preferences`
/// - `POST /users/me/avatar`
/// - `GET /users/me/favorites`
/// - `POST/DELETE /users/me/favorites/:restaurantId`
class UsersRepository {
  UsersRepository(
    this._apiClient, {
    FlutterSecureStorage? storage,
    SecureKeyValueStore? vault,
  }) : _vault =
           vault ??
           (storage != null
               ? SerializingSecureKeyValueStore(
                   FlutterSecureKeyValueStore(storage),
                 )
               : SecureAuthTokenStore.sharedVault);

  final ApiClient _apiClient;
  final SecureKeyValueStore _vault;

  static const String mePath = '/users/me';
  static const String preferencesPath = '/users/me/preferences';
  static const String avatarPath = '/users/me/avatar';
  static const String favoritesPath = '/users/me/favorites';
  static const String _usernameKey = 'customer_username';
  static const String _phoneKey = 'customer_phone';
  static const String _avatarUrlKey = 'customer_avatar_url';

  final Rxn<UserProfileModel> profileRx = Rxn<UserProfileModel>();
  UserPreferencesModel? _cachedPreferences;
  List<RestaurantModel> _cachedFavoriteRestaurants = const <RestaurantModel>[];
  bool _profileLoadAttempted = false;
  Future<void>? _profileLoadInFlight;
  String _cachedUsername = '';
  String _cachedPhone = '';
  String _cachedAvatarUrl = '';
  bool _identityHydrated = false;

  UserProfileModel? get cachedProfile => profileRx.value;
  UserPreferencesModel? get cachedPreferences => _cachedPreferences;
  List<RestaurantModel> get cachedFavoriteRestaurants =>
      List<RestaurantModel>.unmodifiable(_cachedFavoriteRestaurants);
  List<String> get cachedFavoriteRestaurantIds => _cachedFavoriteRestaurants
      .map((RestaurantModel item) => item.id)
      .toList(growable: false);

  /// Clears in-memory user session caches so a new/guest session never sees
  /// stale profile, avatar, preferences, or favorites from a prior account.
  void clearSessionCaches() {
    profileRx.value = null;
    _cachedPreferences = null;
    _cachedFavoriteRestaurants = const <RestaurantModel>[];
    _profileLoadAttempted = false;
    _profileLoadInFlight = null;
  }

  /// Applies signup/login username + phone in memory (never blocks on Keychain).
  ///
  /// Empty [username] / [phone] mean "keep the current cached value" so a
  /// partial login payload cannot wipe identity that already landed in memory.
  void applyCustomerIdentityInMemory({
    required String username,
    required String phone,
    String? avatarUrl,
  }) {
    final String nextUsername = username.trim();
    final String nextPhone = phone.trim();
    if (nextUsername.isNotEmpty) {
      _cachedUsername = nextUsername;
    }
    if (nextPhone.isNotEmpty) {
      _cachedPhone = nextPhone;
    }
    final String normalizedAvatar = _normalizeAvatarUrl(avatarUrl);
    if (normalizedAvatar.isNotEmpty) {
      _cachedAvatarUrl = normalizedAvatar;
    }
    _identityHydrated = true;

    final UserProfileModel? current = profileRx.value;
    if (current != null) {
      profileRx.value = current.copyWith(
        username: _cachedUsername.isNotEmpty
            ? _cachedUsername
            : current.username,
        phone: _cachedPhone.isNotEmpty ? _cachedPhone : current.phone,
        avatarUrl: _cachedAvatarUrl.isNotEmpty
            ? _cachedAvatarUrl
            : current.avatarUrl,
      );
    } else if (_cachedUsername.isNotEmpty || _cachedPhone.isNotEmpty) {
      // Guest→login can finish before `/users/me` — expose identity immediately.
      profileRx.value = UserProfileModel(
        id: '',
        firstName: '',
        lastName: '',
        email: '',
        username: _cachedUsername,
        phone: _cachedPhone.isEmpty ? null : _cachedPhone,
        avatarUrl: _cachedAvatarUrl.isEmpty ? null : _cachedAvatarUrl,
      );
    }

    // Memory is enough for Login→Home. Disk is scheduled by
    // [flushIdentityToDisk] after Home's first frames (shared Keychain vault).
    _identityDiskDirty = true;
  }

  /// Memory apply + marks identity dirty for a later Keychain flush.
  Future<void> rememberCustomerIdentity({
    required String username,
    required String phone,
    String? avatarUrl,
  }) async {
    applyCustomerIdentityInMemory(
      username: username,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }

  /// Allows `/users/me` to run again after guest probing skipped the load.
  void resetProfileLoadGate() {
    _profileLoadAttempted = false;
    _profileLoadInFlight = null;
  }

  bool _identityDiskDirty = false;

  /// Best-effort Keychain flush for cached username/phone.
  Future<void> flushIdentityToDisk() async {
    if (!_identityDiskDirty) {
      return;
    }
    _identityDiskDirty = false;
    await _persistIdentityToDisk(_cachedUsername, _cachedPhone);
  }

  Future<void> _persistIdentityToDisk(String username, String phone) async {
    try {
      await Future.wait<void>(<Future<void>>[
        username.isEmpty
            ? _vault.delete(_usernameKey)
            : _vault.write(_usernameKey, username),
        phone.isEmpty
            ? _vault.delete(_phoneKey)
            : _vault.write(_phoneKey, phone),
        _cachedAvatarUrl.isEmpty
            ? _vault.delete(_avatarUrlKey)
            : _vault.write(_avatarUrlKey, _cachedAvatarUrl),
      ]).timeout(AppDimensions.secureStorageTimeout);
    } catch (_) {
      // Identity remains available in memory for this session.
    }
  }

  Future<void> clearCustomerIdentity() async {
    _cachedUsername = '';
    _cachedPhone = '';
    _cachedAvatarUrl = '';
    _identityHydrated = true;
    _identityDiskDirty = false;
    unawaited(_clearIdentityOnDisk());
  }

  Future<void> _clearIdentityOnDisk() async {
    try {
      await Future.wait<void>(<Future<void>>[
        _vault.delete(_usernameKey),
        _vault.delete(_phoneKey),
        _vault.delete(_avatarUrlKey),
      ]).timeout(AppDimensions.secureStorageTimeout);
    } catch (_) {
      // Guest / logout must not block on storage.
    }
  }

  Future<void> _hydrateCustomerIdentity() async {
    if (_identityHydrated) {
      return;
    }
    try {
      final List<String?> values = await Future.wait<String?>(<Future<String?>>[
        _vault.read(_usernameKey),
        _vault.read(_phoneKey),
        _vault.read(_avatarUrlKey),
      ]).timeout(AppDimensions.secureStorageTimeout);
      final String diskUsername = values[0]?.trim() ?? '';
      final String diskPhone = values[1]?.trim() ?? '';
      final String diskAvatar = _normalizeAvatarUrl(values[2]);
      // Login may call [rememberCustomerIdentity] while this await is in flight.
      // Never clobber a fresher in-memory username/phone with empty Keychain.
      if (_cachedUsername.isEmpty && diskUsername.isNotEmpty) {
        _cachedUsername = diskUsername;
      }
      if (_cachedPhone.isEmpty && diskPhone.isNotEmpty) {
        _cachedPhone = diskPhone;
      }
      if (_cachedAvatarUrl.isEmpty && diskAvatar.isNotEmpty) {
        _cachedAvatarUrl = diskAvatar;
      }
    } catch (_) {
      // Keep any in-memory login identity; disk is best-effort only.
    }
    _identityHydrated = true;
  }

  /// Loads `/users/me` once for shared header avatar (safe to call repeatedly).
  Future<void> ensureProfileLoaded() async {
    if (_profileLoadAttempted) {
      return;
    }
    final Future<void>? inFlight = _profileLoadInFlight;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final Completer<void> completer = Completer<void>();
    _profileLoadInFlight = completer.future;
    try {
      // Anonymous guest / no Bearer — skip without locking the gate so a later
      // login can still load `/users/me` (Home progressive init is one-shot).
      if (Get.isRegistered<GuestModeReader>() &&
          Get.find<GuestModeReader>().isAnonymousGuest) {
        return;
      }
      if (Get.isRegistered<AuthTokenReader>()) {
        final String? access = await Get.find<AuthTokenReader>()
            .readAccessToken();
        if (access == null || access.trim().isEmpty) {
          return;
        }
      }
      _profileLoadAttempted = true;
      try {
        await fetchMyProfile();
      } catch (_) {
        // Header keeps the fallback avatar asset.
      }
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
      _profileLoadInFlight = null;
    }
  }

  Future<UserProfileModel> fetchMyProfile() async {
    await _hydrateCustomerIdentity();
    final UserProfileModel? previous = profileRx.value;
    final ApiResponse<UserProfileModel> response = await _apiClient
        .get<UserProfileModel>(mePath, parseData: _parseProfile);
    final String? previousAvatar = previous?.avatarUrl;
    UserProfileModel profile = _normalizeProfileAvatar(
      _mergeCustomerIdentity(response.data, previous: previous),
    );
    // Profile DTO may omit avatar; keep the last uploaded URL when present.
    if ((profile.avatarUrl == null || profile.avatarUrl!.trim().isEmpty) &&
        previousAvatar != null &&
        previousAvatar.trim().isNotEmpty) {
      profile = profile.copyWith(avatarUrl: previousAvatar);
    }
    // `/users/me` currently omits username — never let that wipe login identity.
    if (profile.username.trim().isEmpty) {
      final String fallback = _cachedUsername.isNotEmpty
          ? _cachedUsername
          : (previous?.username.trim() ?? '');
      if (fallback.isNotEmpty) {
        profile = profile.copyWith(username: fallback);
        _cachedUsername = fallback;
      }
    } else {
      _cachedUsername = profile.username.trim();
    }
    if (kDebugMode) {
      debugPrint(
        '[ProfileIdentity] merged username="${profile.username}" '
        'cache="$_cachedUsername"',
      );
    }
    profileRx.value = profile;
    _profileLoadAttempted = true;
    _identityDiskDirty = true;
    unawaited(flushIdentityToDisk());
    return profile;
  }

  UserProfileModel _mergeCustomerIdentity(
    UserProfileModel profile, {
    UserProfileModel? previous,
  }) {
    final String previousUsername = previous?.username.trim() ?? '';
    final String username = profile.username.trim().isNotEmpty
        ? profile.username.trim()
        : (_cachedUsername.isNotEmpty ? _cachedUsername : previousUsername);
    final String phone = (profile.phone?.trim().isNotEmpty == true)
        ? profile.phone!.trim()
        : (_cachedPhone.isNotEmpty
              ? _cachedPhone
              : (previous?.phone?.trim() ?? ''));
    final String avatarUrl = _normalizeAvatarUrl(
      profile.avatarUrl?.trim().isNotEmpty == true
          ? profile.avatarUrl
          : (_cachedAvatarUrl.isNotEmpty
                ? _cachedAvatarUrl
                : previous?.avatarUrl),
    );
    if (username == profile.username &&
        phone == (profile.phone ?? '') &&
        avatarUrl == (profile.avatarUrl ?? '')) {
      return profile;
    }
    return profile.copyWith(
      username: username,
      phone: phone.isEmpty ? profile.phone : phone,
      avatarUrl: avatarUrl.isEmpty ? profile.avatarUrl : avatarUrl,
    );
  }

  /// Full-replace update matching `UpdateUserProfileRequestDto`.
  Future<UserProfileModel> updateMyProfile({
    required String firstName,
    required String lastName,
    required String language,
    String? phone,
    String? preferredCurrency,
  }) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'language': language,
    };
    if (phone != null) {
      data['phone'] = phone;
    }
    if (preferredCurrency != null) {
      data['preferredCurrency'] = preferredCurrency;
    }

    final ApiResponse<UserProfileModel> response = await _apiClient
        .patch<UserProfileModel>(mePath, data: data, parseData: _parseProfile);
    final String? previousAvatar = profileRx.value?.avatarUrl;
    UserProfileModel profile = _normalizeProfileAvatar(
      _mergeCustomerIdentity(response.data),
    );
    if ((profile.avatarUrl == null || profile.avatarUrl!.trim().isEmpty) &&
        previousAvatar != null &&
        previousAvatar.trim().isNotEmpty) {
      profile = profile.copyWith(avatarUrl: previousAvatar);
    }
    profileRx.value = profile;
    return profile;
  }

  Future<UserPreferencesModel> fetchMyPreferences() async {
    final ApiResponse<UserPreferencesModel> response = await _apiClient
        .get<UserPreferencesModel>(
          preferencesPath,
          parseData: _parsePreferences,
        );
    _cachedPreferences = response.data;
    return response.data;
  }

  Future<UserPreferencesModel> updateMyPreferences({
    required bool notificationOptIn,
    required bool marketingOptIn,
  }) async {
    final ApiResponse<UserPreferencesModel> response = await _apiClient
        .patch<UserPreferencesModel>(
          preferencesPath,
          data: <String, dynamic>{
            'notificationOptIn': notificationOptIn,
            'marketingOptIn': marketingOptIn,
          },
          parseData: _parsePreferences,
        );
    _cachedPreferences = response.data;
    return response.data;
  }

  /// `POST /users/me/avatar` returns UploadAvatarResponseDto (not full profile).
  Future<UserProfileModel> uploadMyAvatar({
    required String filePath,
    String? fileName,
  }) async {
    final String before = _normalizeAvatarUrl(profileRx.value?.avatarUrl);
    final ApiResponse<String> response = await _postAvatarMultipart(
      filePath: filePath,
      fileName: fileName,
    );
    final UserProfileModel refreshedProfile = await fetchMyProfile();
    final String fromProfile = _normalizeAvatarUrl(refreshedProfile.avatarUrl);
    final String fromUpload = _normalizeAvatarUrl(response.data);
    final String resolvedAvatar = fromProfile.isNotEmpty
        ? fromProfile
        : (fromUpload.isNotEmpty ? fromUpload : before);
    if (resolvedAvatar.isEmpty) {
      throw ApiException(message: AppStrings.avatarUploadFailed);
    }
    final UserProfileModel updated = refreshedProfile.copyWith(
      avatarUrl: resolvedAvatar,
    );
    if (resolvedAvatar.isNotEmpty) {
      _cachedAvatarUrl = resolvedAvatar;
      _identityDiskDirty = true;
      unawaited(flushIdentityToDisk());
    }
    profileRx.value = updated;
    return updated;
  }

  Future<ApiResponse<String>> _postAvatarMultipart({
    required String filePath,
    String? fileName,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      // Some deployments expect different multipart field names; send all
      // aliases so avatar persistence does not depend on one backend variant.
      AppStrings.apiAvatarUploadFieldFile: await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
      AppStrings.apiAvatarUploadFieldAvatar: await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
      AppStrings.apiAvatarUploadFieldImage: await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
      AppStrings.apiAvatarUploadFieldProfileImage: await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });
    return _apiClient.postMultipart<String>(
      avatarPath,
      formData: formData,
      parseData: _parseAvatarUrl,
    );
  }

  UserProfileModel _normalizeProfileAvatar(UserProfileModel profile) {
    final String normalized = _normalizeAvatarUrl(profile.avatarUrl);
    if (normalized.isEmpty || normalized == profile.avatarUrl) {
      return profile;
    }
    return profile.copyWith(avatarUrl: normalized);
  }

  String _normalizeAvatarUrl(String? raw) {
    final String value = (raw ?? '').trim();
    if (value.isEmpty) {
      return '';
    }
    if (value.startsWith('${AppStrings.apiHttpSchemePrefix}//') ||
        value.startsWith('${AppStrings.apiHttpsSchemePrefix}//')) {
      return value;
    }
    if (value.startsWith('//')) {
      final Uri base = Uri.parse(AppUrls.apiBaseUrl);
      final String scheme = base.scheme.isNotEmpty
          ? base.scheme
          : AppStrings.apiHttpSchemePrefix.replaceAll(':', '');
      return '$scheme:$value';
    }
    final Uri base = Uri.parse(AppUrls.apiBaseUrl);
    final String origin = '${base.scheme}://${base.authority}';
    if (value.startsWith('/')) {
      return '$origin$value';
    }
    return '$origin/$value';
  }

  /// `GET /users/me/favorites` — restaurant summaries for Profile / Favorites UI.
  Future<List<RestaurantModel>> fetchFavoriteRestaurants({
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
  }) async {
    final ApiResponse<List<RestaurantModel>> response = await _apiClient
        .get<List<RestaurantModel>>(
          favoritesPath,
          queryParameters: <String, dynamic>{'page': page, 'limit': limit},
          parseData: _parseFavoriteRestaurants,
        );
    _cachedFavoriteRestaurants = List<RestaurantModel>.unmodifiable(
      response.data,
    );
    return _cachedFavoriteRestaurants;
  }

  Future<void> addFavoriteRestaurant(String restaurantId) async {
    await _apiClient.postNoContent('$favoritesPath/$restaurantId');
  }

  Future<void> removeFavoriteRestaurant(String restaurantId) async {
    await _apiClient.deleteNoContent('$favoritesPath/$restaurantId');
  }

  static UserProfileModel _parseProfile(Object? raw) {
    if (raw is Map) {
      final Map<String, dynamic> flattened =
          CustomerIdentityPayload.flatten(raw);
      if (kDebugMode) {
        debugPrint(
          '[ProfileIdentity] keys=${flattened.keys.toList()} '
          'username="${flattened['username'] ?? ''}"',
        );
      }
      return UserProfileModel.fromJson(flattened);
    }
    throw ArgumentError(AppStrings.invalidUserProfilePayload);
  }

  /// Test seam for `/users/me` identity flattening.
  @visibleForTesting
  static UserProfileModel parseProfileForTest(Object? raw) =>
      _parseProfile(raw);

  static UserPreferencesModel _parsePreferences(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return UserPreferencesModel.fromJson(raw);
    }
    throw ArgumentError(AppStrings.invalidUserPreferencesPayload);
  }

  static String _parseAvatarUrl(Object? raw) {
    final String parsed = _extractAvatarUrl(raw);
    return parsed.trim();
  }

  static String _extractAvatarUrl(Object? raw) {
    if (raw is String) {
      return raw;
    }
    if (raw is! Map<String, dynamic>) {
      return '';
    }

    const List<String> preferredKeys = <String>[
      AppStrings.apiAvatarFieldAvatarUrl,
      'avatar_url',
      AppStrings.apiAvatarFieldAvatar,
      AppStrings.apiAvatarFieldImageUrl,
      AppStrings.apiAvatarFieldUrl,
      AppStrings.apiAvatarFieldPath,
      'avatarPath',
      'profileImage',
      'secure_url',
    ];

    for (final String key in preferredKeys) {
      final Object? value = raw[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value is Map<String, dynamic>) {
        final String nested = _extractAvatarUrl(value).trim();
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }

    for (final Object? value in raw.values) {
      if (value is Map<String, dynamic>) {
        final String nested = _extractAvatarUrl(value).trim();
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }
    return '';
  }

  static List<RestaurantModel> _parseFavoriteRestaurants(Object? raw) {
    final List<dynamic> items;
    if (raw is Map<String, dynamic> && raw['items'] is List) {
      items = raw['items'] as List<dynamic>;
    } else if (raw is List) {
      items = raw;
    } else {
      items = const <dynamic>[];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> json) {
          final String status = (json['status'] as String?)?.trim() ?? '';
          final bool isAvailable =
              status.isEmpty ||
              status.toLowerCase() == AppStrings.apiFloorPlanStatusActive;
          return RestaurantModel.fromFavoriteJson(
            json,
            availabilityLabel: isAvailable
                ? AppStrings.openNow
                : AppStrings.hoursClosed,
          );
        })
        .where((RestaurantModel item) => item.id.isNotEmpty)
        .toList(growable: false);
  }
}
