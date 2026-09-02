import 'package:flutter_test/flutter_test.dart';
import 'package:served/VolunteerFormPage.dart';

void main() {
  group('volunteer activity classifications', () {
    test('recognizes the Class of 2027 High Needs activity as high needs', () {
      expect(isHighNeedsOrganization('Class of 2027 High Needs'), isTrue);
      expect(isHighNeedsOrganization('Class of 2027 Regular'), isFalse);
    });
  });
}
