import '../../../core/constants/app_strings.dart';
import 'restaurant_offer_model.dart';

/// Customer-facing wording of an offer's terms (backend ADR-047 conditions).
///
/// Kept apart from the widgets so the offer card on Home, the offers list on
/// Details and the booking screen all describe an offer the same way.
class OfferTerms {
  OfferTerms._();

  /// "20% off" / "5000 off", or empty when the offer has no amount.
  static String discountLabel(RestaurantOfferModel offer) {
    final double? value = offer.discountValue;
    if (value == null || value <= 0) {
      return '';
    }
    final String amount = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    final bool percentage =
        offer.discountType.trim().toLowerCase() ==
        AppStrings.offerDiscountTypePercentage.toLowerCase();
    return percentage
        ? AppStrings.offerPercentOff(amount)
        : AppStrings.offerAmountOff(amount);
  }

  /// "Sunday, Tuesday" in week order, or "Every day".
  static String daysLabel(RestaurantOfferModel offer) {
    if (!offer.hasDayLimit) {
      return AppStrings.offerEveryDay;
    }
    return offer.daysOfWeek
        .map(AppStrings.workingHoursDayLabel)
        .join(AppStrings.offerListSeparator);
  }

  /// "18:00 – 22:00", or "All day".
  static String hoursLabel(RestaurantOfferModel offer) {
    if (!offer.hasHourLimit) {
      return AppStrings.offerAllDay;
    }
    return '${offer.startTime} – ${offer.endTime}';
  }

  /// Short lines for the other conditions; empty when there are none.
  static List<String> conditionLines(RestaurantOfferModel offer) {
    return <String>[
      if (offer.minPartySize != null)
        AppStrings.offerMinPartySize(offer.minPartySize!),
      if (offer.branchIds.isNotEmpty) AppStrings.offerSelectedBranches,
      if (offer.oncePerCustomer) AppStrings.offerOncePerCustomer,
      if (offer.bookingCap != null) AppStrings.offerLimitedPlaces,
      // `endsAt` is exclusive, so the last valid day is the moment before it.
      if (offer.endsAt != null)
        AppStrings.offerUntil(
          _shortDate(offer.endsAt!.subtract(const Duration(milliseconds: 1))),
        ),
    ];
  }

  static String _shortDate(DateTime value) {
    final DateTime local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}
