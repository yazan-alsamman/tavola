import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/payment_transaction_model.dart';

class ProfilePaymentsPanel extends StatelessWidget {
  const ProfilePaymentsPanel({super.key, required this.transactions});

  final List<PaymentTransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: AppDimensions.settingsIconSize,
            ),
            SizedBox(width: AppDimensions.smallSpacing),
            Expanded(
              child: Text(
                AppStrings.paymentHistory,
                style: AppTextStyles.settingsHeader,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.smallSpacing),
        ...transactions.map(
          (transaction) => HoverableCard(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.smallSpacing),
              padding: const EdgeInsets.all(AppDimensions.contentPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimensions.cardBorderWidth,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: AppDimensions.avatarSize,
                    height: AppDimensions.avatarSize,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.credit_card_rounded,
                      color: AppColors.primary,
                      size: AppDimensions.mediumIconSize,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.regularSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.restaurantName,
                          style: AppTextStyles.title,
                        ),
                        const SizedBox(height: AppDimensions.tinySpacing),
                        Text(transaction.date, style: AppTextStyles.body),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.smallSpacing),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(transaction.amount, style: AppTextStyles.title),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.smallSpacing,
                          vertical: AppDimensions.tinySpacing,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.pillRadius,
                          ),
                        ),
                        child: Text(
                          transaction.status,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
