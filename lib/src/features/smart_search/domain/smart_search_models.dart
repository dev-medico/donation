import 'package:donation/src/features/donation_member/data/search_member_repository.dart'
    show SearchMemberAnalysis;
import 'package:donation/src/features/donation_member/domain/member.dart';

/// One value the server understood from the typed query.
class SmartChip {
  const SmartChip({
    required this.field,
    required this.value,
    required this.label,
    required this.confidence,
  });

  factory SmartChip.fromJson(Map<String, dynamic> json) => SmartChip(
        field: json['field']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        confidence: _toDouble(json['confidence']),
      );

  final String field;
  final String value;
  final String label;
  final double confidence;
}

/// A value the server could not settle; the user picks one option.
class SmartQuestion {
  const SmartQuestion({
    required this.field,
    required this.prompt,
    required this.options,
    this.labels,
  });

  factory SmartQuestion.fromJson(Map<String, dynamic> json) => SmartQuestion(
        field: json['field']?.toString() ?? '',
        prompt: json['prompt']?.toString() ?? '',
        options: _toStringList(json['options']),
        labels: json['labels'] == null ? null : _toStringList(json['labels']),
      );

  final String field;
  final String prompt;
  final List<String> options;
  final List<String>? labels;

  String labelFor(int index) =>
      (labels != null && index < labels!.length) ? labels![index] : options[index];
}

/// The filters the server actually applied.
class SmartFilters {
  const SmartFilters({
    this.q = '',
    this.bloodGroups = const [],
    this.township,
    this.townshipLabel,
    this.ward,
    this.gender,
    this.urgent = false,
  });

  factory SmartFilters.fromJson(Map<String, dynamic> json) => SmartFilters(
        q: json['q']?.toString() ?? '',
        bloodGroups: _toStringList(json['blood_groups']),
        township: _nullable(json['township']),
        townshipLabel: _nullable(json['township_label']),
        ward: _nullable(json['ward']),
        gender: _nullable(json['gender']),
        urgent: json['urgent'] == true || json['urgent']?.toString() == '1',
      );

  final String q;
  final List<String> bloodGroups;
  final String? township;
  final String? townshipLabel;
  final String? ward;
  final String? gender;
  final bool urgent;

  /// The single group to send back as an explicit filter, or the ABO letters
  /// when both Rh variants were searched.
  String? get bloodGroupParam {
    if (bloodGroups.isEmpty) return null;
    if (bloodGroups.length == 1) return bloodGroups.first;
    final abo = bloodGroups.first.replaceAll(RegExp(r'[+-]$'), '');
    return abo;
  }

  SmartFilters copyWith({
    String? q,
    List<String>? bloodGroups,
    String? township,
    bool clearTownship = false,
    String? gender,
    bool clearGender = false,
    bool? urgent,
  }) {
    return SmartFilters(
      q: q ?? this.q,
      bloodGroups: bloodGroups ?? this.bloodGroups,
      township: clearTownship ? null : (township ?? this.township),
      townshipLabel: clearTownship ? null : townshipLabel,
      ward: ward,
      gender: clearGender ? null : (gender ?? this.gender),
      urgent: urgent ?? this.urgent,
    );
  }
}

class SmartParse {
  const SmartParse({
    required this.chips,
    required this.questions,
    required this.flags,
    required this.urgent,
    required this.fallback,
    required this.fromCache,
    this.intent,
    this.model,
  });

  factory SmartParse.fromJson(Map<String, dynamic> json) => SmartParse(
        chips: (json['chips'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => SmartChip.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false),
        questions: (json['questions'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => SmartQuestion.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false),
        flags: _toStringList(json['flags']),
        urgent: json['urgent'] == true,
        fallback: json['fallback'] == true,
        fromCache: json['from_cache'] == true,
        intent: _nullable(json['intent']),
        model: _nullable(json['model']),
      );

  final List<SmartChip> chips;
  final List<SmartQuestion> questions;
  final List<String> flags;
  final bool urgent;
  final bool fallback;
  final bool fromCache;
  final String? intent;
  final String? model;
}

/// A donor row with its rank. [member] carries the same fields the existing
/// Find Blood screen uses, so the call/remark dialog works unchanged.
class RankedDonor {
  const RankedDonor({
    required this.member,
    required this.rankScore,
    required this.rankReasons,
    required this.availabilityState,
    this.eligibleAgainAt,
    this.townshipKey,
    this.townshipLabel,
    this.wardKey,
    this.bloodGroup,
    this.compatibleOnly = false,
  });

  factory RankedDonor.fromJson(Map<String, dynamic> json) => RankedDonor(
        member: Member.fromJson(json),
        rankScore: _toInt(json['rank_score']),
        rankReasons: _toStringList(json['rank_reasons']),
        availabilityState: json['availability_state']?.toString() ?? 'green',
        eligibleAgainAt: _nullable(json['eligible_again_at']),
        townshipKey: _nullable(json['township_key']),
        townshipLabel: _nullable(json['township_label']),
        wardKey: _nullable(json['ward_key']),
        bloodGroup: _nullable(json['blood_group']),
        compatibleOnly: json['compatible_only'] == true,
      );

  final Member member;
  final int rankScore;
  final List<String> rankReasons;
  final String availabilityState;
  final String? eligibleAgainAt;
  final String? townshipKey;
  final String? townshipLabel;
  final String? wardKey;
  final String? bloodGroup;
  final bool compatibleOnly;

  String get identity => member.id?.toString() ?? member.memberId ?? '';

  RankedDonor withMember(Member updated) => RankedDonor(
        member: updated,
        rankScore: rankScore,
        rankReasons: rankReasons,
        availabilityState: availabilityState,
        eligibleAgainAt: eligibleAgainAt,
        townshipKey: townshipKey,
        townshipLabel: townshipLabel,
        wardKey: wardKey,
        bloodGroup: bloodGroup,
        compatibleOnly: compatibleOnly,
      );
}

class SmartSearchPage {
  const SmartSearchPage({
    required this.mode,
    required this.query,
    required this.parsed,
    required this.filters,
    required this.donors,
    required this.compatible,
    required this.total,
    required this.analysis,
    required this.page,
    required this.limit,
    required this.hasMore,
    this.parseError,
    this.weights,
  });

  factory SmartSearchPage.fromJson(Map<String, dynamic> json) {
    final parsedJson = json['parsed'];
    return SmartSearchPage(
      mode: json['mode']?.toString() ?? 'rank',
      query: json['query']?.toString() ?? '',
      parsed: parsedJson is Map
          ? SmartParse.fromJson(Map<String, dynamic>.from(parsedJson))
          : null,
      filters: json['filters'] is Map
          ? SmartFilters.fromJson(Map<String, dynamic>.from(json['filters']))
          : const SmartFilters(),
      donors: _donors(json['data']),
      compatible: _donors(json['compatible']),
      total: _toInt(json['total']),
      analysis: json['analysis'] is Map
          ? SearchMemberAnalysis.fromJson(
              Map<String, dynamic>.from(json['analysis']))
          : null,
      page: _toInt(json['page']),
      limit: _toInt(json['limit'], fallback: 50),
      hasMore: json['has_more'] == true,
      parseError: _nullable(json['parse_error']),
      weights: _nullable((json['classification'] as Map?)?['weights']),
    );
  }

  final String mode;
  final String query;
  final SmartParse? parsed;
  final SmartFilters filters;
  final List<RankedDonor> donors;
  final List<RankedDonor> compatible;
  final int total;
  final SearchMemberAnalysis? analysis;
  final int page;
  final int limit;
  final bool hasMore;
  final String? parseError;
  final String? weights;

  static List<RankedDonor> _donors(dynamic list) => (list as List? ?? const [])
      .whereType<Map>()
      .map((e) => RankedDonor.fromJson(Map<String, dynamic>.from(e)))
      .toList(growable: false);
}

class TownshipOption {
  const TownshipOption({required this.key, required this.my, required this.en});

  factory TownshipOption.fromJson(Map<String, dynamic> json) => TownshipOption(
        key: json['key']?.toString() ?? '',
        my: json['my']?.toString() ?? '',
        en: json['en']?.toString() ?? '',
      );

  final String key;
  final String my;
  final String en;
}

List<String> _toStringList(dynamic v) =>
    (v as List? ?? const []).map((e) => e.toString()).toList(growable: false);

String? _nullable(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

int _toInt(dynamic v, {int fallback = 0}) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}
