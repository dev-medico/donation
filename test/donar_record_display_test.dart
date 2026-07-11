import 'package:donation/src/features/donar/donar_data_source_new.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('displayDonorRecordName', () {
    test(
      'prefers the saved donation record name over the linked donor name',
      () {
        final donor = {
          'name': 'Kyaw Myo Oo family dedication',
          'moneyDonor': {'name': 'Kyaw Myo Oo'},
        };

        expect(displayDonorRecordName(donor), 'Kyaw Myo Oo family dedication');
      },
    );

    test('falls back to the linked donor name for old records', () {
      final donor = {
        'name': '',
        'moneyDonor': {'name': 'Kyaw Myo Oo'},
      };

      expect(displayDonorRecordName(donor), 'Kyaw Myo Oo');
    });
  });

  group('sortRecordsByDateAscending', () {
    test('uses the entered date instead of creation order', () {
      final records = [
        {'id': 1, 'date': '2026-07-20', 'name': 'first-created'},
        {'id': 99, 'date': '2026-07-03', 'name': 'corrected-date'},
        {'id': 2, 'date': '2026-07-12', 'name': 'middle'},
      ];

      final sorted = sortRecordsByDateAscending(records);

      expect(
        sorted.map((record) => record['name']),
        ['corrected-date', 'middle', 'first-created'],
      );
      expect(records.first['name'], 'first-created');
    });

    test('uses record ID as a stable tie-breaker', () {
      final sorted = sortRecordsByDateAscending([
        {'id': '12', 'date': '2026-07-03'},
        {'id': 4, 'date': '2026-07-03'},
      ]);

      expect(sorted.map((record) => record['id']), [4, '12']);
    });
  });
}
