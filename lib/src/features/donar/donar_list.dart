import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/donar/new_donar.dart';
import 'package:merchant/src/features/donar/new_expense.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';
import 'package:tab_container/tab_container.dart';
import 'package:intl/intl.dart';

class DonarList extends StatefulWidget {
  static const routeName = "/donar_list";

  @override
  _DonarListState createState() => _DonarListState();
}

class _DonarListState extends State<DonarList> {
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
  int totalExpense = 0;

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

  List<Map<String, dynamic>> dataSegments1 = [];
  List<Map<String, dynamic>> dataSegments2 = [];
  List<Map<String, dynamic>> dataSegments3 = [];
  List<Map<String, dynamic>> dataSegments4 = [];
  List<Map<String, dynamic>> dataSegments5 = [];
  List<Map<String, dynamic>> dataSegments6 = [];
  List<Map<String, dynamic>> dataSegments7 = [];
  List<Map<String, dynamic>> dataSegments8 = [];
  List<Map<String, dynamic>> dataSegments9 = [];
  List<Map<String, dynamic>> dataSegments10 = [];
  List<Map<String, dynamic>> dataSegments11 = [];
  List<Map<String, dynamic>> dataSegments12 = [];
  String dataMonth = "";

  TabContainerController controller = TabContainerController(length: 12);

  List<Map<String, dynamic>> data = [];

  tabCreate() => Scaffold(
        backgroundColor: const Color.fromARGB(255, 254, 252, 231),
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
                      width: Responsive.isMobile(context) ? 145 : 120,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewExpense(),
                            ),
                          );
                          initial();
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
                                      "Add Expense",
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
                          margin: const EdgeInsets.only(top: 24, right: 10),
                          width: 140,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewExpense(),
                                ),
                              );
                              initial();
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
                                            top: 12,
                                            bottom: 12,
                                            left: 8,
                                            right: 4),
                                        child: Text(
                                          "Add Expense",
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
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments1, 0),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments2, 1),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments3, 2),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments4, 3),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments5, 4),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments6, 5),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments7, 6),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments8, 7),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments9, 8),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments10, 9),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments11, 10),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: EdgeInsets.only(
                              left: 0.0,
                              top: Responsive.isMobile(context) ? 20 : 0,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments12, 11),
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

  @override
  void initState() {
    super.initState();
    initial();
  }

  initial() async {
    CollectionReference donars =
        FirebaseFirestore.instance.collection('donors');
    donars.get().then((value) {
      for (var element in value.docs) {
        print(element.data());
        final dataAdd = element.data() as Map<String, dynamic>;
        setState(() {
          data.add(dataAdd);
        });
      }
      sortBySegments();
    });
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 252, 231),
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryDark],
        ))),
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text("ရ/သုံး ငွေစာရင်း",
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      ),
      body: data.isNotEmpty
          ? tabCreate()
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewDonarScreen(),
              ),
            );
            initial();
          },
          child: const Icon(Icons.add)),
    );
  }

  sortBySegments() {
    List<Map<String, dynamic>> filterData1 = [];
    List<Map<String, dynamic>> filterData2 = [];
    List<Map<String, dynamic>> filterData3 = [];
    List<Map<String, dynamic>> filterData4 = [];
    List<Map<String, dynamic>> filterData5 = [];
    List<Map<String, dynamic>> filterData6 = [];
    List<Map<String, dynamic>> filterData7 = [];
    List<Map<String, dynamic>> filterData8 = [];
    List<Map<String, dynamic>> filterData9 = [];
    List<Map<String, dynamic>> filterData10 = [];
    List<Map<String, dynamic>> filterData11 = [];
    List<Map<String, dynamic>> filterData12 = [];
    for (int i = 0; i < data.length; i++) {
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Jan") {
        filterData1.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Feb") {
        filterData2.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Mar") {
        filterData3.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Apr") {
        filterData4.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "May") {
        filterData5.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Jun") {
        filterData6.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Jul") {
        filterData7.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Aug") {
        filterData8.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Sep") {
        filterData9.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Oct") {
        filterData10.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Nov") {
        filterData11.add(data[i]);
      }
      if (data[i]['date'].split(" ")[2] == selectedYear &&
          data[i]['date'].split(" ")[1] == "Dec") {
        filterData12.add(data[i]);
      }

      setState(() {
        dataMonth =
            data[i]['date'].split(" ")[1] + " " + data[i]['date'].split(" ")[2];
      });
    }

    filterData1 = filterData1.reversed.toList();

    filterData2 = filterData2.reversed.toList();

    filterData3 = filterData3.reversed.toList();

    filterData4 = filterData4.reversed.toList();

    filterData5 = filterData5.reversed.toList();

    filterData6 = filterData6.reversed.toList();

    filterData7 = filterData7.reversed.toList();

    filterData8 = filterData8.reversed.toList();

    filterData9 = filterData9.reversed.toList();

    filterData10 = filterData10.reversed.toList();

    filterData11 = filterData11.reversed.toList();

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

  buildSimpleTable(List<Map<String, dynamic>> data, int month) {
    const int COLUMN_COUNT = 3;
    int ROWCOUNT = data.length;
    int totalDonation = 0;
    for (var element in data) {
      totalDonation += int.parse(element['amount']);
    }

    List<String> titles = ["အမည်", "အလှူငွေ"];

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
                      fontSize: Responsive.isMobile(context) ? 13 : 14,
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
                    data[rowIndex]["date"].toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ))),
              children: List<Widget>.generate(
                  COLUMN_COUNT - 1,
                  (columnIndex) => Container(
                      decoration: borderDecorationNoRadius(Colors.grey),
                      margin: const EdgeInsets.all(1),
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: 12,
                            left: columnIndex == 4 ? 12 : 20.0,
                            top: columnIndex == 4 ? 4 : 14),
                        child: Text(
                          columnIndex == 0
                              ? data[rowIndex]["name"].toString()
                              : columnIndex == 1
                                  ? data[rowIndex]["amount"].toString()
                                  : "",
                          textAlign: columnIndex == 5 || columnIndex == 1
                              ? TextAlign.right
                              : TextAlign.start,
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 13 : 14,
                              color: Colors.black),
                        ),
                      ))),
            ));

    if (Responsive.isMobile(context)) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ExpandableTable(
              rows: rows,
              header: header,
              cellWidth: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.18,
              cellHeight: 52,
              headerHeight: 52,
              firstColumnWidth: Responsive.isMobile(context) ? 94 : 180,
              scrollShadowColor: Colors.grey,
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Container(
                decoration: shadowDecoration(Colors.white),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(
                  top: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            log("Select - "
                                "${convertToMonthName(controller.index)} $selectedYear");
                            FirebaseFirestore.instance
                                .collection('expenses')
                                .where('date',
                                    isEqualTo:
                                        "${convertToMonthName(controller.index)} $selectedYear")
                                .get()
                                .then((value) {
                              if (value.docs.isNotEmpty) {
                                Map<String, dynamic> data =
                                    value.docs.first.data();
                                setState(() {
                                  totalExpense = int.parse(data['amount']);
                                });
                              } else {
                                Utils.messageDialog("ဒေတာအချက်အလက် မရှိသေးပါ။",
                                    context, "အိုကေ", Colors.black);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0))),
                            width: 170,
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(Icons.calculate_outlined,
                                    color: Colors.white),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 12, bottom: 12, left: 12),
                                    child: Text(
                                      "Calculate",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                    )),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 24,
                    ),
                    Responsive.isMobile(context)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ယခုလ အလှူငွေ စုစုပေါင်း ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: NeumorphicTheme.of(context)
                                        ?.current!
                                        .variantColor),
                              ),
                              Text(
                                "${Utils.strToMM(totalDonation.toString())} ကျပ်",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: NeumorphicTheme.of(context)
                                        ?.current!
                                        .variantColor),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Text(
                                "ယခုလ အလှူငွေ စုစုပေါင်း ",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: NeumorphicTheme.of(context)
                                        ?.current!
                                        .variantColor),
                              ),
                              Text(
                                "${Utils.strToMM(totalDonation.toString())} ကျပ်",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: NeumorphicTheme.of(context)
                                        ?.current!
                                        .variantColor),
                              ),
                            ],
                          ),
                    const SizedBox(
                      height: 12,
                    ),
                    Visibility(
                      visible: totalExpense != 0,
                      child: Responsive.isMobile(context)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ယခုလ အသုံးစာရင်း စုစုပေါင်း   -   ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  "${Utils.strToMM(totalExpense.toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Text(
                                  "ယခုလ အသုံးစာရင်း စုစုပေါင်း   -   ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  "${Utils.strToMM(totalExpense.toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    Visibility(
                      visible: totalExpense != 0,
                      child: const SizedBox(
                        height: 12,
                      ),
                    ),
                    Visibility(
                      visible: totalExpense != 0,
                      child: Responsive.isMobile(context)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ယခုလ ကျန်ရှိငွေ စုစုပေါင်း",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  "${Utils.strToMM((totalDonation - totalExpense).toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: (totalDonation - totalExpense)
                                              .isNegative
                                          ? Colors.red
                                          : Colors.green),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Text(
                                  "ယခုလ ကျန်ရှိငွေ စုစုပေါင်း        -   ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  "${Utils.strToMM((totalDonation - totalExpense).toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: (totalDonation - totalExpense)
                                              .isNegative
                                          ? Colors.red
                                          : Colors.green),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ))
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: ExpandableTable(
              rows: rows,
              header: header,
              cellWidth: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.4
                  : MediaQuery.of(context).size.width * 0.18,
              cellHeight: 52,
              headerHeight: 52,
              firstColumnWidth: Responsive.isMobile(context) ? 94 : 180,
              scrollShadowColor: Colors.grey,
            ),
          ),
          Expanded(
              child: Container(
            decoration: shadowDecoration(Colors.white),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(left: 30),
            child: Column(
              children: [
                const SizedBox(
                  height: 24,
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        log("Select - "
                            "${convertToMonthName(controller.index)} $selectedYear");
                        FirebaseFirestore.instance
                            .collection('expenses')
                            .where('date',
                                isEqualTo:
                                    "${convertToMonthName(controller.index)} $selectedYear")
                            .get()
                            .then((value) {
                          if (value.docs.isNotEmpty) {
                            Map<String, dynamic> data = value.docs.first.data();
                            setState(() {
                              totalExpense = int.parse(data['amount']);
                            });
                          } else {
                            Utils.messageDialog("ဒေတာအချက်အလက် မရှိသေးပါ။",
                                context, "အိုကေ", Colors.black);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12.0))),
                        width: 170,
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 12,
                            ),
                            Icon(Icons.calculate_outlined, color: Colors.white),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 12, bottom: 12, left: 12),
                                child: Text(
                                  "Calculate",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.white),
                                )),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  children: [
                    Text(
                      "ယခုလ အလှူငွေ စုစုပေါင်း           -   ",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicTheme.of(context)
                              ?.current!
                              .variantColor),
                    ),
                    Text(
                      "${Utils.strToMM(totalDonation.toString())} ကျပ်",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NeumorphicTheme.of(context)
                              ?.current!
                              .variantColor),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Visibility(
                  visible: totalExpense != 0,
                  child: Row(
                    children: [
                      Text(
                        "ယခုလ အသုံးစာရင်း စုစုပေါင်း   -   ",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: NeumorphicTheme.of(context)
                                ?.current!
                                .variantColor),
                      ),
                      Text(
                        "${Utils.strToMM(totalExpense.toString())} ကျပ်",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: NeumorphicTheme.of(context)
                                ?.current!
                                .variantColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Visibility(
                  visible: totalExpense != 0,
                  child: const SizedBox(
                    height: 12,
                  ),
                ),
                Visibility(
                  visible: totalExpense != 0,
                  child: Row(
                    children: [
                      Text(
                        "ယခုလ ကျန်ရှိငွေ စုစုပေါင်း        -   ",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: NeumorphicTheme.of(context)
                                ?.current!
                                .variantColor),
                      ),
                      Text(
                        "${Utils.strToMM((totalDonation - totalExpense).toString())} ကျပ်",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: (totalDonation - totalExpense).isNegative
                                ? Colors.red
                                : Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ))
        ],
      );
    }
  }

  convertToMonthName(int month) {
    //convert month index int to  name with Format "MMM"
    return DateFormat("MMM").format(DateTime(2021, month + 1, 1));
  }
}
