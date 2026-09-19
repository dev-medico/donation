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

  String labelFor(int index) => (labels != null && index < labels!.length)
      ? labels![index]
      : options[index];
}

/// The filters the server actually applied.
class SmartFilters {
  const SmartFilters({
    this.q = '',
    this.bloodGroups = const [],
    this.township,
    this.townshipLabel,
    this.townshipMode = 'prefer',
    this.ward,
    this.wardMode = 'prefer',
    this.wardKind,
    this.gender,
    this.urgent = false,
    this.availability,
    this.ageMin,
    this.ageMax,
    this.donorKind,
    this.hospital,
    this.needed,
  });

  factory SmartFilters.fromJson(Map<String, dynamic> json) => SmartFilters(
        q: json['q']?.toString() ?? '',
        bloodGroups: _toStringList(json['blood_groups']),
        township: _nullable(json['township']),
        townshipLabel: _nullable(json['township_label']),
        townshipMode: json['township_mode']?.toString() ?? 'prefer',
        ward: _nullable(json['ward']),
        wardMode: json['ward_mode']?.toString() ?? 'prefer',
        wardKind: _nullable(json['ward_kind']),
        gender: _nullable(json['gender']),
        urgent: json['urgent'] == true || json['urgent']?.toString() == '1',
        availability: _nullable(json['availability']),
        ageMin: json['age_min'] == null ? null : _toInt(json['age_min']),
        ageMax: json['age_max'] == null ? null : _toInt(json['age_max']),
        donorKind: _nullable(json['donor_kind']),
        hospital: _nullable(json['hospital']),
        needed: json['needed'] == null ? null : _toInt(json['needed']),
      );

  final String q;
  final List<String> bloodGroups;
  final String? township;
  final String? townshipLabel;

  /// prefer = nearby townships follow; only = hard filter.
  final String townshipMode;
  final String? ward;

  /// prefer = same quarter ranks first; only = hard filter.
  final String wardMode;

  /// green when the query asked for donors who can give right now.
  final String? availability;
  final int? ageMin;
  final int? ageMax;

  /// regular | first_time
  final String? donorKind;
  final String? hospital;
  final int? needed;

  bool get includeNearby => townshipMode != 'only';
  final String? wardKind;
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
    String? townshipMode,
    String? ward,
    bool clearWard = false,
    String? wardMode,
    String? gender,
    bool clearGender = false,
    bool? urgent,
    bool clearAge = false,
    bool clearDonorKind = false,
    bool clearHospital = false,
    bool clearNeeded = false,
  }) {
    // Changing the township drops a quarter that belongs to the old one.
    final wardStays = !clearWard &&
        !clearTownship &&
        (township == null || township == this.township);
    return SmartFilters(
      q: q ?? this.q,
      bloodGroups: bloodGroups ?? this.bloodGroups,
      township: clearTownship ? null : (township ?? this.township),
      townshipLabel:
          clearTownship ? null : (township == null ? townshipLabel : null),
      ward: ward ?? (wardStays ? this.ward : null),
      wardMode: wardMode ?? this.wardMode,
      wardKind: ward != null ? null : (wardStays ? wardKind : null),
      gender: clearGender ? null : (gender ?? this.gender),
      urgent: urgent ?? this.urgent,
      availability: availability,
      ageMin: clearAge ? null : ageMin,
      ageMax: clearAge ? null : ageMax,
      donorKind: clearDonorKind ? null : donorKind,
      hospital: clearHospital ? null : hospital,
      needed: clearNeeded ? null : needed,
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
    this.wardKind,
    this.locationTier = '',
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
        wardKind: _nullable(json['ward_kind']),
        locationTier: json['location_tier']?.toString() ?? '',
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
  final String? wardKind;

  /// ward | near1 | near2 | township | adjacent | hop2 | ''
  final String locationTier;
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
        wardKind: wardKind,
        locationTier: locationTier,
        bloodGroup: bloodGroup,
        compatibleOnly: compatibleOnly,
      );
}

/// How many of the matching donors live in the requested quarter / township.
class SmartLocationCounts {
  const SmartLocationCounts({
    required this.sameWard,
    required this.sameWardGreen,
    required this.nearWard1,
    required this.nearWard1Green,
    required this.nearWard2,
    required this.nearWard2Green,
    required this.sameTownship,
    required this.sameTownshipGreen,
    required this.adjacentTownship,
    required this.adjacentTownshipGreen,
    required this.secondHop,
    required this.secondHopGreen,
  });

  factory SmartLocationCounts.fromJson(Map<String, dynamic> json) =>
      SmartLocationCounts(
        sameWard: _toInt(json['same_ward']),
        sameWardGreen: _toInt(json['same_ward_green']),
        nearWard1: _toInt(json['near_ward_1']),
        nearWard1Green: _toInt(json['near_ward_1_green']),
        nearWard2: _toInt(json['near_ward_2']),
        nearWard2Green: _toInt(json['near_ward_2_green']),
        sameTownship: _toInt(json['same_township']),
        sameTownshipGreen: _toInt(json['same_township_green']),
        adjacentTownship: _toInt(json['adjacent_township']),
        adjacentTownshipGreen: _toInt(json['adjacent_township_green']),
        secondHop: _toInt(json['second_hop']),
        secondHopGreen: _toInt(json['second_hop_green']),
      );

  final int sameWard;
  final int sameWardGreen;
  final int nearWard1;
  final int nearWard1Green;
  final int nearWard2;
  final int nearWard2Green;
  final int sameTownship;
  final int sameTownshipGreen;
  final int adjacentTownship;
  final int adjacentTownshipGreen;
  final int secondHop;
  final int secondHopGreen;

  /// the last "neighbour" name is kept for older callers
  int get neighbour => adjacentTownship;
}

/// A quarter near the selected one, by degree (1 = directly linked).
class NearbyWard {
  const NearbyWard({
    required this.ward,
    required this.township,
    required this.townshipLabel,
    required this.degree,
    required this.weight,
  });

  factory NearbyWard.fromJson(Map<String, dynamic> json) => NearbyWard(
        ward: json['ward']?.toString() ?? '',
        township: json['township']?.toString() ?? '',
        townshipLabel: json['township_label']?.toString() ?? '',
        degree: _toInt(json['degree'], fallback: 1),
        weight: _toDouble(json['weight']),
      );

  final String ward;
  final String township;
  final String townshipLabel;
  final int degree;
  final double weight;
}

class NearbyTownship {
  const NearbyTownship(
      {required this.key, required this.label, required this.hops});

  factory NearbyTownship.fromJson(Map<String, dynamic> json) => NearbyTownship(
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        hops: _toInt(json['hops'], fallback: 1),
      );

  final String key;
  final String label;
  final int hops;
}

class NearbyInfo {
  const NearbyInfo({
    required this.ward,
    required this.township,
    required this.wards,
    required this.townships,
  });

  factory NearbyInfo.fromJson(Map<String, dynamic> json) => NearbyInfo(
        ward: _nullable(json['ward']),
        township: _nullable(json['township']),
        wards: (json['wards'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => NearbyWard.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false),
        townships: (json['townships'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => NearbyTownship.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false),
      );

  final String? ward;
  final String? township;
  final List<NearbyWard> wards;
  final List<NearbyTownship> townships;
}

/// One stored link touching a quarter, for the manage sheet.
class LocalityLink {
  const LocalityLink({
    required this.id,
    required this.key,
    required this.township,
    required this.weight,
    required this.source,
    required this.confirmed,
    required this.blocked,
    this.evidence,
  });

  factory LocalityLink.fromJson(Map<String, dynamic> json) => LocalityLink(
        id: _toInt(json['id']),
        key: json['key']?.toString() ?? '',
        township: json['township']?.toString() ?? '',
        weight: _toDouble(json['weight']),
        source: json['source']?.toString() ?? '',
        confirmed: json['confirmed'] == true,
        blocked: json['blocked'] == true,
        evidence: _nullable(json['evidence']),
      );

  final int id;
  final String key;
  final String township;
  final double weight;
  final String source;
  final bool confirmed;
  final bool blocked;
  final String? evidence;
}

class WardOption {
  const WardOption({
    required this.key,
    required this.township,
    required this.townshipLabel,
    required this.members,
    required this.kind,
  });

  factory WardOption.fromJson(Map<String, dynamic> json) => WardOption(
        key: json['key']?.toString() ?? '',
        township: json['township']?.toString() ?? '',
        townshipLabel: json['township_label']?.toString() ?? '',
        members: _toInt(json['members']),
        kind: json['kind']?.toString() ?? 'other',
      );

  final String key;
  final String township;
  final String townshipLabel;
  final int members;
  final String kind;
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
    this.location,
  });

  factory SmartSearchPage.fromJson(Map<String, dynamic> json) {
    final parsedJson = json['parsed'];
    final analysisJson = json['analysis'];
    final locationJson = analysisJson is Map ? analysisJson['location'] : null;
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
      location: locationJson is Map
          ? SmartLocationCounts.fromJson(
              Map<String, dynamic>.from(locationJson))
          : null,
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
  final SmartLocationCounts? location;

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
