import 'package:donation/src/features/donation_member/domain/last_donation_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the menu offers ten years, newest first, without the current year', () {
    final years = LastDonationFilter.menuYears(DateTime(2026, 8, 27));

    expect(years, hasLength(10));
    expect(years.first, 2025);
    expect(years.last, 2016);
    expect(years.contains(2026), isFalse);
  });

  test('a year is sent as the year itself and reads as an upper bound', () {
    const filter = LastDonationFilter.upToYear(2024);

    expect(filter.apiValue, '2024');
    expect(filter.label, '2024 နှင့် အရင်');
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
      const LastDonationFilter.upToYear(2024),
      LastDonationFilter.upToYear(2024),
    );
    expect(
      const LastDonationFilter.upToYear(2024).hashCode,
      LastDonationFilter.upToYear(2024).hashCode,
    );
    expect(
      const LastDonationFilter.upToYear(2024),
      isNot(const LastDonationFilter.upToYear(2023)),
    );
    expect(
      const LastDonationFilter.never(),
      isNot(const LastDonationFilter.upToYear(2024)),
    );
  });
}
