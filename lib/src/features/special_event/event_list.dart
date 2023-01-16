import 'dart:convert';
import 'dart:developer';

import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/data/repository/repository.dart';
import 'package:merchant/data/response/special_event_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/special_event/edit_special_event.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';
import 'package:tab_container/tab_container.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class EventListScreen extends StatefulWidget {
  static const routeName = "/event_list";

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<String> ranges = [
    "2023",
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
    false,
  ];
  String selectedYear = "2023";
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

  List<SpecialEventData> dataSegments1 = [];
  List<SpecialEventData> dataSegments2 = [];
  List<SpecialEventData> dataSegments3 = [];
  List<SpecialEventData> dataSegments4 = [];
  List<SpecialEventData> dataSegments5 = [];
  List<SpecialEventData> dataSegments6 = [];
  List<SpecialEventData> dataSegments7 = [];
  List<SpecialEventData> dataSegments8 = [];
  List<SpecialEventData> dataSegments9 = [];
  List<SpecialEventData> dataSegments10 = [];
  List<SpecialEventData> dataSegments11 = [];
  List<SpecialEventData> dataSegments12 = [];

  String dataMonth = "";
  String expensedataMonth = "";
  bool dataFullLoaded = false;

  TabContainerController controller = TabContainerController(length: 12);

  List<SpecialEventData> data = [];

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
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.only(top: 20, right: 12),
                      child: GestureDetector(
                        onTap: () {
                          goToYearlyReport();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0))),
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
                                    "နှစ်ချုပ်စာရင်း",
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.white),
                                  )),
                            ],
                          ),
                        ),
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
                                  : MediaQuery.of(context).size.width / 14,
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
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.only(top: 20, right: 12),
                          child: GestureDetector(
                            onTap: () {
                              goToYearlyReport();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0))),
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
                                        "နှစ်ချုပ်စာရင်း",
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white),
                                      )),
                                ],
                              ),
                            ),
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
                          child: buildSimpleTable(
                            dataSegments1,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments2,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments3,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments4,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments5,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments6,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments7,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments8,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments9,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments10,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments11,
                          ),
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
                          child: buildSimpleTable(
                            dataSegments12,
                          ),
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

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  goToYearlyReport() {
    List<int> monthlyDonation = [];

    int janDonation = 0;
    for (var element in dataSegments1) {
      janDonation += element.total ?? 0;
    }

    int febDonation = 0;
    for (var element in dataSegments2) {
      febDonation += element.total ?? 0;
    }

    int marDonation = 0;
    for (var element in dataSegments3) {
      marDonation += element.total ?? 0;
    }

    int aprDonation = 0;
    for (var element in dataSegments4) {
      aprDonation += element.total ?? 0;
    }

    int mayDonation = 0;
    for (var element in dataSegments5) {
      mayDonation += element.total ?? 0;
    }

    int junDonation = 0;
    for (var element in dataSegments6) {
      junDonation += element.total ?? 0;
    }

    int julDonation = 0;
    for (var element in dataSegments7) {
      julDonation += element.total ?? 0;
    }

    int augDonation = 0;
    for (var element in dataSegments8) {
      augDonation += element.total ?? 0;
    }

    int sepDonation = 0;
    for (var element in dataSegments9) {
      sepDonation += element.total ?? 0;
    }

    int octDonation = 0;
    for (var element in dataSegments10) {
      octDonation += element.total ?? 0;
    }

    int novDonation = 0;
    for (var element in dataSegments11) {
      novDonation += element.total ?? 0;
    }

    int decDonation = 0;
    for (var element in dataSegments12) {
      decDonation += element.total ?? 0;
    }

    monthlyDonation.addAll([
      janDonation,
      febDonation,
      marDonation,
      aprDonation,
      mayDonation,
      junDonation,
      julDonation,
      augDonation,
      sepDonation,
      octDonation,
      novDonation,
      decDonation
    ]);
  }

  @override
  void initState() {
    super.initState();
    callAPI("");
  }

  callAPI(String after) {
    if (after.isEmpty) {
      setState(() {
        data = [];
      });
    }
    XataRepository().getEventsList(after).then((response) {
      logger.i(response.body);

      setState(() {
        data.addAll(SpecialEventListResponse.fromJson(jsonDecode(response.body))
            .specialEventData!);
      });

      if (SpecialEventListResponse.fromJson(jsonDecode(response.body))
              .meta!
              .page!
              .more ??
          false) {
        callAPI(SpecialEventListResponse.fromJson(jsonDecode(response.body))
            .meta!
            .page!
            .cursor!);
      } else {
        setState(() {
          dataFullLoaded = true;
        });
        sortBySegments();
        log("Data Full");
      }
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
          child: Text("ထူးခြားဖြစ်စဥ်များ",
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      ),
      body: dataFullLoaded
          ? tabCreate()
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  sortBySegments() {
    List<SpecialEventData> filterData1 = [];
    List<SpecialEventData> filterData2 = [];
    List<SpecialEventData> filterData3 = [];
    List<SpecialEventData> filterData4 = [];
    List<SpecialEventData> filterData5 = [];
    List<SpecialEventData> filterData6 = [];
    List<SpecialEventData> filterData7 = [];
    List<SpecialEventData> filterData8 = [];
    List<SpecialEventData> filterData9 = [];
    List<SpecialEventData> filterData10 = [];
    List<SpecialEventData> filterData11 = [];
    List<SpecialEventData> filterData12 = [];

    for (int i = 0; i < data.length; i++) {
      var tempDate =
          "${data[i].date!.split(" ")[1]} ${data[i].date!.split(" ")[2]}";
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Jan") {
        filterData1.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Feb") {
        filterData2.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Mar") {
        filterData3.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Apr") {
        filterData4.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "May") {
        filterData5.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Jun") {
        filterData6.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Jul") {
        filterData7.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Aug") {
        filterData8.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Sep") {
        filterData9.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Oct") {
        filterData10.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Nov") {
        filterData11.add(data[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Dec") {
        filterData12.add(data[i]);
      }

      setState(() {
        dataMonth = "${tempDate.split(" ")[0]} ${tempDate.split(" ")[1]}";
      });
    }

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

  YYDialog confirmDeleteDialog(String title, String msg, BuildContext context,
      String buttonMsg, Color color, Function onTap) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.8
          : MediaQuery.of(context).size.width * 0.3
      ..backgroundColor = Colors.white
      ..borderRadius = 10.0
      ..barrierColor = const Color(0xDD000000)
      ..showCallBack = () {
        debugPrint("showCallBack invoke");
      }
      ..dismissCallBack = () {
        debugPrint("dismissCallBack invoke");
      }
      ..widget(Container(
        color: Colors.red,
        padding: const EdgeInsets.only(top: 8),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, left: 20, bottom: 12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      right: 12,
                      bottom: 12,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ))
      ..widget(Padding(
        padding: EdgeInsets.only(
            top: Responsive.isMobile(context) ? 26 : 42, bottom: 26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 8,
                right: 18,
              ),
              child: Image.asset(
                'assets/images/question_mark.png',
                height: 56,
                width: 56,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 12,
                right: 20,
              ),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ))
      ..widget(Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              child: Container(
                decoration:
                    shadowDecorationWithBorder(Colors.white, Colors.black),
                height: 50,
                width: 120,
                margin: EdgeInsets.only(
                  left: 20,
                  bottom: 30,
                  right: Responsive.isMobile(context) ? 12 : 20,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "မလုပ်တော့ပါ",
                    textScaleFactor: 1.0,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: Responsive.isMobile(context) ? 12 : 14),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                onTap.call();
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              child: Container(
                decoration: shadowDecoration(const Color(0xffFF5F17)),
                height: 50,
                width: 120,
                margin: EdgeInsets.only(
                  bottom: 30,
                  right: Responsive.isMobile(context) ? 12 : 30,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "ဖျက်မည်",
                    textScaleFactor: 1.0,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.isMobile(context) ? 12 : 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }

  ExpandableTable buildSimpleTable(List<SpecialEventData> data) {
    const int COLUMN_COUNT = 11;
    int ROWCOUNT = data.length;
    List<String> titles = [
      "ရက်စွဲ",
      "Retro Test\n ခုခံအားကျဆင်းမှု ကူးစက်ရောဂါ",
      "Hbs Ag\n အသည်းရောင် အသားဝါ(ဘီ)ပိုး",
      "HCV Ab\n အသည်းရောင် အသားဝါ(စီ)ပိုး",
      "VDRL Test\n ကာလသားရောဂါ",
      "M.P ( I.C.T )\n ငှက်ဖျားရောဂါ",
      "Haemoglobin ( Hb% )\n သွေးအားရာခိုင်နှုန်း",
      "Lab Name\n ဓါတ်ခွဲခန်းအမည်",
      "Total\n စုစုပေါင်း",
      "လုပ်ဆောင်ချက်"
    ];

    ExpandableTableHeader header = ExpandableTableHeader(
        firstCell: Container(
            width: 26,
            color: primaryColor,
            height: 74,
            margin: const EdgeInsets.all(1),
            child: const Center(
                child: Text(
              'စဥ်',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ))),
        children: List.generate(
            COLUMN_COUNT - 1,
            (index) => Container(
                color: primaryColor,
                height: 74,
                margin: const EdgeInsets.all(1),
                child: Center(
                    child: Text(
                  titles[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 13 : 15,
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
                    Utils.strToMM((rowIndex + 1).toString()),
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
                                  builder: (context) => EditSpecialEventScreen(
                                        event: data[rowIndex],
                                      )));
                          callAPI("");
                        },
                        child: columnIndex == 9
                            ? Container(
                                decoration:
                                    borderDecorationNoRadius(Colors.grey),
                                margin: const EdgeInsets.all(1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                        ),
                                        onPressed: () async {
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditSpecialEventScreen(
                                                        event: data[rowIndex],
                                                      )));
                                          callAPI("");
                                        }),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          confirmDeleteDialog(
                                              "ဖျက်မည်မှာ သေချာပါသလား?",
                                              "ထူးခြားဖြစ်စဥ်အား ဖျက်မည်မှာ \nသေချာပါသလား?",
                                              context,
                                              "အိုကေ",
                                              Colors.black, () {
                                            XataRepository()
                                                .deleteSpecialEventByID(
                                              data[rowIndex].id.toString(),
                                            )
                                                .then((value) {
                                              if (value.statusCode
                                                  .toString()
                                                  .startsWith("2")) {
                                                Utils.messageSuccessNoPopDialog(
                                                    "ထူးခြားဖြစ်စဥ် ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
                                                    context,
                                                    "အိုကေ",
                                                    Colors.black);
                                                callAPI("");
                                              }
                                            });
                                          });
                                        }),
                                  ],
                                ),
                              )
                            : Container(
                                decoration:
                                    borderDecorationNoRadius(Colors.grey),
                                margin: const EdgeInsets.all(1),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, top: 14),
                                  child: Text(
                                    columnIndex == 0
                                        ? data[rowIndex].date.toString()
                                        : columnIndex == 1
                                            ? data[rowIndex].retroTest == 0
                                                ? "-"
                                                : Utils.strToMM(data[rowIndex]
                                                    .retroTest
                                                    .toString())
                                            : columnIndex == 2
                                                ? data[rowIndex].hbsAg == 0
                                                    ? "-"
                                                    : Utils.strToMM(
                                                        data[rowIndex]
                                                            .hbsAg
                                                            .toString())
                                                : columnIndex == 3
                                                    ? data[rowIndex].hcvAb == 0
                                                        ? "-"
                                                        : Utils.strToMM(
                                                            data[rowIndex]
                                                                .hcvAb
                                                                .toString())
                                                    : columnIndex == 4
                                                        ? data[rowIndex]
                                                                    .vdrlTest ==
                                                                0
                                                            ? "-"
                                                            : Utils.strToMM(
                                                                data[rowIndex]
                                                                    .vdrlTest
                                                                    .toString())
                                                        : columnIndex == 5
                                                            ? data[rowIndex]
                                                                        .mpIct ==
                                                                    0
                                                                ? "-"
                                                                : Utils.strToMM(
                                                                    data[rowIndex]
                                                                        .mpIct
                                                                        .toString())
                                                            : columnIndex == 6
                                                                ? data[rowIndex]
                                                                            .haemoglobin ==
                                                                        0
                                                                    ? "-"
                                                                    : Utils.strToMM(data[rowIndex]
                                                                        .haemoglobin
                                                                        .toString())
                                                                : columnIndex == 7
                                                                    ? data[rowIndex].labName != null
                                                                        ? data[rowIndex].labName.toString()
                                                                        : "-"
                                                                    : columnIndex == 8
                                                                        ? data[rowIndex].total != null
                                                                            ? Utils.strToMM(data[rowIndex].total.toString())
                                                                            : "-"
                                                                        : "",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: Responsive.isMobile(context)
                                            ? 16
                                            : 17,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                      )),
            ));

    return ExpandableTable(
      rows: rows,
      header: header,
      cellWidth: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.23
          : MediaQuery.of(context).size.width * 0.135,
      cellHeight: 48,
      headerHeight: 74,
      firstColumnWidth: 50,
      scrollShadowColor: Colors.grey,
    );
  }

  convertToMonthName(int month) {
    return DateFormat("MMM").format(DateTime(2021, month + 1, 1));
  }

  convertToMMMonthName(int month) {
    if (month == 0) return "ဇန်နဝါရီ";
    if (month == 1) return "ဖေဖော်ဝါရီ";
    if (month == 2) return "မတ်";
    if (month == 3) return "ဧပြီ";
    if (month == 4) return "မေ";
    if (month == 5) return "ဇွန်";
    if (month == 6) return "ဇူလိုင်";
    if (month == 7) return "ဩဂုတ်";
    if (month == 8) return "စက်တင်ဘာ";
    if (month == 9) return "အောက်တိုဘာ";
    if (month == 10) return "နိုဝင်ဘာ";
    if (month == 11) return "ဒီဇင်ဘာ";
  }
}
