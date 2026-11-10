import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/app_ltr_text.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/offer_tag.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../discovery/model/offer_terms.dart';
import '../../discovery/model/restaurant_offer_model.dart';

/// The restaurant's running offers with their days, hours and terms, each
/// with a button that books under that offer.
class DetailsOffersSection extends StatelessWidget {
  const DetailsOffersSection({
    super.key,
    required this.offers,
    required this.onBookWithOffer,
  });

  final List<RestaurantOfferModel> offers;
  final ValueChanged<RestaurantOfferModel> onBookWithOffer;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.currentOffers,
          style: AppTextStyles.detailsSectionLabel,
        ),
        const SizedBox(height: AppDimensions.regularSpacing),
        for (final RestaurantOfferModel offer in offers)
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.regularSpacing,
            ),
            child: _OfferCard(
              offer: offer,
              onBook: () => onBookWithOffer(offer),
            ),
          ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.onBook});

  final RestaurantOfferModel offer;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final String discount = OfferTerms.discountLabel(offer);
    final List<String> conditions = OfferTerms.conditionLines(offer);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.contentPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDimensions.smallSpacing,
            runSpacing: AppDimensions.tinySpacing,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(offer.title, style: AppTextStyles.reservationTitle),
              if (discount.isNotEmpty) OfferTag(label: discount),
            ],
          ),
          if (offer.description.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.smallSpacing),
            Text(offer.description.trim(), style: AppTextStyles.body),
          ],
          const SizedBox(height: AppDimensions.regularSpacing),
          _TermRow(
            icon: Symbols.calendar_today,
            label: AppStrings.offerDays,
            child: Text(
              OfferTerms.daysLabel(offer),
              style: AppTextStyles.detailsHoursDay,
            ),
          ),
          const SizedBox(height: AppDimensions.compactSpacing),
          _TermRow(
            icon: Symbols.schedule,
            label: AppStrings.offerHours,
            child: offer.hasHourLimit
                ? AppLtrText(
                    OfferTerms.hoursLabel(offer),
                    style: AppTextStyles.detailsHoursDay,
                  )
                : Text(
                    OfferTerms.hoursLabel(offer),
                    style: AppTextStyles.detailsHoursDay,
                  ),
          ),
          if (conditions.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.regularSpacing),
            for (final String line in conditions)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.tinySpacing,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Symbols.check_small,
                      size: AppDimensions.smallIconSize,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: AppDimensions.tinySpacing),
                    Expanded(child: Text(line, style: AppTextStyles.label)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppDimensions.regularSpacing),
          SizedBox(
            width: double.infinity,
            child: HoverableButton(
              child: FilledButton.icon(
                onPressed: onBook,
                icon: const Icon(
                  Symbols.local_offer,
                  size: AppDimensions.smallIconSize,
                ),
                label: Text(AppStrings.bookWithOffer),
                style: AppButtonStyles.filledHover(
                  FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.textLight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermRow extends StatelessWidget {
  const _TermRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppDimensions.smallIconSize, color: AppColors.primary),
        const SizedBox(width: AppDimensions.smallSpacing),
        Text(label, style: AppTextStyles.label),
        const SizedBox(width: AppDimensions.smallSpacing),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: child,
          ),
        ),
      ],
    );
  }
}
