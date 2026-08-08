import 'dart:async';

import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/domain/search_member_data_source.dart';
import 'package:donation/src/features/donation_member/presentation/widget/call_or_remark_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/utils/Colors.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/ui/blood_chip.dart';

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
                    margin: EdgeInsets.only(left: 12, right: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  left: 2,
                                  right: 4,
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedBloodType,
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        top: 10, left: 12, bottom: 10, right: 6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: 22,
                                  items: [
                                    DropdownMenuItem(
                                      value: "သွေးအုပ်စုဖြင့် ရှာဖွေမည်",
                                      child: Text(
                                        "သွေးအုပ်စု",
                                        style: const TextStyle(fontSize: 12.5),
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
                                  top: 10,
                                  left: 4,
                                  right: 2,
                                ),
                                child: DropdownButtonFormField<String?>(
                                  value: selectedYear,
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        top: 10, left: 12, bottom: 10, right: 6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: 22,
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                        "နှစ်အားလုံး",
                                        style: const TextStyle(fontSize: 12.5),
                                      ),
                                    ),
                                    ...years
                                        .map((year) => DropdownMenuItem<String?>(
                                              value: year,
                                              child: Text(
                                                "$year ခုနှစ်",
                                                style: const TextStyle(fontSize: 12.5),
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
                          margin: const EdgeInsets.only(top: 8, left: 2, right: 2),
                          child: TextFormField(
                            controller: searchController,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
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
                              isDense: true,
                              hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
                              hintStyle: TextStyle(
                                  color: Colors.grey[500], fontSize: 13.5),
                              fillColor: Colors.white.withOpacity(0.2),
                              filled: true,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.search,
                                  size: 20,
                                  color: primaryColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 14, right: 12, top: 10, bottom: 10),
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
                margin: Responsive.isMobile(context)
                    ? const EdgeInsets.only(left: 12, right: 12, top: 8)
                    : const EdgeInsets.only(
                        left: 20.0, right: 20, top: 20, bottom: 12),
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

  /// Compact phone rows for the eligible-donor search: blood chip, name,
  /// phone + last donation date, tap to call or leave a remark.
  Widget _buildMobileSearchList(List<Member> members) {
    if (members.isEmpty) {
      return Center(
        child: Text(
          'ရှာဖွေမှုနှင့် ကိုက်ညီသော သွေးလှူရှင် မရှိပါ',
          style: TextStyle(fontSize: 13.5, color: Colors.grey[600]),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: members.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final member = members[index];
        final phone = (member.phone ?? '').trim();
        final lastDate = (member.lastDate ?? '').trim();
        final secondary = [
          if (phone.isNotEmpty) phone,
          if (lastDate.isNotEmpty) 'နောက်ဆုံး: $lastDate',
        ].join(' · ');
        final status = (member.status ?? '').trim();
        return InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => CallOrRemarkDialog(
                      title: "လုပ်ဆောင်ရန်",
                      member: member,
                    ));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
            child: Row(
              children: [
                BloodChip(bloodType: member.bloodType),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      if (secondary.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          secondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                if (status.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 86),
                    child: Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700]),
                    ),
                  ),
                ],
                Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSimpleTable(List<Member> members) {
    // Phones: compact call-ready rows instead of the 8-column grid.
    if (Responsive.isMobile(context)) {
      return _buildMobileSearchList(members);
    }
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
