class PaymentTransactionModel {
  const PaymentTransactionModel({
    required this.restaurantName,
    required this.date,
    required this.amount,
    required this.status,
  });

  final String restaurantName;
  final String date;
  final String amount;
  final String status;
}
