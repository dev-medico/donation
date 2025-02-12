import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/domain/search_member_data_source.dart';
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
  String? selectedBloodType = "သွေးအုပ်စု အလိုက်ကြည့်မည်";
  String? selectedRange;
  List<Member> allMembers = [];
  List<Member> filteredMembers = [];
  SearchMemberDataSource? memberDataDataSource;
  TextStyle tabStyle = const TextStyle(fontSize: 16);

  final searchController = TextEditingController();
  Timer? _debounceTimer;
  String searchKey = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    print('Starting to load initial data');
    final memberService = MemberService();
    try {
      setState(() {
        isLoading = true;
        allMembers = [];
        filteredMembers = [];
      });

      print('Fetching members from service...');
      try {
        final members = await memberService.searchMembers(
          limit: 5000,
        );
        print('API Response received');
        print('Members count: ${members.length}');

        setState(() {
          allMembers = members;
          filteredMembers = members;
          isLoading = false;
        });

        if (members.isNotEmpty) {
          getRanges(members);
          _filterMembers();
        } else {
          print('No members returned from API');
        }
      } catch (apiError) {
        print('API Error: $apiError');
        setState(() {
          isLoading = false;
        });
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(
                'Failed to load members. Please check your internet connection and try again.\n\nError: $apiError'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _loadInitialData();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error in _loadInitialData: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterMembers() {
    print('Starting to filter members');
    if (allMembers.isEmpty) {
      print('No members to filter');
      return;
    }

    List<Member> filtered = List.from(allMembers);
    print('Initial filter count: ${filtered.length}');

    // Filter by blood type
    if (selectedBloodType != null &&
        selectedBloodType != "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
      filtered = filtered
          .where((member) =>
              member.bloodType != null && member.bloodType == selectedBloodType)
          .toList();
      print('After blood type filter: ${filtered.length}');
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
      print('After search filter: ${filtered.length}');
    }

    // Filter by range
    if (selectedRange != null && selectedRange!.isNotEmpty) {
      for (int i = 0; i < ranges.length; i++) {
        if (selectedRange == ranges[i]) {
          if (i != ranges.length - 1) {
            filtered =
                filtered.sublist(i * 50, min((i + 1) * 50, filtered.length));
          } else {
            filtered = filtered.sublist(i * 50);
          }
          print('After range filter: ${filtered.length}');
          break;
        }
      }
    }

    print('Final filtered count: ${filtered.length}');
    setState(() {
      filteredMembers = filtered;
      _updateDataSource();
    });
  }

  void _updateDataSource() {
    print('Updating data source with ${filteredMembers.length} members');
    memberDataDataSource = SearchMemberDataSource(memberData: filteredMembers);
  }

  void getRanges(List<Member> data) {
    ranges.clear();
    for (int i = 0; i < data.length; i = i + 50) {
      if (i + 50 > data.length) {
        ranges
            .add("${data[i].memberId!} မှ ${data[data.length - 1].memberId!}");
      } else {
        ranges.add("${data[i].memberId!} မှ ${data[i + 49].memberId!}");
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Humberger(
                  onTap: () {
                    ref.watch(drawerControllerProvider)!.toggle!.call();
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
      body: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
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
                                    ? DropdownButtonFormField(
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
                                        items: ranges
                                            .map((item) =>
                                                DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                        validator: (value) {
                                          if (value == null) {
                                            return "အမှတ်စဥ် အလိုက်ကြည့်မည်";
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            selectedRange = value.toString();
                                          });
                                          _filterMembers();
                                        },
                                        onSaved: (value) {},
                                      )
                                    : Container(),
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
                                child: DropdownButtonFormField(
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
                                  hint: Text(
                                    selectedBloodType!,
                                    style: const TextStyle(fontSize: 13),
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
                                    setState(() {
                                      selectedBloodType = value.toString();
                                    });
                                    _filterMembers();
                                  },
                                  onSaved: (value) {},
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
                              setState(() {
                                searchKey = val;
                              });
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
                  )
                : Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        height: 50,
                        margin: const EdgeInsets.only(top: 28, left: 24),
                        child: ranges.isNotEmpty
                            ? DropdownButtonFormField(
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
                                items: ranges
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return "အမှတ်စဥ် အလိုက်ကြည့်မည်";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    selectedRange = value.toString();
                                  });
                                  _filterMembers();
                                },
                                onSaved: (value) {},
                              )
                            : Container(),
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
                            selectedBloodType!,
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
                            setState(() {
                              selectedBloodType = value.toString();
                            });
                            _filterMembers();
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
                              setState(() {
                                searchKey = val;
                              });
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : buildSimpleTable(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          // await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const NewMemberScreen(),
          //   ),
          // );
          _loadInitialData(); // Refresh data after adding new member
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildSimpleTable() {
    print('Building table. Has data source: ${memberDataDataSource != null}');
    if (memberDataDataSource == null) {
      print('Creating new data source');
      _updateDataSource();
    }

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

                  // await Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => MemberDetailScreen(
                  //       data: filteredMembers[details.rowColumnIndex.rowIndex - 1],
                  //     ),
                  //   ),
                  // );
                  //_loadInitialData();
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
