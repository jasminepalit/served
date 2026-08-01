import 'package:flutter_test/flutter_test.dart';
import 'package:served/VolunteerFormPage.dart';

void main() {
  group('Volunteer form organization helpers', () {
    test('marks the requested organizations as high needs', () {
      expect(isHighNeedsOrganization("Abby's House"), isTrue);
      expect(isHighNeedsOrganization('Community Harvest'), isTrue);
      expect(isHighNeedsOrganization('Mustard Seed'), isTrue);
      expect(isHighNeedsOrganization('Project New Hope'), isTrue);
      expect(isHighNeedsOrganization('WRAP'), isTrue);
    });

    test('keeps other organizations as regular', () {
      expect(isHighNeedsOrganization('FRC 190'), isFalse);
      expect(isHighNeedsOrganization('Mass Academy'), isFalse);
      expect(isHighNeedsOrganization('Scouts'), isFalse);
    });
  });
}
