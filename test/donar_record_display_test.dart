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
}
