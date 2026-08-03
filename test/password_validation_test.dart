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

    test('tracks individual password requirements', () {
      expect(hasMinLength('Password1!'), isTrue);
      expect(hasUppercase('Password1!'), isTrue);
      expect(hasNumber('Password1!'), isTrue);
      expect(hasSpecialCharacter('Password1!'), isTrue);

      expect(hasMinLength('short'), isFalse);
      expect(hasUppercase('password1!'), isFalse);
      expect(hasNumber('Password!'), isFalse);
      expect(hasSpecialCharacter('Password1'), isFalse);
    });
  });
}
