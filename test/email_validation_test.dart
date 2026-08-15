import 'package:flutter_test/flutter_test.dart';
import 'package:served/auth_helpers.dart';

void main() {
  group('email validation', () {
    test('accepts valid email addresses', () {
      expect(isValidEmail('student@example.com'), isTrue);
      expect(isValidEmail('first.last+tag@sub.domain.org'), isTrue);
    });

    test('rejects invalid email addresses', () {
      expect(isValidEmail('student'), isFalse);
      expect(isValidEmail('student@'), isFalse);
      expect(isValidEmail('@example.com'), isFalse);
      expect(isValidEmail('student@example'), isFalse);
    });
  });
}
