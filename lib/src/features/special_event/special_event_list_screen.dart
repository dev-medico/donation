import 'dart:async';

import 'package:donation/responsive.dart';
import 'package:donation/src/features/special_event/providers/special_event_provider.dart';
import 'package:donation/src/features/special_event/special_event_data_source.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/myanmar_number_input_formatter.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:donation/src/features/home/mobile_home.dart';

class SpecialEventListScreen extends ConsumerStatefulWidget {
  const SpecialEventListScreen({Key? key, this.fromHome = false})
      : super(key: key);
  static const routeName = "/special-event-list";
  final bool fromHome;

  @override
  ConsumerState<SpecialEventListScreen> createState() =>
      _SpecialEventListScreenState();
}

class _SpecialEventListScreenState
    extends ConsumerState<SpecialEventListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 240) {
      unawaited(ref.read(specialEventListProvider.notifier).loadMore());
    }
  }

  void _search(String value) {
    _searchDebounce?.cancel();
    setState(() {});
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      unawaited(ref.read(specialEventListProvider.notifier).search(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final specialEventsAsync = ref.watch(specialEventListProvider);

    return Scaffold(
      // Always show the app bar — as a home tab it previously had none, which
      // left phones without any way to reach the menu (swipe only).
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
        leading: widget.fromHome && Responsive.isMobile(context)
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: 'မီနူး',
                onPressed: () =>
                    ref.read(drawerControllerProvider)?.toggle?.call(),
              )
            : null,
        centerTitle: true,
        title: const Text(
          "ထူးခြားဖြစ်စဉ်",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
      body: specialEventsAsync.when(
        data: _buildLoadedBody,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: primaryColor,
        tooltip: 'ထူးခြားဖြစ်စဉ် အသစ်ထည့်မည်',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadedBody(SpecialEventListState state) {
    return Column(
      children: [
        _buildSummaryAndSearch(state),
        if (state.isRefreshing)
          LinearProgressIndicator(
            minHeight: 2,
            color: primaryColor,
            backgroundColor: primaryColor.withValues(alpha: 0.08),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: ref.read(specialEventListProvider.notifier).refresh,
            child: state.events.isEmpty
                ? _buildEmptyList(state)
                : _buildEventTable(state.events),
          ),
        ),
        if (state.isLoadingMore)
          LinearProgressIndicator(
            minHeight: 2,
            color: primaryColor,
            backgroundColor: primaryColor.withValues(alpha: 0.08),
          ),
        if (state.loadMoreError != null)
          Material(
            color: const Color(0xFFFFF4F4),
            child: InkWell(
              onTap: ref.read(specialEventListProvider.notifier).loadMore,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('နောက်ထပ်မှတ်တမ်းများ ပြန်ယူမည်'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryAndSearch(SpecialEventListState state) {
    final isMobile = Responsive.isMobile(context);
    final summaryText = Text(
      'စုစုပေါင်း ${Utils.strToMM(state.total.toString())} မှတ်တမ်း',
      key: const ValueKey('special-event-summary'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
    final summary = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(Icons.event_note_outlined, size: 20, color: primaryColor),
          const SizedBox(width: 8),
          if (isMobile) Expanded(child: summaryText) else summaryText,
        ],
      ),
    );

    final search = TextField(
      key: const ValueKey('special-event-search'),
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onChanged: _search,
      onSubmitted: (value) {
        _searchDebounce?.cancel();
        unawaited(ref.read(specialEventListProvider.notifier).search(value));
      },
      decoration: InputDecoration(
        hintText: 'ဓာတ်ခွဲခန်းအမည်ဖြင့် ရှာရန်',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'ရှာဖွေမှု ရှင်းမည်',
                onPressed: _clearSearch,
                icon: const Icon(Icons.close),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                const SizedBox(height: 10),
                search,
              ],
            )
          : Row(
              children: [
                summary,
                const SizedBox(width: 12),
                Expanded(child: search),
              ],
            ),
    );
  }

  Widget _buildEmptyList(SpecialEventListState state) {
    final isSearching = state.query.isNotEmpty;
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        key: const ValueKey('special-event-empty'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(
            height: (constraints.maxHeight - 48).clamp(280.0, 520.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  isSearching
                      ? 'ကိုက်ညီသော မှတ်တမ်း မတွေ့ပါ'
                      : 'ထူးခြားဖြစ်စဉ် မှတ်တမ်း မရှိသေးပါ',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSearching
                      ? 'အခြားဓာတ်ခွဲခန်းအမည်ဖြင့် ထပ်ရှာနိုင်ပါသည်။'
                      : 'မှတ်တမ်းအသစ် ထည့်နိုင်သလို အောက်သို့ဆွဲ၍ ပြန်ယူနိုင်ပါသည်။',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: ValueKey(isSearching
                      ? 'special-event-clear-search'
                      : 'special-event-empty-add'),
                  onPressed: isSearching ? _clearSearch : _showAddEventDialog,
                  style: FilledButton.styleFrom(backgroundColor: primaryColor),
                  icon: Icon(isSearching ? Icons.close : Icons.add),
                  label: Text(isSearching
                      ? 'ရှာဖွေမှု ရှင်းမည်'
                      : 'မှတ်တမ်းအသစ် ထည့်မည်'),
                ),
                if (!isSearching) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    key: const ValueKey('special-event-empty-retry'),
                    onPressed:
                        ref.read(specialEventListProvider.notifier).refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('မှတ်တမ်းများ ပြန်ယူမည်'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBody() {
    return RefreshIndicator(
      onRefresh: ref.read(specialEventListProvider.notifier).refresh,
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          key: const ValueKey('special-event-error'),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            SizedBox(
              height: (constraints.maxHeight - 48).clamp(280.0, 560.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_outlined,
                      size: 56, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'မှတ်တမ်းများ ရယူ၍ မရသေးပါ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'အင်တာနက်ချိတ်ဆက်မှုကို စစ်ဆေးပြီး ထပ်မံကြိုးစားပါ။',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    key: const ValueKey('special-event-retry'),
                    onPressed:
                        ref.read(specialEventListProvider.notifier).refresh,
                    style:
                        FilledButton.styleFrom(backgroundColor: primaryColor),
                    icon: const Icon(Icons.refresh),
                    label: const Text('ပြန်လည်ကြိုးစားမည်'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _showAddEventDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('မှတ်တမ်းအသစ် ထည့်မည်'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {});
    unawaited(ref.read(specialEventListProvider.notifier).search(''));
  }

  String _eventDate(dynamic event) {
    try {
      final dateString = event['date'].toString();
      if (dateString.contains(' ')) {
        try {
          DateFormat('dd MMM yyyy').parse(dateString);
          return dateString;
        } catch (_) {
          return DateFormat('dd MMM yyyy').format(DateTime.parse(dateString));
        }
      }
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateString));
    } catch (_) {
      return '-';
    }
  }

  int _eventNumber(Map<String, dynamic> event, String key) {
    final value = event[key];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Compact phone rows surface only non-zero findings so staff can scan the
  /// exceptional result rather than six repeated zeroes.
  Widget _buildMobileEventList(List<Map<String, dynamic>> events) {
    return ListView.separated(
      key: const ValueKey('special-event-list'),
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 88),
      itemCount: events.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final event = events[index];
        final lab = (event['lab_name'] ?? '').toString().trim();
        final total = _eventNumber(event, 'total');
        final findings = <(String, int)>[
          ('Hb', _eventNumber(event, 'haemoglobin')),
          ('HBs Ag', _eventNumber(event, 'hbs_ag')),
          ('HCV Ab', _eventNumber(event, 'hcv_ab')),
          ('MP ICT', _eventNumber(event, 'mp_ict')),
          ('Retro', _eventNumber(event, 'retro_test')),
          ('VDRL', _eventNumber(event, 'vdrl_test')),
        ].where((finding) => finding.$2 > 0).toList();

        return InkWell(
          onTap: () => _showEventDetails(event),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lab.isEmpty ? 'ဓာတ်ခွဲခန်းအမည် မရှိပါ' : lab,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 13, color: Colors.grey[600]),
                              const SizedBox(width: 5),
                              Text(
                                _eventDate(event),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Semantics(
                      label: 'စုစုပေါင်း $total',
                      excludeSemantics: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE7E7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${Utils.strToMM(total.toString())} ခု',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                if (findings.isEmpty)
                  Text(
                    'ထူးခြားစစ်ဆေးချက် ၀',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  )
                else
                  Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    children: [
                      for (final finding in findings)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Text(
                            '${finding.$1} ${Utils.strToMM(finding.$2.toString())}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: primaryDark,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventTable(List<Map<String, dynamic>> events) {
    if (Responsive.isMobile(context)) {
      return _buildMobileEventList(events);
    }
    final dataSource = SpecialEventDataSource(eventData: events);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SfDataGrid(
          source: dataSource,
          verticalScrollController: _scrollController,
          onCellTap: (details) {
            if (details.rowColumnIndex.rowIndex > 0) {
              final index = details.rowColumnIndex.rowIndex - 1;
              if (index < events.length) {
                _showEventDetails(events[index]);
              }
            }
          },
          onQueryRowHeight: (details) {
            // Add more height for header row
            return details.rowIndex == 0 ? 60.0 : 50.0;
          },
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          columnWidthMode: Responsive.isMobile(context)
              ? ColumnWidthMode.auto
              : ColumnWidthMode.fill,
          columns: <GridColumn>[
            GridColumn(
                columnName: 'စဥ်',
                width: 60,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'စဥ်',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
            GridColumn(
                columnName: 'ရက်စွဲ',
                width: 120,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'ရက်စွဲ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
            GridColumn(
                columnName: 'Lab Name',
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Lab Name',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
            GridColumn(
                columnName: 'Haemoglobin',
                width: 100,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Haemo',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          'globin',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ))),
            GridColumn(
                columnName: 'HBs Ag',
                width: 80,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'HBs Ag',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))),
            GridColumn(
                columnName: 'HCV Ab',
                width: 80,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'HCV Ab',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))),
            GridColumn(
                columnName: 'MP ICT',
                width: 80,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'MP ICT',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))),
            GridColumn(
                columnName: 'Retro',
                width: 80,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Retro',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))),
            GridColumn(
                columnName: 'VDRL',
                width: 80,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'VDRL',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))),
            GridColumn(
                columnName: 'စုစုပေါင်း',
                width: 100,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'စုစုပေါင်း',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    // Parse date safely
    String dateDisplay;
    try {
      final dateStr = event['date'].toString();
      if (dateStr.contains(' ')) {
        try {
          // Only used to validate the "dd MMM yyyy" shape — throws into the
          // catch below when the string is in some other format.
          DateFormat('dd MMM yyyy').parse(dateStr);
          dateDisplay = dateStr;
        } catch (e) {
          final date = DateTime.parse(dateStr);
          dateDisplay = DateFormat('dd MMM yyyy').format(date);
        }
      } else {
        final date = DateTime.parse(dateStr);
        dateDisplay = DateFormat('dd MMM yyyy').format(date);
      }
    } catch (e) {
      dateDisplay = 'Invalid date';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text((event['lab_name'] ?? '').toString().trim().isEmpty
            ? 'ထူးခြားဖြစ်စဉ်'
            : event['lab_name'].toString()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ရက်စွဲ', dateDisplay),
              _buildDetailRow('Haemoglobin', event['haemoglobin']),
              _buildDetailRow('HBs Ag', event['hbs_ag']),
              _buildDetailRow('HCV Ab', event['hcv_ab']),
              _buildDetailRow('MP ICT', event['mp_ict']),
              _buildDetailRow('Retro Test', event['retro_test']),
              _buildDetailRow('VDRL Test', event['vdrl_test']),
              _buildDetailRow('စုစုပေါင်း', event['total']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ပိတ်မည်', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditEventDialog(event);
            },
            child: Text('ပြင်မည်', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event['id'].toString());
            },
            child: const Text('ဖျက်မည်', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value?.toString() ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    if (Responsive.isMobile(context)) {
      unawaited(
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (context) => const _AddSpecialEventDialog(),
          ),
        ),
      );
      return;
    }

    unawaited(showDialog<void>(
      context: context,
      builder: (context) => const _AddSpecialEventDialog(),
    ));
  }

  void _showEditEventDialog(Map<String, dynamic> event) {
    if (Responsive.isMobile(context)) {
      unawaited(
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (context) => _EditSpecialEventDialog(event: event),
          ),
        ),
      );
      return;
    }

    unawaited(showDialog<void>(
      context: context,
      builder: (context) => _EditSpecialEventDialog(event: event),
    ));
  }

  void _deleteEvent(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('မှတ်တမ်း ဖျက်မည်'),
        content: const Text('ဤထူးခြားဖြစ်စဉ်မှတ်တမ်းကို ဖျက်ရန် သေချာပါသလား။'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('မဖျက်တော့ပါ', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(this.context);

              try {
                await ref.read(specialEventListProvider.notifier).delete(id);
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('မှတ်တမ်း ဖျက်ပြီးပါပြီ'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('မှတ်တမ်း ဖျက်၍ မရပါ။ ထပ်မံကြိုးစားပါ။'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('ဖျက်မည်', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

Widget _buildSpecialEventDialogTitle(IconData icon, String title) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: primaryColor),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          softWrap: true,
        ),
      ),
    ],
  );
}

Widget _buildMobileSpecialEventFormPage({
  required String keyPrefix,
  required String title,
  required bool isLoading,
  required Widget form,
  required VoidCallback onSubmit,
  required BuildContext context,
}) {
  return PopScope(
    canPop: !isLoading,
    child: Scaffold(
      key: ValueKey('$keyPrefix-page'),
      backgroundColor: const Color(0xFFFFFBFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: ValueKey('$keyPrefix-close'),
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
          tooltip: 'မလုပ်တော့ပါ',
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
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Theme(
              data: _specialEventMobileFormTheme(context),
              child: form,
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: Color(0xFFE9E4E4)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: ValueKey('$keyPrefix-cancel'),
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('မလုပ်တော့ပါ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: ValueKey('$keyPrefix-save'),
                  onPressed: isLoading ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: primaryColor,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                            semanticsLabel: 'သိမ်းဆည်းနေသည်',
                          ),
                        )
                      : const Text('သိမ်းမည်'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

ThemeData _specialEventMobileFormTheme(BuildContext context) {
  final theme = Theme.of(context);
  const borderColor = Color(0xFFD9D4D4);

  return theme.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: const TextStyle(color: Color(0xFF625D5D), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    ),
  );
}

Widget _buildSpecialEventTestGrid({
  required BuildContext context,
  required List<Widget> children,
}) {
  final isMobile = Responsive.isMobile(context);

  return LayoutBuilder(
    builder: (context, constraints) {
      final columnCount = isMobile
          ? constraints.maxWidth >= 300
              ? 2
              : 1
          : 3;

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: columnCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: isMobile ? 68 : null,
        childAspectRatio: 2.5,
        children: children,
      );
    },
  );
}

// Add Special Event Dialog Widget
class _AddSpecialEventDialog extends ConsumerStatefulWidget {
  const _AddSpecialEventDialog();

  @override
  ConsumerState<_AddSpecialEventDialog> createState() =>
      _AddSpecialEventDialogState();
}

class _AddSpecialEventDialogState
    extends ConsumerState<_AddSpecialEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labNameController = TextEditingController();
  final _haemoglobinController = TextEditingController();
  final _hbsAgController = TextEditingController();
  final _hcvAbController = TextEditingController();
  final _mpIctController = TextEditingController();
  final _retroController = TextEditingController();
  final _vdrlController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _labNameController.dispose();
    _haemoglobinController.dispose();
    _hbsAgController.dispose();
    _hcvAbController.dispose();
    _mpIctController.dispose();
    _retroController.dispose();
    _vdrlController.dispose();
    super.dispose();
  }

  int _calculateTotal() {
    int total = 0;
    total += int.tryParse(_haemoglobinController.text) ?? 0;
    total += int.tryParse(_hbsAgController.text) ?? 0;
    total += int.tryParse(_hcvAbController.text) ?? 0;
    total += int.tryParse(_mpIctController.text) ?? 0;
    total += int.tryParse(_retroController.text) ?? 0;
    total += int.tryParse(_vdrlController.text) ?? 0;
    return total;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      final data = {
        'lab_name': _labNameController.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'haemoglobin': int.parse(_haemoglobinController.text.isEmpty
            ? '0'
            : _haemoglobinController.text),
        'hbs_ag': int.parse(
            _hbsAgController.text.isEmpty ? '0' : _hbsAgController.text),
        'hcv_ab': int.parse(
            _hcvAbController.text.isEmpty ? '0' : _hcvAbController.text),
        'mp_ict': int.parse(
            _mpIctController.text.isEmpty ? '0' : _mpIctController.text),
        'retro_test': int.parse(
            _retroController.text.isEmpty ? '0' : _retroController.text),
        'vdrl_test': int.parse(
            _vdrlController.text.isEmpty ? '0' : _vdrlController.text),
        'total': _calculateTotal(),
      };

      await ref.read(specialEventListProvider.notifier).create(data);
      if (!mounted) return;

      Navigator.of(context).pop();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('ထူးခြားဖြစ်စဉ် အောင်မြင်စွာ ထည့်သွင်းပြီးပါပြီ'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('မှတ်တမ်း ထည့်၍ မရပါ။ ဖြည့်ထားသည်များကို စစ်ဆေးပါ။'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return _buildMobileSpecialEventFormPage(
        keyPrefix: 'special-event-add',
        title: 'ထူးခြားဖြစ်စဉ် ထည့်မည်',
        isLoading: _isLoading,
        form: _buildForm(isMobile: true),
        onSubmit: _submit,
        context: context,
      );
    }

    return AlertDialog(
      title: _buildSpecialEventDialogTitle(
        Icons.add_circle,
        'ထူးခြားဖြစ်စဉ် အသစ်ထည့်သွင်းမည်',
      ),
      content: SizedBox(
        width: 500,
        child: _buildForm(isMobile: false),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('မလုပ်တော့ပါ'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'သိမ်းမည်',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _buildForm({required bool isMobile}) {
    final formattedDate = DateFormat('dd MMM yyyy').format(_selectedDate);

    return SingleChildScrollView(
      key: const ValueKey('special-event-add-form-scroll'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: isMobile
          ? const EdgeInsets.fromLTRB(16, 20, 16, 32)
          : EdgeInsets.zero,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const ValueKey('special-event-add-lab-name'),
              controller: _labNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Lab Name *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lab Name ဖြည့်သွင်းပါ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Semantics(
              key: const ValueKey('special-event-add-date'),
              button: true,
              label: 'ရက်စွဲ $formattedDate',
              excludeSemantics: true,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(isMobile ? 12 : 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    color: isMobile ? Colors.white : null,
                    border: Border.all(
                      color: isMobile ? const Color(0xFFD9D4D4) : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ရက်စွဲ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(formattedDate,
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'စစ်ဆေးချက် အရေအတွက်များ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildSpecialEventTestGrid(
              context: context,
              children: [
                _buildTestField(
                  'Haemoglobin',
                  _haemoglobinController,
                  fieldKey: 'haemoglobin',
                ),
                _buildTestField('HBs Ag', _hbsAgController, fieldKey: 'hbs-ag'),
                _buildTestField('HCV Ab', _hcvAbController, fieldKey: 'hcv-ab'),
                _buildTestField('MP ICT', _mpIctController, fieldKey: 'mp-ict'),
                _buildTestField('Retro', _retroController, fieldKey: 'retro'),
                _buildTestField('VDRL', _vdrlController, fieldKey: 'vdrl'),
              ],
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'စုစုပေါင်း ${_calculateTotal()}',
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'စုစုပေါင်း',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      Utils.strToMM(_calculateTotal().toString()),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildTestField(
    String label,
    TextEditingController controller, {
    required String fieldKey,
  }) {
    return TextFormField(
      key: ValueKey('special-event-add-$fieldKey'),
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: const [MyanmarNumberInputFormatter()],
      onChanged: (value) {
        setState(() {}); // Update total
      },
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return 'ကိန်းဂဏန်းသာ';
          }
        }
        return null;
      },
    );
  }
}

// Edit Special Event Dialog Widget
class _EditSpecialEventDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> event;

  const _EditSpecialEventDialog({
    required this.event,
  });

  @override
  ConsumerState<_EditSpecialEventDialog> createState() =>
      _EditSpecialEventDialogState();
}

class _EditSpecialEventDialogState
    extends ConsumerState<_EditSpecialEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labNameController;
  late TextEditingController _haemoglobinController;
  late TextEditingController _hbsAgController;
  late TextEditingController _hcvAbController;
  late TextEditingController _mpIctController;
  late TextEditingController _retroController;
  late TextEditingController _vdrlController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _labNameController =
        TextEditingController(text: widget.event['lab_name'] ?? '');
    _haemoglobinController = TextEditingController(
        text: widget.event['haemoglobin']?.toString() ?? '0');
    _hbsAgController =
        TextEditingController(text: widget.event['hbs_ag']?.toString() ?? '0');
    _hcvAbController =
        TextEditingController(text: widget.event['hcv_ab']?.toString() ?? '0');
    _mpIctController =
        TextEditingController(text: widget.event['mp_ict']?.toString() ?? '0');
    _retroController = TextEditingController(
        text: widget.event['retro_test']?.toString() ?? '0');
    _vdrlController = TextEditingController(
        text: widget.event['vdrl_test']?.toString() ?? '0');

    // Parse date
    try {
      final dateStr = widget.event['date'].toString();
      if (dateStr.contains(' ')) {
        try {
          _selectedDate = DateFormat('dd MMM yyyy').parse(dateStr);
        } catch (e) {
          _selectedDate = DateTime.parse(dateStr);
        }
      } else {
        _selectedDate = DateTime.parse(dateStr);
      }
    } catch (e) {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _haemoglobinController.dispose();
    _hbsAgController.dispose();
    _hcvAbController.dispose();
    _mpIctController.dispose();
    _retroController.dispose();
    _vdrlController.dispose();
    super.dispose();
  }

  int _calculateTotal() {
    int total = 0;
    total += int.tryParse(_haemoglobinController.text) ?? 0;
    total += int.tryParse(_hbsAgController.text) ?? 0;
    total += int.tryParse(_hcvAbController.text) ?? 0;
    total += int.tryParse(_mpIctController.text) ?? 0;
    total += int.tryParse(_retroController.text) ?? 0;
    total += int.tryParse(_vdrlController.text) ?? 0;
    return total;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      final data = {
        'lab_name': _labNameController.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'haemoglobin': int.parse(_haemoglobinController.text.isEmpty
            ? '0'
            : _haemoglobinController.text),
        'hbs_ag': int.parse(
            _hbsAgController.text.isEmpty ? '0' : _hbsAgController.text),
        'hcv_ab': int.parse(
            _hcvAbController.text.isEmpty ? '0' : _hcvAbController.text),
        'mp_ict': int.parse(
            _mpIctController.text.isEmpty ? '0' : _mpIctController.text),
        'retro_test': int.parse(
            _retroController.text.isEmpty ? '0' : _retroController.text),
        'vdrl_test': int.parse(
            _vdrlController.text.isEmpty ? '0' : _vdrlController.text),
        'total': _calculateTotal(),
      };

      await ref
          .read(specialEventListProvider.notifier)
          .update(widget.event['id'].toString(), data);
      if (!mounted) return;

      Navigator.of(context).pop();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('ထူးခြားဖြစ်စဉ် အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('မှတ်တမ်း ပြင်၍ မရပါ။ ဖြည့်ထားသည်များကို စစ်ဆေးပါ။'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return _buildMobileSpecialEventFormPage(
        keyPrefix: 'special-event-edit',
        title: 'ထူးခြားဖြစ်စဉ် ပြင်မည်',
        isLoading: _isLoading,
        form: _buildForm(isMobile: true),
        onSubmit: _submit,
        context: context,
      );
    }

    return AlertDialog(
      title: _buildSpecialEventDialogTitle(
        Icons.edit,
        'ထူးခြားဖြစ်စဉ် ပြင်ဆင်မည်',
      ),
      content: SizedBox(
        width: 500,
        child: _buildForm(isMobile: false),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('မလုပ်တော့ပါ'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'သိမ်းမည်',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _buildForm({required bool isMobile}) {
    final formattedDate = DateFormat('dd MMM yyyy').format(_selectedDate);

    return SingleChildScrollView(
      key: const ValueKey('special-event-edit-form-scroll'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: isMobile
          ? const EdgeInsets.fromLTRB(16, 20, 16, 32)
          : EdgeInsets.zero,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const ValueKey('special-event-edit-lab-name'),
              controller: _labNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Lab Name *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lab Name ဖြည့်သွင်းပါ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Semantics(
              key: const ValueKey('special-event-edit-date'),
              button: true,
              label: 'ရက်စွဲ $formattedDate',
              excludeSemantics: true,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(isMobile ? 12 : 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    color: isMobile ? Colors.white : null,
                    border: Border.all(
                      color: isMobile ? const Color(0xFFD9D4D4) : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ရက်စွဲ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(formattedDate,
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'စစ်ဆေးချက် အရေအတွက်များ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _buildSpecialEventTestGrid(
              context: context,
              children: [
                _buildTestField(
                  'Haemoglobin',
                  _haemoglobinController,
                  fieldKey: 'haemoglobin',
                ),
                _buildTestField('HBs Ag', _hbsAgController, fieldKey: 'hbs-ag'),
                _buildTestField('HCV Ab', _hcvAbController, fieldKey: 'hcv-ab'),
                _buildTestField('MP ICT', _mpIctController, fieldKey: 'mp-ict'),
                _buildTestField('Retro', _retroController, fieldKey: 'retro'),
                _buildTestField('VDRL', _vdrlController, fieldKey: 'vdrl'),
              ],
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'စုစုပေါင်း ${_calculateTotal()}',
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'စုစုပေါင်း',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      Utils.strToMM(_calculateTotal().toString()),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildTestField(
    String label,
    TextEditingController controller, {
    required String fieldKey,
  }) {
    return TextFormField(
      key: ValueKey('special-event-edit-$fieldKey'),
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: const [MyanmarNumberInputFormatter()],
      onChanged: (value) {
        setState(() {}); // Update total
      },
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return 'ကိန်းဂဏန်းသာ';
          }
        }
        return null;
      },
    );
  }
}
