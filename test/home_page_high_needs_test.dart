import 'package:flutter_test/flutter_test.dart';
import 'package:served/HomePage.dart';

void main() {
  group('isHighNeedsActivity', () {
    test('returns true for the current isHighNeeds field', () {
      expect(isHighNeedsActivity({'isHighNeeds': true}), isTrue);
    });

    test('returns true for legacy high_needs field', () {
      expect(isHighNeedsActivity({'high_needs': true}), isTrue);
    });

    test('returns false when no high-needs flag is present', () {
      expect(isHighNeedsActivity({}), isFalse);
    });
  });
}
