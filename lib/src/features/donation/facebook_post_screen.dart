import 'dart:math' as math;

import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation/facebook_post_builder.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/services/donation_service.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kHelpersPrefsKey = 'fb_post_volunteer_helpers';

/// Builds the group's daily Facebook post from the donation ledger and hands
/// it over ready to paste.
///
/// The ledger cannot supply two things the post needs — the time of day each
/// donation happened (only the data-entry timestamp is stored) and the order
/// the paragraphs should appear in — so both are set here before the text is
/// generated. The generated text stays editable for any last-minute wording.
class FacebookPostScreen extends ConsumerStatefulWidget {
  const FacebookPostScreen({super.key, this.fromHome = false});

  final bool fromHome;

  static const routeName = '/facebook_post';

  @override
  ConsumerState<FacebookPostScreen> createState() => _FacebookPostScreenState();
}

class _FacebookPostScreenState extends ConsumerState<FacebookPostScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  // Built eagerly: `late final` would defer creation to the first read, and on
  // a desktop layout — which has no tabs — that first read would be dispose().
  late final TabController _tabController;
  final TextEditingController _helpersController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  List<DonationPostGroup> _groups = <DonationPostGroup>[];
  List<dynamic> _monthRows = <dynamic>[];
  String? _loadedMonthKey;
  bool _isLoading = false;
  String? _error;
  final Set<String> _savingTimeGroups = <String>{};
  final Map<String, int> _timeFieldRevisions = <String, int>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _helpersController.text = kDefaultVolunteerHelpers;
    _restoreHelpers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _helpersController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _restoreHelpers() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kHelpersPrefsKey);
    if (!mounted || saved == null || saved.trim().isEmpty) return;
    setState(() => _helpersController.text = saved);
    _regenerate();
  }

  Future<void> _persistHelpers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHelpersPrefsKey, _helpersController.text);
  }

  String _monthKey(DateTime date) => '${date.year}-${date.month}';

  Future<void> _load({bool force = false}) async {
    final key = _monthKey(_selectedDate);
    if (!force && key == _loadedMonthKey) {
      _rebuildGroups();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rows = await ref
          .read(donationServiceProvider)
          .getDonationsByMonthYear(_selectedDate.month, _selectedDate.year);
      if (!mounted) return;
      _monthRows = rows;
      _loadedMonthKey = key;
      setState(() => _isLoading = false);
      _rebuildGroups();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'မှတ်တမ်းများ ရယူ၍ မရပါ။ ထပ်မံကြိုးစားပါ။';
      });
    }
  }

  void _rebuildGroups() {
    setState(() {
      _groups = groupDonationsForPost(_monthRows, _selectedDate);
    });
    _regenerate();
  }

  void _regenerate() {
    _textController.text = buildFacebookPostText(
      date: _selectedDate,
      groups: _groups,
      volunteerHelpers: _helpersController.text.trim().isEmpty
          ? kDefaultVolunteerHelpers
          : _helpersController.text,
    );
  }

  void _shiftDay(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
    _load();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'ရက်စွဲ ရွေးပါ',
    );
    if (picked == null) return;
    setState(
        () => _selectedDate = DateTime(picked.year, picked.month, picked.day));
    _load();
  }

  void _copy() {
    Utils.copyToClipBoard(
      context: context,
      text: _textController.text,
      message: 'ပို့စ်စာသား ကူးယူပြီးပါပြီ',
    );
  }

  Future<void> _selectPostTime(
    DonationPostGroup group,
    String selected,
  ) async {
    var resolvedTime = selected;
    if (selected == kCustomNightTimeOption) {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'ညအချိန် ရွေးပါ',
      );
      if (picked == null || !mounted) return;

      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      resolvedTime = 'ည(${toMyanmarDigits(hour)}:${toMyanmarDigits(minute)})';
    }

    await _savePostTime(group, resolvedTime);
  }

  String _timeSaveKey(DateTime date, DonationPostGroup group) {
    return '${date.year}-${date.month}-${date.day}|${group.key}';
  }

  Future<void> _savePostTime(
    DonationPostGroup group,
    String timeOfDay,
  ) async {
    final dateAtSelection = _selectedDate;
    final saveKey = _timeSaveKey(dateAtSelection, group);
    final previousTime = group.timeOfDay;

    setState(() {
      group.timeOfDay = timeOfDay;
      _savingTimeGroups.add(saveKey);
      _bumpTimeFieldRevision(saveKey);
    });
    _regenerate();

    try {
      await ref
          .read(donationServiceProvider)
          .saveFacebookPostTime(group.donationIds, timeOfDay);
      if (!mounted) return;

      _rememberPostTime(group.donationIds, timeOfDay);
      setState(() {
        _savingTimeGroups.remove(saveKey);
        // The user may have moved to another day while the request was in
        // flight. Only touch the visible group when it is still the one that
        // initiated this save.
        if (_isSameDay(_selectedDate, dateAtSelection)) {
          final visibleIndex =
              _groups.indexWhere((item) => item.key == group.key);
          if (visibleIndex != -1) {
            _groups[visibleIndex].timeOfDay = timeOfDay;
          }
        }
      });
      _regenerate();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _savingTimeGroups.remove(saveKey);
        _bumpTimeFieldRevision(saveKey);
        if (_isSameDay(_selectedDate, dateAtSelection)) {
          final visibleIndex =
              _groups.indexWhere((item) => item.key == group.key);
          if (visibleIndex != -1 &&
              _groups[visibleIndex].timeOfDay == timeOfDay) {
            _groups[visibleIndex].timeOfDay = previousTime;
          }
        }
      });
      _regenerate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'အချိန်ကို သိမ်းဆည်း၍ မရပါ။ ထပ်မံရွေးချယ်ပါ။',
          ),
        ),
      );
    }
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  void _bumpTimeFieldRevision(String saveKey) {
    _timeFieldRevisions[saveKey] = (_timeFieldRevisions[saveKey] ?? 0) + 1;
  }

  void _rememberPostTime(List<int> donationIds, String timeOfDay) {
    final savedIds = donationIds.toSet();
    _monthRows = _monthRows.map((row) {
      if (row is! Map) return row;
      final id = row['id'] is int
          ? row['id'] as int
          : int.tryParse(row['id']?.toString() ?? '');
      if (id == null || !savedIds.contains(id)) return row;

      return <String, dynamic>{
        ...Map<String, dynamic>.from(row),
        'facebook_post_time': timeOfDay,
      };
    }).toList();
  }

  int get _donationCount =>
      _groups.fold<int>(0, (sum, group) => sum + group.unitCount);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      appBar: AppBar(
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: widget.fromHome && isMobile
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: 'မီနူး',
                onPressed: () =>
                    ref.read(drawerControllerProvider)?.toggle?.call(),
              )
            : null,
        centerTitle: true,
        title: const Text(
          'Facebook ပို့စ်',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'ပြန်လည်ရယူမည်',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading || _savingTimeGroups.isNotEmpty
                ? null
                : () => _load(force: true),
          ),
        ],
        // A phone cannot show the settings and the finished text at once, and
        // stacking them buried the copy button under every patient card. Two
        // tabs keep both one tap away; the copy bar below stays put in either.
        bottom: isMobile
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                tabs: const [
                  Tab(height: 40, text: 'ပြင်ဆင်ရန်'),
                  Tab(height: 40, text: 'ပို့စ်စာသား'),
                ],
              )
            : null,
      ),
      bottomNavigationBar: isMobile ? _buildCopyBar() : null,
      body: isMobile
          ? TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: _buildControls(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: _buildPreview(expand: true, showHeader: false),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildControls(),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    child: _buildPreview(expand: true),
                  ),
                ),
              ],
            ),
    );
  }

  /// Always-visible copy action for phones, with the day's tally beside it so
  /// the post-text tab still says what is being copied.
  Widget _buildCopyBar() {
    final summary = _groups.isEmpty
        ? 'မှတ်တမ်း မရှိပါ'
        : 'လူနာ ${toMyanmarDigits(_groups.length)} ဦး · '
            'သွေး ${toMyanmarDigits(_donationCount)} လုံး';

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.withValues(alpha: 0.25)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              key: const ValueKey('copy-facebook-post'),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _copy,
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('ကူးယူမည်'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _card(child: _buildDateRow()),
        const SizedBox(height: 12),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          _buildError()
        else if (_groups.isEmpty)
          _buildEmpty()
        else
          _card(child: _buildGroupList()),
        const SizedBox(height: 12),
        _card(
          child: TextField(
            controller: _helpersController,
            decoration: const InputDecoration(
              labelText: 'Volunteer Helper',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) {
              _regenerate();
              _persistHelpers();
            },
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: child,
    );
  }

  Widget _buildDateRow() {
    final navigationDisabled = _isLoading || _savingTimeGroups.isNotEmpty;

    return Row(
      children: [
        IconButton(
          tooltip: 'ယခင်နေ့',
          icon: const Icon(Icons.chevron_left),
          onPressed: navigationDisabled ? null : () => _shiftDay(-1),
        ),
        Expanded(
          child: InkWell(
            onTap: navigationDisabled ? null : _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    formatPostDate(_selectedDate),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _groups.isEmpty
                        ? 'မှတ်တမ်း မရှိပါ'
                        : 'သွေးလှူဒါန်းမှု ${toMyanmarDigits(_donationCount)} ကြိမ်၊ '
                            'လူနာ ${toMyanmarDigits(_groups.length)} ဦး',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'နောက်နေ့',
          icon: const Icon(Icons.chevron_right),
          onPressed: navigationDisabled ? null : () => _shiftDay(1),
        ),
      ],
    );
  }

  Widget _buildError() {
    return _card(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _load(force: true),
            icon: const Icon(Icons.refresh),
            label: const Text('ထပ်မံကြိုးစားမည်'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return _card(
      child: Column(
        children: [
          const Icon(Icons.bloodtype_outlined, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          const Text(
            'ဤရက်စွဲအတွက် သွေးလှူဒါန်းမှု မှတ်တမ်း မရှိသေးပါ။',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'အခြားရက်စွဲ ရွေးကြည့်ပါ။',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            'အပိုဒ်အစီအစဉ်ကို ဆွဲ၍ ပြောင်းနိုင်ပါသည်',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _groups.length,
          // onReorderItem already accounts for the removal at oldIndex.
          onReorderItem: (oldIndex, newIndex) {
            setState(() {
              final moved = _groups.removeAt(oldIndex);
              _groups.insert(newIndex, moved);
            });
            _regenerate();
          },
          itemBuilder: (context, index) =>
              _buildGroupCard(_groups[index], index),
        ),
      ],
    );
  }

  Widget _buildGroupCard(DonationPostGroup group, int index) {
    final hasCustomNightTime =
        group.timeOfDay.startsWith('ည(') && group.timeOfDay.endsWith(')');
    final dropdownValue = hasCustomNightTime
        ? kCustomNightTimeOption
        : (kPostTimeOptions.contains(group.timeOfDay)
            ? group.timeOfDay
            : kDefaultPostTime);
    final saveKey = _timeSaveKey(_selectedDate, group);
    final isSaving = _savingTimeGroups.contains(saveKey);
    final fieldRevision = _timeFieldRevisions[saveKey] ?? 0;

    return Container(
      key: ValueKey('post-group-${group.key}'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, right: 4),
              child: Icon(Icons.drag_indicator,
                  size: 20, color: Colors.grey.shade500),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${toMyanmarDigits(index + 1)}။ ${group.patientName}'
                  ' — (${group.bloodType})သွေး'
                  '(${toMyanmarDigits(group.unitCount)})လုံး',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  group.hospital,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
                Text(
                  group.donorNames.join('၊ '),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 38,
                  child: IgnorePointer(
                    ignoring: isSaving,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(
                        'post-time-${group.key}-${group.timeOfDay}-$fieldRevision',
                      ),
                      initialValue: dropdownValue,
                      isDense: true,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3D3D3D),
                      ),
                      // Without this the field takes the width of its longest
                      // option and overflows the card on a phone.
                      isExpanded: true,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: isSaving
                            ? const _SavingTimeIndicator(
                                key: ValueKey('saving-time-indicator'),
                              )
                            : const Icon(
                                Icons.arrow_drop_down,
                                key: ValueKey('post-time-dropdown-arrow'),
                              ),
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        filled: isSaving,
                        fillColor: isSaving ? const Color(0xFFFFF8F8) : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      items: kPostTimeOptions
                          .map((option) => DropdownMenuItem<String>(
                                value: option,
                                child: Text(
                                    option == kCustomNightTimeOption &&
                                            hasCustomNightTime
                                        ? group.timeOfDay
                                        : option,
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: isSaving
                          ? null
                          : (value) async {
                              if (value == null) return;
                              await _selectPostTime(group, value);
                            },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview({
    bool expand = false,
    double minHeight = 240,
    // Phones label this through the tab and copy from the bottom bar, so the
    // card's own header would only repeat what is already on screen.
    bool showHeader = true,
  }) {
    final field = TextField(
      controller: _textController,
      maxLines: null,
      expands: expand,
      textAlignVertical: TextAlignVertical.top,
      style: const TextStyle(fontSize: 13, height: 1.5),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(12),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'ပို့စ်စာသား',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                FilledButton.icon(
                  key: const ValueKey('copy-facebook-post'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _copy,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('ကူးယူမည်'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (expand)
            Expanded(child: field)
          else
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: field,
            ),
        ],
      ),
    );
  }
}

/// A quiet, compact save treatment for a time field. The old circular
/// progress indicator competed with the dropdown arrow and made the control
/// look crowded, especially on a phone. These staggered dots take the arrow's
/// place while the request is in flight and keep the chosen time readable.
class _SavingTimeIndicator extends StatefulWidget {
  const _SavingTimeIndicator({super.key});

  @override
  State<_SavingTimeIndicator> createState() => _SavingTimeIndicatorState();
}

class _SavingTimeIndicatorState extends State<_SavingTimeIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'အချိန် သိမ်းဆည်းနေသည်',
      child: Container(
        width: 40,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(3, (index) {
                final phase = (_controller.value * math.pi * 2) -
                    (index * math.pi * 0.55);
                final emphasis = (math.sin(phase) + 1) / 2;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Transform.scale(
                    scale: 0.72 + (emphasis * 0.28),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE53935).withValues(
                          alpha: 0.42 + (emphasis * 0.58),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
