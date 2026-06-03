import 'package:donation/utils/age_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Fixed reference "today" so the tests are deterministic.
  final ref = DateTime(2026, 6, 3);

  group('birthDateFromAge', () {
    test('32 years 6 months -> 1993-12-03', () {
      expect(birthDateFromAge(years: 32, months: 6, from: ref),
          DateTime(1993, 12, 3));
    });

    test('years only', () {
      expect(birthDateFromAge(years: 40, from: ref), DateTime(1986, 6, 3));
    });

    test('infant expressed in days', () {
      expect(birthDateFromAge(days: 14, from: ref), DateTime(2026, 5, 20));
    });
  });

  group('ageFromBirthDate', () {
    test('round-trips 32y 6m', () {
      final age = ageFromBirthDate(DateTime(1993, 12, 3), on: ref);
      expect([age.years, age.months, age.days], [32, 6, 0]);
    });

    test('infant in days', () {
      final age = ageFromBirthDate(DateTime(2026, 5, 20), on: ref);
      expect([age.years, age.months, age.days], [0, 0, 14]);
    });

    test('1y 1m 1d round-trip', () {
      final b = birthDateFromAge(years: 1, months: 1, days: 1, from: ref);
      final age = ageFromBirthDate(b, on: ref);
      expect([age.years, age.months, age.days], [1, 1, 1]);
    });

    test('age grows as time passes (same birth date, later reference)', () {
      final birth = birthDateFromAge(years: 32, months: 6, from: ref);
      final laterAge = ageFromBirthDate(birth, on: DateTime(2027, 6, 3));
      expect([laterAge.years, laterAge.months], [33, 6]);
    });

    test('future birth date clamps to zero', () {
      expect(ageFromBirthDate(DateTime(2030, 1, 1), on: ref).isZero, true);
    });
  });

  test('parse / format birth date', () {
    expect(formatBirthDate(DateTime(1993, 12, 3)), '1993-12-03');
    expect(parseBirthDate('1993-12-03'), DateTime(1993, 12, 3));
    expect(parseBirthDate('1993-12-03T00:00:00.000'), DateTime(1993, 12, 3));
    expect(parseBirthDate(''), isNull);
    expect(parseBirthDate(null), isNull);
  });
}
