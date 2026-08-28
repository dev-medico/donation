import 'package:donation/src/features/donation_member/domain/last_donation_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the menu offers every ledger year, newest first', () {
    final years = LastDonationFilter.menuYears(DateTime(2026, 8, 27));

    expect(years, hasLength(17));
    expect(years.first, 2026);
    expect(years.last, 2010);
  });

  test('a year is sent and displayed as one exact year', () {
    const filter = LastDonationFilter.inYear(2024);

    expect(filter.apiValue, '2024');
    expect(filter.label, '2024');
    expect(filter.year, 2024);
    expect(filter.neverDonated, isFalse);
  });

  test('never-donated is its own selection', () {
    const filter = LastDonationFilter.never();

    expect(filter.apiValue, 'never');
    expect(filter.label, 'မလှူရသေးပါ');
    expect(filter.year, isNull);
    expect(filter.neverDonated, isTrue);
  });

  test('equal selections match so the dropdown can find its current item', () {
    // The menu rebuilds its items on every frame, so the selected value is a
    // different instance from the one in the item list.
    expect(
      const LastDonationFilter.inYear(2024),
      LastDonationFilter.inYear(2024),
    );
    expect(
      const LastDonationFilter.inYear(2024).hashCode,
      LastDonationFilter.inYear(2024).hashCode,
    );
    expect(
      const LastDonationFilter.inYear(2024),
      isNot(const LastDonationFilter.inYear(2023)),
    );
    expect(
      const LastDonationFilter.never(),
      isNot(const LastDonationFilter.inYear(2024)),
    );
  });
}
