import 'package:flutter_test/flutter_test.dart';
import 'package:served/auth_helpers.dart';

void main() {
  group('password validation', () {
    test('accepts strong passwords', () {
      expect(isValidPassword('Password1!'), isTrue);
      expect(isValidPassword(r'MySecure123$'), isTrue);
    });

    test('rejects weak passwords', () {
      expect(isValidPassword('password'), isFalse);
      expect(isValidPassword('password1'), isFalse);
      expect(isValidPassword('Password'), isFalse);
      expect(isValidPassword('Password1'), isFalse);
    });
  });
}
