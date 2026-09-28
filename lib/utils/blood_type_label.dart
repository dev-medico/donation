/// Recognizes the stored Rh notation and compact labels without losing the
/// Unicode minus sign used in our own badges.
String compactBloodType(String? raw, {bool omitPositive = false}) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return '';
  final normalized = value
      .toUpperCase()
      .replaceAll(RegExp('[−–—‐‑﹣－]'), '-')
      .replaceAll('＋', '+');
  final match =
      RegExp(r'^(AB|A|B|O)(?=$|[\s(+\-]|RH|NEG|POS)').firstMatch(normalized);
  if (match == null) return value;
  final group = match.group(1)!;
  final suffix = normalized.substring(group.length);
  final negative = suffix.contains('-') || suffix.contains('NEG');
  final positive = suffix.contains('+') || suffix.contains('POS');
  if (negative) return '$group−';
  if (positive && !omitPositive) return '$group+';
  return group;
}
