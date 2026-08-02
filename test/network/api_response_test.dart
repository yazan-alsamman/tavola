import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/core/network/api_exception.dart';
import 'package:tavla/core/network/api_response.dart';

void main() {
  group('ApiResponse', () {
    test('parses success envelope', () {
      final ApiResponse<Map<String, dynamic>> response =
          ApiResponse<Map<String, dynamic>>.fromJson(<String, dynamic>{
            'success': true,
            'message': 'ok',
            'data': <String, dynamic>{'id': '1'},
            'meta': <String, dynamic>{'page': 1},
          }, parseData: (Object? raw) => raw as Map<String, dynamic>);

      expect(response.success, isTrue);
      expect(response.message, 'ok');
      expect(response.data['id'], '1');
      expect(response.meta?['page'], 1);
    });
  });

  group('ApiException', () {
    test('parses error envelope', () {
      final ApiException exception = ApiException.fromErrorBody(
        <String, dynamic>{
          'success': false,
          'message': 'Invalid',
          'code': 'VALIDATION_ERROR',
          'errors': <dynamic>['email'],
          'path': '/users/me',
        },
        statusCode: 422,
      );

      expect(exception.message, 'email');
      expect(exception.code, 'VALIDATION_ERROR');
      expect(exception.isValidation, isTrue);
      expect(exception.statusCode, 422);
      expect(exception.errors, <dynamic>['email']);
    });

    test('parses NestJS list message without throwing', () {
      final ApiException exception = ApiException.fromErrorBody(
        <String, dynamic>{
          'success': false,
          'message': <dynamic>[
            'username must be unique',
            'phoneNumber already used',
          ],
          'code': 409,
          'statusCode': 409,
        },
        statusCode: 409,
      );

      expect(
        exception.message,
        'username must be unique\nphoneNumber already used',
      );
      expect(exception.code, '409');
      expect(exception.statusCode, 409);
    });

    test('parses non-string path and object message safely', () {
      final ApiException exception = ApiException.fromErrorBody(
        <String, dynamic>{
          'message': <String, dynamic>{'detail': 'Conflict'},
          'path': 123,
        },
        statusCode: 409,
      );

      expect(exception.message, 'Conflict');
      expect(exception.path, '123');
    });

    test('falls back to error key when message is absent', () {
      final ApiException exception = ApiException.fromErrorBody(
        <String, dynamic>{'success': false, 'error': 'Account locked'},
        statusCode: 403,
      );

      expect(exception.message, 'Account locked');
      expect(exception.statusCode, 403);
    });

    test('credentialsRejected is not session-expired copy', () {
      final ApiException credentials = ApiException.credentialsRejected();
      final ApiException session = ApiException.unauthorized();
      expect(credentials.message, isNot(session.message));
      expect(credentials.statusCode, 401);
      expect(session.statusCode, 401);
    });
  });
}
