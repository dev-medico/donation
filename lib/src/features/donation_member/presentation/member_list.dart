import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/domain/search_member_data_source.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/member_detail.dart';
import 'package:donation/src/features/donation_member/presentation/new_member.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:donation/src/features/services/member_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MemberListScreen extends ConsumerStatefulWidget {
  static const routeName = "/members";
  final bool fromHome;

  const MemberListScreen({Key? key, this.fromHome = false}) : super(key: key);

  @override
  _MemberListScreenState createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  List<String> ranges = [];
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
  SearchMemberDataSource? memberDataDataSource;
  TextStyle tabStyle = const TextStyle(fontSize: 16);
  final searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    // Get current members and populate ranges
    final membersAsync = ref.read(memberListProvider);

    membersAsync.whenData((members) {
      if (members.isNotEmpty) {
        // Set filtered members initially to all members
        ref.read(filteredMemberListProvider.notifier).state = members;

        // Generate ranges
        getRanges(members);

        // Set default filter states
        ref.read(memberBloodTypeFilterProvider.notifier).state =
            "သွေးအုပ်စု အလိုက်ကြည့်မည်";
        ref.read(memberSearchQueryProvider.notifier).state = '';

        // Trigger setState to rebuild UI with populated ranges
        setState(() {});
      }
    });
  }

  void getRanges(List<Member> data) {
    ranges.clear();
    if (data.isEmpty) return;

    // Sort the data by memberId to ensure correct range generation
    final sortedData = List<Member>.from(data)
      ..sort((a, b) => (a.memberId ?? '').compareTo(b.memberId ?? ''));

    for (int i = 0; i < sortedData.length; i += 50) {
      final endIndex =
          i + 49 < sortedData.length ? i + 49 : sortedData.length - 1;
      if (sortedData[i].memberId != null &&
          sortedData[endIndex].memberId != null) {
        ranges.add(
            "${sortedData[i].memberId!} မှ ${sortedData[endIndex].memberId!}");
      }
    }

    // Make sure ranges are generated
    print('Generated ${ranges.length} ranges');
  }

  void _filterMembers() {
    final allMembers = ref.read(memberListProvider).value ?? [];
    if (allMembers.isEmpty) return;

    List<Member> filtered = List.from(allMembers);
    final selectedBloodType = ref.read(memberBloodTypeFilterProvider);
    final searchKey = ref.read(memberSearchQueryProvider);
    final selectedRange = ref.read(memberRangeFilterProvider);

    // Filter by blood type
    if (selectedBloodType != "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
      filtered = filtered
          .where((member) =>
              member.bloodType != null && member.bloodType == selectedBloodType)
          .toList();
    }

    // Filter by search text
    if (searchKey.isNotEmpty) {
      filtered = filtered
          .where((member) =>
              (member.name?.toLowerCase().contains(searchKey.toLowerCase()) ??
                  false) ||
              (member.memberId
                      ?.toLowerCase()
                      .contains(searchKey.toLowerCase()) ??
                  false) ||
              (member.phone?.toLowerCase().contains(searchKey.toLowerCase()) ??
                  false))
          .toList();
    }

    // Filter by range
    if (selectedRange != null &&
        selectedRange.isNotEmpty &&
        ranges.contains(selectedRange)) {
      final rangeParts = selectedRange.split(' မှ ');
      if (rangeParts.length == 2) {
        final startId = rangeParts[0];
        final endId = rangeParts[1];

        final startIndex =
            filtered.indexWhere((member) => member.memberId == startId);
        final endIndex =
            filtered.indexWhere((member) => member.memberId == endId);

        if (startIndex != -1 && endIndex != -1 && startIndex <= endIndex) {
          filtered = filtered.sublist(startIndex, endIndex + 1);
        }
      }
    }

    ref.read(filteredMemberListProvider.notifier).state = filtered;
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(memberListProvider);
    final filteredMembers = ref.watch(filteredMemberListProvider);
    final selectedBloodType = ref.watch(memberBloodTypeFilterProvider);
    final selectedRange = ref.watch(memberRangeFilterProvider);

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
        centerTitle: true,
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
                    Navigator.pop(context);
                  },
                ),
              ),
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("အဖွဲ့၀င်များ",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 16,
                  color: Colors.white)),
        ),
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(memberListProvider);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        data: (members) => Stack(
          children: [
            Responsive.isMobile(context)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.3,
                                margin:
                                    const EdgeInsets.only(top: 20, right: 6),
                                child: ranges.isNotEmpty
                                    ? DropdownButtonFormField<String>(
                                        value: selectedRange,
                                        dropdownColor: Colors.white,
                                        focusColor: Colors.white,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.only(
                                              top: 16,
                                              left: 20,
                                              bottom: 16,
                                              right: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        isExpanded: true,
                                        hint: const Text(
                                          "အမှတ်စဥ် အလိုက်ကြည့်မည်",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black45,
                                        ),
                                        iconSize: 30,
                                        items: [
                                          DropdownMenuItem(
                                            value: null,
                                            child: Text(
                                              "အမှတ်စဥ် အလိုက်ကြည့်မည်",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          ...ranges.map((item) =>
                                              DropdownMenuItem<String>(
                                                value: item,
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              )),
                                        ],
                                        onChanged: (value) {
                                          ref
                                              .read(memberRangeFilterProvider
                                                  .notifier)
                                              .state = value;
                                          _filterMembers();
                                        },
                                      )
                                    : Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "အမှတ်စဥ် အလိုက်ကြည့်မည်",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700]),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.3,
                                margin: const EdgeInsets.only(
                                  top: 20,
                                  left: 6,
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedBloodType,
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        top: 16,
                                        left: 20,
                                        bottom: 16,
                                        right: 12),
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
                                      value: "သွေးအုပ်စု အလိုက်ကြည့်မည်",
                                      child: Text(
                                        "သွေးအုပ်စု အလိုက်ကြည့်မည်",
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    ...bloodTypes
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            )),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      ref
                                          .read(memberBloodTypeFilterProvider
                                              .notifier)
                                          .state = value;
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 40,
                        margin:
                            const EdgeInsets.only(right: 20, top: 12, left: 20),
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
                                  .read(memberSearchQueryProvider.notifier)
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
                  )
                : Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        height: 50,
                        margin: const EdgeInsets.only(top: 28, left: 24),
                        child: ranges.isNotEmpty
                            ? DropdownButtonFormField<String>(
                                value: selectedRange,
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
                                hint: const Text(
                                  "အမှတ်စဥ် အလိုက်ကြည့်မည်",
                                  style: TextStyle(fontSize: 14),
                                ),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black45,
                                ),
                                iconSize: 30,
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      "အမှတ်စဥ် အလိုက်ကြည့်မည်",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  ...ranges
                                      .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          )),
                                ],
                                onChanged: (value) {
                                  ref
                                      .read(memberRangeFilterProvider.notifier)
                                      .state = value;
                                  _filterMembers();
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      "အမှတ်စဥ် အလိုက်ကြည့်မည်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700]),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        margin: const EdgeInsets.only(top: 28, left: 20),
                        child: DropdownButtonFormField(
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
                          hint: Text(
                            selectedBloodType,
                            style: const TextStyle(fontSize: 14),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 30,
                          items: bloodTypes
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null) {
                              return "သွေးအုပ်စု အလိုက်ကြည့်မည်";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(memberBloodTypeFilterProvider.notifier)
                                  .state = value;
                              _filterMembers();
                            }
                          },
                          onSaved: (value) {},
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        margin:
                            const EdgeInsets.only(right: 40, top: 28, left: 20),
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: TextFormField(
                          autofocus: false,
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
                                  .read(memberSearchQueryProvider.notifier)
                                  .state = val;
                              _filterMembers();
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
            Container(
              margin: EdgeInsets.only(
                  left: 20.0,
                  top: Responsive.isMobile(context) ? 160 : 100,
                  bottom: 12),
              child: buildSimpleTable(filteredMembers),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          // Navigate to a placeholder screen for now
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('အဖွဲ့၀င်အသစ် ထည့်သွင်းခြင်း လုပ်ဆောင်နေဆဲ ဖြစ်ပါသည်။'),
              duration: Duration(seconds: 2),
            ),
          );

          // Refresh the member list
          ref.refresh(memberListProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildSimpleTable(List<Member> members) {
    memberDataDataSource = SearchMemberDataSource(memberData: members);

    return SizedBox(
      height: MediaQuery.of(context).size.height -
          (Responsive.isMobile(context) ? 220 : 160),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  right: Responsive.isMobile(context) ? 20 : 20),
              child: SfDataGrid(
                source: memberDataDataSource!,
                onCellTap: (details) async {
                  if (details.rowColumnIndex.rowIndex == 0) return;

                  final member = members[details.rowColumnIndex.rowIndex - 1];

                  if (member.id != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MemberDetailScreen(
                          memberId: member.id.toString(),
                        ),
                      ),
                    );
                  }
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
                          width: MediaQuery.of(context).size.width * 0.3,
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
                      columnName: 'မှတ်ပုံတင်အမှတ်',
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'မှတ်ပုံတင်အမှတ်',
                            style: TextStyle(color: Colors.white),
                          ))),
                  GridColumn(
                      columnName: 'သွေးဘဏ်ကတ်',
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'သွေးဘဏ်ကတ်',
                            style: TextStyle(color: Colors.white),
                          ))),
                  GridColumn(
                      columnName: 'သွေးလှူမှုကြိမ်ရေ',
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'သွေးလှူမှုကြိမ်ရေ',
                            style: TextStyle(color: Colors.white),
                          ))),
                  GridColumn(
                      columnName: 'မွေးသက္ကရာဇ်',
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'မွေးသက္ကရာဇ်',
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
                      columnName: 'နေရပ်လိပ်စာ',
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'နေရပ်လိပ်စာ',
                            style: TextStyle(color: Colors.white),
                          ))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
