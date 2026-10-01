import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Signed-in name and phone, on a muted glass plate.
class ProfileIdentityHeader extends StatelessWidget {
  const ProfileIdentityHeader({
    super.key,
    required this.name,
    this.phone,
    this.email,
  });

  final String name;
  final String? phone;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final String? phoneValue = _present(phone);
    final String? emailValue = _present(email);
    final String trimmedName = name.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: AppDimensions.profileIdentityElevationOpacity,
            ),
            blurRadius: AppDimensions.profileIdentityElevationBlur,
            offset: const Offset(0, AppDimensions.profileIdentityElevationY),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      AppColors.secondaryLight,
                      AppColors.surface,
                      AppColors.secondary,
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: -AppDimensions.profileIdentityOrbSize * 0.4,
              end: -AppDimensions.profileIdentityOrbSize * 0.2,
              child: const _MutedOrb(
                size: AppDimensions.profileIdentityOrbSize,
                color: AppColors.accent,
                alpha: AppDimensions.profileIdentityAccentOrbAlpha,
              ),
            ),
            PositionedDirectional(
              bottom: -AppDimensions.profileIdentityOrbSize * 0.45,
              start: -AppDimensions.profileIdentityOrbSize * 0.25,
              child: const _MutedOrb(
                size: AppDimensions.profileIdentityOrbSize,
                color: AppColors.primaryDark,
                alpha: AppDimensions.profileIdentityPrimaryOrbAlpha,
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppDimensions.profileIdentityBlurSigma,
                sigmaY: AppDimensions.profileIdentityBlurSigma,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.contentPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(
                    alpha: AppDimensions.profileIdentityGlassAlpha,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  border: Border.all(
                    color: AppColors.primaryDark.withValues(
                      alpha: AppDimensions.profileIdentityBorderAlpha,
                    ),
                    width: AppDimensions.cardBorderWidth,
                  ),
                ),
                child: Row(
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _ProfileIconMark(),
                    const SizedBox(width: AppDimensions.regularSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.ltr,
                        children: [
                          Text(trimmedName, style: AppTextStyles.profileName),
                          if (phoneValue != null) ...[
                            const SizedBox(height: AppDimensions.smallSpacing),
                            _PhoneChip(phone: phoneValue),
                          ],
                          if (emailValue != null) ...[
                            const SizedBox(
                              height: AppDimensions.compactSpacing,
                            ),
                            Text(emailValue, style: AppTextStyles.label),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _present(String? raw) {
    final String value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return null;
    }
    return value;
  }
}

class _ProfileIconMark extends StatelessWidget {
  const _ProfileIconMark();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.profileIdentityIconGlowSigma,
          sigmaY: AppDimensions.profileIdentityIconGlowSigma,
        ),
        child: Container(
          width: AppDimensions.profileIdentityMarkSize,
          height: AppDimensions.profileIdentityMarkSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface.withValues(
              alpha: AppDimensions.profileIdentityChipAlpha,
            ),
            border: Border.all(
              color: AppColors.secondary,
              width: AppDimensions.cardBorderWidth,
            ),
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: AppDimensions.profileIdentityIconGlowSigma,
                  sigmaY: AppDimensions.profileIdentityIconGlowSigma,
                ),
                child: Icon(
                  Symbols.person,
                  size: AppDimensions.profileIdentityIconSize,
                  color: AppColors.accent,
                  fill: 1,
                ),
              ),
              Icon(
                Symbols.person,
                size: AppDimensions.profileIdentityIconSize,
                color: AppColors.primary,
                fill: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneChip extends StatelessWidget {
  const _PhoneChip({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.regularSpacing,
        vertical: AppDimensions.compactSpacing,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withValues(
          alpha: AppDimensions.profileIdentityChipAlpha,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        border: Border.all(
          color: AppColors.primaryDark10,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Symbols.smartphone,
            size: AppDimensions.smallIconSize,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppDimensions.compactSpacing),
          Flexible(
            child: Text(phone, style: AppTextStyles.profileIdentityMeta),
          ),
        ],
      ),
    );
  }
}

class _MutedOrb extends StatelessWidget {
  const _MutedOrb({
    required this.size,
    required this.color,
    required this.alpha,
  });

  final double size;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }
}
