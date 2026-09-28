import 'package:flutter_test/flutter_test.dart';

import 'package:tavla/features/notifications/model/notification_item_model.dart';

void main() {
  test('reads conversation and restaurant ids only from data', () {
    final NotificationItemModel item = NotificationItemModel.fromJson(
      <String, dynamic>{
        'id': 'n-1',
        'type': 'ReservationApproved',
        'title': 'New message',
        'body': 'This inbox text is not a chat message',
        'data': <String, dynamic>{
          'conversationId': 'c-9',
          'restaurantId': 'r-9',
          'ignored': <String, dynamic>{'messageId': 'nope'},
        },
        'read': false,
        'readAt': null,
        'createdAt': '2026-09-29T00:00:00.000Z',
      },
    );

    expect(item.conversationId, 'c-9');
    expect(item.restaurantId, 'r-9');
    expect(item.type, 'ReservationApproved');
    expect(item.data.containsKey('ignored'), isFalse);
    expect(item.body, 'This inbox text is not a chat message');
  });

  test('leaves chat targets empty when data has no identifiers', () {
    final NotificationItemModel item = NotificationItemModel.fromJson(
      <String, dynamic>{
        'id': 'n-2',
        'type': 'ReservationApproved',
        'title': 'Reservation confirmed',
        'body': 'Your reservation has been confirmed.',
        'data': <String, dynamic>{
          'reservationId': '22222222-2222-4222-8222-222222222222',
        },
        'read': false,
        'createdAt': '2026-09-29T00:00:00.000Z',
      },
    );

    expect(item.conversationId, isEmpty);
    expect(item.restaurantId, isEmpty);
    expect(item.data['reservationId'], '22222222-2222-4222-8222-222222222222');
  });
}
