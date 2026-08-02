import 'package:flutter_test/flutter_test.dart';
import 'package:tavla/features/auth/model/auth_validation.dart';

void main() {
  group('AuthValidation phone NSN constraints', () {
    test('AE uses mobile lengths only (9 digits, not fixed-line 8)', () {
      final PhoneNsnConstraints constraints =
          AuthValidation.phoneNsnConstraints('AE');

      expect(constraints.hasLengthMetadata, isTrue);
      expect(constraints.minLength, 9);
      expect(constraints.maxLength, 9);
      expect(constraints.allowedLengths, <int>{9});
      expect(AuthValidation.isValidNationalPhone('501234567', 'AE'), isTrue);
      expect(AuthValidation.isValidNationalPhone('22345678', 'AE'), isFalse);
    });

    test('SY requires 9 mobile digits and rejects fixed-line length', () {
      final PhoneNsnConstraints constraints =
          AuthValidation.phoneNsnConstraints('SY');

      expect(constraints.hasLengthMetadata, isTrue);
      expect(constraints.minLength, 9);
      expect(constraints.maxLength, 9);
      expect(AuthValidation.isValidNationalPhone('944567890', 'SY'), isTrue);
      expect(AuthValidation.isValidNationalPhone('91234567', 'SY'), isFalse);
    });

    test('rejects numbers outside country max length', () {
      expect(AuthValidation.isValidNationalPhone('05012345678', 'AE'), isFalse);
    });
  });
}
