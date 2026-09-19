import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/presentation/widget/call_or_remark_dialog.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';
import 'package:donation/src/features/smart_search/presentation/controller/smart_search_provider.dart';
import 'package:donation/src/features/smart_search/presentation/widget/compact_donor_row.dart';
import 'package:donation/src/features/smart_search/presentation/widget/ranked_donor_card.dart';
import 'package:donation/src/features/smart_search/presentation/widget/smart_chips.dart';
import 'package:donation/src/features/smart_search/presentation/widget/smart_home.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _pageBackground = Color(0xFFF3F4F6);
const _border = Color(0xFFE5E7EB);
const _muted = Color(0xFF6B7280);

final _groupToken = RegExp(r'^(A|B|AB|O)[+-]?$', caseSensitive: false);

/// Smart Find Blood (beta): one text box, server-side parsing and ranking.
/// Lives beside the existing Find Blood screen and shares nothing with it
/// except the call/remark dialog.
class SmartSearchScreen extends ConsumerStatefulWidget {
  static const routeName = '/smart_search';
  final bool fromHome;
  const SmartSearchScreen({super.key, this.fromHome = false});

  @override
  ConsumerState<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends ConsumerState<SmartSearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  static const _examples = <String>[
    'B+ မော်လမြိုင် အမျိုးသမီး',
    'O- အရေးပေါ် ငွေမိုးဆေးရုံ',
    'AB+ ဆေးရုံကြီး ဒီည ချက်ချင်း',
    'A+ or O+ ဇေယျာသီရိ 3 ဦး',
    'B positive regular donors age 20-40',
    'A ရှိလား',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit([String? value]) {
    final q = (value ?? _controller.text).trim();
    if (q.isEmpty) return;
    _controller.text = q;
    _focus.unfocus();
    ref.read(smartRecentSearchesProvider.notifier).add(q);
    ref.read(smartSearchControllerProvider.notifier).search(q);
  }

  /// Quick picks add a word to the box; the user presses search when done.
  void _append(String token) {
    final current = _controller.text.trim();
    final words = current.split(RegExp(r'\s+'));
    if (words.contains(token)) return;
    _controller.text = current.isEmpty ? token : '$current $token';
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    _focus.requestFocus();
  }

  /// A group tile searches at once, replacing any group already typed.
  void _searchGroup(String group) {
    final rest = _controller.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !_groupToken.hasMatch(w))
        .join(' ');
    _submit('$group $rest'.trim());
  }

  /// Back to the home state: no query, no filters, cursor in the box.
  void _reset() {
    _controller.clear();
    ref.read(smartSearchControllerProvider.notifier).reset();
    _focus.requestFocus();
  }

  void _openActions(RankedDonor donor) {
    showDialog<void>(
      context: context,
      builder: (context) => CallOrRemarkDialog(
        title: 'လုပ်ဆောင်ရန်',
        member: donor.member,
        onSaved: (saved) => ref
            .read(smartSearchControllerProvider.notifier)
            .applyAvailabilityEdit(saved),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(smartSearchControllerProvider);
    final compact = ref.watch(smartCompactProvider);
    final isMobile = Responsive.isMobile(context);
    final searching = resultAsync.isLoading ||
        resultAsync.hasError ||
        resultAsync.asData?.value != null;

    return Scaffold(
      backgroundColor: compact ? _pageBackground : Colors.white,
      appBar: AppBar(
        toolbarHeight: 48,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [primaryColor, primaryDark],
            ),
          ),
        ),
        leading: widget.fromHome && isMobile
            ? IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'မီနူး',
                onPressed: () =>
                    ref.read(drawerControllerProvider)?.toggle?.call(),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              ),
        centerTitle: true,
        title: Text(
          isMobile
              ? 'စမတ် ရှာဖွေမှု (Beta)'
              : 'စမတ် သွေးလှူရှင်ရှာဖွေမှု (Beta)',
          style: TextStyle(
            fontSize: isMobile ? 15 : 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (searching)
            IconButton(
              key: const ValueKey('smart-search-reset'),
              tooltip: 'အစမှ ပြန်စမည် (စစ်ထုတ်မှုများ ရှင်းမည်)',
              icon: const Icon(Icons.restart_alt, color: Colors.white),
              onPressed: _reset,
            ),
          IconButton(
            key: const ValueKey('smart-search-density'),
            tooltip: compact ? 'ကျယ်ပြန့်စွာ ပြမည်' : 'ကျစ်လစ်စွာ ပြမည်',
            icon: Icon(
              compact ? Icons.view_agenda_outlined : Icons.table_rows_outlined,
              color: Colors.white,
            ),
            onPressed: () => ref.read(smartCompactProvider.notifier).toggle(),
          ),
          if (searching)
            IconButton(
              tooltip: 'ပြန်လည်ရှာမည်',
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () =>
                  ref.read(smartSearchControllerProvider.notifier).refresh(),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _SearchBox(
            controller: _controller,
            focusNode: _focus,
            onSubmit: _submit,
            compact: compact,
          ),
          Expanded(
            child: resultAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: '$error',
                onRetry: () => _submit(),
                onReset: _reset,
              ),
              data: (state) {
                if (state == null) {
                  return SmartHomeState(
                    examples: _examples,
                    onSearch: _submit,
                    onAppend: _append,
                    onGroup: _searchGroup,
                  );
                }
                return _Results(
                  state: state,
                  compact: compact,
                  onOpenActions: _openActions,
                  onReset: _reset,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.compact,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function([String? value]) onSubmit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 40.0 : 46.0;
    return Padding(
      padding: compact
          ? const EdgeInsets.fromLTRB(12, 8, 12, 4)
          : const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: height,
              child: TextField(
                key: const ValueKey('smart-search-input'),
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) => onSubmit(v),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'ဥပမာ - B+ မော်လမြိုင် အမျိုးသမီး',
                  hintStyle: const TextStyle(fontSize: 13.5, color: _muted),
                  prefixIcon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            iconSize: 18,
                            tooltip: 'စာသား ရှင်းမည်',
                            icon: const Icon(Icons.clear),
                            onPressed: controller.clear,
                          ),
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: height,
            child: ElevatedButton.icon(
              key: const ValueKey('smart-search-submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => onSubmit(),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('ရှာမည်', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState(
      {required this.message, required this.onRetry, required this.onReset});

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                    onPressed: onRetry, child: const Text('ပြန်ကြိုးစားမည်')),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('အစမှ ပြန်စမည်'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Outlined chip that drops every filter and returns to the home state.
class _ResetChip extends StatelessWidget {
  const _ResetChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      key: const ValueKey('smart-chip-reset'),
      visualDensity: VisualDensity.compact,
      avatar: const Icon(Icons.restart_alt, size: 15, color: Color(0xFFA70507)),
      label: const Text('အစပြန်စမည်',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA70507))),
      side: const BorderSide(color: Color(0xFFA70507)),
      backgroundColor: Colors.white,
      tooltip: 'ရှာဖွေမှုနှင့် စစ်ထုတ်မှု အားလုံး ရှင်းပြီး မူလစာမျက်နှာသို့',
      onPressed: onTap,
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.state,
    required this.compact,
    required this.onOpenActions,
    required this.onReset,
  });

  final SmartSearchState state;
  final bool compact;
  final ValueChanged<RankedDonor> onOpenActions;
  final VoidCallback onReset;

  /// Chips, questions, nearby, counts and availability; shared by both densities.
  List<Widget> _header(
    BuildContext context,
    WidgetRef ref, {
    required List<TownshipOption> townships,
    required NearbyInfo? nearbyInfo,
  }) {
    final notifier = ref.read(smartSearchControllerProvider.notifier);
    final page = state.page;

    final bar = SmartUnderstoodBar(
      page: page,
      townships: townships,
      compact: compact,
      onChangeBloodGroup: (g) => g == null
          ? notifier.applyOverride(clearBloodGroup: true)
          : notifier.applyOverride(bloodGroup: g),
      onChangeTownship: (t) => t == null
          ? notifier.applyOverride(clearTownship: true)
          : notifier.applyOverride(township: t),
      onChangeGender: (g) => g == null
          ? notifier.applyOverride(clearGender: true)
          : notifier.applyOverride(gender: g),
      onToggleUrgent: (u) => notifier.applyOverride(urgent: u),
      onToggleNearby: (on) =>
          notifier.applyOverride(townshipMode: on ? 'prefer' : 'only'),
      onClearExtra: (field) => notifier.applyOverride(
        clearHospital: field == 'hospital',
        clearAge: field == 'age',
        clearDonorKind: field == 'donor_kind',
        clearNeeded: field == 'needed',
      ),
      onChangeWard: (ward, township) => ward == null
          ? notifier.applyOverride(clearWard: true)
          : notifier.applyOverride(ward: ward, township: township),
      loadWards: ({String? township, String? query}) => ref
          .read(smartSearchRepositoryProvider)
          .wards(township: township, query: query),
    );

    final nearby = NearbyRow(
      compact: compact,
      filters: page.filters,
      info: nearbyInfo,
      onPickWard: (ward, township) =>
          notifier.applyOverride(ward: ward, township: township),
      onManage: () async {
        final ward = page.filters.ward;
        final township = page.filters.township;
        if (ward == null || township == null) return;
        final repo = ref.read(smartSearchRepositoryProvider);
        final changed = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => NearbyLinksSheet(
            ward: ward,
            township: township,
            loadLinks: () => repo.links(ward: ward, township: township),
            setLink: (to, toTownship, action) => repo.setLink(
              from: ward,
              fromTownship: township,
              to: to,
              toTownship: toTownship,
              action: action,
            ),
            loadWards: ({String? township, String? query}) =>
                repo.wards(township: township, query: query),
          ),
        );
        if (changed == true) {
          ref.invalidate(smartNearbyProvider);
          notifier.refresh();
        }
      },
    );

    final availability = AvailabilitySummary(
      compact: compact,
      analysis: page.analysis,
      total: page.total,
      selected: state.request.availability,
      onSelected: (level) => notifier.setAvailability(level),
    );

    final shown = state.donors.length;
    final summary = Text(
      'ကိုက်ညီသူ ${page.total} · $shown ဦး ပြထားသည်',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 11.5, color: _muted),
    );

    return [
      if (compact)
        Row(
          children: [
            _ResetChip(onTap: onReset),
            const SizedBox(width: 6),
            Expanded(child: bar),
          ],
        )
      else ...[
        bar,
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Align(
              alignment: Alignment.centerLeft,
              child: _ResetChip(onTap: onReset)),
        ),
      ],
      if (page.parsed != null && page.parsed!.questions.isNotEmpty)
        SmartQuestionsBar(
          questions: page.parsed!.questions,
          onAnswer: (field, value) {
            if (field == 'blood_group') {
              notifier.applyOverride(bloodGroup: value);
            } else if (field == 'township') {
              notifier.applyOverride(township: value);
            } else if (field == 'ward') {
              notifier.applyOverride(ward: value);
            } else if (field == 'hospital') {
              notifier.search('${page.query} $value');
            }
          },
        ),
      if (page.parseError != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'စမတ်ရှာဖွေမှု မရသဖြင့် စာသားဖြင့်သာ ရှာထားသည် (${page.parseError})',
            maxLines: compact ? 1 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
            style: const TextStyle(fontSize: 12, color: Colors.orange),
          ),
        ),
      nearby,
      LocationCountsLine(
          compact: compact, filters: page.filters, location: page.location),
      SizedBox(height: compact ? 4 : 8),
      if (compact && MediaQuery.of(context).size.width >= 640)
        Row(
          children: [
            Expanded(child: availability),
            const SizedBox(width: 8),
            Flexible(child: summary),
          ],
        )
      else if (compact) ...[
        availability,
        Align(alignment: Alignment.centerRight, child: summary),
      ] else ...[
        availability,
        const SizedBox(height: 4),
        summary,
      ],
    ];
  }

  Widget _empty(WidgetRef ref) {
    final notifier = ref.read(smartSearchControllerProvider.notifier);
    final f = state.page.filters;
    final level = state.request.availability;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_search_outlined,
              size: 36, color: Colors.black26),
          const SizedBox(height: 8),
          const Text('ကိုက်ညီသော သွေးလှူရှင် မတွေ့ပါ',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (level != null)
                OutlinedButton.icon(
                  onPressed: () => notifier.setAvailability(null),
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                  label: const Text('လှူနိုင်မှု အားလုံး ပြမည်'),
                ),
              if (f.township != null && !f.includeNearby)
                OutlinedButton.icon(
                  onPressed: () =>
                      notifier.applyOverride(townshipMode: 'prefer'),
                  icon: const Icon(Icons.near_me_outlined, size: 16),
                  label: const Text('အနီးအနား မြို့နယ်များပါ ရှာမည်'),
                ),
              if (f.ward != null)
                OutlinedButton.icon(
                  onPressed: () => notifier.applyOverride(clearWard: true),
                  icon: const Icon(Icons.location_off_outlined, size: 16),
                  label: const Text('ရပ်ကွက် ဖြုတ်မည်'),
                ),
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt, size: 18),
                label: const Text('အစမှ ပြန်စမည်'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loadMore(WidgetRef ref) {
    final notifier = ref.read(smartSearchControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: state.isLoadingMore
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : OutlinedButton(
                key: const ValueKey('smart-search-load-more'),
                onPressed: notifier.loadNextPage,
                child: Text(state.loadMoreError == null
                    ? 'နောက်ထပ် ကြည့်မည်'
                    : 'ပြန်ကြိုးစားမည် (${state.loadMoreError})'),
              ),
      ),
    );
  }

  Widget _compatibleHeader(int count) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bloodtype_outlined,
                  size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'လက်ခံနိုင်သော အခြားသွေးအုပ်စုများ ($count)',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'တောင်းဆိုသည့် သွေးအုပ်စု အတိအကျ မရှိပါက ဤသွေးလှူရှင်များကို ဆရာဝန်နှင့် တိုင်ပင်၍ အသုံးပြုနိုင်ပါသည်။',
            style: TextStyle(fontSize: 11.5, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = state.page;
    // watched here, in build, and handed down: LayoutBuilder runs later
    final townships = ref.watch(smartSearchTownshipsProvider).asData?.value ??
        const <TownshipOption>[];
    final nearbyInfo = ref
        .watch(smartNearbyProvider(
            (ward: page.filters.ward, township: page.filters.township)))
        .asData
        ?.value;
    final header =
        _header(context, ref, townships: townships, nearbyInfo: nearbyInfo);
    if (!compact) return _spacious(context, ref, header);

    return LayoutBuilder(
      builder: (context, constraints) {
        final table = constraints.maxWidth >= 640;
        final layout = DonorTableLayout(width: constraints.maxWidth - 24);
        final notifier = ref.read(smartSearchControllerProvider.notifier);
        final donors = state.donors;
        final compatible = page.compatible;

        Widget row(int index, RankedDonor donor, {bool muted = false}) => table
            ? DonorTableRow(
                rank: index + 1,
                donor: donor,
                layout: layout,
                compatible: muted,
                onTap: () => onOpenActions(donor),
              )
            : CompactDonorRow(
                rank: index + 1,
                donor: donor,
                compatible: muted,
                onTap: () => onOpenActions(donor),
              );

        final items = <Widget>[
          if (donors.isEmpty) _empty(ref),
          for (var i = 0; i < donors.length; i++) row(i, donors[i]),
          if (state.hasMore) _loadMore(ref),
          if (compatible.isNotEmpty) ...[
            _compatibleHeader(compatible.length),
            for (var i = 0; i < compatible.length; i++)
              row(i, compatible[i], muted: true),
          ],
        ];
        // rows near the end pull the next page in, so scrolling just continues
        final triggerAt = donors.length - 8;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final w in header)
                    Padding(padding: const EdgeInsets.only(top: 2), child: w),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    if (table && donors.isNotEmpty)
                      DonorTableHeader(layout: layout),
                    Expanded(
                      child: ListView.builder(
                        key: const ValueKey('smart-search-results'),
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          if (state.hasMore &&
                              !state.isLoadingMore &&
                              state.loadMoreError == null &&
                              i == triggerAt &&
                              i > 0) {
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => notifier.loadNextPage());
                          }
                          return items[i];
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// The original card layout, kept behind the density toggle.
  Widget _spacious(BuildContext context, WidgetRef ref, List<Widget> header) {
    final page = state.page;
    return ListView(
      key: const ValueKey('smart-search-results'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        ...header,
        const SizedBox(height: 8),
        if (state.donors.isEmpty) _empty(ref),
        for (var i = 0; i < state.donors.length; i++)
          RankedDonorCard(
            rank: i + 1,
            donor: state.donors[i],
            onTap: () => onOpenActions(state.donors[i]),
          ),
        if (state.hasMore) _loadMore(ref),
        if (page.compatible.isNotEmpty) ...[
          const Divider(height: 24),
          _compatibleHeader(page.compatible.length),
          const SizedBox(height: 8),
          for (var i = 0; i < page.compatible.length; i++)
            RankedDonorCard(
              rank: i + 1,
              donor: page.compatible[i],
              compatible: true,
              onTap: () => onOpenActions(page.compatible[i]),
            ),
        ],
      ],
    );
  }
}
