import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:served/StudentActivityPage.dart';

void main() {
  group('buildActivityDetailRows', () {
    test('includes the original submission fields in a readable order', () {
      final rows = buildActivityDetailRows({
        'organization': 'Community Harvest',
        'description': 'Food drive',
        'advisorName': 'Ms. Lee',
        'advisorEmail': 'ms.lee@example.com',
        'advisorNumber': '5551234567',
        'isHighNeeds': true,
        'highNeedsDescription': 'Needed for outreach',
        'status': 'pending',
        'requestMessage': 'Please clarify the time',
      });

      expect(rows.map((entry) => entry.key).toList(), containsAll([
        'Organization Name',
        'Activity Description',
        'Advisor Name',
        'Advisor Email',
        'Advisor Phone Number',
        'Date',
        'High Needs',
        'High Needs Description',
        'Status',
        'Admin Request Message',
      ]));

      expect(rows.firstWhere((entry) => entry.key == 'High Needs').value, 'Yes');
      expect(
        rows.firstWhere((entry) => entry.key == 'Activity Description').value,
        'Food drive',
      );
    });
  });
}
