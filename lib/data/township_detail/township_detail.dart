import 'dart:convert';

import 'package:flutter/services.dart';

/// A single selectable place inside a township: either a ward (ရပ်ကွက်) grouped
/// under a town (မြို့), or a village (ကျေးရွာ) grouped under a village-tract
/// (ကျေးရွာအုပ်စု).
class PlaceEntry {
  final String name; // ward or village name
  final String type; // 'ward' | 'village'
  final String group; // town (for ward) or village-tract (for village)
  final String township;
  final String district;
  final String state;

  const PlaceEntry({
    required this.name,
    required this.type,
    required this.group,
    required this.township,
    required this.district,
    required this.state,
  });

  bool get isWard => type == 'ward';
  bool get isVillage => type == 'village';

  /// Localised label for the place type.
  String get typeLabelMm => isWard ? 'ရပ်ကွက်' : 'ကျေးရွာ';
}

class TownshipDetail {
  final String township;
  final String district;
  final String state;
  final List<PlaceEntry> places;

  const TownshipDetail({
    required this.township,
    required this.district,
    required this.state,
    required this.places,
  });
}

/// Loads and caches the Mon/Kayin administrative hierarchy bundled in
/// `assets/json/townships_detail.json` (state > district > township >
/// town/village-tract > ward/village) for the location selector.
///
/// The asset is ~380 KB, so it is parsed once and shared via [instance].
class TownshipDetailRepository {
  TownshipDetailRepository._();
  static final TownshipDetailRepository instance = TownshipDetailRepository._();

  final Map<String, TownshipDetail> _byTownship = {};
  List<String> _townshipNames = const [];
  bool _loaded = false;
  Future<void>? _loading;

  bool get isLoaded => _loaded;
  List<String> get townshipNames => _townshipNames;

  Future<void> ensureLoaded() {
    if (_loaded) return Future.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    final raw =
        await rootBundle.loadString('assets/json/townships_detail.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    final list = (map['townships'] as List?) ?? const [];

    for (final t in list) {
      final tm = t as Map<String, dynamic>;
      final township = (tm['township'] ?? '').toString();
      final district = (tm['district'] ?? '').toString();
      final state = (tm['state'] ?? '').toString();
      final places = <PlaceEntry>[];

      for (final w in (tm['wards'] as List? ?? const [])) {
        final wm = w as Map<String, dynamic>;
        places.add(PlaceEntry(
          name: (wm['name'] ?? '').toString(),
          type: 'ward',
          group: (wm['town'] ?? '').toString(),
          township: township,
          district: district,
          state: state,
        ));
      }
      for (final v in (tm['villages'] as List? ?? const [])) {
        final vm = v as Map<String, dynamic>;
        places.add(PlaceEntry(
          name: (vm['name'] ?? '').toString(),
          type: 'village',
          group: (vm['tract'] ?? '').toString(),
          township: township,
          district: district,
          state: state,
        ));
      }

      _byTownship[township] = TownshipDetail(
        township: township,
        district: district,
        state: state,
        places: places,
      );
    }

    _townshipNames = _byTownship.keys.toList()..sort();
    _loaded = true;
  }

  TownshipDetail? township(String name) => _byTownship[name];

  List<PlaceEntry> placesFor(String township) =>
      _byTownship[township]?.places ?? const [];

  /// Find the structured entry for a place by (township, name), or null when the
  /// value was free-typed, missing, or ambiguous within the township.
  ///
  /// Place names can repeat under different towns in the same township. In that
  /// case choosing the first match would silently attach a legacy flat address
  /// to the wrong town, so callers must ask the user to select the place again.
  PlaceEntry? findPlace(String township, String name) {
    final places = _byTownship[township]?.places;
    if (places == null) return null;
    PlaceEntry? match;
    for (final p in places) {
      if (p.name != name) continue;
      if (match != null && (match.type != p.type || match.group != p.group)) {
        return null;
      }
      match ??= p;
    }
    return match;
  }

  /// The town (မြို့) a ward belongs to, but only when it is unambiguous within
  /// the township. Some townships reuse ward names — e.g. "အမှတ်(၁)ရပ်ကွက်"
  /// exists under several towns — so the town cannot be inferred from the ward
  /// name alone; in that case (and for villages / unknown wards) this returns ''.
  String unambiguousTownForWard(String township, String ward) {
    final places = _byTownship[township.trim()]?.places;
    if (places == null) return '';
    final w = ward.trim();
    String? town;
    for (final p in places) {
      if (p.isWard && p.name == w) {
        if (town != null && town != p.group) return ''; // ambiguous
        town = p.group;
      }
    }
    return town ?? '';
  }
}
