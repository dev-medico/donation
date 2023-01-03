import 'dart:convert';
import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/data/repository/repository.dart';
import 'package:merchant/data/response/member_response.dart';
import 'package:merchant/data/response/xata_member_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/member/member_detail.dart';
import 'package:merchant/src/features/member/new_member.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';

class MemberListNewStyle extends StatefulWidget {
  static const routeName = "/member_list";

  const MemberListNewStyle({Key? key}) : super(key: key);

  @override
  _MemberListNewStyleState createState() => _MemberListNewStyleState();
}

class _MemberListNewStyleState extends State<MemberListNewStyle>
    with SingleTickerProviderStateMixin {
  List<String> ranges = [];
  List<String> bloodTypes = [
    "A (Rh +)",
    "A (Rh -)",
    "B (Rh +)",
    "B (Rh -)",
    "AB (Rh +)",
    "AB (Rh -)",
    "O (Rh +)",
    "O (Rh -)"
  ];
  String? selectedBloodType = "သွေးအုပ်စု အလိုက်ကြည့်မည်";
  String? selectedRange;
  List<MemberData> dataSegments = [];
  TextStyle tabStyle = const TextStyle(fontSize: 16);
  @override
  void initState() {
    super.initState();
    callAPI("");
  }

  tabCreate() => Scaffold(
        backgroundColor: Colors.white70,
        body: Stack(
          children: [
            Responsive.isMobile(context)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2.22,
                            margin: const EdgeInsets.only(top: 20, left: 20),
                            child: DropdownButtonFormField2(
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                              buttonHeight: 60,
                              buttonPadding:
                                  const EdgeInsets.only(left: 20, right: 10),
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                for (int i = 0; i < ranges.length; i++) {
                                  if (value == ranges[i]) {
                                    if (i != ranges.length - 1) {
                                      setState(() {
                                        dataSegments =
                                            data!.sublist(i * 50, (i + 1) * 50);
                                      });
                                    } else {
                                      setState(() {
                                        dataSegments = data!.sublist(i * 50);
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
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2.22,
                            margin: const EdgeInsets.only(top: 20, left: 12),
                            child: DropdownButtonFormField2(
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
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
                              buttonHeight: 60,
                              buttonPadding:
                                  const EdgeInsets.only(left: 20, right: 10),
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                List<MemberData>? filterdata = [];
                                for (int i = 0; i < data!.length; i++) {
                                  //get memberdata from data only where bloodtype is equal to value
                                  if (searchController.text.isNotEmpty) {
                                    if (data![i].name!.toLowerCase().contains(
                                            searchController.text
                                                .toString()
                                                .toLowerCase()) &&
                                        data![i].bloodType ==
                                            selectedBloodType) {
                                      filterdata.add(data![i]);
                                    }
                                  } else {
                                    if (data![i].bloodType ==
                                        selectedBloodType) {
                                      filterdata.add(data![i]);
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
                        ],
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
                            List<MemberData>? filterdata = [];
                            for (int i = 0; i < data!.length; i++) {
                              //get memberdata from data only where bloodtype is equal to value
                              if (selectedBloodType !=
                                  "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
                                if (data![i].name!.toLowerCase().contains(
                                        searchController.text
                                            .toString()
                                            .toLowerCase()) &&
                                    data![i].bloodType == selectedBloodType) {
                                  filterdata.add(data![i]);
                                }
                              } else {
                                if (data![i]
                                    .name!
                                    .toLowerCase()
                                    .contains(val.toLowerCase())) {
                                  filterdata.add(data![i]);
                                }
                              }
                            }
                            setState(() {
                              dataSegments = filterdata.sublist(0);
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
                        margin: const EdgeInsets.only(top: 28, left: 24),
                        child: DropdownButtonFormField2(
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
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
                          buttonHeight: 60,
                          buttonPadding:
                              const EdgeInsets.only(left: 20, right: 10),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            for (int i = 0; i < ranges.length; i++) {
                              if (value == ranges[i]) {
                                if (i != ranges.length - 1) {
                                  setState(() {
                                    dataSegments =
                                        data!.sublist(i * 50, (i + 1) * 50);
                                  });
                                } else {
                                  setState(() {
                                    dataSegments = data!.sublist(i * 50);
                                  });
                                }
                              }
                            }
                            setState(() {
                              searchController.text = "";
                              selectedBloodType = "သွေးအုပ်စု အလိုက်ကြည့်မည်";
                            });
                            log(selectedBloodType.toString());
                          },
                          onSaved: (value) {},
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        margin: const EdgeInsets.only(top: 28, left: 20),
                        child: DropdownButtonFormField2(
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
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
                          buttonHeight: 60,
                          buttonPadding:
                              const EdgeInsets.only(left: 20, right: 10),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            List<MemberData>? filterdata = [];
                            for (int i = 0; i < data!.length; i++) {
                              if (searchController.text.isNotEmpty) {
                                if (data![i].name!.toLowerCase().contains(
                                        searchController.text
                                            .toString()
                                            .toLowerCase()) &&
                                    data![i].bloodType == selectedBloodType) {
                                  filterdata.add(data![i]);
                                }
                              } else {
                                if (data![i].bloodType == selectedBloodType) {
                                  filterdata.add(data![i]);
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
                            List<MemberData>? filterdata = [];
                            for (int i = 0; i < data!.length; i++) {
                              //get memberdata from data only where bloodtype is equal to value
                              if (selectedBloodType !=
                                  "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
                                if (data![i].name!.toLowerCase().contains(
                                        searchController.text
                                            .toString()
                                            .toLowerCase()) &&
                                    data![i].bloodType == selectedBloodType) {
                                  filterdata.add(data![i]);
                                }
                              } else {
                                if (data![i]
                                    .name!
                                    .toLowerCase()
                                    .contains(val.toLowerCase())) {
                                  filterdata.add(data![i]);
                                }
                              }
                            }
                            setState(() {
                              dataSegments = filterdata.sublist(0);
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
            dataFullLoad
                ? Container(
                    padding: EdgeInsets.only(
                        left: 20.0,
                        top: Responsive.isMobile(context) ? 160 : 100,
                        bottom: 12),
                    child: buildSimpleTable(dataSegments),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ],
        ),
      );
  final searchController = TextEditingController();
  final memberController = TextEditingController();
  List<String> membersSelected = <String>[];
  List<String> allMembers = <String>[];
  bool inputted = false;
  bool dataFullLoad = false;
  List<MemberData>? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.of(context)?.current!.accentColor,
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
                  fontSize: Responsive.isMobile(context) ? 15 : 17,
                  color: Colors.white)),
        ),
      ),
      body: data != null && data!.isNotEmpty
          ? tabCreate()
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewMemberScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  callAPI(String after) {
    if (after.isEmpty) {
      setState(() {
        data = [];
      });
    }
    XataRepository().getMemberList(after).then((response) {
      log(response.body.toString());

      setState(() {
        data!.addAll(XataMemberListResponse.fromJson(jsonDecode(response.body))
            .records!);
      });

      if (XataMemberListResponse.fromJson(jsonDecode(response.body))
          .meta!
          .page!
          .more!) {
        callAPI(XataMemberListResponse.fromJson(jsonDecode(response.body))
            .meta!
            .page!
            .cursor!);
      } else {
        addData();
      }
    });
  }

  addData() {
    int tabLength = 0;
    data!.sort((a, b) => a.memberId!.compareTo(b.memberId!));

    if (data!.length % 50 == 0) {
      tabLength = data!.length ~/ 50;
    } else {
      tabLength = data!.length ~/ 50 + 1;
    }

    for (int i = 0; i < data!.length; i = i + 50) {
      if (i + 50 > data!.length) {
        ranges.add(
            "${data![i].memberId!} မှ ${data![data!.length - 1].memberId!}");
      } else {
        ranges.add("${data![i].memberId!} မှ ${data![i + 49].memberId!}");
      }
    }
    setState(() {
      dataFullLoad = true;
      dataSegments = data!.sublist(0, 50);
    });
  }

  ExpandableTable buildSimpleTable(List<MemberData> data) {
    const int COLUMN_COUNT = 7;
    int ROWCOUNT = data.length;
    List<String> titles = [
      "အမည်",
      "အဖအမည်",
      "သွေးအုပ်စု",
      "မှတ်ပုံတင်အမှတ်",
      "သွေးဘဏ်ကတ်",
      "သွေးလှူမှုကြိမ်ရေ"
    ];

    //Creation header
    ExpandableTableHeader header = ExpandableTableHeader(
        firstCell: Container(
            width: Responsive.isMobile(context) ? 80 : 120,
            color: primaryColor,
            height: 60,
            margin: const EdgeInsets.all(1),
            child: const Center(
                child: Text(
              'အမှတ်စဥ်',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ))),
        children: List.generate(
            COLUMN_COUNT - 1,
            (index) => Container(
                color: primaryColor,
                margin: const EdgeInsets.all(1),
                child: Center(
                    child: Text(
                  titles[index],
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 14 : 15,
                      color: Colors.white),
                )))));
    //Creation rows
    List<ExpandableTableRow> rows = List.generate(
        ROWCOUNT,
        (rowIndex) => ExpandableTableRow(
              height: 50,
              firstCell: Container(
                  color: const Color(0xffe1e1e1),
                  margin: const EdgeInsets.all(1),
                  child: Center(
                      child: Text(
                    data[rowIndex].memberId.toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ))),
              children: List<Widget>.generate(
                  COLUMN_COUNT - 1,
                  (columnIndex) => GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemberDetailScreen(
                                data: data[rowIndex],
                              ),
                            ),
                          );
                          callAPI("");
                        },
                        child: Container(
                            decoration: borderDecorationNoRadius(Colors.grey),
                            margin: const EdgeInsets.all(1),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: columnIndex == 4 ? 32 : 20.0, top: 14),
                              child: Text(
                                columnIndex == 0
                                    ? data[rowIndex].name.toString()
                                    : columnIndex == 1
                                        ? data[rowIndex].fatherName.toString()
                                        : columnIndex == 2
                                            ? data[rowIndex]
                                                .bloodType
                                                .toString()
                                            : columnIndex == 3
                                                ? data[rowIndex].nrc.toString()
                                                : columnIndex == 4
                                                    ? data[rowIndex]
                                                        .bloodBankCard
                                                        .toString()
                                                    : columnIndex == 5
                                                        ? data[rowIndex]
                                                            .donationCounts
                                                            .toString()
                                                            .toString()
                                                        : "",
                                textAlign: columnIndex == 5 || columnIndex == 2
                                    ? TextAlign.center
                                    : TextAlign.start,
                                style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 14 : 15,
                                    color: Colors.black),
                              ),
                            )),
                      )),
            ));

    return ExpandableTable(
      rows: rows,
      header: header,
      cellWidth: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.4
          : MediaQuery.of(context).size.width * 0.14,
      cellHeight: 48,
      headerHeight: 52,
      firstColumnWidth: Responsive.isMobile(context) ? 94 : 200,
      scrollShadowColor: Colors.grey,
    );
  }
}
