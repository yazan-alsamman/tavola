import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../common/widgets/app_ltr_text.dart';
import '../../../common/widgets/hoverable_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_button_styles.dart';
import '../model/reservation_confirmation_model.dart';
import 'reservation_status_colors.dart';
import 'reservation_status_pill.dart';
import 'torn_paper_clipper.dart';
import 'package:material_symbols_icons/symbols.dart';

class ReservationConfirmationOverlay extends StatefulWidget {
  const ReservationConfirmationOverlay({
    super.key,
    required this.onDismiss,
    this.confirmation,
  });

  final ReservationConfirmationModel? confirmation;
  final VoidCallback onDismiss;

  @override
  State<ReservationConfirmationOverlay> createState() =>
      _ReservationConfirmationOverlayState();
}

class _ReservationConfirmationOverlayState
    extends State<ReservationConfirmationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _sent;
  late final AnimationController _reveal;
  late final CurvedAnimation _sentFade;
  late final CurvedAnimation _sentCurve;
  late final CurvedAnimation _revealFade;
  late final CurvedAnimation _revealCurve;
  late final Animation<double> _sentScale;
  late final Animation<double> _sentTravel;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardTravel;

  bool _motionReady = false;
  bool _cardVisible = false;

  @override
  void initState() {
    super.initState();
    _sent = AnimationController(
      vsync: this,
      duration: AppDimensions.reservationConfirmSentDuration,
    );
    _reveal = AnimationController(
      vsync: this,
      duration: AppDimensions.reservationConfirmCardRevealDuration,
    );
    _sentFade = CurvedAnimation(
      parent: _sent,
      curve: const Interval(0, 0.72, curve: Curves.easeOut),
    );
    _sentCurve = CurvedAnimation(parent: _sent, curve: Curves.easeOutCubic);
    _revealFade = CurvedAnimation(parent: _reveal, curve: Curves.easeOut);
    _revealCurve = CurvedAnimation(parent: _reveal, curve: Curves.easeOutCubic);
    _sentScale = Tween<double>(
      begin: AppDimensions.reservationConfirmSentBeginScale,
      end: 1,
    ).animate(_sentCurve);
    _sentTravel = Tween<double>(
      begin: AppDimensions.smallSpacing,
      end: 0,
    ).animate(_sentCurve);
    _cardScale = Tween<double>(
      begin: AppDimensions.reservationConfirmCardBeginScale,
      end: 1,
    ).animate(_revealCurve);
    _cardTravel = Tween<double>(
      begin: AppDimensions.smallSpacing,
      end: 0,
    ).animate(_revealCurve);
    _sent.addStatusListener(_onSentStatus);
  }

  void _onSentStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _showCard();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionReady) {
      return;
    }
    _motionReady = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      if (widget.confirmation != null) {
        _cardVisible = true;
        _reveal.value = 1;
      }
      _sent.value = 1;
      return;
    }
    _sent.forward();
  }

  @override
  void didUpdateWidget(ReservationConfirmationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confirmation == null && widget.confirmation != null) {
      _showCard();
    }
  }

  void _showCard() {
    if (!mounted ||
        _cardVisible ||
        widget.confirmation == null ||
        _sent.value < 1) {
      return;
    }
    _cardVisible = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _reveal.value = 1;
    } else {
      _reveal.forward();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _sent.removeStatusListener(_onSentStatus);
    _sentFade.dispose();
    _sentCurve.dispose();
    _revealFade.dispose();
    _revealCurve.dispose();
    _sent.dispose();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReservationConfirmationModel? confirmation = widget.confirmation;
    return Positioned.fill(
      child: Material(
        color: AppColors.transparent,
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_sent, _reveal]),
          builder: (BuildContext context, Widget? child) {
            final double cardOpacity = _cardVisible ? _revealFade.value : 0;
            final double markOpacity = _cardVisible
                ? (1 - cardOpacity).clamp(0, 1)
                : _sentFade.value;
            return Stack(
              fit: StackFit.expand,
              children: [
                const _ConfirmationScrim(),
                if (markOpacity > 0)
                  IgnorePointer(
                    child: Center(
                      child: Opacity(
                        opacity: markOpacity,
                        child: Transform.translate(
                          offset: Offset(0, _sentTravel.value),
                          child: Transform.scale(
                            scale: _sentScale.value,
                            child: const _ConfirmationMark(),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_cardVisible && confirmation != null)
                  _ConfirmationCard(
                    confirmation: confirmation,
                    onDismiss: widget.onDismiss,
                    opacity: cardOpacity,
                    scale: _cardScale.value,
                    travel: _cardTravel.value,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConfirmationScrim extends StatelessWidget {
  const _ConfirmationScrim();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppDimensions.confirmationOverlayBlurSigma,
        sigmaY: AppDimensions.confirmationOverlayBlurSigma,
      ),
      child: const ColoredBox(color: AppColors.primaryDark22),
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard({
    required this.confirmation,
    required this.onDismiss,
    required this.opacity,
    required this.scale,
    required this.travel,
  });

  final ReservationConfirmationModel confirmation;
  final VoidCallback onDismiss;
  final double opacity;
  final double scale;
  final double travel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePadding,
            vertical: AppDimensions.sectionSpacing,
          ),
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, travel),
              child: Transform.scale(
                scale: scale,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.confirmationCardMaxWidth,
                  ),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark10,
                          blurRadius: AppDimensions.shadowBlur,
                          offset: Offset(0, AppDimensions.shadowOffsetY),
                        ),
                      ],
                    ),
                    child: ClipPath(
                      clipper: const TornPaperClipper(),
                      child: ColoredBox(
                        color: AppColors.surface,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ConfirmationHeader(
                              referenceCode: confirmation.referenceCode,
                              statusLabel: confirmation.statusLabel,
                            ),
                            _ConfirmationDetails(
                              confirmation: confirmation,
                              onDismiss: onDismiss,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationHeader extends StatelessWidget {
  const _ConfirmationHeader({
    required this.referenceCode,
    required this.statusLabel,
  });

  final String? referenceCode;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimensions.confirmationHeaderHeight,
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.contentPadding,
        vertical: AppDimensions.sectionSpacing,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _ConfirmationMark(),
          const SizedBox(height: AppDimensions.regularSpacing),
          Text(
            statusLabel != null && statusLabel!.trim().isNotEmpty
                ? statusLabel!
                : AppStrings.confirmed,
            style: AppTextStyles.confirmationTitle,
          ),
          if (referenceCode != null && referenceCode!.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.smallSpacing),
            AppLtrText(
              '${AppStrings.referencePrefix}$referenceCode',
              style: AppTextStyles.confirmationReference,
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfirmationMark extends StatelessWidget {
  const _ConfirmationMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.confirmationIconContainerSize,
      height: AppDimensions.confirmationIconContainerSize,
      decoration: const BoxDecoration(
        color: AppColors.textLight90,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Symbols.check,
        color: AppColors.primaryDark,
        size: AppDimensions.confirmationIconSize,
      ),
    );
  }
}

class _ConfirmationDetails extends StatelessWidget {
  const _ConfirmationDetails({
    required this.confirmation,
    required this.onDismiss,
  });

  final ReservationConfirmationModel confirmation;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppDimensions.contentPadding,
        AppDimensions.sectionSpacing,
        AppDimensions.contentPadding,
        AppDimensions.confirmationBottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (confirmation.statusLabel != null &&
              confirmation.statusLabel!.trim().isNotEmpty) ...[
            _ConfirmationDetailRow(
              label: AppStrings.tableStatus,
              value: confirmation.statusLabel!,
              valueColor: ReservationStatusColors.forCustomerLabel(
                confirmation.statusLabel,
              ),
            ),
            const _ConfirmationDivider(),
          ],
          _ConfirmationDetailRow(
            label: AppStrings.confirmationRestaurant,
            value: confirmation.restaurantName,
          ),
          const _ConfirmationDivider(),
          _ConfirmationDetailRow(
            label: AppStrings.confirmationGuests,
            value: confirmation.guestsLabel,
          ),
          const _ConfirmationDivider(),
          _ConfirmationDetailRow(
            label: AppStrings.confirmationDate,
            value: confirmation.dateLabel,
          ),
          const _ConfirmationDivider(),
          _ConfirmationDetailRow(
            label: AppStrings.confirmationTable,
            value: confirmation.tableLabel,
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          SizedBox(
            width: double.infinity,
            child: HoverableButton(
              child: ElevatedButton(
                onPressed: onDismiss,
                style: AppButtonStyles.filledHover(
                  ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.textLight,
                    textStyle: AppTextStyles.confirmReservationButton,
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
                child: Text(
                  AppStrings.dismiss,
                  style: AppTextStyles.confirmReservationButton,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationDetailRow extends StatelessWidget {
  const _ConfirmationDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.regularSpacing,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: AppDimensions.confirmationLabelFlex,
            child: Text(label, style: AppTextStyles.confirmationDetailLabel),
          ),
          const SizedBox(width: AppDimensions.smallSpacing),
          Expanded(
            flex: AppDimensions.confirmationValueFlex,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: valueColor == null
                  ? Text(
                      value,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.confirmationDetailValue,
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: ReservationStatusPill(
                        label: value,
                        color: valueColor!,
                        textStyle: AppTextStyles.confirmationDetailValue,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationDivider extends StatelessWidget {
  const _ConfirmationDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: AppDimensions.dividerHeight,
      thickness: AppDimensions.dividerHeight,
      color: AppColors.border,
    );
  }
}
