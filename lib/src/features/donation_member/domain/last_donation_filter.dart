import 'package:flutter/foundation.dart';

/// The Find Blood "last donated" filter.
///
/// A year means "that year or earlier" rather than that year alone. The group
/// uses this filter to reach the donors who have rested the longest, so the
/// useful question is "who has not donated since ...". The cumulative reading
/// is also what keeps the menu short: the oldest entry absorbs everyone before
/// it, so a fixed ten-year window still reaches the whole ledger.
///
/// Members who never donated have no date to compare against. They are the
/// most rested donors of all, so every year includes them, and they can also be
/// picked on their own.
@immutable
class LastDonationFilter {
  const LastDonationFilter.upToYear(int this.year) : neverDonated = false;

  const LastDonationFilter.never()
      : year = null,
        neverDonated = true;

  /// Inclusive upper bound: the donor last gave in this year or earlier.
  final int? year;

  final bool neverDonated;

  /// How many years the menu offers.
  static const int menuYearCount = 10;

  /// Selectable years, newest first. The current year is deliberately absent —
  /// "this year or earlier" matches every member, which is what "all" already
  /// does.
  static List<int> menuYears(DateTime now) => List<int>.generate(
        menuYearCount,
        (index) => now.year - 1 - index,
      );

  /// Wire value for the `last_donation` parameter of `search-member/index`.
  String get apiValue => neverDonated ? 'never' : '$year';

  /// Latin digits keep this consistent with the rest of Find Blood, where
  /// counts, phone numbers, and donation dates are all shown in Latin digits.
  String get label => neverDonated ? 'မလှူရသေးပါ' : '$year နှင့် အရင်';

  @override
  bool operator ==(Object other) =>
      other is LastDonationFilter &&
      other.year == year &&
      other.neverDonated == neverDonated;

  @override
  int get hashCode => Object.hash(year, neverDonated);

  @override
  String toString() => 'LastDonationFilter($apiValue)';
}
