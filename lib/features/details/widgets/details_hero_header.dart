import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../common/widgets/circle_back_button.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../common/widgets/app_safe_image.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/model/restaurant_model.dart';
import '../model/restaurant_detail_model.dart';

class DetailsHeroHeader extends StatelessWidget {
  const DetailsHeroHeader({
    super.key,
    required this.restaurant,
    required this.detail,
    required this.ratingLabel,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  final RestaurantModel restaurant;
  final RestaurantDetailModel detail;
  final String ratingLabel;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final List<String> gallery = <String>[
      for (final String url in detail.galleryImageUrls)
        if (url.trim().isNotEmpty) url.trim(),
    ];
    final String cover = restaurant.imageUrl.trim();
    final List<String> frames = gallery.isNotEmpty
        ? gallery
        : <String>[if (cover.isNotEmpty) cover];

    return SizedBox(
      height: AppDimensions.detailsHeroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _DetailsHeroFrames(urls: frames),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: AppDimensions.detailsHeroOverlayHeight,
            // Gradient-only fade — BackdropFilter blur on a full-bleed hero
            // forces expensive first-frame raster work during route transition.
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.transparent,
                      AppColors.primaryDark22,
                      AppColors.primaryDark75,
                    ],
                    stops: [
                      AppDimensions.detailsHeroFadeStart,
                      AppDimensions.detailsHeroFadeMid,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.transparent,
                      AppColors.transparent,
                      AppColors.primaryDark22,
                      AppColors.primaryDark75,
                      AppColors.primaryDark,
                    ],
                    stops: [
                      0.0,
                      AppDimensions.detailsHeroFadeMid,
                      AppDimensions.detailsHeroFadeEnd,
                      0.85,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppDimensions.pagePadding,
                AppDimensions.sectionSpacing,
                AppDimensions.pagePadding,
                AppDimensions.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(restaurant.name, style: AppTextStyles.detailsHeroTitle),
                  const SizedBox(height: AppDimensions.compactSpacing),
                  Text(ratingLabel, style: AppTextStyles.detailsHeroRating),
                  const SizedBox(height: AppDimensions.tinySpacing),
                  Text(
                    detail.locationBlurb,
                    style: AppTextStyles.detailsHeroLocation,
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            top: AppDimensions.pagePadding,
            start: AppDimensions.pagePadding,
            child: SafeArea(
              child: CircleBackButton(
                onPressed: Get.back,
                onDarkBackground: true,
              ),
            ),
          ),
          PositionedDirectional(
            top: AppDimensions.pagePadding,
            end: AppDimensions.pagePadding,
            child: SafeArea(
              child: SizedBox(
                width: AppDimensions.circleBackButtonSize,
                height: AppDimensions.circleBackButtonSize,
                child: HoverableButton(
                  child: Material(
                    color: AppColors.surface75,
                    shape: const CircleBorder(),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onFavoritePressed,
                      child: Center(
                        child: Icon(
                          Symbols.favorite,
                          fill: isFavorite ? 1 : 0,
                          color: isFavorite
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
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

class _DetailsHeroFrames extends StatefulWidget {
  const _DetailsHeroFrames({required this.urls});

  final List<String> urls;

  @override
  State<_DetailsHeroFrames> createState() => _DetailsHeroFramesState();
}

class _DetailsHeroFramesState extends State<_DetailsHeroFrames> {
  final PageController _pageController = PageController();
  Timer? _advanceTimer;
  int _page = 0;

  bool get _cycles => widget.urls.length > 1;

  @override
  void initState() {
    super.initState();
    _scheduleAdvance();
  }

  @override
  void didUpdateWidget(covariant _DetailsHeroFrames oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.urls.length != widget.urls.length ||
        oldWidget.urls.join() != widget.urls.join()) {
      _page = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _scheduleAdvance();
    }
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleAdvance() {
    _advanceTimer?.cancel();
    if (!_cycles) {
      return;
    }
    _advanceTimer = Timer(AppDimensions.detailsGalleryInterval, () {
      unawaited(_advance());
    });
  }

  Future<void> _advance() async {
    if (!mounted || !_pageController.hasClients || !_cycles) {
      return;
    }
    final int next = (_page + 1) % widget.urls.length;
    await _pageController.animateToPage(
      next,
      duration: AppDimensions.detailsGallerySlideDuration,
      curve: Curves.easeOutCubic,
    );
    if (mounted) {
      _scheduleAdvance();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) {
      return const AppSafeImage(path: '', fit: BoxFit.cover);
    }
    if (!_cycles) {
      return AppSafeImage(path: widget.urls.first, fit: BoxFit.cover);
    }
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.urls.length,
      onPageChanged: (int index) {
        _page = index;
        _scheduleAdvance();
      },
      itemBuilder: (BuildContext context, int index) {
        return AppSafeImage(path: widget.urls[index], fit: BoxFit.cover);
      },
    );
  }
}
