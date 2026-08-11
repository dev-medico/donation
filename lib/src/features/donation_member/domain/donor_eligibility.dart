import 'dart:math' as math;

import 'package:donation/src/features/donation_member/domain/member.dart';

/// The three visual states used by the Find Blood directory.
enum DonorEligibilityLevel {
  eligible,
  caution,
  disabled,
}

extension DonorEligibilityLevelApi on DonorEligibilityLevel {
  /// Stable values shared with the Find Blood backend contract.
  String get apiValue => switch (this) {
        DonorEligibilityLevel.eligible => 'green',
        DonorEligibilityLevel.caution => 'yellow',
        DonorEligibilityLevel.disabled => 'red',
      };
}

/// A single, testable interpretation of a donor's saved availability,
/// last-donation date, and remark.
///
/// Manual availability is authoritative. A donor who has been switched off is
/// always red. Otherwise a saved remark or an unfinished four-calendar-month
/// waiting period is yellow. Only donors without either restriction are green.
class DonorEligibility {
  static const int waitingPeriodMonths = 4;

  const DonorEligibility({
    required this.level,
    required this.remark,
    required this.hasRemark,
    required this.isWaiting,
    required this.hasInvalidLastDonationDate,
    required this.remainingMonths,
    required this.remainingDays,
    this.lastDonationDate,
    this.nextEligibleDate,
  });

  final DonorEligibilityLevel level;
  final String remark;
  final bool hasRemark;
  final bool isWaiting;
  final bool hasInvalidLastDonationDate;
  final int remainingMonths;
  final int remainingDays;
  final DateTime? lastDonationDate;
  final DateTime? nextEligibleDate;

  bool get canDonateNow => level == DonorEligibilityLevel.eligible;

  factory DonorEligibility.fromMember(
    Member member, {
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final rawLastDate = (member.lastDate ?? '').trim();
    final parsedLastDate = parseDonationDate(rawLastDate);
    final invalidLastDate = rawLastDate.isNotEmpty && parsedLastDate == null;
    final lastDate = parsedLastDate == null ? null : _dateOnly(parsedLastDate);
    final nextDate = lastDate == null
        ? null
        : addCalendarMonths(lastDate, waitingPeriodMonths);
    final waiting = nextDate != null && today.isBefore(nextDate);
    final remaining =
        waiting ? remainingCalendarTime(today, nextDate) : (months: 0, days: 0);
    final remark = normalizeRemark(member.note);
    final hasRemark = remark.isNotEmpty;

    final level = !member.canDonate
        ? DonorEligibilityLevel.disabled
        : (hasRemark || waiting || invalidLastDate)
            ? DonorEligibilityLevel.caution
            : DonorEligibilityLevel.eligible;

    return DonorEligibility(
      level: level,
      remark: remark,
      hasRemark: hasRemark,
      isWaiting: waiting,
      hasInvalidLastDonationDate: invalidLastDate,
      remainingMonths: remaining.months,
      remainingDays: remaining.days,
      lastDonationDate: lastDate,
      nextEligibleDate: nextDate,
    );
  }

  /// Historical imports commonly use a dash as an empty-note placeholder.
  /// Treat those placeholders as empty so they do not turn most donors yellow.
  static String normalizeRemark(String? value) {
    final remark = (value ?? '').trim();
    if (remark.isEmpty) return '';
    if (const {'-', '—', '–'}.contains(remark)) return '';
    return remark;
  }

  /// Parses the formats currently returned by the API while keeping invalid
  /// non-empty values detectable. An invalid date is never treated as green.
  static DateTime? parseDonationDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) return parsed;

    // A few older records use day-month-year separators.
    final match =
        RegExp(r'^(\d{1,2})[-\/.](\d{1,2})[-\/.](\d{4})$').firstMatch(trimmed);
    if (match == null) return null;

    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;

    final candidate = DateTime(year, month, day);
    if (candidate.year != year ||
        candidate.month != month ||
        candidate.day != day) {
      return null;
    }
    return candidate;
  }

  /// Adds calendar months and clamps end-of-month dates (for example,
  /// October 31 + 4 months becomes February 28/29 rather than spilling into
  /// March).
  static DateTime addCalendarMonths(DateTime date, int months) {
    final zeroBasedTargetMonth = date.year * 12 + date.month - 1 + months;
    final targetYear = zeroBasedTargetMonth ~/ 12;
    final targetMonth = zeroBasedTargetMonth % 12 + 1;
    final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
    return DateTime(
      targetYear,
      targetMonth,
      math.min(date.day, lastDay),
    );
  }

  /// Returns the whole calendar months and remaining days until [target].
  /// Both values are zero when the target has already been reached.
  static ({int months, int days}) remainingCalendarTime(
    DateTime from,
    DateTime target,
  ) {
    final startDate = _dateOnly(from);
    final targetDate = _dateOnly(target);
    if (!startDate.isBefore(targetDate)) return (months: 0, days: 0);

    var months = (targetDate.year - startDate.year) * 12 +
        targetDate.month -
        startDate.month;
    var anchor = addCalendarMonths(startDate, months);
    if (anchor.isAfter(targetDate)) {
      months -= 1;
      anchor = addCalendarMonths(startDate, months);
    }

    return (
      months: months,
      days: targetDate.difference(anchor).inDays,
    );
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
