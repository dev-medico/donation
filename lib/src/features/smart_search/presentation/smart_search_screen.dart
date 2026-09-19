import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/presentation/widget/call_or_remark_dialog.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';
import 'package:donation/src/features/smart_search/presentation/controller/smart_search_provider.dart';
import 'package:donation/src/features/smart_search/presentation/widget/ranked_donor_card.dart';
import 'package:donation/src/features/smart_search/presentation/widget/smart_chips.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    'O- အရေးပေါ် မုဒုံ',
    'AB+ ကျိုက်မရော',
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
    ref.read(smartSearchControllerProvider.notifier).search(q);
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
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
            ? Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'မီနူး',
                  onPressed: () =>
                      ref.read(drawerControllerProvider)?.toggle?.call(),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'စမတ် သွေးလှူရှင်ရှာဖွေမှု (Beta)',
            style: TextStyle(
              fontSize: isMobile ? 15 : 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: IconButton(
              tooltip: 'ပြန်လည်ရှာမည်',
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () =>
                  ref.read(smartSearchControllerProvider.notifier).refresh(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBox(
            controller: _controller,
            focusNode: _focus,
            onSubmit: _submit,
          ),
          Expanded(
            child: resultAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: '$error',
                onRetry: () => _submit(),
              ),
              data: (state) {
                if (state == null) {
                  return _IdleState(
                    examples: _examples,
                    onExample: (q) => _submit(q),
                  );
                }
                return _Results(
                  state: state,
                  onOpenActions: _openActions,
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
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function([String? value]) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('smart-search-input'),
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) => onSubmit(v),
              decoration: InputDecoration(
                hintText: 'ဥပမာ - B+ မော်လမြိုင် အမျိုးသမီး',
                prefixIcon: const Icon(Icons.auto_awesome_outlined),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: controller.clear,
                        ),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              key: const ValueKey('smart-search-submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => onSubmit(),
              icon: const Icon(Icons.search, size: 20),
              label: const Text('ရှာမည်'),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState({required this.examples, required this.onExample});

  final List<String> examples;
  final ValueChanged<String> onExample;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text(
          'သွေးအုပ်စု၊ မြို့နယ်၊ ကျား/မ၊ အရေးပေါ် စသည်တို့ကို စာကြောင်းတစ်ကြောင်းတည်းဖြင့် ရိုက်ထည့်ပါ။ '
          'ရှာဖွေမှုကို နားလည်ထားသည့်အတိုင်း chip များဖြင့် ပြပေးပြီး လှူနိုင်မှု၊ နေရာ၊ လှူခဲ့သည့်အကြိမ်အရေအတွက်တို့ဖြင့် အစီအစဉ်တကျ ပြပါမည်။',
          style: TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 16),
        const Text('ဥပမာများ',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in examples)
              ActionChip(
                label: Text(e),
                onPressed: () => onExample(e),
              ),
          ],
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            OutlinedButton(onPressed: onRetry, child: const Text('ပြန်ကြိုးစားမည်')),
          ],
        ),
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.state, required this.onOpenActions});

  final SmartSearchState state;
  final ValueChanged<RankedDonor> onOpenActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(smartSearchControllerProvider.notifier);
    final page = state.page;
    final analysis = page.analysis;
    final townships = ref.watch(smartSearchTownshipsProvider).asData?.value ??
        const <TownshipOption>[];
    final selectedLevel = state.request.availability;

    return ListView(
      key: const ValueKey('smart-search-results'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        SmartUnderstoodBar(
          page: page,
          townships: townships,
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
        ),
        if (page.parsed != null && page.parsed!.questions.isNotEmpty)
          SmartQuestionsBar(
            questions: page.parsed!.questions,
            onAnswer: (field, value) {
              if (field == 'blood_group') {
                notifier.applyOverride(bloodGroup: value);
              } else if (field == 'township') {
                notifier.applyOverride(township: value);
              }
            },
          ),
        if (page.parseError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'စမတ်ရှာဖွေမှု မရသဖြင့် စာသားဖြင့်သာ ရှာထားသည် (${page.parseError})',
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
        const SizedBox(height: 8),
        AvailabilitySummary(
          analysis: analysis,
          total: page.total,
          selected: selectedLevel,
          onSelected: (level) => notifier.setAvailability(level),
        ),
        const SizedBox(height: 8),
        if (state.donors.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text('ကိုက်ညီသော သွေးလှူရှင် မတွေ့ပါ',
                  style: TextStyle(color: Colors.black54)),
            ),
          ),
        for (var i = 0; i < state.donors.length; i++)
          RankedDonorCard(
            rank: i + 1,
            donor: state.donors[i],
            onTap: () => onOpenActions(state.donors[i]),
          ),
        if (state.hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
          ),
        if (page.compatible.isNotEmpty) ...[
          const Divider(height: 32),
          Row(
            children: [
              const Icon(Icons.bloodtype_outlined, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'လက်ခံနိုင်သော အခြားသွေးအုပ်စုများ (${page.compatible.length})',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'တောင်းဆိုသည့် သွေးအုပ်စု အတိအကျ မရှိပါက ဤသွေးလှူရှင်များကို ဆရာဝန်နှင့် တိုင်ပင်၍ အသုံးပြုနိုင်ပါသည်။',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
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
