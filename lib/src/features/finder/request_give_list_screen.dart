import 'package:donation/src/features/services/request_give_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/age_utils.dart';
import 'package:donation/utils/myanmar_number_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class RequestGiveListScreen extends ConsumerStatefulWidget {
  const RequestGiveListScreen({super.key, this.initialMonth});

  static const routeName = '/request-give-list';

  final DateTime? initialMonth;

  @override
  ConsumerState<RequestGiveListScreen> createState() =>
      _RequestGiveListScreenState();
}

class _RequestGiveListScreenState extends ConsumerState<RequestGiveListScreen> {
  static const _monthNames = <String>[
    'ဇန်နဝါရီ',
    'ဖေဖော်ဝါရီ',
    'မတ်',
    'ဧပြီ',
    'မေ',
    'ဇွန်',
    'ဇူလိုင်',
    'ဩဂုတ်',
    'စက်တင်ဘာ',
    'အောက်တိုဘာ',
    'နိုဝင်ဘာ',
    'ဒီဇင်ဘာ',
  ];

  static const _weekdayNames = <String>[
    'နွေ',
    'လာ',
    'ဂါ',
    'ဟူး',
    'တေး',
    'ကြာ',
    'နေ',
  ];

  final _dateFormat = DateFormat('yyyy-MM-dd');
  final List<_DayEntry> _days = [];

  late DateTime _selectedMonth;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDirty = false;
  bool _editable = false;
  bool _legacyOnly = false;
  int _revision = 0;
  int _loadGeneration = 0;
  DateTime? _serverToday;
  String? _loadError;
  Map<String, dynamic>? _legacySummary;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final requested = widget.initialMonth ?? now;
    final requestedMonth = DateTime(requested.year, requested.month);
    final currentMonth = DateTime(now.year, now.month);
    final firstMonth = DateTime(2020);
    _selectedMonth = requestedMonth.isAfter(currentMonth)
        ? currentMonth
        : requestedMonth.isBefore(firstMonth)
            ? firstMonth
            : requestedMonth;
    _replaceDayControllers(const {});
    _loadMonth();
  }

  @override
  void dispose() {
    _disposeDayControllers();
    super.dispose();
  }

  int get _daysInMonth =>
      DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

  int? _valueOf(TextEditingController controller) {
    final value = normalizeMyanmarDigits(controller.text.trim());
    return value.isEmpty ? null : int.tryParse(value);
  }

  int get _requestTotal {
    if (_legacyOnly) return _legacyValue('request');
    return _days.fold(0, (sum, day) => sum + (_valueOf(day.request) ?? 0));
  }

  int get _giveTotal {
    if (_legacyOnly) return _legacyValue('give');
    return _days.fold(0, (sum, day) => sum + (_valueOf(day.give) ?? 0));
  }

  int get _recordedDays => _legacyOnly
      ? 0
      : _days
          .where(
            (day) =>
                day.request.text.trim().isNotEmpty ||
                day.give.text.trim().isNotEmpty,
          )
          .length;

  int _legacyValue(String key) {
    final raw = _legacySummary?[key];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  DateTime get _businessToday {
    final now = _serverToday ?? DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get _isCurrentMonth {
    final now = _businessToday;
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  bool _canEditDate(DateTime date) {
    if (!_editable || _isLoading || _isSaving) return false;
    return !date.isAfter(_businessToday);
  }

  void _disposeDayControllers() {
    for (final day in _days) {
      day.request.dispose();
      day.give.dispose();
    }
    _days.clear();
  }

  void _replaceDayControllers(Map<String, Map<String, dynamic>> savedRows) {
    _disposeDayControllers();
    for (var day = 1; day <= _daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final saved = savedRows[_dateFormat.format(date)];
      final request = TextEditingController(
        text: _displayCellValue(saved?['request']),
      );
      final give = TextEditingController(
        text: _displayCellValue(saved?['give']),
      );
      request.addListener(_onCellChanged);
      give.addListener(_onCellChanged);
      _days.add(_DayEntry(date: date, request: request, give: give));
    }
  }

  String _displayCellValue(dynamic value) {
    if (value == null) return '';
    if (value is num) return value.toInt().toString();
    return value.toString();
  }

  void _onCellChanged() {
    if (!mounted || _isLoading) return;
    setState(() => _isDirty = true);
  }

  Future<void> _loadMonth() async {
    if (_isSaving) return;
    final requestedMonth = _selectedMonth;
    final generation = ++_loadGeneration;
    setState(() {
      _isLoading = true;
      _editable = false;
      _loadError = null;
    });

    try {
      final payload = await ref.read(requestGiveServiceProvider).getMonthEntry(
            year: requestedMonth.year,
            month: requestedMonth.month,
          );
      if (!mounted ||
          generation != _loadGeneration ||
          requestedMonth != _selectedMonth) {
        return;
      }
      _applyPayload(payload);
    } catch (_) {
      if (!mounted ||
          generation != _loadGeneration ||
          requestedMonth != _selectedMonth) {
        return;
      }
      setState(() {
        _isLoading = false;
        _editable = false;
        _loadError =
            'လစဉ်မှတ်တမ်းကို ရယူ၍မရပါ။ အင်တာနက်ချိတ်ဆက်မှုကို စစ်ဆေးပြီး ထပ်မံကြိုးစားပါ။';
      });
    }
  }

  void _applyPayload(Map<String, dynamic> payload) {
    final rowsByDate = <String, Map<String, dynamic>>{};
    final rawRows = payload['rows'];
    if (rawRows is List) {
      for (final rawRow in rawRows) {
        if (rawRow is! Map) continue;
        final row = Map<String, dynamic>.from(rawRow);
        final rawDate = row['date']?.toString() ?? '';
        if (rawDate.length >= 10) rowsByDate[rawDate.substring(0, 10)] = row;
      }
    }

    _replaceDayControllers(rowsByDate);
    setState(() {
      _legacyOnly = payload['legacyOnly'] == true;
      _editable = payload['editable'] == true && !_legacyOnly;
      final rawRevision = payload['revision'];
      _revision = rawRevision is num
          ? rawRevision.toInt()
          : int.tryParse(rawRevision?.toString() ?? '') ?? 0;
      final rawToday = payload['today']?.toString();
      final parsedToday = rawToday == null ? null : DateTime.tryParse(rawToday);
      _serverToday = parsedToday == null
          ? null
          : DateTime(parsedToday.year, parsedToday.month, parsedToday.day);
      final legacy = payload['legacySummary'];
      _legacySummary = legacy is Map ? Map<String, dynamic>.from(legacy) : null;
      _isLoading = false;
      _isDirty = false;
      _loadError = null;
    });
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_isDirty) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('မသိမ်းရသေးသော မှတ်တမ်းရှိပါသည်'),
        content: const Text(
          'ယခုလအတွက် ဖြည့်ထားသော အချက်အလက်များကို မသိမ်းဘဲ ထွက်လိုပါသလား။',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ဆက်ဖြည့်မည်'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'မသိမ်းဘဲ ထွက်မည်',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
    return discard == true;
  }

  Future<void> _changeMonth(DateTime month) async {
    if (_isSaving) return;
    final normalized = DateTime(month.year, month.month);
    if (normalized == _selectedMonth) return;
    if (!await _confirmDiscardChanges() || !mounted) return;
    setState(() {
      _selectedMonth = normalized;
      _isDirty = false;
      _legacyOnly = false;
      _legacySummary = null;
      _replaceDayControllers(const {});
    });
    await _loadMonth();
  }

  Future<void> _moveMonth(int delta) async {
    final target = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + delta,
    );
    final current = DateTime(_businessToday.year, _businessToday.month);
    if (target.isAfter(current) || target.isBefore(DateTime(2020))) return;
    await _changeMonth(target);
  }

  Future<void> _pickMonth() async {
    if (_isSaving) return;
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: _businessToday,
    );
    if (picked != null && mounted) await _changeMonth(picked);
  }

  Future<void> _saveMonth() async {
    if (_legacyOnly || !_editable || _isSaving || _isLoading || !_isDirty) {
      return;
    }

    final records = <Map<String, dynamic>>[];
    for (final day in _days) {
      final request = _valueOf(day.request);
      final give = _valueOf(day.give);
      if (request == null && give == null) continue;
      records.add({
        'date': _dateFormat.format(day.date),
        'request': request,
        'give': give,
      });
    }

    final savingMonth = _selectedMonth;
    final expectedRevision = _revision;
    setState(() => _isSaving = true);
    try {
      final payload = await ref.read(requestGiveServiceProvider).saveMonth(
            year: savingMonth.year,
            month: savingMonth.month,
            records: records,
            expectedRevision: expectedRevision,
          );
      if (!mounted || savingMonth != _selectedMonth) return;
      _applyPayload(payload);
      ref.read(requestGiveRevisionProvider.notifier).state++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_monthNames[savingMonth.month - 1]}လ မှတ်တမ်းကို သိမ်းဆည်းပြီးပါပြီ။',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } on RequestGiveConflictException {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('မှတ်တမ်း အပြောင်းအလဲရှိနေပါသည်'),
          content: const Text(
            'အခြားသူတစ်ဦးက ဤလစာရင်းကို ပြင်ဆင်ထားသဖြင့် မှတ်တမ်းအသစ်ကို ပြန်ယူပါမည်။ မပြန်ယူပါက ယခုဖြည့်ထားသည်များကို သိမ်းနိုင်မည်မဟုတ်ပါ။',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('အသစ်ပြန်ရယူမည်'),
            ),
          ],
        ),
      );
      if (mounted) {
        setState(() {
          _isDirty = false;
          _isSaving = false;
        });
        await _loadMonth();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'မှတ်တမ်းကို မသိမ်းဆည်းနိုင်ပါ။ ခဏအကြာတွင် ထပ်မံကြိုးစားပါ။',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleBack() async {
    if (_isSaving) return;
    if (!await _confirmDiscardChanges() || !mounted) return;
    setState(() => _isDirty = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _refreshMonth() async {
    if (_isSaving) return;
    if (!await _confirmDiscardChanges() || !mounted) return;
    setState(() => _isDirty = false);
    await _loadMonth();
  }

  Future<void> _handleSystemBack(bool didPop, Object? result) async {
    if (didPop || _isSaving) return;
    await _handleBack();
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 360;
    return PopScope(
      canPop: !_isDirty && !_isSaving,
      onPopInvokedWithResult: _handleSystemBack,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: AppBar(
          leading: IconButton(
            onPressed: _isSaving ? null : _handleBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'နောက်သို့',
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [primaryColor, primaryDark],
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            isNarrow
                ? 'နေ့စဉ် သွေးမှတ်တမ်း'
                : 'သွေးတောင်းခံ/လှူဒါန်းမှု မှတ်တမ်း',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: _isLoading || _isSaving ? null : _refreshMonth,
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'ပြန်လည်ရယူမည်',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshMonth,
          color: primaryColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth < 600 ? 12.0 : 24.0;
              return ListView(
                key: const Key('request-give-month-worksheet'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  28,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMonthSelector(),
                          const SizedBox(height: 12),
                          _buildSummary(),
                          const SizedBox(height: 12),
                          if (_loadError != null) ...[
                            _buildErrorBanner(),
                          ] else if (_legacyOnly) ...[
                            _buildLegacyBanner(),
                          ] else ...[
                            _buildEntryHint(),
                            const SizedBox(height: 12),
                            _buildWorksheet(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: _buildSaveBar(isNarrow: isNarrow),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final isNarrow = MediaQuery.sizeOf(context).width < 360;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            IconButton(
              key: const Key('previous-month'),
              onPressed: _isLoading || _isSaving ? null : () => _moveMonth(-1),
              icon: const Icon(Icons.chevron_left),
              color: primaryColor,
              tooltip: 'ယခင်လ',
            ),
            Expanded(
              child: InkWell(
                key: const Key('month-picker'),
                onTap: _isLoading || _isSaving ? null : _pickMonth,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isNarrow) ...[
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 19,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              '${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isNarrow ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          if (!isNarrow) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              color: primaryColor,
                            ),
                          ],
                        ],
                      ),
                      if (!isNarrow) ...[
                        const SizedBox(height: 2),
                        Text(
                          'နေ့စဉ်စာရင်းကို တစ်လစာ တစ်ကြိမ်တည်း ဖြည့်သွင်းနိုင်ပါသည်',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              key: const Key('next-month'),
              onPressed: _isLoading || _isSaving || _isCurrentMonth
                  ? null
                  : () => _moveMonth(1),
              icon: const Icon(Icons.chevron_right),
              color: primaryColor,
              tooltip: 'နောက်လ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final itemWidth = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: _SummaryTile(
                key: const Key('request-total'),
                label: 'တောင်းခံ',
                value: _requestTotal,
                icon: Icons.call_received_rounded,
                color: const Color(0xFFB54708),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _SummaryTile(
                key: const Key('give-total'),
                label: 'လှူဒါန်း',
                value: _giveTotal,
                icon: Icons.volunteer_activism_rounded,
                color: const Color(0xFF067647),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _SummaryTile(
                key: const Key('recorded-days'),
                label: 'မှတ်တမ်းရက်',
                value: _recordedDays,
                suffix: '/ $_daysInMonth',
                icon: Icons.fact_check_outlined,
                color: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEntryHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: Color(0xFF2563EB)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'အလွတ်ထားခြင်းသည် မမှတ်ရသေးခြင်းဖြစ်ပြီး “၀” ထည့်ခြင်းသည် ထိုနေ့တွင် မရှိကြောင်း အတည်ပြုခြင်းဖြစ်ပါသည်။',
              style: TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyBanner() {
    return Container(
      key: const Key('legacy-month-banner'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5D28C)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 20, color: Color(0xFF9A6700)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'ဤလတွင် ယခင်လချုပ်မှတ်တမ်းသာရှိပြီး နေ့စဉ်အသေးစိတ် မရှိပါ။ မူလလချုပ်ကိန်းဂဏန်း မပြောင်းလဲစေရန် ဖတ်ရှုရန်သာ ပြထားပါသည်။',
              style: TextStyle(fontSize: 12.5, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      key: const Key('month-load-error'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF4B8B8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _loadError!,
              style: const TextStyle(fontSize: 12.5, height: 1.4),
            ),
          ),
          TextButton(
            onPressed: _loadMonth,
            child: const Text('ထပ်ကြိုးစားမည်'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorksheet() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            color: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: const Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    'ရက်စွဲ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call_received, color: Colors.white, size: 15),
                      SizedBox(width: 5),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'တောင်းခံ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: 15,
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'လှူဒါန်း',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 3)
          else
            const SizedBox(height: 3),
          for (var index = 0; index < _days.length; index++)
            _buildDayRow(_days[index], index),
        ],
      ),
    );
  }

  Widget _buildDayRow(_DayEntry day, int index) {
    final enabled = _canEditDate(day.date);
    final now = DateTime.now();
    final isToday = day.date.year == now.year &&
        day.date.month == now.month &&
        day.date.day == now.day;
    final background = isToday
        ? const Color(0xFFFFF4F4)
        : index.isEven
            ? Colors.white
            : const Color(0xFFFAFAFB);

    return Container(
      key: Key('request-give-day-${day.date.day}'),
      color: background,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isToday ? primaryColor : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    day.date.day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isToday ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _weekdayNames[day.date.weekday % 7],
                    style:
                        TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CountField(
              key: Key('request-day-${day.date.day}'),
              controller: day.request,
              enabled: enabled,
              color: const Color(0xFFB54708),
              semanticLabel: '${day.date.day} ရက်နေ့ တောင်းခံမှု အရေအတွက်',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CountField(
              key: Key('give-day-${day.date.day}'),
              controller: day.give,
              enabled: enabled,
              color: const Color(0xFF067647),
              semanticLabel: '${day.date.day} ရက်နေ့ လှူဒါန်းမှု အရေအတွက်',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveBar({required bool isNarrow}) {
    final locked = _legacyOnly || _loadError != null;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: locked
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _legacyOnly ? Icons.lock_outline : Icons.cloud_off,
                        color: Colors.grey.shade600,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _legacyOnly
                              ? 'ယခင်လချုပ်မှတ်တမ်း — ပြင်ဆင်၍မရပါ'
                              : 'မှတ်တမ်းရယူပြီးမှ ဖြည့်သွင်းနိုင်ပါသည်',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      key: const Key('save-request-give-month'),
                      onPressed: _isLoading || _isSaving || !_isDirty
                          ? null
                          : _saveMonth,
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _isDirty
                                  ? Icons.save_outlined
                                  : Icons.check_circle_outline,
                              size: 20,
                            ),
                      label: Text(
                        _isSaving
                            ? 'သိမ်းဆည်းနေပါသည်...'
                            : !_isDirty
                                ? 'မှတ်တမ်း သိမ်းပြီး'
                                : isNarrow
                                    ? 'မှတ်တမ်းသိမ်းမည် • $_recordedDays ရက်'
                                    : 'တစ်လစာ မှတ်တမ်းသိမ်းမည်  •  $_recordedDays ရက်',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _DayEntry {
  const _DayEntry({
    required this.date,
    required this.request,
    required this.give,
  });

  final DateTime date;
  final TextEditingController request;
  final TextEditingController give;
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix = ' ကြိမ်',
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value$suffix',
      container: true,
      excludeSemantics: true,
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$value',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    TextSpan(
                      text: suffix,
                      style: TextStyle(fontSize: 10.5, color: color),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountField extends StatelessWidget {
  const _CountField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.color,
    required this.semanticLabel,
  });

  final TextEditingController controller;
  final bool enabled;
  final Color color;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      textField: true,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        textAlign: TextAlign.center,
        inputFormatters: const [MyanmarNumberInputFormatter()],
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: '—',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          filled: true,
          fillColor:
              enabled ? color.withValues(alpha: 0.055) : Colors.grey.shade100,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: color.withValues(alpha: 0.22)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: color, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }
}
