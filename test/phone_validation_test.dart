import 'package:flutter_test/flutter_test.dart';
import 'package:served/auth_helpers.dart';

void main() {
  group('phone validation', () {
    test('accepts real phone numbers and N/A variants', () {
      expect(isValidPhoneNumber('1234567890'), isTrue);
      expect(isValidPhoneNumber('(123) 456-7890'), isTrue);
      expect(isValidPhoneNumber('N/A'), isTrue);
      expect(isValidPhoneNumber('n/a'), isTrue);
      expect(isValidPhoneNumber('NA'), isTrue);
      expect(isValidPhoneNumber('na'), isTrue);
      expect(isValidPhoneNumber('   n/a   '), isTrue);
    });

    test('rejects invalid phone inputs', () {
      expect(isValidPhoneNumber(''), isFalse);
      expect(isValidPhoneNumber('12345'), isFalse);
      expect(isValidPhoneNumber('abc'), isFalse);
    });
  });
}
