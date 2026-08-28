import 'dart:async';

import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/last_donation_filter.dart';
import 'package:donation/src/features/donation_member/presentation/widget/call_or_remark_dialog.dart';
import 'package:donation/src/features/donation_member/presentation/widget/donor_search_results.dart';
import 'package:donation/src/features/donation_member/presentation/widget/remark_write_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/src/features/home/mobile_home.dart';

class SearchMemberListScreen extends ConsumerStatefulWidget {
  static const routeName = "/search_members";
  final bool fromHome;
  const SearchMemberListScreen({Key? key, this.fromHome = false})
    : super(key: key);

  @override
  _SearchMemberListScreenState createState() => _SearchMemberListScreenState();
}

class _SearchMemberListScreenState
    extends ConsumerState<SearchMemberListScreen> {
  List<String> bloodTypes = [
    "A (Rh +)",
    "B (Rh +)",
    "AB (Rh +)",
    "O (Rh +)",
    "A (Rh -)",
    "B (Rh -)",
    "AB (Rh -)",
    "O (Rh -)",
  ];

  TextStyle tabStyle = const TextStyle(fontSize: 16);

  final searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _clearFilters() {
    _debounceTimer?.cancel();
    searchController.clear();
    ref.read(searchMemberQueryProvider.notifier).state = '';
    ref.read(searchMemberBloodTypeFilterProvider.notifier).state =
        'သွေးအုပ်စုဖြင့် ရှာဖွေမည်';
    ref.read(searchMemberAvailabilityFilterProvider.notifier).state = null;
    ref.read(searchMemberLastDonationFilterProvider.notifier).state = null;
  }

  /// Filters by the exact calendar year in which the donor last donated.
  Widget _buildLastDonationFilter({
    required LastDonationFilter? selected,
    required bool compact,
  }) {
    final textStyle = TextStyle(fontSize: compact ? 12.5 : 14);
    final years = LastDonationFilter.menuYears(DateTime.now());

    return DropdownButtonFormField<LastDonationFilter?>(
      key: ValueKey('last-donation-filter-${selected?.apiValue ?? 'all'}'),
      initialValue: selected,
      dropdownColor: Colors.white,
      focusColor: Colors.white,
      isExpanded: true,
      icon: Icon(
        Icons.arrow_drop_down,
        color: Colors.black45,
        size: compact ? 20 : 30,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: compact
            ? const EdgeInsets.only(top: 8, left: 9, bottom: 8, right: 4)
            : const EdgeInsets.only(top: 16, left: 20, bottom: 16, right: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
        ),
      ),
      items: [
        DropdownMenuItem<LastDonationFilter?>(
          value: null,
          child: Text(
            compact
                ? 'နောက်ဆုံးလှူသည့်နှစ်'
                : 'နောက်ဆုံးလှူသည့်နှစ်ဖြင့် ရှာဖွေမည်',
            style: textStyle,
          ),
        ),
        ...years.map((year) {
          final filter = LastDonationFilter.inYear(year);
          return DropdownMenuItem<LastDonationFilter?>(
            value: filter,
            child: Text(filter.label, style: textStyle),
          );
        }),
        DropdownMenuItem<LastDonationFilter?>(
          value: const LastDonationFilter.never(),
          child: Text(const LastDonationFilter.never().label, style: textStyle),
        ),
      ],
      onChanged: (value) {
        ref.read(searchMemberLastDonationFilterProvider.notifier).state = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrowPhone = MediaQuery.sizeOf(context).width <= 360;
    final membersAsync = ref.watch(searchMemberListProvider);
    final selectedBloodType = ref.watch(searchMemberBloodTypeFilterProvider);
    final selectedQuery = ref.watch(searchMemberQueryProvider);
    final selectedAvailability = ref.watch(
      searchMemberAvailabilityFilterProvider,
    );
    final selectedLastDonation = ref.watch(
      searchMemberLastDonationFilterProvider,
    );
    final hasActiveFilters =
        selectedBloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်' ||
        selectedQuery.trim().isNotEmpty ||
        selectedAvailability != null ||
        selectedLastDonation != null;

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
        leading: widget.fromHome && Responsive.isMobile(context)
            ? Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: IconButton(
                  icon: Icon(Icons.menu),
                  tooltip: 'မီနူး',
                  onPressed: () {
                    // Home tabs live inside the zoom drawer, not a scaffold
                    // drawer (that one is an empty placeholder).
                    ref.read(drawerControllerProvider)?.toggle?.call();
                  },
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: IconButton(
              tooltip: 'စာရင်း ပြန်လည်ရယူရန်',
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                ref.read(searchMemberListProvider.notifier).refresh();
              },
            ),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "သွေးလှူရှင်များ ရှာဖွေရန်",
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 15 : 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter section - always visible
          Responsive.isMobile(context)
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: isNarrowPhone ? 110 : 132,
                            child: DropdownButtonFormField<String>(
                              key: ValueKey('blood-filter-$selectedBloodType'),
                              initialValue: selectedBloodType,
                              dropdownColor: Colors.white,
                              focusColor: Colors.white,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.only(
                                  top: 8,
                                  left: 9,
                                  bottom: 8,
                                  right: 4,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              isExpanded: true,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                                size: 20,
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်',
                                  child: Text(
                                    'သွေးအုပ်စု',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                ...bloodTypes.map(
                                  (item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  ref
                                          .read(
                                            searchMemberBloodTypeFilterProvider
                                                .notifier,
                                          )
                                          .state =
                                      value;
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildLastDonationFilter(
                              selected: selectedLastDonation,
                              compact: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const ValueKey('member-search-field'),
                        controller: searchController,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        onChanged: (val) {
                          if (_debounceTimer?.isActive ?? false) {
                            _debounceTimer?.cancel();
                          }

                          _debounceTimer = Timer(
                            const Duration(milliseconds: 500),
                            () {
                              if (!mounted) return;
                              ref
                                      .read(searchMemberQueryProvider.notifier)
                                      .state =
                                  val;
                            },
                          );
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'အမည် / ဖုန်း / အမှတ် / နေရပ်',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          filled: true,
                          suffixIcon: hasActiveFilters
                              ? IconButton(
                                  key: const ValueKey('clear-member-filters'),
                                  tooltip: 'စစ်ထုတ်မှုအားလုံး ဖျက်ရန်',
                                  onPressed: _clearFilters,
                                  icon: Icon(
                                    Icons.filter_alt_off_outlined,
                                    size: 20,
                                    color: primaryColor,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.search,
                                    size: 20,
                                    color: primaryColor,
                                  ),
                                ),
                          contentPadding: const EdgeInsets.only(
                            left: 10,
                            right: 8,
                            top: 8,
                            bottom: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 5,
                      margin: const EdgeInsets.only(top: 28, left: 20),
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('blood-filter-$selectedBloodType'),
                        initialValue: selectedBloodType,
                        dropdownColor: Colors.white,
                        focusColor: Colors.white,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                            top: 16,
                            left: 20,
                            bottom: 16,
                            right: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        iconSize: 30,
                        items: [
                          DropdownMenuItem(
                            value: "သွေးအုပ်စုဖြင့် ရှာဖွေမည်",
                            child: Text(
                              "သွေးအုပ်စုဖြင့် ရှာဖွေမည်",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          ...bloodTypes.map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                    .read(
                                      searchMemberBloodTypeFilterProvider
                                          .notifier,
                                    )
                                    .state =
                                value;
                          }
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      margin: const EdgeInsets.only(
                        right: 40,
                        top: 28,
                        left: 20,
                      ),
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: TextFormField(
                        key: const ValueKey('member-search-field'),
                        controller: searchController,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        onChanged: (val) {
                          if (_debounceTimer?.isActive ?? false) {
                            _debounceTimer?.cancel();
                          }

                          _debounceTimer = Timer(
                            const Duration(milliseconds: 500),
                            () {
                              if (!mounted) return;
                              ref
                                      .read(searchMemberQueryProvider.notifier)
                                      .state =
                                  val;
                            },
                          );
                        },
                        decoration: InputDecoration(
                          hintText:
                              'အမည်၊ အမှတ်၊ ဖုန်း၊ လိပ်စာ၊ ရပ်ကွက်၊ မြို့နယ်',
                          hintStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                          ),
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          filled: true,
                          suffixIcon: hasActiveFilters
                              ? IconButton(
                                  key: const ValueKey('clear-member-filters'),
                                  tooltip: 'စစ်ထုတ်မှုအားလုံး ဖျက်ရန်',
                                  onPressed: _clearFilters,
                                  icon: Icon(
                                    Icons.filter_alt_off_outlined,
                                    color: primaryColor,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.search,
                                    color: primaryColor,
                                  ),
                                ),
                          contentPadding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 4,
                            bottom: 4,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 5,
                      margin: const EdgeInsets.only(top: 28),
                      child: _buildLastDonationFilter(
                        selected: selectedLastDonation,
                        compact: false,
                      ),
                    ),
                  ],
                ),
          // Table section with loading overlay
          Expanded(
            child: membersAsync.when(
              skipLoadingOnRefresh: false,
              loading: _buildSearchLoading,
              error: (error, stack) => _buildSearchError(error),
              data: (directory) => Container(
                margin: Responsive.isMobile(context)
                    ? const EdgeInsets.only(left: 8, right: 8, top: 6)
                    : const EdgeInsets.only(
                        left: 20.0,
                        right: 20,
                        top: 20,
                        bottom: 12,
                      ),
                child: buildSimpleTable(directory),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 16),
          Text(
            'သွေးလှူရှင်များ ရှာဖွေနေပါသည်...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchError(Object error) {
    final message = error is TimeoutException
        ? 'ရှာဖွေမှု အချိန်ကြာနေပါသည်။ အင်တာနက်ချိတ်ဆက်မှုကို စစ်ဆေးပြီး ထပ်မံကြိုးစားပါ။'
        : 'သွေးလှူရှင်စာရင်းကို မရယူနိုင်ပါ။ ထပ်မံကြိုးစားပါ။';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 44, color: Colors.grey[500]),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Keep the current query, blood type, and availability on retry.
                ref.read(searchMemberListProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('ပြန်လည်ကြိုးစားမည်'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSimpleTable(SearchMemberDirectoryState directory) {
    return DonorSearchResults(
      members: directory.members,
      analysis: directory.analysis,
      filteredTotal: directory.filteredTotal,
      selectedLevel: ref.watch(searchMemberAvailabilityFilterProvider),
      hasMore: directory.hasMore,
      isLoadingMore: directory.isLoadingMore,
      loadMoreError: directory.loadMoreError,
      onSelectedLevel: (level) {
        ref.read(searchMemberAvailabilityFilterProvider.notifier).state = level;
      },
      onClearFilters: _clearFilters,
      onLoadMore: () {
        ref.read(searchMemberListProvider.notifier).loadNextPage();
      },
      onOpenActions: (member) {
        showDialog(
          context: context,
          builder: (context) =>
              CallOrRemarkDialog(title: 'လုပ်ဆောင်ရန်', member: member),
        );
      },
      onEdit: (member) {
        showDialog(
          context: context,
          builder: (context) => RemarkWriteDialog(member: member),
        );
      },
    );
  }
}
