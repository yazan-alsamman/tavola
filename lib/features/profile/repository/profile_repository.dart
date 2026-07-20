import '../../../core/constants/app_strings.dart';
import '../model/payment_transaction_model.dart';

/// Provides profile payments, reservation labels, and notification prefs.
class ProfileRepository {
  Future<List<PaymentTransactionModel>> fetchPaymentTransactions() async {
    return getPaymentTransactions();
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

  List<PaymentTransactionModel> getPaymentTransactions() {
    return List<PaymentTransactionModel>.unmodifiable(_paymentTransactions);
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
        AppStrings.payments,
        AppStrings.favorites,
        AppStrings.settings,
      ];

  static List<(String, String)> get _notificationOptions => [
        (
          AppStrings.reservationReminderNotifications,
          AppStrings.reservationReminderDescription,
        ),
        (AppStrings.tablePreparedNotice, AppStrings.tablePreparedDescription),
        (AppStrings.lateArrivalInform, AppStrings.lateArrivalDescription),
        (
          AppStrings.promotionsConciergeEvents,
          AppStrings.promotionsConciergeDescription,
        ),
      ];

  static List<(String, String)> get _reservationDetails => [
        (AppStrings.date, AppStrings.reservationDate),
        (AppStrings.time, AppStrings.reservationTime),
        (AppStrings.guests, AppStrings.reservationGuests),
      ];

  static const List<bool> _defaultNotificationSettings = [
    true,
    true,
    true,
    true,
  ];

  static List<PaymentTransactionModel> get _paymentTransactions => [
        PaymentTransactionModel(
          restaurantName: AppStrings.oliveAndOak,
          date: AppStrings.paymentDateOne,
          amount: AppStrings.paymentAmountOne,
          status: AppStrings.paymentCompleted,
        ),
        PaymentTransactionModel(
          restaurantName: AppStrings.otakoSushi,
          date: AppStrings.paymentDateTwo,
          amount: AppStrings.paymentAmountTwo,
          status: AppStrings.paymentCompleted,
        ),
        PaymentTransactionModel(
          restaurantName: AppStrings.saffronHouse,
          date: AppStrings.paymentDateThree,
          amount: AppStrings.paymentAmountThree,
          status: AppStrings.paymentCompleted,
        ),
      ];
}
