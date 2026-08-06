import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/features/reservation/model/customer_reservation_model.dart';

void main() {
  test('parses enriched /reservations/my list item fields', () {
    final CustomerReservationModel model = CustomerReservationModel.fromJson(
      <String, dynamic>{
        'reservationId': 'r1',
        'restaurantId': 'rest-1',
        'restaurantName': 'The Old Mill',
        'restaurantImage': 'img-uuid',
        'branchId': 'b1',
        'branchName': '123 Main St',
        'reservationStartTime': '2026-09-12T18:00:00.000Z',
        'reservationEndTime': '2026-09-12T19:30:00.000Z',
        'partySize': 2,
        'status': 'Approved',
        'specialRequest': 'Window seat',
        'table': <String, dynamic>{
          'tableId': 't1',
          'tableNumber': 'A2',
          'capacity': 4,
        },
      },
    );

    expect(model.reservationId, 'r1');
    expect(model.restaurantName, 'The Old Mill');
    expect(model.imageUrl, 'img-uuid');
    expect(model.branchName, '123 Main St');
    expect(model.guests, 2);
    expect(model.notes, 'Window seat');
    expect(model.tableId, 't1');
    expect(model.isActive, isTrue);
    expect(model.status, 'Approved');
  });

  test('parses flat /reservations/my/:id detail fields', () {
    final CustomerReservationModel model = CustomerReservationModel.fromJson(
      <String, dynamic>{
        'reservationId': 'r2',
        'restaurantId': 'rest-1',
        'branchId': 'b1',
        'tableId': 't9',
        'guests': 4,
        'status': 'Completed',
        'notes': 'Quiet table',
        'reservationStartTime': '2026-06-02T19:00:00.000Z',
      },
      restaurantName: 'Cached Name',
      imageUrl: 'cached.png',
    );

    expect(model.guests, 4);
    expect(model.notes, 'Quiet table');
    expect(model.tableId, 't9');
    expect(model.isActive, isFalse);
    expect(model.restaurantName, 'Cached Name');
    expect(model.imageUrl, 'cached.png');
  });
}
