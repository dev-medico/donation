import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';
import 'package:donation/src/features/smart_search/presentation/controller/smart_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _primary = Color(0xFFA70507);
const _green = Color(0xFF2E7D32);
const _border = Color(0xFFE5E7EB);
const _muted = Color(0xFF6B7280);
const _body = Color(0xFF374151);

const _allGroups = ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'];

/// What the screen shows before anything is searched: donors per group who
/// can give now, quick picks that build a query, recent searches, examples.
class SmartHomeState extends ConsumerWidget {
  const SmartHomeState({
    super.key,
    required this.examples,
    required this.onSearch,
    required this.onAppend,
    required this.onGroup,
  });

  final List<String> examples;

  /// Runs the search right away.
  final ValueChanged<String> onSearch;

  /// Adds a word to the search box so the user can combine picks.
  final ValueChanged<String> onAppend;

  /// Searches a blood group, keeping whatever else is typed.
  final ValueChanged<String> onGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(smartOverviewProvider);
    final recent = ref.watch(smartRecentSearchesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 850;
        final groupsCard = _Card(
          title: 'သွေးအုပ်စုအလိုက် ယခု လှူနိုင်သူ',
          icon: Icons.water_drop_outlined,
          trailing: overview.isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : overview.hasError
                  ? IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      tooltip: 'အရေအတွက် ပြန်ယူမည်',
                      icon: const Icon(Icons.refresh, color: _muted),
                      onPressed: () => ref.invalidate(smartOverviewProvider),
                    )
                  : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GroupGrid(
                groups: overview.asData?.value.groups ?? const [],
                onGroup: onGroup,
              ),
              const SizedBox(height: 8),
              const Text(
                'Rh-negative အုပ်စုများ ရှားပါးသဖြင့် အနီရောင်ဘောင်ဖြင့် ပြထားသည်။ တစ်ခုကို နှိပ်လျှင် ထိုအုပ်စုကို အနီးဆုံးမှ စီ၍ ရှာပေးမည်။',
                style: TextStyle(fontSize: 11, color: _muted, height: 1.4),
              ),
            ],
          ),
        );
        final quickCard = _Card(
          title: 'အမြန်ရွေးရန်',
          icon: Icons.bolt_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Quick(
                    label: 'ယခုလှူနိုင်သူသာ',
                    icon: Icons.bolt,
                    color: _green,
                    onTap: () => onAppend('ချက်ချင်း'),
                  ),
                  _Quick(
                    label: 'အရေးပေါ် (အနီးဆုံးမှ)',
                    icon: Icons.near_me_outlined,
                    color: _primary,
                    onTap: () => onAppend('အရေးပေါ်'),
                  ),
                  _Quick(
                    label: 'အမျိုးသမီး',
                    icon: Icons.female,
                    onTap: () => onAppend('အမျိုးသမီး'),
                  ),
                  _Quick(
                    label: 'အမျိုးသား',
                    icon: Icons.male,
                    onTap: () => onAppend('အမျိုးသား'),
                  ),
                  _Quick(
                    label: 'ပုံမှန်လှူသူများ',
                    icon: Icons.history,
                    onTap: () => onAppend('ပုံမှန်လှူသူ'),
                  ),
                  _Quick(
                    label: 'ပထမဆုံးအကြိမ်',
                    icon: Icons.auto_awesome_outlined,
                    onTap: () => onAppend('ပထမဆုံးအကြိမ်လှူသူ'),
                  ),
                  for (final h
                      in (overview.asData?.value.hospitals ?? const []).take(4))
                    _Quick(
                      label: h.label,
                      icon: Icons.local_hospital_outlined,
                      onTap: () => onAppend(h.label),
                    ),
                  for (final t
                      in (overview.asData?.value.townships ?? const []).take(4))
                    _Quick(
                      label: t.label,
                      icon: Icons.place_outlined,
                      onTap: () => onAppend(t.label),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'နှိပ်လိုက်သည်များကို ရှာဖွေရန်အကွက်ထဲ ပေါင်းထည့်ပေးမည်; ပြီးလျှင် "ရှာမည်" နှိပ်ပါ။',
                style: TextStyle(fontSize: 11, color: _muted, height: 1.4),
              ),
            ],
          ),
        );
        final recentCard = _Card(
          title: 'မကြာသေးမီက ရှာခဲ့သည်များ',
          icon: Icons.history,
          trailing: recent.isEmpty
              ? null
              : TextButton(
                  key: const ValueKey('smart-recent-clear'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: _muted,
                    textStyle: const TextStyle(fontSize: 11.5),
                  ),
                  onPressed: () =>
                      ref.read(smartRecentSearchesProvider.notifier).clear(),
                  child: const Text('ရှင်းမည်'),
                ),
          child: recent.isEmpty
              ? const Text(
                  'ရှာဖွေမှုများ ဤနေရာတွင် မှတ်ထားပေးမည်။',
                  style: TextStyle(fontSize: 12, color: _muted),
                )
              : Column(
                  children: [
                    for (final q in recent)
                      InkWell(
                        key: ValueKey('smart-recent-$q'),
                        onTap: () => onSearch(q),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Color(0xFFF1F5F9))),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.history,
                                  size: 14, color: _muted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  q,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                iconSize: 15,
                                tooltip: 'ဖျက်မည်',
                                icon: const Icon(Icons.close, color: _muted),
                                onPressed: () => ref
                                    .read(smartRecentSearchesProvider.notifier)
                                    .remove(q),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        );
        final examplesCard = _Card(
          title: 'ဥပမာများ',
          icon: Icons.auto_awesome_outlined,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in examples)
                _Quick(
                  label: e,
                  icon: Icons.search,
                  onTap: () => onSearch(e),
                ),
            ],
          ),
        );

        return ListView(
          key: const ValueKey('smart-search-home'),
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
          children: [
            const Text(
              'သွေးအုပ်စု၊ မြို့နယ်၊ ရပ်ကွက်/ကျေးရွာ၊ ဆေးရုံ၊ ကျား/မ၊ အသက်၊ အရေးပေါ်၊ ချက်ချင်းလှူနိုင်သူ — စကားပြောသလို တစ်ကြောင်းတည်း ရိုက်ပါ။ B+ve, ဘီပေါ့စ်, O -ve စသည်လည်း နားလည်သည်။',
              style: TextStyle(fontSize: 12, color: _muted, height: 1.5),
            ),
            const SizedBox(height: 10),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: groupsCard),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        quickCard,
                        const SizedBox(height: 12),
                        recentCard,
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              groupsCard,
              const SizedBox(height: 12),
              quickCard,
              const SizedBox(height: 12),
              recentCard,
            ],
            const SizedBox(height: 12),
            examplesCard,
          ],
        );
      },
    );
  }
}

class _GroupGrid extends StatelessWidget {
  const _GroupGrid({required this.groups, required this.onGroup});

  final List<GroupAvailability> groups;
  final ValueChanged<String> onGroup;

  @override
  Widget build(BuildContext context) {
    final byGroup = {for (final g in groups) g.group: g};
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 560 ? 8 : 4;
        const gap = 6.0;
        final w = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final name in _allGroups)
              SizedBox(
                width: w,
                child: _GroupTile(
                  name: name,
                  stats: byGroup[name],
                  narrow: w < 96,
                  onTap: () => onGroup(name),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.name,
    required this.stats,
    required this.onTap,
    this.narrow = false,
  });

  final String name;
  final GroupAvailability? stats;
  final VoidCallback onTap;

  /// Phone-width tiles have no room for the word before the numbers.
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final rare = stats?.rare ?? name.endsWith('-');
    return Material(
      color: rare ? const Color(0xFFFFF7F7) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: rare ? const Color(0xFFF5C2C2) : _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('smart-group-$name'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: _primary),
              ),
              const SizedBox(height: 1),
              stats == null
                  ? const Text('…',
                      style: TextStyle(fontSize: 11, color: _muted))
                  : RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11, color: _body),
                        children: [
                          if (!narrow) const TextSpan(text: 'လှူနိုင် '),
                          TextSpan(
                            text: '${stats!.green}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, color: _green),
                          ),
                          TextSpan(text: ' / ${stats!.total}'),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = _muted,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(side: BorderSide(color: _border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: _primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _body),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
