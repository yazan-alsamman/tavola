import 'dart:async';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/routes/app_routes.dart';
import '../../../common/widgets/app_confirm_dialog.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/navigation/bottom_nav_navigation.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_token_reader.dart';
import '../../../core/utils/app_dependency.dart';
import '../../../core/utils/post_frame_work.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../details/controller/details_controller.dart';
import '../../details/controller/restaurant_menu_controller.dart';
import '../../favorites/repository/favorites_repository.dart';
import '../../home/model/restaurant_model.dart';
import '../../notifications/controller/notifications_badge_controller.dart';
import '../../reservation/controller/reservation_controller.dart';
import '../../reservation/model/customer_reservation_model.dart';
import '../../reservation/model/reservation_route_args.dart';
import '../../reservation/repository/reservation_repository.dart';
import '../../reviews/model/review_model.dart';
import '../../reviews/repository/reviews_repository.dart';
import '../../reviews/widgets/write_review_sheet.dart';
import '../../users/model/user_preferences_model.dart';
import '../../users/model/user_profile_model.dart';
import '../../users/repository/users_repository.dart';
import '../model/reservation_history_item_model.dart';
import '../repository/profile_repository.dart';

class ProfileController extends GetxController {
  static const int activeReservationsSectionIndex = 0;
  static const int lastReservationsSectionIndex = 1;
  static const int favoritesSectionIndex = 2;
  static const int settingsSectionIndex = 3;
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;

  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();
  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();
  final UsersRepository _usersRepository = Get.find<UsersRepository>();
  final ReservationRepository _reservationRepository =
      Get.find<ReservationRepository>();
  final ReviewsRepository _reviewsRepository = Get.find<ReviewsRepository>();
  final ImagePicker _imagePicker = ImagePicker();

  final RxInt selectedSectionIndex = 0.obs;
  final RxList<bool> notificationSettings = <bool>[].obs;
  final RxList<String> sections = <String>[].obs;
  final RxList<(String, String)> notificationOptions = <(String, String)>[].obs;
  final RxList<(String, String)> reservationDetails = <(String, String)>[].obs;
  final RxList<ReservationHistoryItemModel> reservationHistory =
      <ReservationHistoryItemModel>[].obs;
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;

  final Rxn<UserProfileModel> userProfile = Rxn<UserProfileModel>();
  final Rxn<UserPreferencesModel> userPreferences = Rxn<UserPreferencesModel>();
  final RxBool isLoadingProfile = false.obs;
  final RxBool isLoadingReservations = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxBool isReviewBusy = false.obs;
  final RxnString profileError = RxnString();
  final RxnString reservationsError = RxnString();

  @override
  void onInit() {
    super.onInit();
    notificationSettings.assignAll(
      _profileRepository.getNotificationSettings(),
    );
    // Seed from any already-cached `/users/me` payload (e.g. app bar load).
    userProfile.value = _usersRepository.cachedProfile;
    userPreferences.value = _usersRepository.cachedPreferences;
    if (userPreferences.value != null) {
      _applyPreferencesToNotificationSettings(userPreferences.value!);
    }
    // Keep Profile header in sync with shared users cache (login after guest).
    ever<UserProfileModel?>(_usersRepository.profileRx, (
      UserProfileModel? profile,
    ) {
      if (!isClosed) {
        userProfile.value = profile;
      }
    });
    if (Get.isRegistered<AuthSessionController>()) {
      ever<bool>(Get.find<AuthSessionController>().hasAuthenticatedSession, (
        bool authenticated,
      ) {
        if (!authenticated || isClosed) {
          return;
        }
        unawaited(loadUserProfile());
        unawaited(loadUserPreferences());
        unawaited(loadReservations());
        unawaited(loadMyReviews());
      });
    }
    reloadLocalizedData();
    _syncReservationLists();
  }

  @override
  void onReady() {
    super.onReady();
    // Network / storage after the first Profile frame is committed.
    PostFrameWork.schedule(() {
      if (isClosed) {
        return;
      }
      unawaited(_favoritesRepository.ensureInitialized());
      unawaited(loadRestaurants());
      unawaited(loadUserProfile());
      unawaited(loadUserPreferences());
      unawaited(loadReservations());
      unawaited(loadMyReviews());
      if (Get.isRegistered<NotificationsBadgeController>()) {
        Get.find<NotificationsBadgeController>().scheduleRefresh();
      }
    });
  }

  void reloadLocalizedData() {
    if (isClosed) {
      return;
    }
    restaurants.clear();
    sections.assignAll(_profileRepository.getSections());
    sections.refresh();
    notificationOptions.assignAll(_profileRepository.getNotificationOptions());
    notificationOptions.refresh();
    reservationDetails.assignAll(
      _profileRepository.getReservationDetailLabels(),
    );
    reservationDetails.refresh();
    _syncReservationLists();
  }

  Future<void> loadRestaurants() async {
    if (!isClosed) {
      restaurants.clear();
    }
  }

  Future<void> loadUserProfile() async {
    if (isClosed) {
      return;
    }
    isLoadingProfile.value = true;
    profileError.value = null;
    try {
      // Guests / logged-out sessions have no Bearer token — never hit `/users/me`
      // (same rule as [UsersRepository.ensureProfileLoaded]).
      if (!await _hasAccessToken()) {
        if (!isClosed) {
          userProfile.value = _usersRepository.cachedProfile;
        }
        return;
      }
      final UserProfileModel profile = await _usersRepository.fetchMyProfile();
      if (!isClosed) {
        userProfile.value = profile;
      }
    } on ApiException catch (error) {
      if (!isClosed) {
        userProfile.value = _usersRepository.cachedProfile;
        profileError.value = error.message;
      }
    } catch (_) {
      if (!isClosed) {
        userProfile.value = _usersRepository.cachedProfile;
        profileError.value = AppStrings.networkUnexpectedError;
      }
    } finally {
      if (!isClosed) {
        isLoadingProfile.value = false;
      }
    }
  }

  Future<void> loadUserPreferences() async {
    if (isClosed) {
      return;
    }
    try {
      if (!await _hasAccessToken()) {
        return;
      }
      final UserPreferencesModel preferences = await _usersRepository
          .fetchMyPreferences();
      if (isClosed) {
        return;
      }
      userPreferences.value = preferences;
      _applyPreferencesToNotificationSettings(preferences);
    } on ApiException {
      // Keep local defaults when preferences fail.
    } catch (_) {
      // Keep local defaults when preferences fail.
    }
  }

  Future<bool> _hasAccessToken() async {
    if (!Get.isRegistered<AuthTokenReader>()) {
      return false;
    }
    final String? access = await Get.find<AuthTokenReader>().readAccessToken();
    return access != null && access.trim().isNotEmpty;
  }

  void _applyPreferencesToNotificationSettings(
    UserPreferencesModel preferences,
  ) {
    notificationSettings.assignAll(<bool>[
      preferences.notificationOptIn,
      preferences.marketingOptIn,
    ]);
  }

  /// Profile card name = signup/login username from API identity.
  String get profileDisplayName {
    // Touch both Rx sources so Obx rebuilds after login identity lands.
    final String fromController =
        userProfile.value?.displayName.trim() ?? '';
    final String fromRepository =
        _usersRepository.profileRx.value?.displayName.trim() ?? '';
    if (fromController.isNotEmpty) {
      return fromController;
    }
    if (fromRepository.isNotEmpty) {
      return fromRepository;
    }
    return AppStrings.userProfileEmpty;
  }

  String? get profilePhone {
    final String? phone = userProfile.value?.phone?.trim();
    if (phone == null || phone.isEmpty) {
      return null;
    }
    return phone;
  }

  String? get profileAvatarUrl {
    final String? url = userProfile.value?.avatarUrl?.trim();
    if (url == null || url.isEmpty) {
      return null;
    }
    return url;
  }

  List<RestaurantModel> get featuredRestaurants {
    return const <RestaurantModel>[];
  }

  /// Active / upcoming bookings from `GET /reservations/my/upcoming`.
  List<CustomerReservationModel> get activeCustomerReservations {
    _reservationRepository.upcomingReservations.length;
    _reservationRepository.myReservations.length;
    return _reservationRepository.activeReservations;
  }

  /// Rebuild Profile reservation tabs after create / cancel / reschedule.
  void refreshReservations() {
    unawaited(loadReservations());
  }

  /// `GET /reservations/my/upcoming` + `GET /reservations/my/history`.
  Future<void> loadReservations() async {
    if (isClosed) {
      return;
    }
    if (!await _hasAccessToken()) {
      reservationsError.value = null;
      isLoadingReservations.value = false;
      _syncReservationLists();
      return;
    }
    isLoadingReservations.value = true;
    reservationsError.value = null;
    try {
      await _reservationRepository.syncProfileReservations();
      if (!isClosed) {
        _syncReservationLists();
      }
      unawaited(loadMyReviews());
    } on ApiException catch (error) {
      if (!isClosed) {
        reservationsError.value = error.message;
        _syncReservationLists();
      }
    } catch (_) {
      if (!isClosed) {
        reservationsError.value = AppStrings.reservationsLoadFailed;
        _syncReservationLists();
      }
    } finally {
      if (!isClosed) {
        isLoadingReservations.value = false;
      }
    }
  }

  /// `GET /users/me/reviews` — hydrate card review state by reservationId.
  Future<void> loadMyReviews() async {
    if (isClosed) {
      return;
    }
    if (!await _hasAccessToken()) {
      _reviewsRepository.myReviewsByReservationId.clear();
      return;
    }
    try {
      await _reviewsRepository.syncMyReviews();
    } catch (_) {
      // History cards remain usable without review badges.
    }
  }

  ReviewModel? reviewForReservation(String reservationId) {
    _reviewsRepository.myReviewsByReservationId.length;
    return _reviewsRepository.reviewForReservation(reservationId);
  }

  Future<void> openWriteReview(ReservationHistoryItemModel item) async {
    if (!item.canReview) {
      return;
    }
    if (!await _requireSignIn()) {
      return;
    }
    await WriteReviewSheet.open(
      restaurantName: item.restaurantName,
      onPickImage: _pickReviewImagePath,
      onSubmit:
          ({
            required int rating,
            required String comment,
            String? imagePath,
          }) {
            return submitReview(
              reservationId: item.reservationId,
              rating: rating,
              comment: comment,
              imagePath: imagePath,
            );
          },
    );
  }

  Future<String?> _pickReviewImagePath() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppDimensions.avatarPickerMaxWidth,
        maxHeight: AppDimensions.avatarPickerMaxHeight,
        imageQuality: AppDimensions.avatarPickerImageQuality,
      );
      return file?.path;
    } catch (_) {
      return null;
    }
  }

  /// `POST /reviews` then optional `POST /reviews/:id/images`.
  Future<bool> submitReview({
    required String reservationId,
    required int rating,
    required String comment,
    String? imagePath,
  }) async {
    if (isReviewBusy.value) {
      return false;
    }
    isReviewBusy.value = true;
    try {
      final ReviewModel review = await _reviewsRepository.submitReview(
        reservationId: reservationId,
        rating: rating,
        comment: comment,
      );
      final String path = (imagePath ?? '').trim();
      if (path.isNotEmpty && review.hasId) {
        try {
          final ReviewImageModel image = await _reviewsRepository
              .uploadReviewImage(reviewId: review.reviewId, filePath: path);
          final ReviewModel? current = _reviewsRepository.reviewForReservation(
            reservationId,
          );
          if (current != null) {
            _reviewsRepository.myReviewsByReservationId[reservationId] = current
                .copyWith(images: <ReviewImageModel>[...current.images, image]);
          }
        } catch (_) {
          // Review text/rating already saved — photo is optional.
        }
      }
      if (!isClosed) {
        Get.snackbar(AppStrings.rateYourVisit, AppStrings.reviewSubmitted);
      }
      return true;
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.rateYourVisit, error.message);
      return false;
    } catch (_) {
      Get.snackbar(AppStrings.rateYourVisit, AppStrings.reviewSubmitFailed);
      return false;
    } finally {
      if (!isClosed) {
        isReviewBusy.value = false;
      }
    }
  }

  /// Soft-delete `DELETE /reviews/:id`.
  Future<void> deleteReviewForItem(ReservationHistoryItemModel item) async {
    final ReviewModel? review = reviewForReservation(item.reservationId);
    if (review == null || !review.hasId) {
      return;
    }
    final bool confirmed = await AppConfirmDialog.show(
      title: AppStrings.areYouSure,
      message: AppStrings.confirmDeleteReviewMessage,
      icon: Symbols.delete,
    );
    if (!confirmed) {
      return;
    }
    isReviewBusy.value = true;
    try {
      await _reviewsRepository.deleteReview(review.reviewId);
      if (!isClosed) {
        Get.snackbar(AppStrings.rateYourVisit, AppStrings.reviewDeleted);
      }
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.rateYourVisit, error.message);
    } catch (_) {
      Get.snackbar(AppStrings.rateYourVisit, AppStrings.reviewDeleteFailed);
    } finally {
      if (!isClosed) {
        isReviewBusy.value = false;
      }
    }
  }

  RestaurantModel restaurantPreviewFor(CustomerReservationModel reservation) {
    return RestaurantModel(
      id: reservation.restaurantId.isNotEmpty
          ? reservation.restaurantId
          : reservation.reservationId,
      name: reservation.restaurantName.isNotEmpty
          ? reservation.restaurantName
          : AppStrings.reservations,
      cuisine: '',
      occasion: '',
      description: '',
      imageUrl: reservation.imageUrl,
      location: reservation.branchName,
      availabilityLabel: reservation.status,
      isAvailable: reservation.isActive,
    );
  }

  List<(String, String)> detailsForReservation(
    CustomerReservationModel reservation,
  ) {
    return <(String, String)>[
      (AppStrings.date, _formatDate(reservation.reservationStartTime)),
      (AppStrings.time, _formatTime(reservation.reservationStartTime)),
      (
        AppStrings.guests,
        reservation.guests > 0 ? '${reservation.guests}' : '',
      ),
    ];
  }

  /// Profile Favorites tab — `GET /users/me/favorites` summaries.
  List<RestaurantModel> get favoriteRestaurants {
    return _favoritesRepository.listedFavoriteRestaurants();
  }

  void selectSection(int index) {
    selectedSectionIndex.value = index;
  }

  Future<void> toggleNotification(int index, bool value) async {
    if (index < 0 || index >= notificationSettings.length) {
      return;
    }
    // Preferences sync to `/users/me` — guests must sign in first.
    if (!await _requireSignIn()) {
      return;
    }

    final bool previous = notificationSettings[index];
    notificationSettings[index] = value;
    // RxList element writes do not always notify Obx — force a rebuild.
    notificationSettings.refresh();

    final bool notificationOptIn = notificationSettings.isNotEmpty
        ? notificationSettings[0]
        : false;
    final bool marketingOptIn = notificationSettings.length > 1
        ? notificationSettings[1]
        : false;

    try {
      final UserPreferencesModel updated = await _usersRepository
          .updateMyPreferences(
            notificationOptIn: notificationOptIn,
            marketingOptIn: marketingOptIn,
          );
      if (isClosed) {
        return;
      }
      userPreferences.value = updated;
      _applyPreferencesToNotificationSettings(updated);
    } catch (_) {
      if (isClosed) {
        return;
      }
      notificationSettings[index] = previous;
      notificationSettings.refresh();
      Get.snackbar(AppStrings.settings, AppStrings.preferencesUpdateFailed);
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    if (!await _requireSignIn()) {
      return;
    }
    final bool confirmed = await AppConfirmDialog.confirmCancelReservation();
    if (!confirmed || isClosed) {
      return;
    }
    try {
      await _reservationRepository.cancelReservation(
        reservationId: reservationId,
      );
      if (!isClosed) {
        _syncReservationLists();
        unawaited(loadReservations());
      }
    } on ApiException catch (error) {
      if (!isClosed) {
        Get.snackbar(AppStrings.reservations, error.message);
      }
    } catch (_) {
      if (!isClosed) {
        Get.snackbar(AppStrings.reservations, AppStrings.networkUnexpectedError);
      }
    }
  }

  Future<void> rescheduleReservation(CustomerReservationModel reservation) async {
    if (!await _requireSignIn()) {
      return;
    }
    final bool confirmed =
        await AppConfirmDialog.confirmRescheduleReservation();
    if (!confirmed || isClosed) {
      return;
    }
    if (Get.isRegistered<ReservationController>()) {
      Get.delete<ReservationController>(force: true);
    }
    AppNavigation.pushOnce(
      AppRoutes.reservation,
      arguments: ReservationRouteArgs(
        restaurantId: reservation.restaurantId,
        restaurantName: reservation.restaurantName.isNotEmpty
            ? reservation.restaurantName
            : AppStrings.reservations,
        rescheduleReservationId: reservation.reservationId,
      ),
    );
  }

  void _syncReservationLists() {
    // Observe server lists so Obx rebuilds when sync completes.
    _reservationRepository.historyReservationsList.length;
    _reservationRepository.upcomingReservations.length;
    reservationHistory.assignAll(
      _reservationRepository.historyReservations.map(
        (CustomerReservationModel item) => ReservationHistoryItemModel(
          reservationId: item.reservationId,
          restaurantId: item.restaurantId,
          restaurantName: item.restaurantName.isNotEmpty
              ? item.restaurantName
              : AppStrings.reservations,
          imageUrl: item.imageUrl,
          date: _formatDate(item.reservationStartTime),
          time: _formatTime(item.reservationStartTime),
          guests: item.guests > 0 ? '${item.guests}' : '',
          // Keep raw API status (never a translated label) for review gating.
          status: item.status,
        ),
      ),
    );
  }

  static String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    final DateTime local = value.toLocal();
    final String year = (local.year % 100).toString().padLeft(2, '0');
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '$year';
  }

  static String _formatTime(DateTime? value) {
    if (value == null) {
      return '';
    }
    final DateTime local = value.toLocal();
    final int hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final String minute = local.minute.toString().padLeft(2, '0');
    final String period = local.hour >= 12
        ? AppStrings.timePeriodPm
        : AppStrings.timePeriodAm;
    return '$hour:$minute $period';
  }

  Future<void> syncLanguageToProfile({required bool isArabic}) async {
    final UserProfileModel? current = userProfile.value;
    if (current == null) {
      return;
    }
    // Guests / logged-out: language is already persisted locally — never hit
    // PATCH /users/me (would 401 and show a false "update failed" snackbar).
    if (!await _hasAccessToken()) {
      return;
    }
    try {
      final UserProfileModel updated = await _usersRepository.updateMyProfile(
        firstName: current.firstName,
        lastName: current.lastName,
        phone: current.phone,
        language: isArabic
            ? LocaleController.arabicCode
            : LocaleController.englishCode,
        preferredCurrency: current.preferredCurrency,
      );
      if (!isClosed) {
        userProfile.value = updated;
      }
    } catch (_) {
      if (!isClosed) {
        Get.snackbar(AppStrings.profile, AppStrings.profileUpdateFailed);
      }
    }
  }

  /// Locale switch + optional profile sync — UI should call this, not LocaleController alone.
  Future<void> switchAppLanguage({required bool isArabic}) async {
    if (!Get.isRegistered<LocaleController>()) {
      return;
    }
    final LocaleController localeController = Get.find<LocaleController>();
    if (localeController.isSwitchingLanguage.value) {
      return;
    }
    final bool currentlyArabic =
        localeController.languageCode.value == LocaleController.arabicCode;
    if (currentlyArabic == isArabic) {
      return;
    }
    await localeController.setArabic(isArabic);
    await syncLanguageToProfile(isArabic: isArabic);
  }

  Future<void> pickAndUploadAvatar() async {
    if (!await _requireSignIn()) {
      return;
    }
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppDimensions.avatarPickerMaxWidth,
        maxHeight: AppDimensions.avatarPickerMaxHeight,
        imageQuality: AppDimensions.avatarPickerImageQuality,
      );
      if (file == null) {
        return;
      }
      isUploadingAvatar.value = true;
      final UserProfileModel updated = await _usersRepository.uploadMyAvatar(
        filePath: file.path,
        fileName: file.name,
      );
      userProfile.value = updated;
    } on ApiException catch (error) {
      Get.snackbar(AppStrings.profile, error.message);
    } catch (_) {
      Get.snackbar(AppStrings.profile, AppStrings.avatarUploadFailed);
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<bool> _requireSignIn() async {
    if (Get.isRegistered<AuthSessionController>()) {
      return Get.find<AuthSessionController>().requireSignInForProtectedAction();
    }
    return _hasAccessToken();
  }

  bool isFavorite(String id) {
    return _favoritesRepository.isFavorite(id);
  }

  int watchFavorites() => _favoritesRepository.watchFavorites();

  Future<void> toggleFavorite(String id) async {
    if (!await _requireSignIn()) {
      return;
    }
    try {
      RestaurantModel? preview;
      for (final RestaurantModel item in favoriteRestaurants) {
        if (item.id == id) {
          preview = item;
          break;
        }
      }
      await _favoritesRepository.toggleFavorite(id, preview: preview);
    } catch (_) {
      Get.snackbar(AppStrings.favorites, AppStrings.networkUnexpectedError);
    }
  }

  void openDetails(RestaurantModel restaurant) {
    DetailsController.open(restaurant);
  }

  void openMenu(RestaurantModel restaurant) {
    RestaurantMenuController.open(restaurant);
  }

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(index, currentIndex: profileNavigationIndex);
  }

  /// Explore banner CTA — return to the Home shell tab without disposing
  /// shell controllers (`goShell` + permanent Home/Profile registrations).
  void exploreHome() {
    AppDependency.ensureHomeController();
    BottomNavNavigation.handle(
      homeNavigationIndex,
      currentIndex: profileNavigationIndex,
    );
  }

  /// Settings logout → Welcome (Login / Sign Up + Continue as Guest).
  Future<void> logOut() async {
    final bool confirmed = await AppConfirmDialog.confirmLogOut();
    if (!confirmed || isClosed) {
      return;
    }
    if (Get.isRegistered<AuthSessionController>()) {
      await Get.find<AuthSessionController>().logOut();
      return;
    }
    AppNavigation.goShell(AppRoutes.welcome);
  }
}
