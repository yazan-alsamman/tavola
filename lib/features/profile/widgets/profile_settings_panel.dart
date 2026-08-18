import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/routes/app_routes.dart';
import '../../../common/widgets/app_confirm_dialog.dart';
import '../../../common/widgets/app_success_toast.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../common/widgets/hoverable_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../../core/utils/app_dependency.dart';
import '../../auth/controller/auth_session_controller.dart';
import '../../users/repository/users_repository.dart';
import '../controller/profile_controller.dart';

class ProfileSettingsPanel extends StatelessWidget {
  const ProfileSettingsPanel({super.key, required this.onChanged});

  final Future<void> Function(int index, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final LocaleController localeController = Get.find<LocaleController>();
    final ProfileController profileController = Get.find<ProfileController>();

    return Obx(() {
      // Rebuild every localized label as soon as the active locale changes.
      localeController.languageCode.value;
      final bool isSignedIn = Get.isRegistered<AuthSessionController>()
          ? Get.find<AuthSessionController>().hasAuthenticatedSession.value
          : false;
      final List<(String, String)> options = profileController.notificationOptions
          .toList(growable: false);
      final List<bool> values = profileController.notificationSettings.toList(
        growable: false,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.settings,
                color: AppColors.primary,
                size: AppDimensions.settingsIconSize,
              ),
              const SizedBox(width: AppDimensions.smallSpacing),
              Expanded(
                child: Text(
                  AppStrings.fineSystemConfigurations,
                  style: AppTextStyles.settingsHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          HoverableCard(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimensions.cardBorderWidth,
                ),
              ),
              child: Column(
                children: List.generate(options.length, (index) {
                  final (String title, String body) = options[index];
                  final bool checked = index < values.length
                      ? values[index]
                      : false;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.contentPadding,
                          vertical: AppDimensions.buttonVerticalPadding,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: AppTextStyles.settingsItemTitle,
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.tinySpacing,
                                  ),
                                  Text(
                                    body,
                                    style: AppTextStyles.settingsItemBody,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppDimensions.smallSpacing),
                            Checkbox(
                              value: checked,
                              onChanged: (bool? value) {
                                // Fire-and-forget; controller updates Obx state.
                                onChanged(index, value ?? false);
                              },
                              fillColor:
                                  WidgetStateProperty.resolveWith<Color?>((
                                    Set<WidgetState> states,
                                  ) {
                                    if (states.contains(WidgetState.selected)) {
                                      return AppColors.primary;
                                    }
                                    return AppColors.surface;
                                  }),
                              checkColor: AppColors.textLight,
                              side: const BorderSide(
                                color: AppColors.divider,
                                width: AppDimensions.checkboxBorderWidth,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index != options.length - 1)
                        const Divider(
                          height: AppDimensions.cardBorderWidth,
                          color: AppColors.border,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          Row(
            children: [
              Icon(
                Symbols.language,
                color: AppColors.primary,
                size: AppDimensions.settingsIconSize,
              ),
              const SizedBox(width: AppDimensions.smallSpacing),
              Expanded(
                child: Text(
                  AppStrings.languageSettings,
                  style: AppTextStyles.settingsHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          HoverableCard(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                border: Border.all(
                  color: AppColors.border,
                  width: AppDimensions.cardBorderWidth,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.contentPadding,
                  vertical: AppDimensions.buttonVerticalPadding,
                ),
                child: Builder(
                  builder: (BuildContext context) {
                    final bool isArabic = localeController.isArabic;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.languageSettings,
                          style: AppTextStyles.settingsItemTitle,
                        ),
                        const SizedBox(height: AppDimensions.tinySpacing),
                        Text(
                          AppStrings.languageSettingsDescription,
                          style: AppTextStyles.settingsItemBody,
                        ),
                        const SizedBox(height: AppDimensions.regularSpacing),
                        Container(
                          padding: const EdgeInsets.all(
                            AppDimensions.tinySpacing,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.pillRadius,
                            ),
                            border: Border.all(
                              color: AppColors.border,
                              width: AppDimensions.cardBorderWidth,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _LanguageOptionButton(
                                  label: AppStrings.languageEnglish,
                                  selected: !isArabic,
                                  onTap: () async {
                                    await profileController.switchAppLanguage(
                                      isArabic: false,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: _LanguageOptionButton(
                                  label: AppStrings.languageArabic,
                                  selected: isArabic,
                                  onTap: () async {
                                    await profileController.switchAppLanguage(
                                      isArabic: true,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          if (isSignedIn) ...[
            const SizedBox(height: AppDimensions.sectionSpacing),
            Row(
              children: [
                Icon(
                  Symbols.lock,
                  color: AppColors.primary,
                  size: AppDimensions.settingsIconSize,
                ),
                const SizedBox(width: AppDimensions.smallSpacing),
                Expanded(
                  child: Text(
                    AppStrings.profileAccountDetails,
                    style: AppTextStyles.settingsHeader,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.smallSpacing),
            HoverableCard(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  border: Border.all(
                    color: AppColors.border,
                    width: AppDimensions.cardBorderWidth,
                  ),
                ),
                child: Column(
                  children: [
                    _SettingsNavRow(
                      title: AppStrings.changePassword,
                      body: AppStrings.changePasswordInstruction,
                      onTap: () => Get.toNamed(AppRoutes.changePassword),
                    ),
                    const Divider(
                      height: AppDimensions.cardBorderWidth,
                      color: AppColors.border,
                    ),
                    _SettingsNavRow(
                      title: AppStrings.manageDevices,
                      body: AppStrings.manageDevicesDescription,
                      onTap: () => Get.toNamed(AppRoutes.activeSessions),
                    ),
                    const Divider(
                      height: AppDimensions.cardBorderWidth,
                      color: AppColors.border,
                    ),
                    _SettingsNavRow(
                      title: AppStrings.deleteAccount,
                      body: AppStrings.deleteAccountInstruction,
                      onTap: () => Get.toNamed(AppRoutes.deleteAccount),
                    ),
                    const Divider(
                      height: AppDimensions.cardBorderWidth,
                      color: AppColors.border,
                    ),
                    _SettingsNavRow(
                      title: AppStrings.exportMyData,
                      body: AppStrings.exportMyDataDescription,
                      onTap: () => _exportMyData(),
                    ),
                    if (Get.isRegistered<UsersRepository>() &&
                        Get.find<UsersRepository>()
                            .hasPendingAccountDeletion
                            .value) ...[
                      const Divider(
                        height: AppDimensions.cardBorderWidth,
                        color: AppColors.border,
                      ),
                      _SettingsNavRow(
                        title: AppStrings.cancelAccountDeletion,
                        body: AppStrings.cancelAccountDeletionDescription,
                        onTap: () => _cancelPendingAccountDeletion(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.sectionSpacing),
            SizedBox(
              width: double.infinity,
              child: HoverableButton(
                child: ElevatedButton(
                  onPressed: () {
                    profileController.logOut();
                  },
                  style: AppButtonStyles.filledHover(
                    ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.textLight,
                      textStyle: AppTextStyles.settingsItemTitle.copyWith(
                        color: AppColors.textLight,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.buttonVerticalPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                      ),
                    ),
                    idleBackground: AppColors.primaryDark,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.logout,
                        size: AppDimensions.settingsIconSize,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: AppDimensions.smallSpacing),
                      Text(
                        AppStrings.logOut,
                        style: AppTextStyles.settingsItemTitle.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _SettingsNavRow extends StatelessWidget {
  const _SettingsNavRow({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.contentPadding,
            vertical: AppDimensions.buttonVerticalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.settingsItemTitle,
                    ),
                    const SizedBox(height: AppDimensions.tinySpacing),
                    Text(
                      body,
                      style: AppTextStyles.settingsItemBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.smallSpacing),
              Icon(
                Symbols.chevron_right,
                color: AppColors.textSecondary,
                size: AppDimensions.settingsIconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


Future<void> _exportMyData() async {
  AppDependency.ensureUsersRepository();
  if (!Get.isRegistered<UsersRepository>()) {
    return;
  }
  try {
    final result = await Get.find<UsersRepository>().exportMyData();
    final String summary = AppStrings.exportMyDataSummary(
      reservations: result.reservationsTotal,
      reviews: result.reviewsTotal,
      favorites: result.favoritesTotal,
    );
    final String message = result.message.trim().isNotEmpty
        ? result.message.trim()
        : AppStrings.exportMyDataSuccess;
    AppSuccessToast.show(
      title: AppStrings.exportMyData,
      message: '$message\n$summary',
    );
  } on ApiException catch (error) {
    Get.snackbar(AppStrings.exportMyData, error.message);
  } catch (_) {
    Get.snackbar(AppStrings.exportMyData, AppStrings.networkUnexpectedError);
  }
}


Future<void> _cancelPendingAccountDeletion() async {
  final bool confirmed = await AppConfirmDialog.show(
    title: AppStrings.areYouSure,
    message: AppStrings.cancelAccountDeletionConfirmMessage,
    icon: Symbols.undo,
  );
  if (!confirmed) {
    return;
  }
  AppDependency.ensureUsersRepository();
  if (!Get.isRegistered<UsersRepository>()) {
    return;
  }
  try {
    await Get.find<UsersRepository>().cancelAccountDeletion();
    AppSuccessToast.show(
      title: AppStrings.cancelAccountDeletion,
      message: AppStrings.cancelAccountDeletionSuccess,
    );
  } on ApiException catch (error) {
    Get.snackbar(AppStrings.cancelAccountDeletion, error.message);
  } catch (_) {
    Get.snackbar(
      AppStrings.cancelAccountDeletion,
      AppStrings.networkUnexpectedError,
    );
  }
}

class _LanguageOptionButton extends StatelessWidget {
  const _LanguageOptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
        child: AnimatedContainer(
          duration: AppDimensions.settingsLanguageToggleAnimDuration,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.compactVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.settingsItemTitle.copyWith(
              color: selected ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
