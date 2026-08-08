import 'package:intl/intl.dart';

/// Pure helpers to convert between a patient's age (years / months / days) and a
/// birth date, so that the age can be recomputed correctly as time passes.
///
/// The birth date is the value persisted on the patient; the displayed age is
/// always derived from it relative to "today".

class AgeParts {
  final int years;
  final int months;
  final int days;

  const AgeParts({this.years = 0, this.months = 0, this.days = 0});

  bool get isZero => years == 0 && months == 0 && days == 0;
}

final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

/// Today's date with the time component stripped.
DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Convert an age expressed as years/months/days into an approximate birth date,
/// i.e. the date that is exactly that age before today.
///
/// Relies on [DateTime]'s built-in normalisation so month/day underflow rolls
/// over correctly. E.g. 32 years 6 months before 2026-06-03 -> 1993-12-03.
DateTime birthDateFromAge({
  int years = 0,
  int months = 0,
  int days = 0,
  DateTime? from,
}) {
  final base = from == null ? _today() : DateTime(from.year, from.month, from.day);
  return DateTime(base.year - years, base.month - months, base.day - days);
}

/// Compute the age (years, months, days) for [birthDate] relative to today.
AgeParts ageFromBirthDate(DateTime birthDate, {DateTime? on}) {
  final today = on == null ? _today() : DateTime(on.year, on.month, on.day);
  final birth = DateTime(birthDate.year, birthDate.month, birthDate.day);
  if (!birth.isBefore(today)) {
    return const AgeParts();
  }

  int years = today.year - birth.year;
  int months = today.month - birth.month;
  int days = today.day - birth.day;

  if (days < 0) {
    months -= 1;
    // Day 0 of the current month == last day of the previous month, whose
    // `.day` is the number of days we borrow.
    final prevMonth = DateTime(today.year, today.month, 0);
    days += prevMonth.day;
  }
  if (months < 0) {
    years -= 1;
    months += 12;
  }
  return AgeParts(years: years, months: months, days: days);
}

/// Replace Myanmar digits (၀-၉, U+1040–U+1049) with ASCII 0-9.
///
/// Staff keyboards (Myanmar3 layouts) emit Myanmar digits on the number row,
/// and legacy patient records store ages that way (e.g. "၅၄"), which
/// `int.tryParse` cannot read.
String normalizeMyanmarDigits(String input) {
  const zero = 0x1040; // ၀
  final buffer = StringBuffer();
  for (final unit in input.codeUnits) {
    if (unit >= zero && unit <= zero + 9) {
      buffer.writeCharCode(0x30 + (unit - zero));
    } else {
      buffer.writeCharCode(unit);
    }
  }
  return buffer.toString();
}

/// Parse an ISO `yyyy-MM-dd` (or full ISO datetime) string into a date, or null.
DateTime? parseBirthDate(String? value) {
  if (value == null) return null;
  final v = value.trim();
  if (v.isEmpty) return null;
  try {
    // Accept both 'yyyy-MM-dd' and full ISO-8601 datetime strings.
    return DateTime.parse(v.length >= 10 ? v.substring(0, 10) : v);
  } catch (_) {
    return null;
  }
}

/// Format a date as `yyyy-MM-dd` for sending to the backend.
String formatBirthDate(DateTime date) => _isoDate.format(date);

/// Human-readable Burmese age label, e.g. "32 နှစ် 6 လ" or "14 ရက်".
String formatAgeMm(AgeParts age) {
  final parts = <String>[];
  if (age.years > 0) parts.add('${age.years} နှစ်');
  if (age.months > 0) parts.add('${age.months} လ');
  if (age.days > 0) parts.add('${age.days} ရက်');
  if (parts.isEmpty) return '၀ ရက်';
  return parts.join(' ');
}

/// Current age for display, derived from [birthDateString] when available so it
/// stays correct as time passes, otherwise the stored [fallbackAge] string.
///
/// When [detailed] is true returns e.g. "32 နှစ် 6 လ"; otherwise whole years.
/// [empty] is returned when neither a birth date nor a fallback age is known.
String displayAge(
  String? birthDateString, {
  String? fallbackAge,
  bool detailed = true,
  String empty = '',
}) {
  final birth = parseBirthDate(birthDateString);
  if (birth != null) {
    final age = ageFromBirthDate(birth);
    return detailed ? formatAgeMm(age) : age.years.toString();
  }
  final fallback = (fallbackAge ?? '').trim();
  return fallback.isEmpty ? empty : fallback;
}
