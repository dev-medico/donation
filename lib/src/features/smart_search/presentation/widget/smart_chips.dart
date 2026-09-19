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
  });

  final SmartSearchPage page;
  final List<TownshipOption> townships;
  final ValueChanged<String?> onChangeBloodGroup;
  final ValueChanged<String?> onChangeTownship;
  final ValueChanged<String?> onChangeGender;
  final ValueChanged<bool> onToggleUrgent;

  /// (wardKey, townshipKey); null clears the quarter.
  final void Function(String? ward, String? township) onChangeWard;
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

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
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
            labels: townships
                .map((t) => '${t.my} · ${t.en}')
                .toList(growable: false),
            selected: f.township,
            onPicked: onChangeTownship,
          ),
        ),
        _FilterChip(
          keyName: 'ward',
          label: f.ward ?? 'ရပ်ကွက် / ကျေးရွာ',
          set: f.ward != null,
          confidence: _confidence('ward'),
          onTap: () =>
              _pickWard(context, township: f.township, selected: f.ward),
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
        FilterChip(
          key: const ValueKey('smart-chip-urgent'),
          visualDensity: VisualDensity.compact,
          selected: f.urgent,
          label: const Text('အရေးပေါ်', style: TextStyle(fontSize: 12)),
          selectedColor: const Color(0xFFFDECEC),
          checkmarkColor: const Color(0xFFA70507),
          onSelected: onToggleUrgent,
        ),
      ],
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
  const LocationCountsLine(
      {super.key, required this.filters, required this.location});

  final SmartFilters filters;
  final SmartLocationCounts? location;

  @override
  Widget build(BuildContext context) {
    final loc = location;
    if (loc == null || (filters.ward == null && filters.township == null)) {
      return const SizedBox.shrink();
    }
    final parts = <String>[
      if (filters.ward != null)
        'ရပ်ကွက်တူ ${loc.sameWard} (လှူနိုင် ${loc.sameWardGreen})',
      if (filters.township != null) 'မြို့နယ်တူ ${loc.sameTownship}',
      if (loc.neighbour > 0) 'အနီးအနား ${loc.neighbour}',
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, size: 15, color: Colors.black45),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              parts.join(' · '),
              style: const TextStyle(fontSize: 12.5, color: Colors.black87),
            ),
          ),
        ],
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
  });

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

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        chip(null, 'အားလုံး', a?.total ?? total, Colors.black54),
        chip('green', 'လှူနိုင်', a?.green ?? 0, availabilityColor('green')),
        chip('yellow', 'စောင့်ဆိုင်း', a?.yellow ?? 0,
            availabilityColor('yellow')),
        chip('red', 'ပိတ်ထား', a?.red ?? 0, availabilityColor('red')),
      ],
    );
  }
}
