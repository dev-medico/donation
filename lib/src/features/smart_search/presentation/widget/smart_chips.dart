import 'package:donation/src/features/donation_member/data/search_member_repository.dart'
    show SearchMemberAnalysis;
import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';
import 'package:donation/src/features/smart_search/presentation/widget/ranked_donor_card.dart';
import 'package:flutter/material.dart';

const bloodGroupOptions = <String>['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

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
  });

  final SmartSearchPage page;
  final List<TownshipOption> townships;
  final ValueChanged<String?> onChangeBloodGroup;
  final ValueChanged<String?> onChangeTownship;
  final ValueChanged<String?> onChangeGender;
  final ValueChanged<bool> onToggleUrgent;

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
            labels: townships.map((t) => '${t.my} · ${t.en}').toList(growable: false),
            selected: f.township,
            onPicked: onChangeTownship,
          ),
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
      side: BorderSide(color: set ? const Color(0xFFF5C2C2) : const Color(0xFFE5E7EB)),
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
                  q.field == 'blood_group' ? 'Rh အမျိုးအစား?' : 'မြို့နယ် ဘယ်ဟာလဲ?',
                  style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w600),
                ),
                for (var i = 0; i < q.options.length; i++)
                  ActionChip(
                    key: ValueKey('smart-question-${q.field}-${q.options[i]}'),
                    visualDensity: VisualDensity.compact,
                    label: Text(q.labelFor(i), style: const TextStyle(fontSize: 12)),
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
        chip('yellow', 'စောင့်ဆိုင်း', a?.yellow ?? 0, availabilityColor('yellow')),
        chip('red', 'ပိတ်ထား', a?.red ?? 0, availabilityColor('red')),
      ],
    );
  }
}
