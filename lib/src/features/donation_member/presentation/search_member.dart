import 'dart:async';
import 'dart:developer';

import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/domain/search_member_data_source.dart';
import 'package:donation/src/features/donation_member/presentation/widget/call_or_remark_dialog.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/utils/Colors.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:donation/src/features/services/member_service.dart'
    hide memberServiceProvider;

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
  
  List<String> years = [];
  
  SearchMemberDataSource? memberDataDataSource;
  TextStyle tabStyle = const TextStyle(fontSize: 16);

  final searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Generate years from 2020 to current year
    final currentYear = DateTime.now().year;
    for (int year = 2020; year <= currentYear; year++) {
      years.add(year.toString());
    }
    years = years.reversed.toList(); // Most recent year first
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetAllFilters();
    });
  }

  // Method to reset all filters including those from member list
  void _resetAllFilters() {
    // Reset search-specific filters
    resetSearchFilterProviders(ref);

    // Also reset main list filters to prevent cross-contamination
    resetFilterProviders(ref);

    // Clear search controller
    searchController.clear();

    // Set initial values
    ref.read(searchMemberBloodTypeFilterProvider.notifier).state =
        "သွေးအုပ်စုဖြင့် ရှာဖွေမည်";
    ref.read(searchMemberQueryProvider.notifier).state = '';
    ref.read(searchMemberDonationYearFilterProvider.notifier).state = DateTime.now().year.toString();

    // Force refresh of the filtered list with year-filtered members
    if (ref.read(searchMemberListWithYearProvider).hasValue) {
      final allMembers = ref.read(searchMemberListWithYearProvider).value ?? [];
      ref.read(filteredSearchMemberListProvider.notifier).state =
          List.from(allMembers);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    // Clear filters when screen is disposed
    resetSearchFilterProviders(ref);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch all necessary providers - use the provider with year filter for search
    final membersAsync = ref.watch(searchMemberListWithYearProvider);
    final filteredMembers = ref.watch(filteredSearchMemberListProvider);
    final selectedBloodType = ref.watch(searchMemberBloodTypeFilterProvider);
    final selectedYear = ref.watch(searchMemberDonationYearFilterProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryDark],
        ))),
        leading: widget.fromHome && Responsive.isMobile(context)
            ? Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    // Clear all filters before navigating back
                    resetSearchFilterProviders(ref);
                    // Don't reset main list filters - we want to preserve those
                    searchController.clear();
                    Navigator.pop(context);
                  },
                ),
              ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("လှူဒါန်းနိုင်မည့် သွေးလှူရှင်များ",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 16,
                  color: Colors.white)),
        ),
      ),
      body: Column(
        children: [
          // Filter section - always visible
          Responsive.isMobile(context)
              ? Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                  left: 6,
                                  right: 6,
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedBloodType,
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        top: 16, left: 20, bottom: 16, right: 12),
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
                                    ...bloodTypes
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            )),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      ref
                                          .read(searchMemberBloodTypeFilterProvider
                                              .notifier)
                                          .state = value;
                                    }
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                  left: 6,
                                  right: 6,
                                ),
                                child: DropdownButtonFormField<String?>(
                                  value: selectedYear,
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        top: 16, left: 20, bottom: 16, right: 12),
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
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                        "နှစ်အားလုံး",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    ...years
                                        .map((year) => DropdownMenuItem<String?>(
                                              value: year,
                                              child: Text(
                                                "$year ခုနှစ်",
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            )),
                                  ],
                                  onChanged: (value) {
                                    ref
                                        .read(searchMemberDonationYearFilterProvider
                                            .notifier)
                                        .state = value;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          margin: const EdgeInsets.only(
                            top: 20,
                            left: 6,
                          ),
                          child: TextFormField(
                            controller: searchController,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black),
                            onChanged: (val) {
                              if (_debounceTimer?.isActive ?? false) {
                                _debounceTimer?.cancel();
                              }

                              _debounceTimer =
                                  Timer(const Duration(milliseconds: 500), () {
                                ref
                                    .read(searchMemberQueryProvider.notifier)
                                    .state = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
                              hintStyle: const TextStyle(
                                  color: Colors.black, fontSize: 15.0),
                              fillColor: Colors.white.withOpacity(0.2),
                              filled: true,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.search,
                                  color: primaryColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 4, bottom: 4),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey)),
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey)),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        )
                      ],
                    ),
                  )
              : Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 6,
                        margin: const EdgeInsets.only(top: 28, left: 20),
                        child: DropdownButtonFormField<String>(
                          value: selectedBloodType,
                          dropdownColor: Colors.white,
                          focusColor: Colors.white,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(
                                top: 16, left: 20, bottom: 16, right: 12),
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
                            ...bloodTypes
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    )),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(searchMemberBloodTypeFilterProvider
                                      .notifier)
                                  .state = value;
                            }
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 6,
                        margin: const EdgeInsets.only(top: 28, left: 20),
                        child: DropdownButtonFormField<String?>(
                          value: selectedYear,
                          dropdownColor: Colors.white,
                          focusColor: Colors.white,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(
                                top: 16, left: 20, bottom: 16, right: 12),
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
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                "နှစ်အားလုံး",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            ...years
                                .map((year) => DropdownMenuItem<String?>(
                                      value: year,
                                      child: Text(
                                        "$year ခုနှစ်",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    )),
                          ],
                          onChanged: (value) {
                            ref
                                .read(searchMemberDonationYearFilterProvider
                                    .notifier)
                                .state = value;
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 6,
                        margin:
                            const EdgeInsets.only(right: 40, top: 28, left: 20),
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: TextFormField(
                          controller: searchController,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black),
                          onChanged: (val) {
                            if (_debounceTimer?.isActive ?? false) {
                              _debounceTimer?.cancel();
                            }

                            _debounceTimer =
                                Timer(const Duration(milliseconds: 500), () {
                              ref
                                  .read(searchMemberQueryProvider.notifier)
                                  .state = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
                            hintStyle: const TextStyle(
                                color: Colors.black, fontSize: 15.0),
                            fillColor: Colors.white.withOpacity(0.2),
                            filled: true,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.search,
                                color: primaryColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.only(
                                left: 20, right: 20, top: 4, bottom: 4),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
          // Table section with loading overlay
          Expanded(
            child: membersAsync.when(
              loading: () => Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20.0, right: 20, top: 20, bottom: 12),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: primaryColor),
                          const SizedBox(height: 16),
                          Text('Loading...', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(searchMemberListWithYearProvider);
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (members) => Container(
                margin: EdgeInsets.only(left: 20.0, right: 20, top: 20, bottom: 12),
                child: buildSimpleTable(filteredMembers),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          // Reset all filters first
          _resetAllFilters();

          // Then refresh member list with year filter
          ref.invalidate(searchMemberListWithYearProvider);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget buildSimpleTable(List<Member> members) {
    memberDataDataSource = SearchMemberDataSource(memberData: members);

    return SfDataGrid(
        source: memberDataDataSource!,
        onCellTap: (details) async {
          if (details.rowColumnIndex.rowIndex == 0) return;

          final member = members[details.rowColumnIndex.rowIndex - 1];
          showDialog(
              context: context,
              builder: (context) => CallOrRemarkDialog(
                    title: "လုပ်ဆောင်ရန်",
                    member: member,
                  ));
        },
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: Responsive.isMobile(context)
            ? ColumnWidthMode.auto
            : ColumnWidthMode.fitByCellValue,
        columns: <GridColumn>[
          GridColumn(
              columnName: 'အမှတ်စဥ်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'အမှတ်စဥ်',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'အမည်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'အမည်',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'အဖအမည်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'အဖအမည်',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'သွေးအုပ်စု',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'သွေးအုပ်စု',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'ဖုန်းနံပါတ်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'ဖုန်းနံပါတ်',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'နောက်ဆုံးလှူဒါန်းသည့်ရက်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'နောက်ဆုံးလှူဒါန်းသည့်ရက်',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'အခြေအနေ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'အခြေအနေ',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'မှတ်ချက်',
              minimumWidth: 100,
              width: double.nan,  // This allows it to fit content
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'မှတ်ချက်',
                    style: TextStyle(color: Colors.white),
                  ))),
        ],
      );
  }
}
