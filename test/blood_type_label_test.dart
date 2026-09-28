import 'package:donation/src/ui/blood_chip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all eight stored types and already-formatted badges preserve Rh', () {
    for (final group in ['A', 'B', 'AB', 'O']) {
      expect(BloodChip.short('$group (Rh +)'), '$group+');
      for (final minus in ['-', '−', '–', '－']) {
        expect(BloodChip.short('$group (Rh $minus)'), '$group−');
      }
      expect(BloodChip.short(BloodChip.short('$group (Rh -)')), '$group−');
    }
    expect(BloodChip.short(null), '—');
    expect(BloodChip.short(''), '—');
    expect(BloodChip.short('Bombay'), 'Bombay');
  });
}
