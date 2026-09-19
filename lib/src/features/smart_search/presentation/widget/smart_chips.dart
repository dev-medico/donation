import 'package:donation/src/features/donation_member/data/search_member_repository.dart'
    show SearchMemberAnalysis;
import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';
import 'package:donation/src/features/smart_search/presentation/widget/ranked_donor_card.dart';
import 'package:flutter/material.dart';

const bloodGroupOptions = <String>[
  'A+',
  'A-',
  'B+',
  'B-',
  'O+',
  'O-',
  'AB+',
  'AB-'
];

/// What the server understood, as tappable chips. Tapping opens a picker and
/// re-queries with explicit filters, so the user always has the last word.
/// One horizontally scrollable line of chips for the compact layout.
Widget hScrollRow(List<Widget> children, {double gap = 6}) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          children[i],
        ],
      ],
    ),
  );
}

class SmartUnderstoodBar extends StatelessWidget {
  const SmartUnderstoodBar({
    super.key,
    required this.page,
    required this.townships,
    required this.onChangeBloodGroup,
    required this.onChangeTownship,
    required this.onChangeGender,
    required this.onToggleUrgent,
    required this.onChangeWard,
    required this.loadWards,
    required this.onToggleNearby,
    required this.onClearExtra,
    this.compact = false,
  });

  /// One scrollable line instead of a wrapping cloud.
  final bool compact;
  final SmartSearchPage page;

  /// Clears one of the understood extras: hospital | age | donor_kind | needed.
  final ValueChanged<String> onClearExtra;
  final List<TownshipOption> townships;
  final ValueChanged<String?> onChangeBloodGroup;
  final ValueChanged<String?> onChangeTownship;
  final ValueChanged<String?> onChangeGender;
  final ValueChanged<bool> onToggleUrgent;

  /// (wardKey, townshipKey); null clears the quarter.
  final void Function(String? ward, String? township) onChangeWard;
  final ValueChanged<bool> onToggleNearby;
  final Future<List<WardOption>> Function({String? township, String? query})
      loadWards;

  double? _confidence(String field) {
    final chips = page.parsed?.chips ?? const [];
    for (final c in chips) {
      if (c.field == field) return c.confidence;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final f = page.filters;
    final modeLabel = switch (page.mode) {
      'smart' => page.parsed?.fromCache == true ? 'စမတ် (cache)' : 'စမတ်',
      'rank' => 'ကိုယ်တိုင်ရွေး',
      _ => 'စာသားရှာဖွေမှု',
    };
    final groupLabel = f.bloodGroups.isEmpty
        ? null
        : (f.bloodGroups.length == 1
            ? f.bloodGroups.first
            : '${f.bloodGroups.first.replaceAll(RegExp(r'[+-]$'), '')} (Rh ?)');
    final genderLabel = switch (f.gender) {
      'female' => 'အမျိုးသမီး',
      'male' => 'အမျိုးသား',
      _ => null,
    };

    final children = <Widget>[
      Chip(
        visualDensity: VisualDensity.compact,
        avatar: const Icon(Icons.auto_awesome, size: 15),
        label: Text(modeLabel, style: const TextStyle(fontSize: 12)),
        backgroundColor: const Color(0xFFF3F4F6),
        side: BorderSide.none,
      ),
      _FilterChip(
        keyName: 'blood_group',
        label: groupLabel ?? 'သွေးအုပ်စု',
        set: groupLabel != null,
        confidence: _confidence('blood_group'),
        onTap: () => _pickFromList(
          context,
          title: 'သွေးအုပ်စု',
          options: bloodGroupOptions,
          labels: bloodGroupOptions,
          selected: f.bloodGroups.length == 1 ? f.bloodGroups.first : null,
          onPicked: onChangeBloodGroup,
        ),
      ),
      _FilterChip(
        keyName: 'township',
        label: f.townshipLabel ?? (f.township ?? 'မြို့နယ်'),
        set: f.township != null,
        confidence: _confidence('township'),
        onTap: () => _pickFromList(
          context,
          title: 'မြို့နယ်',
          options: townships.map((t) => t.key).toList(growable: false),
          labels:
              townships.map((t) => '${t.my} · ${t.en}').toList(growable: false),
          selected: f.township,
          onPicked: onChangeTownship,
        ),
      ),
      _FilterChip(
        keyName: 'ward',
        label: f.ward ?? 'ရပ်ကွက် / ကျေးရွာ',
        set: f.ward != null,
        confidence: _confidence('ward'),
        onTap: () => _pickWard(context, township: f.township, selected: f.ward),
      ),
      _FilterChip(
        keyName: 'gender',
        label: genderLabel ?? 'ကျား/မ',
        set: genderLabel != null,
        confidence: _confidence('gender'),
        onTap: () => _pickFromList(
          context,
          title: 'ကျား/မ',
          options: const ['female', 'male'],
          labels: const ['အမျိုးသမီး', 'အမျိုးသား'],
          selected: f.gender,
          onPicked: onChangeGender,
        ),
      ),
      if (f.hospital != null)
        _ExtraChip(
          keyName: 'hospital',
          icon: Icons.local_hospital_outlined,
          label: f.hospital!,
          onClear: () => onClearExtra('hospital'),
        ),
      if (f.ageMin != null || f.ageMax != null)
        _ExtraChip(
          keyName: 'age',
          icon: Icons.cake_outlined,
          label: 'အသက် ${f.ageMin ?? ''}–${f.ageMax ?? ''}',
          onClear: () => onClearExtra('age'),
        ),
      if (f.donorKind != null)
        _ExtraChip(
          keyName: 'donor_kind',
          icon: Icons.history_outlined,
          label: f.donorKind == 'regular' ? 'ပုံမှန်လှူသူ' : 'ပထမဆုံးအကြိမ်',
          onClear: () => onClearExtra('donor_kind'),
        ),
      if (f.needed != null)
        _ExtraChip(
          keyName: 'needed',
          icon: Icons.groups_outlined,
          label: '${f.needed} ဦး လိုအပ်',
          onClear: () => onClearExtra('needed'),
        ),
      if (f.bloodGroups.length > 2)
        _ExtraChip(
          keyName: 'groups',
          icon: Icons.bloodtype_outlined,
          label: f.bloodGroups.join(' / '),
          onClear: () => onChangeBloodGroup(null),
        ),
      FilterChip(
        key: const ValueKey('smart-chip-nearby'),
        visualDensity: VisualDensity.compact,
        selected: f.includeNearby,
        avatar: const Icon(Icons.near_me_outlined, size: 15),
        label: const Text('အနီးအနားပါ', style: TextStyle(fontSize: 12)),
        selectedColor: const Color(0xFFE8F5E9),
        checkmarkColor: const Color(0xFF2E7D32),
        tooltip:
            'ဖွင့်ထားလျှင် မြို့နယ်တူ၊ ကပ်လျက်၊ အနီးအနား မြို့နယ်များကို အနီးဆုံးမှ စီပြသည်; ပိတ်လျှင် ရွေးထားသည့် မြို့နယ်သာ',
        onSelected: onToggleNearby,
      ),
      FilterChip(
        key: const ValueKey('smart-chip-urgent'),
        visualDensity: VisualDensity.compact,
        selected: f.urgent,
        label: const Text('အရေးပေါ်', style: TextStyle(fontSize: 12)),
        selectedColor: const Color(0xFFFDECEC),
        checkmarkColor: const Color(0xFFA70507),
        onSelected: onToggleUrgent,
      ),
    ];
    if (compact) return hScrollRow(children);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  Future<void> _pickFromList(
    BuildContext context, {
    required String title,
    required List<String> options,
    required List<String> labels,
    required String? selected,
    required ValueChanged<String?> onPicked,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            ListTile(
              key: const ValueKey('smart-pick-any'),
              leading: const Icon(Icons.clear_all),
              title: const Text('အားလုံး (ကန့်သတ်ချက် မထား)'),
              onTap: () => Navigator.pop(context, ''),
            ),
            for (var i = 0; i < options.length; i++)
              ListTile(
                key: ValueKey('smart-pick-${options[i]}'),
                title: Text(labels[i]),
                trailing: options[i] == selected
                    ? const Icon(Icons.check, color: Color(0xFFA70507))
                    : null,
                onTap: () => Navigator.pop(context, options[i]),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    onPicked(picked.isEmpty ? null : picked);
  }

  Future<void> _pickWard(BuildContext context,
      {String? township, String? selected}) async {
    final picked = await showModalBottomSheet<WardOption?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _WardPicker(
        township: township,
        townshipLabel: townships
            .where((t) => t.key == township)
            .map((t) => t.my)
            .firstOrNull,
        selected: selected,
        loadWards: loadWards,
      ),
    );
    if (picked == null) return;
    if (picked.key.isEmpty) {
      onChangeWard(null, null);
    } else {
      onChangeWard(picked.key, picked.township);
    }
  }
}

/// Searchable list of quarters / villages, optionally within one township.
class _WardPicker extends StatefulWidget {
  const _WardPicker({
    required this.township,
    required this.townshipLabel,
    required this.selected,
    required this.loadWards,
  });

  final String? township;
  final String? townshipLabel;
  final String? selected;
  final Future<List<WardOption>> Function({String? township, String? query})
      loadWards;

  @override
  State<_WardPicker> createState() => _WardPickerState();
}

class _WardPickerState extends State<_WardPicker> {
  final _search = TextEditingController();
  List<WardOption> _all = const [];
  bool _loading = true;
  String? _error;
  bool _allTownships = false;

  @override
  void initState() {
    super.initState();
    _allTownships = widget.township == null;
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await widget.loadWards(
        township: _allTownships ? null : widget.township,
      );
      if (!mounted) return;
      setState(() {
        _all = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  String _norm(String s) => s
      .replaceAll(RegExp(r'\s+|[()（）]'), '')
      .replaceAll(RegExp(r'(ရပ်ကွက်|ရပ်|ကျေးရွာ|ရွာ|မြို့)$'), '');

  @override
  Widget build(BuildContext context) {
    final needle = _norm(_search.text.trim());
    final rows = needle.isEmpty
        ? _all
        : _all
            .where((w) =>
                _norm(w.key).contains(needle) ||
                w.key.contains(_search.text.trim()))
            .toList();
    final height = MediaQuery.sizeOf(context).height * 0.75;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.townshipLabel == null || _allTownships
                        ? 'ရပ်ကွက် / ကျေးရွာ (အားလုံး)'
                        : 'ရပ်ကွက် / ကျေးရွာ · ${widget.townshipLabel}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                if (widget.township != null)
                  TextButton(
                    key: const ValueKey('smart-ward-picker-scope'),
                    onPressed: () {
                      setState(() => _allTownships = !_allTownships);
                      _load();
                    },
                    child:
                        Text(_allTownships ? 'ဤမြို့နယ်သာ' : 'မြို့နယ်အားလုံး'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              key: const ValueKey('smart-ward-picker-search'),
              controller: _search,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ရပ်ကွက် သို့မဟုတ် ကျေးရွာ အမည် ရိုက်ပါ',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            key: const ValueKey('smart-ward-picker-any'),
            dense: true,
            leading: const Icon(Icons.clear_all),
            title: const Text('ကန့်သတ်ချက် မထား'),
            onTap: () => Navigator.pop(
                context,
                const WardOption(
                    key: '',
                    township: '',
                    townshipLabel: '',
                    members: 0,
                    kind: 'other')),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.black54)))
                    : ListView.builder(
                        itemCount: rows.length,
                        itemBuilder: (context, i) {
                          final w = rows[i];
                          final kind = switch (w.kind) {
                            'village' => 'ကျေးရွာ',
                            'street' => 'လမ်း',
                            'ward' => 'ရပ်ကွက်',
                            _ => '',
                          };
                          return ListTile(
                            key: ValueKey('smart-ward-${w.key}'),
                            dense: true,
                            title: Text(w.key),
                            subtitle: Text(
                              [w.townshipLabel, if (kind.isNotEmpty) kind]
                                  .join(' · '),
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text('${w.members}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                            selected: w.key == widget.selected,
                            onTap: () => Navigator.pop(context, w),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ExtraChip extends StatelessWidget {
  const _ExtraChip({
    required this.keyName,
    required this.icon,
    required this.label,
    required this.onClear,
  });

  final String keyName;
  final IconData icon;
  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      key: ValueKey('smart-chip-$keyName'),
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 15, color: const Color(0xFFA70507)),
      label: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFFFDECEC),
      side: const BorderSide(color: Color(0xFFF5C2C2)),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onClear,
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.keyName,
    required this.label,
    required this.set,
    required this.confidence,
    required this.onTap,
  });

  final String keyName;
  final String label;
  final bool set;
  final double? confidence;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unsure = set && confidence != null && confidence! < 0.8;
    return ActionChip(
      key: ValueKey('smart-chip-$keyName'),
      visualDensity: VisualDensity.compact,
      avatar: Icon(
        set ? Icons.check_circle : Icons.add_circle_outline,
        size: 16,
        color: set ? const Color(0xFFA70507) : Colors.black45,
      ),
      label: Text(
        unsure ? '$label ?' : label,
        style: TextStyle(
          fontSize: 12,
          color: set ? Colors.black : Colors.black54,
          fontWeight: set ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      backgroundColor: set ? const Color(0xFFFDECEC) : Colors.white,
      side: BorderSide(
          color: set ? const Color(0xFFF5C2C2) : const Color(0xFFE5E7EB)),
      onPressed: onTap,
    );
  }
}

/// Questions the server could not settle, each answered with one tap.
class SmartQuestionsBar extends StatelessWidget {
  const SmartQuestionsBar({
    super.key,
    required this.questions,
    required this.onAnswer,
  });

  final List<SmartQuestion> questions;
  final void Function(String field, String value) onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final q in questions)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  q.field == 'blood_group'
                      ? 'Rh အမျိုးအစား?'
                      : 'မြို့နယ် ဘယ်ဟာလဲ?',
                  style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w600),
                ),
                for (var i = 0; i < q.options.length; i++)
                  ActionChip(
                    key: ValueKey('smart-question-${q.field}-${q.options[i]}'),
                    visualDensity: VisualDensity.compact,
                    label: Text(q.labelFor(i),
                        style: const TextStyle(fontSize: 12)),
                    backgroundColor: const Color(0xFFFFF7ED),
                    side: const BorderSide(color: Color(0xFFFED7AA)),
                    onPressed: () => onAnswer(q.field, q.options[i]),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// "12 in the same quarter, 455 in the township": what the ranking put first.
class LocationCountsLine extends StatelessWidget {
  const LocationCountsLine({
    super.key,
    required this.filters,
    required this.location,
    this.compact = false,
  });

  final bool compact;
  final SmartFilters filters;
  final SmartLocationCounts? location;

  @override
  Widget build(BuildContext context) {
    final loc = location;
    if (loc == null || (filters.ward == null && filters.township == null)) {
      return const SizedBox.shrink();
    }
    String tier(String label, int total, int green) =>
        compact ? '$label $total ($green)' : '$label $total (လှူနိုင် $green)';
    final parts = <String>[
      if (filters.ward != null)
        tier('ရပ်ကွက်တူ', loc.sameWard, loc.sameWardGreen),
      if (filters.ward != null && loc.nearWard1 > 0)
        tier('အနီးဆုံး ၁', loc.nearWard1, loc.nearWard1Green),
      if (filters.ward != null && loc.nearWard2 > 0)
        tier('အနီးအနား ၂', loc.nearWard2, loc.nearWard2Green),
      if (filters.township != null)
        tier('မြို့နယ်တူ', loc.sameTownship, loc.sameTownshipGreen),
      if (filters.township != null &&
          filters.includeNearby &&
          loc.adjacentTownship > 0)
        tier(
            'ကပ်လျက်မြို့နယ်', loc.adjacentTownship, loc.adjacentTownshipGreen),
      if (filters.township != null &&
          filters.includeNearby &&
          loc.secondHop > 0)
        tier('အနီးအနားမြို့နယ်', loc.secondHop, loc.secondHopGreen),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.place_outlined, size: 15, color: Colors.black45),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              parts.join(' · '),
              maxLines: compact ? 1 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
              style: TextStyle(
                  fontSize: compact ? 11.5 : 12.5,
                  color: Colors.black87,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nearby quarters of the selected one, by degree; tap to search from there,
/// long-press to manage the connections.
class NearbyRow extends StatelessWidget {
  const NearbyRow({
    super.key,
    required this.filters,
    required this.info,
    required this.onPickWard,
    required this.onManage,
    this.compact = false,
  });

  final bool compact;
  final SmartFilters filters;
  final NearbyInfo? info;
  final void Function(String ward, String township) onPickWard;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final i = info;
    if (i == null || filters.ward == null) return const SizedBox.shrink();
    final wards = i.wards.take(compact ? 8 : 12).toList(growable: false);
    final hidden = i.wards.length - wards.length;
    final children = <Widget>[
      const Text('အနီးအနား:',
          style: TextStyle(fontSize: 12, color: Colors.black54)),
      if (wards.isEmpty)
        const Text('ချိတ်ဆက်ထားသည့် ရပ်ကွက် မရှိသေးပါ',
            style: TextStyle(fontSize: 12, color: Colors.black38)),
      for (final w in wards)
        ActionChip(
          key: ValueKey('smart-nearby-${w.ward}'),
          visualDensity: VisualDensity.compact,
          avatar: CircleAvatar(
            radius: 9,
            backgroundColor: w.degree == 1
                ? const Color(0xFF2E7D32)
                : const Color(0xFF9CCC65),
            child: Text('${w.degree}',
                style: const TextStyle(fontSize: 10, color: Colors.white)),
          ),
          label: Text(w.ward, style: const TextStyle(fontSize: 12)),
          onPressed: () => onPickWard(w.ward, w.township),
        ),
      ActionChip(
        key: const ValueKey('smart-nearby-manage'),
        visualDensity: VisualDensity.compact,
        avatar: const Icon(Icons.edit_location_alt_outlined, size: 15),
        label:
            const Text('ချိတ်ဆက်မှု ပြင်ရန်', style: TextStyle(fontSize: 12)),
        onPressed: onManage,
      ),
    ];
    if (hidden > 0) {
      children.insert(
        children.length - 1,
        Text('+$hidden',
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: compact ? 4 : 6),
      child: compact
          ? hScrollRow(children)
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children,
            ),
    );
  }
}

/// Manage the connections of one quarter: confirm, block, or add.
class NearbyLinksSheet extends StatefulWidget {
  const NearbyLinksSheet({
    super.key,
    required this.ward,
    required this.township,
    required this.loadLinks,
    required this.setLink,
    required this.loadWards,
  });

  final String ward;
  final String township;
  final Future<List<LocalityLink>> Function() loadLinks;
  final Future<void> Function(String to, String toTownship, String action)
      setLink;
  final Future<List<WardOption>> Function({String? township, String? query})
      loadWards;

  @override
  State<NearbyLinksSheet> createState() => _NearbyLinksSheetState();
}

class _NearbyLinksSheetState extends State<NearbyLinksSheet> {
  List<LocalityLink> _links = const [];
  bool _loading = true;
  String? _error;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await widget.loadLinks();
      if (!mounted) return;
      setState(() {
        _links = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _act(LocalityLink l, String action) async {
    try {
      await widget.setLink(l.key, l.township, action);
      _changed = true;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _add() async {
    final picked = await showModalBottomSheet<WardOption?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _WardPicker(
        township: widget.township,
        townshipLabel: null,
        selected: null,
        loadWards: widget.loadWards,
      ),
    );
    if (picked == null || picked.key.isEmpty || picked.key == widget.ward)
      return;
    try {
      await widget.setLink(picked.key, picked.township, 'add');
      _changed = true;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.75;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {},
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${widget.ward} · အနီးအနား ချိတ်ဆက်မှု',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  TextButton.icon(
                    key: const ValueKey('smart-links-add'),
                    onPressed: _add,
                    icon: const Icon(Icons.add_link, size: 18),
                    label: const Text('ထည့်ရန်'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'အလိုအလျောက် ချိတ်ဆက်မှုများသည် လိပ်စာ၊ လမ်းအမည်နှင့် သွေးလှူမှတ်တမ်းမှ ရရှိသည်။ အတည်ပြုလျှင် အမြဲရေတွက်ပြီး ပိတ်လျှင် ဘယ်တော့မှ မရေတွက်ပါ။',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 6),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.black54)))
                      : _links.isEmpty
                          ? const Center(
                              child: Text('ချိတ်ဆက်မှု မရှိသေးပါ',
                                  style: TextStyle(color: Colors.black54)))
                          : ListView.builder(
                              itemCount: _links.length,
                              itemBuilder: (context, i) {
                                final l = _links[i];
                                final state = l.blocked
                                    ? 'ပိတ်ထား'
                                    : l.confirmed
                                        ? 'အတည်ပြုပြီး'
                                        : 'အလိုအလျောက် ${(l.weight * 100).round()}%';
                                return ListTile(
                                  key: ValueKey('smart-link-${l.id}'),
                                  dense: true,
                                  leading: Icon(
                                    l.blocked
                                        ? Icons.block
                                        : l.confirmed
                                            ? Icons.verified_outlined
                                            : Icons.auto_awesome_outlined,
                                    color: l.blocked
                                        ? Colors.red
                                        : l.confirmed
                                            ? const Color(0xFF2E7D32)
                                            : Colors.black45,
                                  ),
                                  title: Text(l.key),
                                  subtitle: Text(
                                      [
                                        state,
                                        if (l.evidence != null) l.evidence!
                                      ].join(' · '),
                                      style: const TextStyle(fontSize: 11.5)),
                                  trailing: Wrap(
                                    spacing: 4,
                                    children: [
                                      if (!l.confirmed && !l.blocked)
                                        IconButton(
                                          tooltip: 'အတည်ပြုမည်',
                                          icon: const Icon(
                                              Icons.check_circle_outline,
                                              size: 20),
                                          onPressed: () => _act(l, 'confirm'),
                                        ),
                                      if (!l.blocked)
                                        IconButton(
                                          tooltip: 'ပိတ်မည်',
                                          icon:
                                              const Icon(Icons.block, size: 20),
                                          onPressed: () => _act(l, 'block'),
                                        )
                                      else
                                        IconButton(
                                          tooltip: 'ပြန်ဖွင့်မည်',
                                          icon:
                                              const Icon(Icons.undo, size: 20),
                                          onPressed: () => _act(l, 'unblock'),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, _changed),
                    child: const Text('ပိတ်မည်'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Green / yellow / red counts for the whole result, used as a page filter.
class AvailabilitySummary extends StatelessWidget {
  const AvailabilitySummary({
    super.key,
    required this.analysis,
    required this.total,
    required this.selected,
    required this.onSelected,
    this.compact = false,
  });

  final bool compact;
  final SearchMemberAnalysis? analysis;
  final int total;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    Widget chip(String? level, String label, int count, Color color) {
      final isSelected = selected == level;
      return ChoiceChip(
        key: ValueKey('smart-availability-${level ?? 'all'}'),
        visualDensity: VisualDensity.compact,
        selected: isSelected,
        showCheckmark: false,
        selectedColor: color.withValues(alpha: 0.18),
        side: BorderSide(color: isSelected ? color : const Color(0xFFE5E7EB)),
        avatar: level == null
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
        label: Text('$label $count', style: const TextStyle(fontSize: 12)),
        onSelected: (_) => onSelected(isSelected ? null : level),
      );
    }

    final children = <Widget>[
      chip(null, 'အားလုံး', a?.total ?? total, Colors.black54),
      chip('green', 'လှူနိုင်', a?.green ?? 0, availabilityColor('green')),
      chip('yellow', 'စောင့်ဆိုင်း', a?.yellow ?? 0,
          availabilityColor('yellow')),
      chip('red', 'ပိတ်ထား', a?.red ?? 0, availabilityColor('red')),
    ];
    if (compact) return hScrollRow(children);
    return Wrap(spacing: 6, runSpacing: 6, children: children);
  }
}
