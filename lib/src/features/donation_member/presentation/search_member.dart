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
  String? selectedBloodType = "သွေးအုပ်စုဖြင့် ရှာဖွေမည်";
  List<Member> dataSegments = [];
  TextStyle tabStyle = const TextStyle(fontSize: 16);

  final searchController = TextEditingController();
  Timer? _debounceTimer;
  String searchKey = "";
  SearchMemberDataSource? memberDataDataSource;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = ref.watch(searchMemberProvider((
      search: searchKey,
      bloodType: selectedBloodType == "သွေးအုပ်စုဖြင့် ရှာဖွေမည်"
          ? null
          : selectedBloodType
    )));

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
      body: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Responsive.isMobile(context)
                  ? Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
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
                                    top: 16, left: 20, bottom: 16, right: 12),
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
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              validator: (value) {
                                if (value == null) {
                                  return "သွေးအုပ်စုဖြင့် ရှာဖွေမည်";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  selectedBloodType = value.toString();
                                });
                              },
                              onSaved: (value) {},
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.only(
                              top: 20,
                              left: 6,
                            ),
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

                                _debounceTimer = Timer(
                                    const Duration(milliseconds: 500), () {
                                  setState(() {
                                    searchKey = val;
                                  });
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
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            validator: (value) {
                              if (value == null) {
                                return "သွေးအုပ်စုဖြင့် ရှာဖွေမည်";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                selectedBloodType = value.toString();
                              });
                            },
                            onSaved: (value) {},
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 5,
                          margin: const EdgeInsets.only(
                              right: 40, top: 28, left: 20),
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
                child: searchResult.when(
                  data: (members) {
                    memberDataDataSource =
                        SearchMemberDataSource(memberData: members);
                    return buildSimpleTable();
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          )),
    );
  }

  Widget buildSimpleTable() {
    if (memberDataDataSource == null) return Container();

    return Container(
      margin: EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
      child: SfDataGrid(
        source: memberDataDataSource!,
        onCellTap: (details) async {
          if (details.rowColumnIndex.rowIndex == 0) return;

          final members = memberDataDataSource!.rows
              .map((row) => Member.fromJson(
                  row.getCells().asMap().map((key, cell) => MapEntry(
                      [
                        'id',
                        'memberId',
                        'name',
                        'lastDate',
                        'bloodType',
                        'nrc',
                        'phone',
                        'status',
                        'note'
                      ][key],
                      cell.value))))
              .toList();

          showDialog(
              context: context,
              builder: (context) => CallOrRemarkDialog(
                    title: "လုပ်ဆောင်ရန်",
                    member: members[details.rowColumnIndex.rowIndex - 1],
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
              columnName: 'လှူဒါန်းခဲ့သည့်ရက်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'လှူဒါန်းခဲ့သည့်ရက်',
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
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'မှတ်ချက်',
                    style: TextStyle(color: Colors.white),
                  ))),
        ],
      ),
    );
  }
}
