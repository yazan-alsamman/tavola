import '../../../core/constants/app_strings.dart';
import '../model/reservation_history_item_model.dart';

/// Provides profile reservation history, labels, and notification prefs.
class ProfileRepository {
  Future<List<ReservationHistoryItemModel>> fetchReservationHistory() async {
    return getReservationHistory();
  }

  Future<List<(String, String)>> fetchReservationDetailLabels() async {
    return getReservationDetailLabels();
  }

  Future<List<(String, String)>> fetchNotificationOptions() async {
    return getNotificationOptions();
  }

  Future<List<bool>> fetchNotificationSettings() async {
    return getNotificationSettings();
  }

  Future<List<String>> fetchSections() async {
    return getSections();
  }

  List<ReservationHistoryItemModel> getReservationHistory() {
    return List<ReservationHistoryItemModel>.unmodifiable(_reservationHistory);
  }

  List<(String, String)> getReservationDetailLabels() {
    return List<(String, String)>.unmodifiable(_reservationDetails);
  }

  List<(String, String)> getNotificationOptions() {
    return List<(String, String)>.unmodifiable(_notificationOptions);
  }

  List<bool> getNotificationSettings() {
    return List<bool>.from(_defaultNotificationSettings);
  }

  List<String> getSections() {
    return List<String>.unmodifiable(_sections);
  }

  static List<String> get _sections => [
    AppStrings.reservations,
    AppStrings.lastReservations,
    AppStrings.favorites,
    AppStrings.settings,
  ];

  /// Matches `GET/PATCH /users/me/preferences` (2 fields only).
  static List<(String, String)> get _notificationOptions => [
    (
      AppStrings.notificationOptInTitle,
      AppStrings.notificationOptInDescription,
    ),
    (AppStrings.marketingOptInTitle, AppStrings.marketingOptInDescription),
  ];

  static List<(String, String)> get _reservationDetails => [
    (AppStrings.date, AppStrings.reservationDate),
    (AppStrings.time, AppStrings.reservationTime),
    (AppStrings.guests, AppStrings.reservationGuests),
  ];

  static const List<bool> _defaultNotificationSettings = [true, false];

  /// History comes from [ReservationRepository] (created bookings in-session).
  static List<ReservationHistoryItemModel> get _reservationHistory =>
      const <ReservationHistoryItemModel>[];
}
