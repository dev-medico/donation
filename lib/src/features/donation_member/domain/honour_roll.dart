import 'package:donation/src/features/donation_member/domain/member.dart';

/// A donor on the honour roll, with the lifetime total the server computed:
/// donations made before joining plus the ones recorded with the group.
class HonourRollEntry {
  const HonourRollEntry({
    required this.member,
    required this.total,
    this.previous,
    this.recorded,
  });

  final Member member;
  final int total;

  /// Donations before joining (ယခင်), when the server sent the breakdown.
  final int? previous;

  /// Donations recorded with the group (အဖွဲ့နှင့်), when the server sent the
  /// breakdown.
  final int? recorded;

  bool get hasBreakdown => previous != null && recorded != null;

  factory HonourRollEntry.fromJson(Map<String, dynamic> json) {
    final counts = json['donation_counts'];
    final breakdown = counts is Map ? counts : const {};
    return HonourRollEntry(
      member: Member.fromJson(json),
      total: _readInt(breakdown['total']) ?? _readInt(json['total_count']) ?? 0,
      previous: _readInt(breakdown['before_joining']),
      recorded: _readInt(breakdown['in_system']),
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}'.trim());
  }
}

/// One band of the honour roll: donors whose total lies between [min] and
/// [max], both inclusive. An open-ended band has no [max].
class HonourTier {
  const HonourTier(this.min, [this.max]);

  final int min;
  final int? max;

  bool contains(int total) => total >= min && (max == null || total <= max!);

  /// '10–19', or '50+' for the open-ended band.
  String get label => max == null ? '$min+' : '$min–$max';

  /// The band in words, for screen readers: '10 မှ 19 ကြိမ်'.
  String get spokenLabel =>
      max == null ? '$min ကြိမ်နှင့်အထက်' : '$min မှ $max ကြိမ်';

  @override
  bool operator ==(Object other) =>
      other is HonourTier && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}

/// The lowest total the honour roll lists.
const honourRollMinimum = 10;

/// The bands the group asked for — 10–19, 20–29, 30–39 and 40–49 — shown even
/// when empty, plus 50+ once anyone has reached it so the most frequent donors
/// are never left off.
List<HonourTier> honourTiersFor(Iterable<int> totals) {
  const asked = [
    HonourTier(10, 19),
    HonourTier(20, 29),
    HonourTier(30, 39),
    HonourTier(40, 49),
  ];
  const beyond = HonourTier(50);
  return [
    ...asked,
    if (totals.any(beyond.contains)) beyond,
  ];
}

/// Positions for totals already sorted most-first, sharing a position on a
/// tie: 57, 57, 54 → 1, 1, 3.
List<int> competitionRanks(List<int> totalsDescending) {
  final ranks = <int>[];
  for (var i = 0; i < totalsDescending.length; i++) {
    final tied = i > 0 && totalsDescending[i] == totalsDescending[i - 1];
    ranks.add(tied ? ranks[i - 1] : i + 1);
  }
  return ranks;
}
