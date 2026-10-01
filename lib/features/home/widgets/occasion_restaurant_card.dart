import 'dart:async';

import 'package:flutter/material.dart';

import '../../../common/widgets/app_safe_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../model/restaurant_model.dart';

class OccasionRestaurantEntrance extends StatefulWidget {
  const OccasionRestaurantEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<OccasionRestaurantEntrance> createState() =>
      _OccasionRestaurantEntranceState();
}

class _OccasionRestaurantEntranceState extends State<OccasionRestaurantEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delay;
  bool _motionStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDimensions.occasionRestaurantEntranceDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionStarted) {
      return;
    }
    _motionStarted = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    final int slot =
        widget.index % AppDimensions.occasionRestaurantStaggerWindow;
    final Duration delay = Duration(
      milliseconds: slot * AppDimensions.occasionRestaurantStaggerStepMs,
    );
    if (delay == Duration.zero) {
      _controller.forward();
      return;
    }
    _delay = Timer(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeOutCubic.transform(_controller.value);
        final double scale =
            AppDimensions.occasionRestaurantEntranceBeginScale +
            ((1 - AppDimensions.occasionRestaurantEntranceBeginScale) * t);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * AppDimensions.smallSpacing),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class OccasionRestaurantCard extends StatefulWidget {
  const OccasionRestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  final RestaurantModel restaurant;
  final VoidCallback onTap;

  @override
  State<OccasionRestaurantCard> createState() => _OccasionRestaurantCardState();
}

class _OccasionRestaurantCardState extends State<OccasionRestaurantCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final RestaurantModel restaurant = widget.restaurant;
    final String? rating = restaurant.averageRating == null
        ? null
        : '${AppStrings.starSymbol}${restaurant.averageRating!.toStringAsFixed(1)}';
    final List<String> meta = <String>[
      if (restaurant.cuisine.trim().isNotEmpty) restaurant.cuisine.trim(),
      if (restaurant.location.trim().isNotEmpty) restaurant.location.trim(),
    ];

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? AppDimensions.occasionRestaurantPressedScale : 1,
        duration: AppDimensions.hoverDuration,
        curve: Curves.easeOutCubic,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: AppColors.border,
              width: AppDimensions.cardBorderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryDark10,
                blurRadius: AppDimensions.shadowBlur,
                offset: Offset(0, AppDimensions.shadowOffsetY),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AppSafeImage(
                    path: restaurant.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.regularSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.occasionLabel,
                      ),
                      if (rating != null) ...[
                        const SizedBox(height: AppDimensions.tinySpacing),
                        Text(
                          rating,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label,
                        ),
                      ],
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.tinySpacing),
                        Text(
                          meta.join(AppStrings.restaurantSummarySeparator),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
