import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:tavla/core/constants/app_colors.dart';
import 'package:tavla/core/constants/app_dimensions.dart';
import 'package:tavla/core/constants/app_images.dart';
import 'package:tavla/core/constants/app_strings.dart';
import 'package:tavla/features/home/model/restaurant_model.dart';
import 'package:tavla/features/profile/model/reservation_history_item_model.dart';
import 'package:tavla/features/profile/widgets/profile_reservation_card.dart';
import 'package:tavla/features/profile/widgets/profile_reservation_history_card.dart';
import 'package:tavla/features/reservation/model/reservation_confirmation_model.dart';
import 'package:tavla/features/reservation/widgets/reservation_confirmation_overlay.dart';
import 'package:tavla/features/reservation/widgets/reservation_status_colors.dart';
import 'package:tavla/features/reservation/widgets/reservation_status_pill.dart';

void main() {
  test('maps pending, accepted, and rejected onto existing colors', () {
    expect(
      ReservationStatusColors.forStoredStatus(
        AppStrings.apiReservationStatusPending,
      ),
      AppColors.primaryDark,
    );
    expect(
      ReservationStatusColors.forStoredStatus(
        AppStrings.apiReservationStatusApproved,
      ),
      AppColors.online,
    );
    expect(
      ReservationStatusColors.forStoredStatus(
        AppStrings.apiReservationStatusRejected,
      ),
      AppColors.warning,
    );
    expect(
      ReservationStatusColors.forStoredStatus(
        AppStrings.apiReservationStatusCancelled,
      ),
      isNull,
    );
    expect(
      ReservationStatusColors.forCustomerLabel(
        AppStrings.reservationStatusPending,
      ),
      AppColors.primaryDark,
    );
    expect(
      ReservationStatusColors.forCustomerLabel(
        AppStrings.reservationStatusAccepted,
      ),
      AppColors.online,
    );
    expect(
      ReservationStatusColors.forCustomerLabel(
        AppStrings.reservationStatusRejected,
      ),
      AppColors.warning,
    );
    expect(
      ReservationStatusColors.forCustomerLabel(
        AppStrings.reservationStatusCompleted,
      ),
      isNull,
    );
  });

  testWidgets('upcoming reservation status text uses the status color', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileReservationCard(
            restaurant: RestaurantModel(
              id: AppStrings.restaurantIdTwo,
              name: AppStrings.otakoSushi,
              cuisine: AppStrings.sushi,
              occasion: AppStrings.dinner,
              description: AppStrings.otakoDescription,
              imageUrl: AppImages.r3,
              location: AppStrings.marinaBay,
              availabilityLabel: AppStrings.openNow,
              isAvailable: true,
            ),
            details: const <(String, String)>[
              ('Date', 'Fri 24'),
              ('Time', '7:30 PM'),
              ('Guests', '2'),
            ],
            statusLabel: AppStrings.reservationStatusAccepted,
            reservationStatus: AppStrings.apiReservationStatusApproved,
          ),
        ),
      ),
    );

    final Text status = tester.widget<Text>(
      find.text(AppStrings.reservationStatusAccepted),
    );
    expect(status.style?.color, AppColors.online);
  });

  testWidgets('history chip colors the three reservation statuses', (
    WidgetTester tester,
  ) async {
    Future<void> pumpStatus(String status) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileReservationHistoryCard(
              item: ReservationHistoryItemModel(
                reservationId: 'reservation',
                restaurantId: 'restaurant',
                restaurantName: 'Tavola',
                imageUrl: '',
                date: 'Fri 24',
                time: '7:30 PM',
                guests: '2',
                status: status,
              ),
            ),
          ),
        ),
      );
    }

    await pumpStatus(AppStrings.apiReservationStatusPending);
    expect(_pillColor(tester), AppColors.primaryDark);
    expect(
      find.text(AppStrings.reservationStatusPending.toUpperCase()),
      findsOneWidget,
    );

    await pumpStatus(AppStrings.apiReservationStatusApproved);
    expect(_pillColor(tester), AppColors.online);

    await pumpStatus(AppStrings.apiReservationStatusRejected);
    expect(_pillColor(tester), AppColors.warning);
  });

  testWidgets('confirmation colors accepted and rejected statuses', (
    WidgetTester tester,
  ) async {
    await _pumpConfirmation(tester, AppStrings.reservationStatusAccepted);
    expect(_headerColor(tester), AppColors.primaryDark);
    expect(_pillColor(tester), AppColors.online);
    expect(
      _detailColor(tester, AppStrings.reservationStatusAccepted),
      AppColors.online,
    );

    await _pumpConfirmation(tester, AppStrings.reservationStatusRejected);
    expect(_headerColor(tester), AppColors.primaryDark);
    expect(_pillColor(tester), AppColors.warning);
    expect(
      _detailColor(tester, AppStrings.reservationStatusRejected),
      AppColors.warning,
    );

    await _pumpConfirmation(tester, AppStrings.reservationStatusPending);
    expect(_headerColor(tester), AppColors.primaryDark);
    expect(_pillColor(tester), AppColors.primaryDark);
    expect(
      _detailColor(tester, AppStrings.reservationStatusPending),
      AppColors.primaryDark,
    );
  });

  testWidgets('status pill stays still when motion is reduced', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _reducedMotion(
        const Scaffold(
          body: ReservationStatusPill(
            label: 'Pending',
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
    await tester.pump(AppDimensions.reservationConfirmSentDuration);

    expect(find.text('Pending'), findsOneWidget);
    expect(_pillColor(tester), AppColors.primaryDark);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pumpWidget(
      _reducedMotion(
        Scaffold(
          body: Stack(
            children: <Widget>[
              ReservationConfirmationOverlay(
                confirmation: ReservationConfirmationModel(
                  restaurantName: 'Tavola',
                  guestsLabel: '2',
                  dateLabel: 'Fri 24',
                  tableLabel: 'T1',
                  referenceCode: 'TVL',
                  statusLabel: AppStrings.reservationStatusPending,
                ),
                onDismiss: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.reservationStatusPending), findsWidgets);
    expect(_pillColor(tester), AppColors.primaryDark);
    expect(_headerColor(tester), AppColors.primaryDark);
  });

  testWidgets('confirm plays a short transition, then shows the card', (
    WidgetTester tester,
  ) async {
    Future<void> pump({ReservationConfirmationModel? confirmation}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: <Widget>[
                ReservationConfirmationOverlay(
                  confirmation: confirmation,
                  onDismiss: () {},
                ),
              ],
            ),
          ),
        ),
      );
    }

    await pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.byIcon(Symbols.check), findsOneWidget);
    expect(find.text(AppStrings.confirmed), findsNothing);
    expect(find.byType(ReservationStatusPill), findsNothing);

    await tester.pump(AppDimensions.reservationConfirmSentDuration);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(AppStrings.confirmed), findsNothing);
    expect(find.byType(ReservationStatusPill), findsNothing);
    expect(find.byIcon(Symbols.check), findsOneWidget);

    await pump(
      confirmation: ReservationConfirmationModel(
        restaurantName: 'Tavola',
        guestsLabel: '2',
        dateLabel: 'Fri 24',
        tableLabel: 'T1',
        referenceCode: 'TVL',
        statusLabel: AppStrings.reservationStatusPending,
      ),
    );
    await tester.pump();
    await tester.pump(AppDimensions.reservationConfirmCardRevealDuration);

    expect(find.byIcon(Symbols.check), findsWidgets);
    expect(find.text(AppStrings.reservationStatusPending), findsWidgets);
    expect(_pillColor(tester), AppColors.primaryDark);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    expect(_pillColor(tester), AppColors.primaryDark);
    expect(find.text(AppStrings.dismiss), findsOneWidget);
  });
}

Widget _reducedMotion(Widget child) {
  return MaterialApp(
    builder: (BuildContext context, Widget? nested) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: nested ?? const SizedBox.shrink(),
      );
    },
    home: child,
  );
}

Color _pillColor(WidgetTester tester) {
  return tester
      .widget<ReservationStatusPill>(find.byType(ReservationStatusPill))
      .color;
}

Color? _headerColor(WidgetTester tester) {
  for (final Element element in find.byType(Container).evaluate()) {
    final Container container = element.widget as Container;
    final RenderBox box = element.renderObject! as RenderBox;
    if (container.color != null &&
        box.hasSize &&
        box.size.height == AppDimensions.confirmationHeaderHeight) {
      return container.color;
    }
  }
  return null;
}

Color? _detailColor(WidgetTester tester, String label) {
  final Iterable<Text> texts = tester.widgetList<Text>(find.text(label));
  return texts
      .map((Text text) => text.style?.color)
      .firstWhere(
        (Color? color) =>
            color == AppColors.online ||
            color == AppColors.warning ||
            color == AppColors.primaryDark,
      );
}

Future<void> _pumpConfirmation(WidgetTester tester, String statusLabel) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            ReservationConfirmationOverlay(
              confirmation: ReservationConfirmationModel(
                restaurantName: 'Tavola',
                guestsLabel: '2',
                dateLabel: 'Fri 24',
                tableLabel: 'T1',
                referenceCode: 'TVL',
                statusLabel: statusLabel,
              ),
              onDismiss: () {},
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump(AppDimensions.reservationConfirmSentDuration);
  await tester.pump();
  await tester.pump(AppDimensions.reservationConfirmCardRevealDuration);
}
