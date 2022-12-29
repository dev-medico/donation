import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/donation_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/donation/blood_donation_report.dart';
import 'package:merchant/src/features/donation/new_blood_donation.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';
import 'package:tab_container/tab_container.dart';

class BloodDonationListNewStyle extends StatefulWidget {
  static const routeName = "/new_blood_donation_list";

  const BloodDonationListNewStyle({Key? key}) : super(key: key);

  @override
  _BloodDonationListNewStyleState createState() =>
      _BloodDonationListNewStyleState();
}

class _BloodDonationListNewStyleState extends State<BloodDonationListNewStyle>
    with SingleTickerProviderStateMixin {
  late TextTheme textTheme;
  List<String> ranges = [
    "2022",
    "2021",
    "2020",
    "2019",
    "2018",
    "2017",
    "2016",
    "2015",
    "2014",
    "2013",
    "2012",
  ];
  List<bool> rangesSelect = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  String selectedYear = "2022";
  List<String> months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];

  List<String> monthsMobile = [
    "01",
    "02",
    "03",
    "04",
    "05",
    "06",
    "07",
    "08",
    "09",
    "10",
    "11",
    "12",
  ];
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
  List<DonationData> dataSegments1 = [];
  List<DonationData> dataSegments2 = [];
  List<DonationData> dataSegments3 = [];
  List<DonationData> dataSegments4 = [];
  List<DonationData> dataSegments5 = [];
  List<DonationData> dataSegments6 = [];
  List<DonationData> dataSegments7 = [];
  List<DonationData> dataSegments8 = [];
  List<DonationData> dataSegments9 = [];
  List<DonationData> dataSegments10 = [];
  List<DonationData> dataSegments11 = [];
  List<DonationData> dataSegments12 = [];
  TextStyle tabStyle = const TextStyle(fontSize: 16);
  TabContainerController controller = TabContainerController(length: 12);

  @override
  void didChangeDependencies() {
    textTheme = Theme.of(context).textTheme;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('member_count')
        .doc("donation_string")
        .get()
        .then((value) {
      var members = value['donations'];
      setState(() {
        data = DonationListResponse.fromJson(jsonDecode(members)).data!;

        sortBySegments();
      });
    });
  }

  tabCreate() => Scaffold(
        backgroundColor: Colors.white70,
        body: Stack(
          children: [
            ListView(
              children: [
                Visibility(
                  visible: Responsive.isMobile(context),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0))),
                      margin:
                          const EdgeInsets.only(left: 15, top: 12, right: 30),
                      width: 120,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          int selectedMonth = controller.index;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder:
                                      (context) => BloodDonationReportScreen(
                                            month: selectedMonth,
                                            year: selectedYear,
                                            data: selectedMonth == 0
                                                ? dataSegments1
                                                : selectedMonth == 1
                                                    ? dataSegments2
                                                    : selectedMonth == 2
                                                        ? dataSegments3
                                                        : selectedMonth == 3
                                                            ? dataSegments4
                                                            : selectedMonth == 4
                                                                ? dataSegments5
                                                                : selectedMonth ==
                                                                        5
                                                                    ? dataSegments6
                                                                    : selectedMonth ==
                                                                            6
                                                                        ? dataSegments7
                                                                        : selectedMonth ==
                                                                                7
                                                                            ? dataSegments8
                                                                            : selectedMonth == 8
                                                                                ? dataSegments9
                                                                                : selectedMonth == 9
                                                                                    ? dataSegments10
                                                                                    : selectedMonth == 10
                                                                                        ? dataSegments11
                                                                                        : dataSegments12,
                                          )));
                        },
                        child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(Icons.list_alt_outlined,
                                    color: Colors.white),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 12, bottom: 12, left: 12),
                                    child: Text(
                                      "Report",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                    )),
                              ],
                            )),
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 20, right: 20),
                      height: 50,
                      width: double.infinity,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(0.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: ranges.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                rangesSelect.clear();
                                rangesSelect.addAll([
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false
                                ]);
                                rangesSelect[index] = true;
                                selectedYear = ranges[index];
                              });
                              sortBySegments();
                            },
                            child: Container(
                              width: Responsive.isMobile(context)
                                  ? MediaQuery.of(context).size.width / 5
                                  : MediaQuery.of(context).size.width / 13,
                              height: 50,
                              decoration: shadowDecorationOnlyTop(
                                  rangesSelect[index]
                                      ? Colors.red.withOpacity(0.6)
                                      : const Color(0xffe3e3e3)),
                              child: Center(
                                  child: Text(
                                ranges[index],
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: rangesSelect[index]
                                        ? Colors.white
                                        : primaryColor),
                              )),
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(
                      visible: !Responsive.isMobile(context),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0))),
                          margin: const EdgeInsets.only(
                              left: 15, top: 24, right: 30),
                          width: 120,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              int selectedMonth = controller.index;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BloodDonationReportScreen(
                                            month: selectedMonth,
                                            year: selectedYear,
                                            data: selectedMonth == 0
                                                ? dataSegments1
                                                : selectedMonth == 1
                                                    ? dataSegments2
                                                    : selectedMonth == 2
                                                        ? dataSegments3
                                                        : selectedMonth == 3
                                                            ? dataSegments4
                                                            : selectedMonth == 4
                                                                ? dataSegments5
                                                                : selectedMonth ==
                                                                        5
                                                                    ? dataSegments6
                                                                    : selectedMonth ==
                                                                            6
                                                                        ? dataSegments7
                                                                        : selectedMonth ==
                                                                                7
                                                                            ? dataSegments8
                                                                            : selectedMonth == 8
                                                                                ? dataSegments9
                                                                                : selectedMonth == 9
                                                                                    ? dataSegments10
                                                                                    : selectedMonth == 10
                                                                                        ? dataSegments11
                                                                                        : dataSegments12,
                                          )));
                            },
                            child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Icon(Icons.list_alt_outlined,
                                        color: Colors.white),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 12, bottom: 12, left: 12),
                                        child: Text(
                                          "Report",
                                          textScaleFactor: 1.0,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              color: Colors.white),
                                        )),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 2),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.81,
                  child: TabContainer(
                    controller: controller,
                    color: const Color(0xffe3e3e3),
                    radius: 8,
                    tabEdge: TabEdge.top,
                    tabCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      animation = CurvedAnimation(
                          curve: Curves.easeIn, parent: animation);
                      return SlideTransition(
                        position: Tween(
                          begin: const Offset(0.2, 0.0),
                          end: const Offset(0.0, 0.0),
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    selectedTextStyle: TextStyle(
                        fontSize: 15,
                        color: primaryColor,
                        fontWeight: FontWeight.bold),
                    unselectedTextStyle:
                        const TextStyle(fontSize: 14, color: Colors.black),
                    tabs: Responsive.isMobile(context) ? monthsMobile : months,
                    children: [
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments1),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments2),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments3),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments4),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments5),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments6),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments7),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments8),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments9),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments10),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments11),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  final searchController = TextEditingController();
  final memberController = TextEditingController();
  List<String> membersSelected = <String>[];
  List<String> allMembers = <String>[];
  bool inputted = false;
  List<DonationData>? data;

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
          child: Text("သွေးလှူဒါန်းမှုစာရင်း",
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
              builder: (context) => NewBloodDonationScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  sortBySegments() {
    List<DonationData> filterData1 = [];
    List<DonationData> filterData2 = [];
    List<DonationData> filterData3 = [];
    List<DonationData> filterData4 = [];
    List<DonationData> filterData5 = [];
    List<DonationData> filterData6 = [];
    List<DonationData> filterData7 = [];
    List<DonationData> filterData8 = [];
    List<DonationData> filterData9 = [];
    List<DonationData> filterData10 = [];
    List<DonationData> filterData11 = [];
    List<DonationData> filterData12 = [];
    for (int i = 0; i < data!.length; i++) {
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Jan") {
        filterData1.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Feb") {
        filterData2.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Mar") {
        filterData3.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Apr") {
        filterData4.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "May") {
        filterData5.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Jun") {
        filterData6.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Jul") {
        filterData7.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Aug") {
        filterData8.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Sep") {
        filterData9.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Oct") {
        filterData10.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Nov") {
        filterData11.add(data![i]);
      }
      if (data![i].date!.split(" ")[2] == selectedYear &&
          data![i].date!.split(" ")[1] == "Dec") {
        filterData12.add(data![i]);
      }
    }
    filterData1.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData1 = filterData1.reversed.toList();
    filterData2.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData2 = filterData2.reversed.toList();
    filterData3.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData3 = filterData3.reversed.toList();
    filterData4.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData4 = filterData4.reversed.toList();
    filterData5.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData5 = filterData5.reversed.toList();
    filterData6.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData6 = filterData6.reversed.toList();
    filterData7.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData7 = filterData7.reversed.toList();
    filterData8.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData8 = filterData8.reversed.toList();
    filterData9.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData9 = filterData9.reversed.toList();
    filterData10.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData10 = filterData10.reversed.toList();
    filterData11.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData11 = filterData11.reversed.toList();
    filterData12.sort((a, b) {
      return DateTime.parse(b.dateDetail == null
              ? "2020-01-01"
              : b.dateDetail.toString().split("T")[0])
          .compareTo(DateTime.parse(a.dateDetail == null
              ? "2020-01-01"
              : a.dateDetail.toString().split("T")[0]));
    });
    filterData12 = filterData12.reversed.toList();

    setState(() {
      dataSegments1 = filterData1;
      dataSegments2 = filterData2;
      dataSegments3 = filterData3;
      dataSegments4 = filterData4;
      dataSegments5 = filterData5;
      dataSegments6 = filterData6;
      dataSegments7 = filterData7;
      dataSegments8 = filterData8;
      dataSegments9 = filterData9;
      dataSegments10 = filterData10;
      dataSegments11 = filterData11;
      dataSegments12 = filterData12;
    });
  }

  fetchMembers() async {
    FirebaseFirestore.instance
        .collection('member_count')
        .doc("donation_string")
        .get()
        .then((value) {
      var members = value['donations'];
      var data = DonationListResponse.fromJson(jsonDecode(members)).data!;

      for (var element in data) {
        setState(() {
          allMembers.add(element.memberName!);
        });
      }
      allMembers.sort((a, b) => b.compareTo(a));
    });
  }

  ExpandableTable buildSimpleTable(List<DonationData> data) {
    const int COLUMN_COUNT = 8;
    int ROWCOUNT = data.length;
    List<String> titles = [
      "သွေးအလှူရှင်",
      "သွေးအုပ်စု",
      "လှူဒါန်းသည့်နေရာ",
      "လူနာအမည်",
      "လိပ်စာ",
      "အသက်",
      "ဖြစ်ပွားသည့်ရောဂါ"
    ];

    ExpandableTableHeader header = ExpandableTableHeader(
        firstCell: Container(
            width: Responsive.isMobile(context) ? 90 : 120,
            color: primaryColor,
            height: 60,
            margin: const EdgeInsets.all(1),
            child: const Center(
                child: Text(
              'ရက်စွဲ',
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

    List<ExpandableTableRow> rows = List.generate(
        ROWCOUNT,
        (rowIndex) => ExpandableTableRow(
              height: 50,
              firstCell: Container(
                  color: const Color(0xffe1e1e1),
                  margin: const EdgeInsets.all(1),
                  child: Center(
                      child: Text(
                    data[rowIndex].date.toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ))),
              children: List<Widget>.generate(
                  COLUMN_COUNT - 1,
                  (columnIndex) => Container(
                      decoration: borderDecorationNoRadius(Colors.grey),
                      margin: const EdgeInsets.all(1),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: columnIndex == 4 ? 12 : 20.0,
                            top: columnIndex == 4 ? 4 : 14),
                        child: Text(
                          columnIndex == 0
                              ? data[rowIndex].memberName.toString()
                              : columnIndex == 1
                                  ? data[rowIndex].memberBloodType.toString()
                                  : columnIndex == 2
                                      ? data[rowIndex].hospital.toString()
                                      : columnIndex == 3
                                          ? data[rowIndex]
                                              .patientName
                                              .toString()
                                          : columnIndex == 4
                                              ? data[rowIndex]
                                                  .patientAddress
                                                  .toString()
                                              : columnIndex == 5
                                                  ? Utils.strToMM(data[rowIndex]
                                                      .patientAge
                                                      .toString())
                                                  : columnIndex == 6
                                                      ? data[rowIndex]
                                                          .patientDisease
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
          : MediaQuery.of(context).size.width * 0.115,
      cellHeight: 52,
      headerHeight: 52,
      firstColumnWidth: Responsive.isMobile(context) ? 94 : 200,
      scrollShadowColor: Colors.grey,
    );
  }
}
