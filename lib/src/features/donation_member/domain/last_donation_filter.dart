import 'package:flutter/foundation.dart';

/// The Find Blood "last donated" filter.
///
/// A year matches that calendar year only. Members who never donated have no
/// year to compare against and remain available through their own selection.
@immutable
class LastDonationFilter {
  const LastDonationFilter.inYear(int this.year) : neverDonated = false;

  const LastDonationFilter.never() : year = null, neverDonated = true;

  /// The exact calendar year in which the donor last gave.
  final int? year;

  final bool neverDonated;

  /// The earliest year represented in the imported member/donation ledger.
  static const int firstRecordedYear = 2010;

  /// Every ledger year, newest first, including the current year.
  static List<int> menuYears(DateTime now) {
    final count = now.year < firstRecordedYear
        ? 1
        : now.year - firstRecordedYear + 1;
    return List<int>.generate(count, (index) => now.year - index);
  }

  /// Wire value for the `last_donation` parameter of `search-member/index`.
  String get apiValue => neverDonated ? 'never' : '$year';

  /// Latin digits keep this consistent with the rest of Find Blood, where
  /// counts, phone numbers, and donation dates are all shown in Latin digits.
  String get label => neverDonated ? 'မလှူရသေးပါ' : '$year';

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
