import 'dart:async';
import 'dart:developer';

import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/presentation/member_detail.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/new_member.dart';
import 'package:donation/src/features/donation_member/domain/member_data_source.dart';
import 'package:donation/utils/Colors.dart';
import 'package:realm/realm.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MemberListScreen extends ConsumerStatefulWidget {
  static const routeName = "/members";

  const MemberListScreen({Key? key}) : super(key: key);

  @override
  _MemberListScreenState createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen>
    with SingleTickerProviderStateMixin {
  List<String> ranges = [];
  List<String> bloodTypes = [
    "A (Rh +)",
    "B (Rh +)",
    "O (Rh +)",
    "AB (Rh +)",
    "A (Rh -)",
    "B (Rh -)",
    "O (Rh -)",
    "AB (Rh -)"
  ];
  String? selectedBloodType = "သွေးအုပ်စု အလိုက်ကြည့်မည်";
  String? selectedRange;
  List<Member> dataSegments = [];
  MemberDataSource? memberDataDataSource;
  List<Member> oldData = [];
  TextStyle tabStyle = const TextStyle(fontSize: 16);

  final searchController = TextEditingController();
  final memberController = TextEditingController();
  List<String> membersSelected = <String>[];
  List<String> allMembers = <String>[];
  bool inputted = false;
  String searchKey = "";
  Timer? _debounceTimer;
  int range = -1;
  bool firstTime = true;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(membersDataProvider);

    log("Data " + results.length.toString());
    if (firstTime) {
      oldData.clear();
      for (int i = 0; i < results.length; i++) {
        setState(() {
          oldData.add(results[i]);
        });
      }
      setState(() {
        dataSegments = oldData;
      });
      ranges.clear();
      getRanges(oldData);
    }

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
                                          "အမှတ်စဥ် အလိုက်ကြည့်မည်",
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
                                            return "အမှတ်စဥ် အလိုက်ကြည့်မည်";
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            selectedRange = value.toString();
                                          });
                                          log("Selected Range : " +
                                              selectedRange.toString());

                                          for (int i = 0;
                                              i < ranges.length;
                                              i++) {
                                            if (value == ranges[i]) {
                                              if (i != ranges.length - 1) {
                                                setState(() {
                                                  dataSegments =
                                                      oldData.sublist(
                                                          i * 50, (i + 1) * 50);
                                                });
                                              } else {
                                                setState(() {
                                                  dataSegments =
                                                      oldData.sublist(i * 50);
                                                });
                                              }
                                            }
                                          }
                                          setState(() {
                                            searchController.text = "";
                                            selectedBloodType =
                                                "သွေးအုပ်စု အလိုက်ကြည့်မည်";
                                          });
                                          log(selectedBloodType.toString());
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
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  validator: (value) {
                                    if (value == null) {
                                      return "သွေးအုပ်စု အလိုက်ကြည့်မည်";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedBloodType = value.toString();
                                    });
                                    log(selectedBloodType.toString());
                                    log(dataSegments.length.toString());
                                    List<Member>? filterdata = [];
                                    for (int i = 0; i < oldData.length; i++) {
                                      //get memberdata from data only where bloodtype is equal to value
                                      if (searchController.text.isNotEmpty) {
                                        if (oldData[i]
                                                .name!
                                                .toLowerCase()
                                                .contains(searchController.text
                                                    .toString()
                                                    .toLowerCase()) &&
                                            oldData[i].bloodType ==
                                                selectedBloodType) {
                                          filterdata.add(oldData[i]);
                                        }
                                      } else {
                                        if (oldData[i].bloodType ==
                                            selectedBloodType) {
                                          filterdata.add(oldData[i]);
                                        }
                                      }
                                    }
                                    setState(() {
                                      dataSegments = filterdata.sublist(0);
                                    });
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
                              List<Member>? filterdata = [];
                              oldData.forEach((element) {
                                if (element.name
                                        .toString()
                                        .toLowerCase()
                                        .split("")
                                        .toSet()
                                        .intersection(searchKey
                                            .toLowerCase()
                                            .split("")
                                            .toSet())
                                        .length ==
                                    searchKey
                                        .toLowerCase()
                                        .split("")
                                        .toSet()
                                        .length) {
                                  setState(() {
                                    filterdata.add(element);
                                  });
                                }
                              });
                              setState(() {
                                dataSegments = filterdata.sublist(0);
                              });
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
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
                                  "အမှတ်စဥ် အလိုက်ကြည့်မည်",
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
                                    return "အမှတ်စဥ် အလိုက်ကြည့်မည်";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    selectedRange = value.toString();
                                  });
                                  log("Selected Range : " +
                                      selectedRange.toString());
                                  List<Member>? filterdata = [];
                                  for (int i = 0; i < ranges.length; i++) {
                                    if (value == ranges[i]) {
                                      log("Exist Index + " + i.toString());
                                      log("Data Index + " +
                                          oldData.length.toString());
                                      if (i != ranges.length - 1) {
                                        setState(() {
                                          filterdata = oldData.sublist(
                                              i * 50, (i + 1) * 50);
                                        });
                                      } else {
                                        setState(() {
                                          filterdata = oldData.sublist(i * 50);
                                        });
                                      }
                                    }
                                  }
                                  log("Filter Result - " +
                                      filterdata!.length.toString());
                                  log("Filter Result - " +
                                      filterdata![0].memberId.toString());
                                  setState(() {
                                    // searchController.text = "";
                                    // selectedBloodType =
                                    //     "သွေးအုပ်စု အလိုက်ကြည့်မည်";
                                    dataSegments = filterdata!.sublist(0);
                                  });
                                  log(selectedBloodType.toString());
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
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null) {
                              return "သွေးအုပ်စု အလိုက်ကြည့်မည်";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedBloodType = value.toString();
                            });
                            log(selectedBloodType.toString());
                            log(dataSegments.length.toString());
                            List<Member>? filterdata = [];
                            for (int i = 0; i < oldData.length; i++) {
                              if (searchController.text.isNotEmpty) {
                                if (oldData[i].name!.toLowerCase().contains(
                                        searchController.text
                                            .toString()
                                            .toLowerCase()) &&
                                    oldData[i].bloodType == selectedBloodType) {
                                  filterdata.add(oldData[i]);
                                }
                              } else {
                                if (oldData[i].bloodType == selectedBloodType) {
                                  filterdata.add(oldData[i]);
                                }
                              }
                            }
                            setState(() {
                              dataSegments = filterdata.sublist(0);
                            });
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
                                Timer(const Duration(milliseconds: 700), () {
                              setState(() {
                                searchKey = val;
                              });
                              List<Member>? filterdata = [];
                              oldData.forEach((element) {
                                if (element.name
                                        .toString()
                                        .toLowerCase()
                                        .split("")
                                        .toSet()
                                        .intersection(searchKey
                                            .toLowerCase()
                                            .split("")
                                            .toSet())
                                        .length ==
                                    searchKey
                                        .toLowerCase()
                                        .split("")
                                        .toSet()
                                        .length) {
                                  setState(() {
                                    filterdata.add(element);
                                  });
                                }
                              });
                              setState(() {
                                dataSegments = filterdata.sublist(0);
                              });
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
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
              child: dataSegments.isNotEmpty
                  ? buildSimpleTable(results)
                  : Container(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewMemberScreen(),
            ),
          );
          refresh(results);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  refresh(RealmResults<Member> results) {
    setState(() {
      oldData.clear();
      for (int i = 0; i < results.length; i++) {
        setState(() {
          oldData.add(results[i]);
        });
      }
      setState(() {
        dataSegments = oldData;
      });
      ranges.clear();
      getRanges(oldData);
      if (searchController.text.isNotEmpty) {
        setState(() {
          searchKey = searchController.text;
        });
        List<Member>? filterdata = [];
        oldData.forEach((element) {
          if (element.name
                  .toString()
                  .toLowerCase()
                  .split("")
                  .toSet()
                  .intersection(searchKey.toLowerCase().split("").toSet())
                  .length ==
              searchKey.toLowerCase().split("").toSet().length) {
            setState(() {
              filterdata.add(element);
            });
          }
        });
        log("call here");
        setState(() {
          dataSegments = filterdata.sublist(0);
        });
      }
    });
  }

  getRanges(List<Member> data) {
    ranges.clear();
    for (int i = 0; i < data.length; i = i + 50) {
      if (i + 50 > data.length) {
        setState(() {
          ranges.add(
              "${data[i].memberId!} မှ ${data[data.length - 1].memberId!}");
        });
      } else {
        setState(() {
          ranges.add("${data[i].memberId!} မှ ${data[i + 49].memberId!}");
        });
      }
    }
    setState(() {
      firstTime = false;
    });
    log("Ranges + " + ranges.length.toString());
  }

  buildSimpleTable(RealmResults<Member> results) {
    memberDataDataSource = MemberDataSource(memberData: dataSegments);
    return Container(
      margin: EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
      child: SfDataGrid(
        source: memberDataDataSource!,
        onCellTap: (details) async {
          Logger logger = Logger();
          logger.i(details.rowColumnIndex.rowIndex);

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberDetailScreen(
                data: dataSegments[details.rowColumnIndex.rowIndex - 1],
              ),
            ),
          );
          ref.invalidate(membersDataProvider);
          refresh(results);
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
        ],
      ),
    );
  }
}
