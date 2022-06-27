import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/data/response/member_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/member/member_detail.dart';
import 'package:merchant/src/features/member/new_member.dart';
import 'package:merchant/src/features/new_features/member/member_detail_new_style.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';

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
  List<MemberData> dataSegments = [];
  TextStyle tabStyle = const TextStyle(fontSize: 16);
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('member_count')
        .doc("member_string")
        .get()
        .then((value) {
      var members = value['members'];
      int tabLength = 0;
      setState(() {
        data = MemberListResponse.fromJson(jsonDecode(members)).data!;

        if (data!.length % 50 == 0) {
          tabLength = data!.length ~/ 50;
        } else {
          tabLength = data!.length ~/ 50 + 1;
        }

        for (int i = 0; i < data!.length; i = i + 50) {
          if (i + 50 > data!.length) {
            ranges.add(data![i].memberId! +
                " မှ " +
                data![data!.length - 1].memberId!);
          } else {
            ranges.add(data![i].memberId! + " မှ " + data![i + 49].memberId!);
          }
        }
        setState(() {
          dataSegments = data!.sublist(0, 50);
        });
      });
    });
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
                              hint: const Text(
                                "သွေးအုပ်စု အလိုက်ကြည့်မည်",
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
                                List<MemberData>? filterdata = [];
                                for (int i = 0; i < data!.length; i++) {
                                  //get memberdata from data only where bloodtype is equal to value
                                  if (data![i].bloodType == value) {
                                    filterdata.add(data![i]);
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
                              if (data![i].name!.contains(val)) {
                                filterdata.add(data![i]);
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
                          hint: const Text(
                            "သွေးအုပ်စု အလိုက်ကြည့်မည်",
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
                            List<MemberData>? filterdata = [];
                            for (int i = 0; i < data!.length; i++) {
                              //get memberdata from data only where bloodtype is equal to value
                              if (data![i].bloodType == value) {
                                filterdata.add(data![i]);
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
                              if (data![i].name!.contains(val)) {
                                filterdata.add(data![i]);
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
            Container(
              padding: EdgeInsets.only(
                  left: 20.0,
                  top: Responsive.isMobile(context) ? 160 : 100,
                  bottom: 12),
              child: buildSimpleTable(dataSegments),
            ),
          ],
        ),
      );
  final searchController = TextEditingController();
  final memberController = TextEditingController();
  List<String> membersSelected = <String>[];
  List<String> allMembers = <String>[];
  bool inputted = false;
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

  fetchMembers() async {
    FirebaseFirestore.instance
        .collection('member_count')
        .doc("member_string")
        .get()
        .then((value) {
      var members = value['members'];
      var data = MemberListResponse.fromJson(jsonDecode(members)).data!;
      for (var element in data) {
        setState(() {
          allMembers.add(element.name!);
        });
      }
    });
  }

  Widget header() {
    return Container(
      height: Responsive.isMobile(context) ? 48 : 60,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 2.4
          : MediaQuery.of(context).size.width - 40,
      margin: const EdgeInsets.only(left: 12, right: 20),
      padding: const EdgeInsets.only(left: 20, right: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Colors.deepOrange,
      ),
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 5
                    : MediaQuery.of(context).size.width / 12,
                child: Text(
                  "အမှတ်စဉ်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: Responsive.isMobile(context) ? 4 : 8,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 6.2,
                child: Text(
                  "အမည်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3.5
                    : MediaQuery.of(context).size.width / 8,
                child: Text(
                  "အဖအမည်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: Responsive.isMobile(context) ? 2 : 26,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 5
                    : MediaQuery.of(context).size.width / 9,
                child: Text(
                  "သွေးအုပ်စု",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 2.5
                    : MediaQuery.of(context).size.width / 7,
                child: Text(
                  "မှတ်ပုံတင်အမှတ်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3.5
                    : MediaQuery.of(context).size.width / 7,
                child: Text(
                  "သွေးဘဏ်ကတ်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 7,
                child: Text(
                  "သွေးလှူမှုကြိမ်ရေ",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget memberRow(MemberData data) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailNewStyleScreen(data: data),
          ),
        );
      },
      child: Container(
        height: Responsive.isMobile(context) ? 60 : 64,
        decoration: shadowDecoration(Colors.white),
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 2.4
            : MediaQuery.of(context).size.width - 40,
        margin: const EdgeInsets.only(top: 4, left: 12, right: 20),
        padding: const EdgeInsets.only(left: 18, right: 20),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: [
            Row(
              children: [
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 5
                      : MediaQuery.of(context).size.width / 10,
                  child: Text(
                    data.memberId ?? "-",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 2.8
                      : MediaQuery.of(context).size.width / 6.5,
                  child: Text(
                    data.name ?? "-",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 5
                      : MediaQuery.of(context).size.width / 8,
                  child: Text(
                    data.fatherName ?? "-",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: Responsive.isMobile(context) ? 4 : 0,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 4
                      : MediaQuery.of(context).size.width / 9,
                  child: Text(
                    data.bloodType ?? "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 2.5
                      : MediaQuery.of(context).size.width / 8,
                  child: Text(
                    data.nrc ?? "-",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: Responsive.isMobile(context) ? 18 : 54,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 3.5
                      : MediaQuery.of(context).size.width / 7,
                  child: Text(
                    data.bloodBankCard ?? "-",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: Responsive.isMobile(context) ? 12 : 0,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 3.5
                      : MediaQuery.of(context).size.width / 7,
                  child: Text(
                    data.totalCount != null
                        ? Utils.strToMM(data.totalCount!)
                        : "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget memberRow2(Map<String, dynamic> data) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailScreen(data: data),
          ),
        );
      },
      child: Container(
        height: Responsive.isMobile(context) ? 98 : 102,
        decoration: shadowDecoration(Colors.white),
        margin: const EdgeInsets.only(top: 4, left: 12, right: 20),
        padding: const EdgeInsets.only(left: 18, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 12.0, bottom: 8, left: 6, right: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data['member_id'] ?? "-",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    data['total_count'] != null
                        ? Utils.strToMM(data['total_count']) + " ကြိမ်"
                        : "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                data['name'] ?? "-",
                                style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 15 : 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "( အဖ - " + data['father_name'] + ")",
                                style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 14 : 16,
                                    color: Colors.black),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          data['nrc'] ?? "-",
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 14 : 16,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          data['blood_type'] ?? "-",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 15 : 17,
                              color: Colors.red),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          data['blood_bank_card'] ?? "-",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 14 : 16,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                  (columnIndex) => Container(
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
                                      ? data[rowIndex].bloodType.toString()
                                      : columnIndex == 3
                                          ? data[rowIndex].nrc.toString()
                                          : columnIndex == 4
                                              ? data[rowIndex]
                                                  .bloodBankCard
                                                  .toString()
                                              : columnIndex == 5
                                                  ? data[rowIndex]
                                                      .memberCount
                                                      .toString()
                                                  : "",
                          textAlign: columnIndex == 5 || columnIndex == 2
                              ? TextAlign.center
                              : TextAlign.start,
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 14 : 15,
                              color: Colors.black),
                        ),
                      ))),
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
