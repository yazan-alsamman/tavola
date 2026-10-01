import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

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
import '../model/delete_account_result_model.dart';
import '../model/export_user_data_result_model.dart';
import '../model/user_preferences_model.dart';
import '../model/user_profile_model.dart';

/// Users self-service APIs under `/users/me` (Profile + Favorites).
///
/// - `GET/PATCH /users/me`
/// - `DELETE /users/me` (request account deletion)
/// - `POST /users/me/cancel-deletion`
/// - `GET /users/me/export`
/// - `GET/PATCH /users/me/preferences`
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

  static const String mePath = AppUrls.usersMePath;
  static const String exportPath = AppUrls.usersMeExportPath;
  static const String cancelDeletionPath = AppUrls.usersMeCancelDeletionPath;
  static const String preferencesPath = AppUrls.usersMePreferencesPath;
  static const String favoritesPath = AppUrls.usersMeFavoritesPath;
  static const String _pageQueryKey = 'page';
  static const String _pageSizeQueryKey = 'pageSize';
  static const String _limitQueryKey = 'limit';
  static const String _usernameKey = 'customer_username';
  static const String _phoneKey = 'customer_phone';
  static const String _pendingDeletionAtKey =
      'customer_pending_account_deletion_at';

  final Rxn<UserProfileModel> profileRx = Rxn<UserProfileModel>();
  final RxBool hasPendingAccountDeletion = false.obs;
  UserPreferencesModel? _cachedPreferences;
  List<RestaurantModel> _cachedFavoriteRestaurants = const <RestaurantModel>[];
  bool _profileLoadAttempted = false;
  Future<void>? _profileLoadInFlight;
  String _cachedUsername = '';
  String _cachedPhone = '';
  bool _identityHydrated = false;

  UserProfileModel? get cachedProfile => profileRx.value;
  UserPreferencesModel? get cachedPreferences => _cachedPreferences;
  List<RestaurantModel> get cachedFavoriteRestaurants =>
      List<RestaurantModel>.unmodifiable(_cachedFavoriteRestaurants);
  List<String> get cachedFavoriteRestaurantIds => _cachedFavoriteRestaurants
      .map((RestaurantModel item) => item.id)
      .toList(growable: false);

  /// Clears in-memory user session caches so a new/guest session never sees
  /// stale profile, preferences, or favorites from a prior account.
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
  }) {
    final String nextUsername = username.trim();
    final String nextPhone = phone.trim();
    if (nextUsername.isNotEmpty) {
      _cachedUsername = nextUsername;
    }
    if (nextPhone.isNotEmpty) {
      _cachedPhone = nextPhone;
    }
    _identityHydrated = true;

    final UserProfileModel? current = profileRx.value;
    if (current != null) {
      profileRx.value = current.copyWith(
        username: _cachedUsername.isNotEmpty
            ? _cachedUsername
            : current.username,
        phone: _cachedPhone.isNotEmpty ? _cachedPhone : current.phone,
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
  }) async {
    applyCustomerIdentityInMemory(username: username, phone: phone);
  }

  /// Allows `/users/me` to run again after guest probing skipped the load.
  void resetProfileLoadGate() {
    _profileLoadAttempted = false;
    _profileLoadInFlight = null;
  }

  bool _identityDiskDirty = false;

  /// Best-effort Keychain flush for cached username/phone.
  Future<void> flushIdentityToDisk() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return;
    }
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
      ]).timeout(AppDimensions.secureStorageTimeout);
    } catch (_) {
      // Identity remains available in memory for this session.
    }
  }

  Future<void> clearCustomerIdentity() async {
    _cachedUsername = '';
    _cachedPhone = '';
    _identityHydrated = true;
    _identityDiskDirty = false;
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      unawaited(_clearIdentityOnDisk());
    }
  }

  Future<void> _clearIdentityOnDisk() async {
    try {
      await Future.wait<void>(<Future<void>>[
        _vault.delete(_usernameKey),
        _vault.delete(_phoneKey),
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
      ]).timeout(AppDimensions.secureStorageTimeout);
      final String diskUsername = values[0]?.trim() ?? '';
      final String diskPhone = values[1]?.trim() ?? '';
      // Login may call [rememberCustomerIdentity] while this await is in flight.
      // Never clobber a fresher in-memory username/phone with empty Keychain.
      if (_cachedUsername.isEmpty && diskUsername.isNotEmpty) {
        _cachedUsername = diskUsername;
      }
      if (_cachedPhone.isEmpty && diskPhone.isNotEmpty) {
        _cachedPhone = diskPhone;
      }
    } catch (_) {
      // Keep any in-memory login identity; disk is best-effort only.
    }
    _identityHydrated = true;
  }

  /// Loads `/users/me` once for shared profile identity (safe to call repeatedly).
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
        // Profile card keeps the last in-memory identity.
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
    UserProfileModel profile = _mergeCustomerIdentity(
      response.data,
      previous: previous,
    );
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
    if (username == profile.username && phone == (profile.phone ?? '')) {
      return profile;
    }
    return profile.copyWith(
      username: username,
      phone: phone.isEmpty ? profile.phone : phone,
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
    final UserProfileModel profile = _mergeCustomerIdentity(response.data);
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

  /// `GET /users/me/favorites?page=&pageSize=` — favorites list.
  Future<List<RestaurantModel>> fetchFavoriteRestaurants({
    int page = AppDimensions.apiDefaultPage,
    int limit = AppDimensions.apiDefaultLimit,
  }) async {
    final List<Map<String, dynamic>> queries = <Map<String, dynamic>>[
      <String, dynamic>{_pageQueryKey: page, _pageSizeQueryKey: limit},
      <String, dynamic>{_pageQueryKey: page, _limitQueryKey: limit},
      <String, dynamic>{_limitQueryKey: limit},
      const <String, dynamic>{},
    ];

    ApiException? lastError;
    for (int index = 0; index < queries.length; index++) {
      final Map<String, dynamic> query = queries[index];
      try {
        final ApiResponse<List<RestaurantModel>> response = await _apiClient
            .get<List<RestaurantModel>>(
              favoritesPath,
              queryParameters: query.isEmpty ? null : query,
              parseData: _parseFavoriteRestaurants,
            );
        _cachedFavoriteRestaurants = List<RestaurantModel>.unmodifiable(
          response.data,
        );
        return _cachedFavoriteRestaurants;
      } on ApiException catch (error) {
        lastError = error;
        final bool hasNext = index < queries.length - 1;
        if (!hasNext || !_shouldRetryFavoritePagination(error)) {
          rethrow;
        }
      }
    }
    throw lastError ?? ApiException.unexpected();
  }

  static bool _shouldRetryFavoritePagination(ApiException error) {
    if (!error.isValidation && error.statusCode != 400) {
      return false;
    }
    final String message = error.message.toLowerCase();
    return message.contains('pagesize') ||
        message.contains('page size') ||
        message.contains('property page should not exist') ||
        message.contains('property limit should not exist') ||
        message.contains('unknown query');
  }

  Future<void> addFavoriteRestaurant(String restaurantId) async {
    await _apiClient.postNoContent(AppUrls.usersMeFavoritePath(restaurantId));
  }

  Future<void> removeFavoriteRestaurant(String restaurantId) async {
    await _apiClient.deleteNoContent(AppUrls.usersMeFavoritePath(restaurantId));
  }

  /// `GET /users/me/export` — GDPR portability export bundle.
  Future<ExportUserDataResultModel> exportMyData() async {
    final ApiResponse<ExportUserDataResultModel> response = await _apiClient
        .get<ExportUserDataResultModel>(
          exportPath,
          parseData: (Object? raw) {
            if (raw is Map) {
              return ExportUserDataResultModel.fromJson(
                Map<String, dynamic>.from(raw),
              );
            }
            return const ExportUserDataResultModel(
              exportedAt: '',
              reservationsTotal: 0,
              reviewsTotal: 0,
              favoritesTotal: 0,
            );
          },
        );
    return ExportUserDataResultModel(
      exportedAt: response.data.exportedAt,
      reservationsTotal: response.data.reservationsTotal,
      reviewsTotal: response.data.reviewsTotal,
      favoritesTotal: response.data.favoritesTotal,
      message: response.message,
    );
  }

  /// `DELETE /users/me` — schedule anonymization (grace period).
  Future<DeleteAccountResultModel> requestAccountDeletion({
    required String password,
  }) async {
    final ApiResponse<DeleteAccountResultModel> response = await _apiClient
        .delete<DeleteAccountResultModel>(
          mePath,
          data: <String, dynamic>{'password': password},
          parseData: (Object? raw) {
            if (raw is Map) {
              return DeleteAccountResultModel.fromJson(
                Map<String, dynamic>.from(raw),
              );
            }
            return const DeleteAccountResultModel(scheduledAnonymizationAt: '');
          },
        );
    final DeleteAccountResultModel result = DeleteAccountResultModel(
      scheduledAnonymizationAt: response.data.scheduledAnonymizationAt,
      message: response.message,
    );
    await markPendingAccountDeletion(
      scheduledAnonymizationAt: result.scheduledAnonymizationAt,
    );
    return result;
  }

  /// `POST /users/me/cancel-deletion` — 204, idempotent.
  Future<void> cancelAccountDeletion() async {
    await _apiClient.postNoContent(cancelDeletionPath);
    await clearPendingAccountDeletion();
  }

  Future<void> markPendingAccountDeletion({
    required String scheduledAnonymizationAt,
  }) async {
    hasPendingAccountDeletion.value = true;
    final String value = scheduledAnonymizationAt.trim().isEmpty
        ? 'pending'
        : scheduledAnonymizationAt.trim();
    try {
      await _vault
          .write(_pendingDeletionAtKey, value)
          .timeout(AppDimensions.secureStorageTimeout);
    } catch (_) {
      // In-memory flag still drives Settings cancel row.
    }
  }

  Future<void> clearPendingAccountDeletion() async {
    hasPendingAccountDeletion.value = false;
    try {
      await _vault
          .delete(_pendingDeletionAtKey)
          .timeout(AppDimensions.secureStorageTimeout);
    } catch (_) {
      // Best-effort disk clear.
    }
  }

  Future<void> hydratePendingAccountDeletion() async {
    try {
      final String? raw = await _vault
          .read(_pendingDeletionAtKey)
          .timeout(AppDimensions.secureStorageTimeout);
      hasPendingAccountDeletion.value = raw != null && raw.trim().isNotEmpty;
    } catch (_) {
      // Keep current in-memory value.
    }
  }

  static UserProfileModel _parseProfile(Object? raw) {
    if (raw is Map) {
      final Map<String, dynamic> flattened = CustomerIdentityPayload.flatten(
        raw,
      );
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
