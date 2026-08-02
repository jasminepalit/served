import 'package:flutter_test/flutter_test.dart';
import 'package:served/ActivityApprovalDetailPage.dart';

void main() {
  group('validateActivityDescription', () {
    test('returns an error message for blank or placeholder descriptions', () {
      expect(
        validateActivityDescription(''),
        'Activity description is required before this activity can be submitted.',
      );
      expect(
        validateActivityDescription('   '),
        'Activity description is required before this activity can be submitted.',
      );
      expect(
        validateActivityDescription('N/A'),
        'Activity description is required before this activity can be submitted.',
      );
      expect(
        validateActivityDescription(null),
        'Activity description is required before this activity can be submitted.',
      );
    });

    test('returns null for a populated description', () {
      expect(validateActivityDescription('Tutored students after school'), isNull);
    });
  });
}
