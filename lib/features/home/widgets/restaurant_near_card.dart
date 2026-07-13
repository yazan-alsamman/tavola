import 'package:flutter/material.dart';

import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_text_styles.dart';

class RestaurantNearCard extends StatelessWidget {
  const RestaurantNearCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      child: Card(
        child: ListTile(
          title: Text(title, style: AppTextStyles.placeholder),
          subtitle: Text(subtitle, style: AppTextStyles.placeholder),
        ),
      ),
    );
  }
}
