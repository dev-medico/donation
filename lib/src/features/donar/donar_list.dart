import 'dart:convert';
import 'dart:developer';

import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/data/repository/repository.dart';
import 'package:merchant/data/response/xata_closing_balance_response.dart';
import 'package:merchant/data/response/xata_donors_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/donar/donar_yearly_report.dart';
import 'package:merchant/src/features/donar/edit_donar.dart';
import 'package:merchant/src/features/donar/new_donar.dart';
import 'package:merchant/src/features/donar/new_expense_record.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';
import 'package:tab_container/tab_container.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class DonarList extends StatefulWidget {
  static const routeName = "/donar_list";

  @override
  _DonarListState createState() => _DonarListState();
}

class _DonarListState extends State<DonarList> {
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

  List<DonorData> dataSegments1 = [];
  List<DonorData> dataSegments2 = [];
  List<DonorData> dataSegments3 = [];
  List<DonorData> dataSegments4 = [];
  List<DonorData> dataSegments5 = [];
  List<DonorData> dataSegments6 = [];
  List<DonorData> dataSegments7 = [];
  List<DonorData> dataSegments8 = [];
  List<DonorData> dataSegments9 = [];
  List<DonorData> dataSegments10 = [];
  List<DonorData> dataSegments11 = [];
  List<DonorData> dataSegments12 = [];

  List<DonorData> expensedataSegments1 = [];
  List<DonorData> expensedataSegments2 = [];
  List<DonorData> expensedataSegments3 = [];
  List<DonorData> expensedataSegments4 = [];
  List<DonorData> expensedataSegments5 = [];
  List<DonorData> expensedataSegments6 = [];
  List<DonorData> expensedataSegments7 = [];
  List<DonorData> expensedataSegments8 = [];
  List<DonorData> expensedataSegments9 = [];
  List<DonorData> expensedataSegments10 = [];
  List<DonorData> expensedataSegments11 = [];
  List<DonorData> expensedataSegments12 = [];
  String dataMonth = "";
  String expensedataMonth = "";
  bool dataFullLoaded = false;
  bool dataExpenseFullLoaded = false;

  int leftBalance1 = 0;
  int leftBalance2 = 0;
  int leftBalance3 = 0;
  int leftBalance4 = 0;
  int leftBalance5 = 0;
  int leftBalance6 = 0;
  int leftBalance7 = 0;
  int leftBalance8 = 0;
  int leftBalance9 = 0;
  int leftBalance10 = 0;
  int leftBalance11 = 0;
  int leftBalance12 = 0;

  TabContainerController controller = TabContainerController(length: 12);

  List<DonorData> data = [];
  List<DonorData> expensesData = [];

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
                                calculateLeftBalance();
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
                          child: buildSimpleTable(dataSegments1,
                              expensedataSegments1, 0, leftBalance1),
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
                          child: buildSimpleTable(dataSegments2,
                              expensedataSegments2, 1, leftBalance2),
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
                          child: buildSimpleTable(dataSegments3,
                              expensedataSegments3, 2, leftBalance3),
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
                          child: buildSimpleTable(dataSegments4,
                              expensedataSegments4, 3, leftBalance4),
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
                          child: buildSimpleTable(dataSegments5,
                              expensedataSegments5, 4, leftBalance5),
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
                          child: buildSimpleTable(dataSegments6,
                              expensedataSegments6, 5, leftBalance6),
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
                          child: buildSimpleTable(dataSegments7,
                              expensedataSegments7, 6, leftBalance7),
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
                          child: buildSimpleTable(dataSegments8,
                              expensedataSegments8, 7, leftBalance8),
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
                          child: buildSimpleTable(dataSegments9,
                              expensedataSegments9, 8, leftBalance9),
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
                          child: buildSimpleTable(dataSegments10,
                              expensedataSegments10, 9, leftBalance10),
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
                          child: buildSimpleTable(dataSegments11,
                              expensedataSegments11, 10, leftBalance11),
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
                          child: buildSimpleTable(dataSegments12,
                              expensedataSegments12, 11, leftBalance12),
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
    List<int> monthlyExpense = [];
    int closingBalance = 0;
    int totalExpense = 0;
    int totalDonationAmount = 0;

    int janDonation = 0;
    for (var element in dataSegments1) {
      janDonation += element.amount ?? 0;
    }

    int febDonation = 0;
    for (var element in dataSegments2) {
      febDonation += element.amount ?? 0;
    }

    int marDonation = 0;
    for (var element in dataSegments3) {
      marDonation += element.amount ?? 0;
    }

    int aprDonation = 0;
    for (var element in dataSegments4) {
      aprDonation += element.amount ?? 0;
    }

    int mayDonation = 0;
    for (var element in dataSegments5) {
      mayDonation += element.amount ?? 0;
    }

    int junDonation = 0;
    for (var element in dataSegments6) {
      junDonation += element.amount ?? 0;
    }

    int julDonation = 0;
    for (var element in dataSegments7) {
      julDonation += element.amount ?? 0;
    }

    int augDonation = 0;
    for (var element in dataSegments8) {
      augDonation += element.amount ?? 0;
    }

    int sepDonation = 0;
    for (var element in dataSegments9) {
      sepDonation += element.amount ?? 0;
    }

    int octDonation = 0;
    for (var element in dataSegments10) {
      octDonation += element.amount ?? 0;
    }

    int novDonation = 0;
    for (var element in dataSegments11) {
      novDonation += element.amount ?? 0;
    }

    int decDonation = 0;
    for (var element in dataSegments12) {
      decDonation += element.amount ?? 0;
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

    int janExpense = 0;
    for (var element in expensedataSegments1) {
      janExpense += element.amount ?? 0;
    }

    int febExpense = 0;
    for (var element in expensedataSegments2) {
      febExpense += element.amount ?? 0;
    }

    int marExpense = 0;
    for (var element in expensedataSegments3) {
      marExpense += element.amount ?? 0;
    }

    int aprExpense = 0;
    for (var element in expensedataSegments4) {
      aprExpense += element.amount ?? 0;
    }

    int mayExpense = 0;
    for (var element in expensedataSegments5) {
      mayExpense += element.amount ?? 0;
    }

    int junExpense = 0;
    for (var element in expensedataSegments6) {
      junExpense += element.amount ?? 0;
    }

    int julExpense = 0;
    for (var element in expensedataSegments7) {
      julExpense += element.amount ?? 0;
    }

    int augExpense = 0;
    for (var element in expensedataSegments8) {
      augExpense += element.amount ?? 0;
    }

    int sepExpense = 0;
    for (var element in expensedataSegments9) {
      sepExpense += element.amount ?? 0;
    }

    int octExpense = 0;
    for (var element in expensedataSegments10) {
      octExpense += element.amount ?? 0;
    }

    int novExpense = 0;
    for (var element in expensedataSegments11) {
      novExpense += element.amount ?? 0;
    }

    int decExpense = 0;
    for (var element in expensedataSegments12) {
      decExpense += element.amount ?? 0;
    }

    monthlyExpense.addAll([
      janExpense,
      febExpense,
      marExpense,
      aprExpense,
      mayExpense,
      junExpense,
      julExpense,
      augExpense,
      sepExpense,
      octExpense,
      novExpense,
      decExpense
    ]);

    totalExpense = monthlyExpense.reduce((a, b) => a + b);
    totalDonationAmount = monthlyDonation.reduce((a, b) => a + b);

    closingBalance = (leftBalance1 + totalDonationAmount) - totalExpense;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DonationYearlyReport(
                  openingBalance: leftBalance1,
                  monthlyDonation: monthlyDonation,
                  monthlyExpense: monthlyExpense,
                  closingBalance: closingBalance,
                  totalExpense: totalExpense,
                  totalDonationAmount: totalDonationAmount,
                  selectedYear: int.parse(selectedYear),
                )));
  }

  @override
  void initState() {
    super.initState();
    calculateLeftBalance();
    callAPI("");
  }

  calculateLeftBalance() {
    for (int month = 0; month < 12; month++) {
      XataRepository()
          .getClosingBalance(
              month == 0 ? 12 : month,
              month == 0
                  ? (int.parse(selectedYear) - 1).toString()
                  : selectedYear)
          .then((value) {
        logger.i("Month $month - ${value.body}");
        if (XataClosingBalanceResponse.fromJson(jsonDecode(value.body))
            .records!
            .isNotEmpty) {
          var leftBalance = int.parse(
              XataClosingBalanceResponse.fromJson(jsonDecode(value.body))
                  .records![0]
                  .amount
                  .toString());
          if (month == 0) {
            setState(() {
              leftBalance1 = leftBalance;
            });
          } else if (month == 1) {
            setState(() {
              leftBalance2 = leftBalance;
            });
          } else if (month == 2) {
            setState(() {
              leftBalance3 = leftBalance;
            });
          } else if (month == 3) {
            setState(() {
              leftBalance4 = leftBalance;
            });
          } else if (month == 4) {
            setState(() {
              leftBalance5 = leftBalance;
            });
          } else if (month == 5) {
            setState(() {
              leftBalance6 = leftBalance;
            });
          } else if (month == 6) {
            setState(() {
              leftBalance7 = leftBalance;
            });
          } else if (month == 7) {
            setState(() {
              leftBalance8 = leftBalance;
            });
          } else if (month == 8) {
            setState(() {
              leftBalance9 = leftBalance;
            });
          } else if (month == 9) {
            setState(() {
              leftBalance10 = leftBalance;
            });
          } else if (month == 10) {
            setState(() {
              leftBalance11 = leftBalance;
            });
          } else if (month == 11) {
            setState(() {
              leftBalance12 = leftBalance;
            });
          }
        }
      });
    }
  }

  callAPI(String after) {
    if (after.isEmpty) {
      setState(() {
        data = [];
      });
    }
    XataRepository().getDonorsList(after).then((response) {
      logger.i(response.body);

      setState(() {
        data.addAll(XataDonorsListResponse.fromJson(jsonDecode(response.body))
            .records!);
      });

      if (XataDonorsListResponse.fromJson(jsonDecode(response.body))
              .meta!
              .page!
              .more ??
          false) {
        callAPI(XataDonorsListResponse.fromJson(jsonDecode(response.body))
            .meta!
            .page!
            .cursor!);
      } else {
        setState(() {
          dataFullLoaded = true;
        });
        callExpenseAPI("");
      }
    });
  }

  callExpenseAPI(String after) {
    if (after.isEmpty) {
      setState(() {
        expensesData = [];
      });
    }
    XataRepository().getExpensesList(after).then((response) {
      logger.i(response.body);

      setState(() {
        expensesData.addAll(
            XataDonorsListResponse.fromJson(jsonDecode(response.body))
                .records!);
      });

      if (XataDonorsListResponse.fromJson(jsonDecode(response.body))
              .meta!
              .page!
              .more ??
          false) {
        callExpenseAPI(
            XataDonorsListResponse.fromJson(jsonDecode(response.body))
                .meta!
                .page!
                .cursor!);
      } else {
        setState(() {
          dataExpenseFullLoaded = true;
        });
        sortBySegments();
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
          child: Text("ရ/သုံး ငွေစာရင်း",
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      ),
      body: dataExpenseFullLoaded
          ? tabCreate()
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  sortBySegments() {
    List<DonorData> filterData1 = [];
    List<DonorData> filterData2 = [];
    List<DonorData> filterData3 = [];
    List<DonorData> filterData4 = [];
    List<DonorData> filterData5 = [];
    List<DonorData> filterData6 = [];
    List<DonorData> filterData7 = [];
    List<DonorData> filterData8 = [];
    List<DonorData> filterData9 = [];
    List<DonorData> filterData10 = [];
    List<DonorData> filterData11 = [];
    List<DonorData> filterData12 = [];

    for (int i = 0; i < data.length; i++) {
      var tempDate = DateFormat('MMM yyyy').format(DateTime.parse(
          (data[i].date!.replaceAll("T", " ")).replaceAll("Z", "")));
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

    // filterData1 = filterData1.reversed.toList();

    // filterData2 = filterData2.reversed.toList();

    // filterData3 = filterData3.reversed.toList();

    // filterData4 = filterData4.reversed.toList();

    // filterData5 = filterData5.reversed.toList();

    // filterData6 = filterData6.reversed.toList();

    // filterData7 = filterData7.reversed.toList();

    // filterData8 = filterData8.reversed.toList();

    // filterData9 = filterData9.reversed.toList();

    // filterData10 = filterData10.reversed.toList();

    // filterData11 = filterData11.reversed.toList();

    // filterData12 = filterData12.reversed.toList();
    filterData1.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData1 = filterData1.reversed.toList();

    filterData2.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData2 = filterData2.reversed.toList();

    filterData3.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData3 = filterData3.reversed.toList();

    filterData4.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData4 = filterData4.reversed.toList();

    filterData5.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData5 = filterData5.reversed.toList();

    filterData6.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData6 = filterData6.reversed.toList();

    filterData7.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData7 = filterData7.reversed.toList();

    filterData8.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData8 = filterData8.reversed.toList();

    filterData9.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData9 = filterData9.reversed.toList();

    filterData10.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData10 = filterData10.reversed.toList();

    filterData11.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
    });
    filterData11 = filterData11.reversed.toList();

    filterData12.sort((a, b) {
      log(b.date.toString());
      return DateTime.parse(
              b.date.toString() == "null" || !b.date.toString().contains("T")
                  ? "2020-01-01"
                  : b.date.toString().split("T")[0])
          .compareTo(DateTime.parse(
              a.date.toString() == "null" || !a.date.toString().contains("T")
                  ? "2020-01-01"
                  : a.date.toString().split("T")[0]));
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

    List<DonorData> expensefilterData1 = [];
    List<DonorData> expensefilterData2 = [];
    List<DonorData> expensefilterData3 = [];
    List<DonorData> expensefilterData4 = [];
    List<DonorData> expensefilterData5 = [];
    List<DonorData> expensefilterData6 = [];
    List<DonorData> expensefilterData7 = [];
    List<DonorData> expensefilterData8 = [];
    List<DonorData> expensefilterData9 = [];
    List<DonorData> expensefilterData10 = [];
    List<DonorData> expensefilterData11 = [];
    List<DonorData> expensefilterData12 = [];

    for (int i = 0; i < expensesData.length; i++) {
      var tempDate = DateFormat('MMM yyyy').format(DateTime.parse(
          (expensesData[i].date!.replaceAll("T", " ")).replaceAll("Z", "")));
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Jan") {
        expensefilterData1.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Feb") {
        expensefilterData2.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Mar") {
        expensefilterData3.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Apr") {
        expensefilterData4.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "May") {
        expensefilterData5.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Jun") {
        expensefilterData6.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Jul") {
        expensefilterData7.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Aug") {
        expensefilterData8.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Sep") {
        expensefilterData9.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Oct") {
        expensefilterData10.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Nov") {
        expensefilterData11.add(expensesData[i]);
      }
      if (tempDate.split(" ")[1] == selectedYear &&
          tempDate.split(" ")[0] == "Dec") {
        expensefilterData12.add(expensesData[i]);
      }

      setState(() {
        expensedataMonth =
            "${tempDate.split(" ")[0]} ${tempDate.split(" ")[1]}";
      });
    }

    // expensefilterData1 = expensefilterData1.reversed.toList();

    // expensefilterData2 = expensefilterData2.reversed.toList();

    // expensefilterData3 = expensefilterData3.reversed.toList();

    // expensefilterData4 = expensefilterData4.reversed.toList();

    // expensefilterData5 = expensefilterData5.reversed.toList();

    // expensefilterData6 = expensefilterData6.reversed.toList();

    // expensefilterData7 = expensefilterData7.reversed.toList();

    // expensefilterData8 = expensefilterData8.reversed.toList();

    // expensefilterData9 = expensefilterData9.reversed.toList();

    // expensefilterData10 = expensefilterData10.reversed.toList();

    // expensefilterData11 = expensefilterData11.reversed.toList();

    // expensefilterData12 = expensefilterData12.reversed.toList();

    setState(() {
      expensedataSegments1 = expensefilterData1;
      expensedataSegments2 = expensefilterData2;
      expensedataSegments3 = expensefilterData3;
      expensedataSegments4 = expensefilterData4;
      expensedataSegments5 = expensefilterData5;
      expensedataSegments6 = expensefilterData6;
      expensedataSegments7 = expensefilterData7;
      expensedataSegments8 = expensefilterData8;
      expensedataSegments9 = expensefilterData9;
      expensedataSegments10 = expensefilterData10;
      expensedataSegments11 = expensefilterData11;
      expensedataSegments12 = expensefilterData12;
    });
  }

  YYDialog confirmDeleteDialog(String title, String msg, BuildContext context,
      String buttonMsg, Color color, Function onTap) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.8
          : MediaQuery.of(context).size.width * 0.3
//      ..height = 110
      ..backgroundColor =
          Colors.white //Colors.black.withOpacity(0.8)//main_theme_color
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

  buildSimpleTable(List<DonorData> data, List<DonorData> expenses, int month,
      int leftBalance) {
    const int COLUMN_COUNT = 5;
    int ROWCOUNT = data.length;
    int totalDonation = 0;
    int totalExpense = 0;
    int thisMonthLeftBalance = 0;
    int longTextCount = 0;

    for (var element in expenses) {
      if (element.name!.length > 22) {
        longTextCount++;
      }
    }

    for (var element in data) {
      totalDonation += int.parse(element.amount.toString());
    }

    for (var element in expenses) {
      totalExpense += int.parse(element.amount.toString());
    }

    thisMonthLeftBalance = (totalDonation + leftBalance) - totalExpense;

    List<String> titles = ["ရက်စွဲ", "အမည်", "အလှူငွေ", ""];

    ExpandableTableHeader header = ExpandableTableHeader(
        firstCell: Container(
            width: Responsive.isMobile(context) ? 90 : 120,
            color: primaryColor,
            height: 60,
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
                margin: const EdgeInsets.all(1),
                child: Center(
                    child: Text(
                  titles[index],
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 13 : 14,
                      color: Colors.white),
                )))));

    List<ExpandableTableRow> rows = List.generate(ROWCOUNT, (rowIndex) {
      var tempDate = DateFormat('dd MMM yyyy').format(DateTime.parse(
          (data[rowIndex].date!.replaceAll("T", " ")).replaceAll("Z", "")));
      return ExpandableTableRow(
        height: 58,
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
            (columnIndex) => Container(
                decoration: borderDecorationNoRadius(Colors.grey),
                margin: const EdgeInsets.all(1),
                child: Container(
                  height: 58,
                  padding: EdgeInsets.only(
                      right: 12,
                      left: columnIndex == 4 ? 12 : 20.0,
                      top: columnIndex == 1 ? 4 : 14),
                  child: columnIndex == 3
                      ? Row(
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
                                          builder: (context) => EditDonarScreen(
                                                donor: data[rowIndex],
                                              )));
                                  calculateLeftBalance();
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
                                      "အလှူရှင်စာရင်းအား ဖျက်မည်မှာ \nသေချာပါသလား?",
                                      context,
                                      "အိုကေ",
                                      Colors.black, () {
                                    XataRepository()
                                        .deleteDonorByID(
                                      data[rowIndex].id.toString(),
                                    )
                                        .then((value) {
                                      if (value.statusCode
                                          .toString()
                                          .startsWith("2")) {
                                        Utils.messageSuccessNoPopDialog(
                                            "အလှူစာရင်း ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
                                            context,
                                            "အိုကေ",
                                            Colors.black);
                                        calculateLeftBalance();
                                        callAPI("");
                                      }
                                    });
                                  });
                                }),
                          ],
                        )
                      : Align(
                          alignment: columnIndex == 2
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            columnIndex == 0
                                ? tempDate.toString()
                                : columnIndex == 1
                                    ? data[rowIndex].name.toString()
                                    : columnIndex == 2
                                        ? data[rowIndex].amount.toString()
                                        : "",
                            textAlign: columnIndex == 6 || columnIndex == 2
                                ? TextAlign.right
                                : columnIndex == 1
                                    ? TextAlign.left
                                    : TextAlign.start,
                            style: TextStyle(
                                height: 1.4,
                                fontSize:
                                    Responsive.isMobile(context) ? 13 : 14,
                                color: Colors.black),
                          ),
                        ),
                ))),
      );
    });

    if (Responsive.isMobile(context)) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ExpandableTable(
              rows: rows,
              header: header,
              cellWidth: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width * 0.12,
              cellHeight: 58,
              headerHeight: 60,
              firstColumnWidth: Responsive.isMobile(context) ? 44 : 50,
              scrollShadowColor: Colors.grey,
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Container(
                decoration: shadowDecoration(Colors.white),
                padding: const EdgeInsets.only(
                    left: 8, right: 8, bottom: 20, top: 12),
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Text(
                        "${"${Utils.strToMM(selectedYear)} ${convertToMMMonthName(month)}"} လ စာရင်းရှင်းတမ်း",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: NeumorphicTheme.of(context)
                                ?.current!
                                .variantColor)),
                    const SizedBox(
                      height: 24,
                    ),

                    //New
                    Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      children: <TableRow>[
                        TableRow(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(
                                  Responsive.isMobile(context) ? 8 : 12),
                              child: const Text(
                                "ဝင်ငွေ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  // fontFamily: "Times New Roman",
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(
                                  Responsive.isMobile(context) ? 8 : 12),
                              child: const Text(
                                "အသုံးစားရိတ်",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  // fontFamily: "Times New Roman",
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      children: <TableRow>[
                        TableRow(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(
                                  Responsive.isMobile(context) ? 8 : 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "စာရင်းဖွင့်လက်ကျန်ငွေ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: NeumorphicTheme.of(context)
                                                  ?.current!
                                                  .variantColor),
                                        ),
                                        Text(
                                          "${Utils.strToMM(leftBalance.toString())} ကျပ်",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: NeumorphicTheme.of(context)
                                                  ?.current!
                                                  .variantColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "ယခုလ အလှူငွေ စုစုပေါင်း",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: NeumorphicTheme.of(context)
                                                  ?.current!
                                                  .variantColor),
                                        ),
                                        Text(
                                          "${Utils.strToMM(totalDonation.toString())} ကျပ်",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: NeumorphicTheme.of(context)
                                                  ?.current!
                                                  .variantColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: Responsive.isMobile(context) ? 8 : 12,
                                  top: Responsive.isMobile(context) ? 8 : 12,
                                  bottom:
                                      Responsive.isMobile(context) ? 8 : 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: expenses.length * 30 +
                                        (longTextCount * 30),
                                    child: ListView.builder(
                                        itemCount: expenses.length,
                                        itemBuilder: ((context, index) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 4),
                                            height:
                                                expenses[index].name!.length >
                                                        22
                                                    ? 60
                                                    : 30,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    expenses[index].name ?? "-",
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            NeumorphicTheme.of(
                                                                    context)
                                                                ?.current!
                                                                .variantColor),
                                                  ),
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${Utils.strToMM(expenses[index].amount.toString())} ကျပ်",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: NeumorphicTheme
                                                                  .of(context)
                                                              ?.current!
                                                              .variantColor),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: expenses[
                                                                          index]
                                                                      .name!
                                                                      .length >
                                                                  22
                                                              ? 8
                                                              : 0),
                                                      child: IconButton(
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            size: 16,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () {
                                                            confirmDeleteDialog(
                                                                "ဖျက်မည်မှာ သေချာပါသလား?",
                                                                "အသုံးစားရိတ်အား ဖျက်မည်မှာ \nသေချာပါသလား?",
                                                                context,
                                                                "အိုကေ",
                                                                Colors.black,
                                                                () {
                                                              XataRepository()
                                                                  .deleteExpenseByID(
                                                                      expenses[
                                                                              index]
                                                                          .id
                                                                          .toString())
                                                                  .then(
                                                                      (value) {
                                                                if (value
                                                                    .statusCode
                                                                    .toString()
                                                                    .startsWith(
                                                                        "2")) {
                                                                  Utils.messageSuccessNoPopDialog(
                                                                      "အသုံးစားရိတ် ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
                                                                      context,
                                                                      "အိုကေ",
                                                                      Colors
                                                                          .black);
                                                                  calculateLeftBalance();
                                                                  callAPI("");
                                                                }
                                                              });
                                                            });
                                                          }),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        })),
                                  ),
                                  Visibility(
                                    visible: expenses.isNotEmpty,
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.only(top: 12, bottom: 12),
                                      child: Divider(
                                        color: Colors.black,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(right: 12),
                                    height: 30,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "စုစုပေါင်း ကုန်ကျငွေ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: NeumorphicTheme.of(context)
                                                  ?.current!
                                                  .variantColor),
                                        ),
                                        Text(
                                          "${Utils.strToMM(totalExpense.toString())} ကျပ်",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: NeumorphicTheme.of(context)
                                                  ?.current!
                                                  .variantColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(right: 12),
                                    height: 30,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "စာရင်းပိတ် လက်ကျန်ငွေ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: NeumorphicTheme.of(context)
                                                  ?.current!
                                                  .variantColor),
                                        ),
                                        Text(
                                          "${Utils.strToMM(thisMonthLeftBalance.toString())} ကျပ်",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: NeumorphicTheme.of(context)
                                                  ?.current!
                                                  .variantColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      children: <TableRow>[
                        TableRow(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(
                                  Responsive.isMobile(context) ? 8 : 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "စုစုပေါင်း",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: NeumorphicTheme.of(context)
                                            ?.current!
                                            .variantColor),
                                  ),
                                  Text(
                                    "${Utils.strToMM((totalDonation + leftBalance).toString())} ကျပ်",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: NeumorphicTheme.of(context)
                                            ?.current!
                                            .variantColor),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(
                                  Responsive.isMobile(context) ? 8 : 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "စုစုပေါင်း",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: NeumorphicTheme.of(context)
                                            ?.current!
                                            .variantColor),
                                  ),
                                  Text(
                                    "${Utils.strToMM((totalDonation + leftBalance).toString())} ကျပ်",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: NeumorphicTheme.of(context)
                                            ?.current!
                                            .variantColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewDonarScreen(),
                                ),
                              );
                              calculateLeftBalance();
                              callAPI("");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0))),
                              child: Row(
                                children: const [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Icon(Icons.calculate_outlined,
                                      color: Colors.white),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: 12, bottom: 12, left: 12),
                                      child: Text(
                                        "အလှူရှင် ထည့်မည်",
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
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NewExpenseRecordScreen(),
                                ),
                              );
                              calculateLeftBalance();
                              callAPI("");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0))),
                              child: Row(
                                children: const [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Icon(Icons.calculate_outlined,
                                      color: Colors.white),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: 12, bottom: 12, left: 12),
                                      child: Text(
                                        "အသုံးစာရင်း ထည့်မည်",
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
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: GestureDetector(
                              onTap: () {
                                XataRepository()
                                    .getClosingBalance(month + 1, selectedYear)
                                    .then((value) {
                                  if (XataClosingBalanceResponse.fromJson(
                                          jsonDecode(value.body))
                                      .records!
                                      .isEmpty) {
                                    XataRepository()
                                        .uploadNewClosingBalance(
                                            jsonEncode(<String, dynamic>{
                                      "month": "${month + 1}-$selectedYear",
                                      "amount": thisMonthLeftBalance,
                                    }))
                                        .then((value) {
                                      Utils.messageSuccessNoPopDialog(
                                          "စာရင်းပိတ်ခြင်း \nအောင်မြင်ပါသည်။",
                                          context,
                                          "အိုကေ",
                                          Colors.black);
                                      calculateLeftBalance();
                                      callAPI("");
                                    });
                                  } else {
                                    XataRepository()
                                        .updatewClosingBalance(
                                            XataClosingBalanceResponse.fromJson(
                                                    jsonDecode(value.body))
                                                .records![0]
                                                .id
                                                .toString(),
                                            jsonEncode(<String, dynamic>{
                                              "month":
                                                  "${month + 1}-$selectedYear",
                                              "amount": thisMonthLeftBalance,
                                            }))
                                        .then((value) {
                                      Utils.messageSuccessNoPopDialog(
                                          "စာရင်းပိတ်ခြင်း \nအောင်မြင်ပါသည်။",
                                          context,
                                          "အိုကေ",
                                          Colors.black);
                                      calculateLeftBalance();
                                      callAPI("");
                                    });
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12.0))),
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Icon(Icons.calculate_outlined,
                                        color: Colors.white),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 12, bottom: 12, left: 12),
                                        child: Text(
                                          "စာရင်းပိတ်မည်",
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
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12.0))),
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Icon(Icons.exit_to_app,
                                        color: Colors.white),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 12, bottom: 12, left: 12),
                                        child: Text(
                                          "ပင်မစာမျက်နှာသို့",
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
                      ],
                    )
                  ],
                ),
              ))
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: ExpandableTable(
              rows: rows,
              header: header,
              cellWidth: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.4
                  : MediaQuery.of(context).size.width * 0.12,
              cellHeight: 58,
              headerHeight: 60,
              firstColumnWidth: Responsive.isMobile(context) ? 44 : 50,
              scrollShadowColor: Colors.grey,
            ),
          ),
          Expanded(
              child: Container(
            decoration: shadowDecoration(Colors.white),
            padding:
                const EdgeInsets.only(left: 8, right: 8, bottom: 20, top: 12),
            margin: const EdgeInsets.only(left: 30),
            child: Column(
              children: [
                Text(
                    "${"${Utils.strToMM(selectedYear)} ${convertToMMMonthName(month)}"} လ စာရင်းရှင်းတမ်း",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: NeumorphicTheme.of(context)
                            ?.current!
                            .variantColor)),
                const SizedBox(
                  height: 24,
                ),

                //New
                Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(
                              Responsive.isMobile(context) ? 8 : 12),
                          child: const Text(
                            "ဝင်ငွေ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // fontFamily: "Times New Roman",
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(
                              Responsive.isMobile(context) ? 8 : 12),
                          child: const Text(
                            "အသုံးစားရိတ်",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // fontFamily: "Times New Roman",
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(
                              Responsive.isMobile(context) ? 8 : 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "စာရင်းဖွင့်လက်ကျန်ငွေ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NeumorphicTheme.of(context)
                                              ?.current!
                                              .variantColor),
                                    ),
                                    Text(
                                      "${Utils.strToMM(leftBalance.toString())} ကျပ်",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NeumorphicTheme.of(context)
                                              ?.current!
                                              .variantColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              SizedBox(
                                height: 30,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "ယခုလ အလှူငွေ စုစုပေါင်း",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NeumorphicTheme.of(context)
                                              ?.current!
                                              .variantColor),
                                    ),
                                    Text(
                                      "${Utils.strToMM(totalDonation.toString())} ကျပ်",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NeumorphicTheme.of(context)
                                              ?.current!
                                              .variantColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 8 : 12,
                              top: Responsive.isMobile(context) ? 8 : 12,
                              bottom: Responsive.isMobile(context) ? 8 : 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    expenses.length * 30 + (longTextCount * 30),
                                child: ListView.builder(
                                    itemCount: expenses.length,
                                    itemBuilder: ((context, index) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 4),
                                        height:
                                            expenses[index].name!.length > 22
                                                ? 60
                                                : 30,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                expenses[index].name ?? "-",
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: NeumorphicTheme.of(
                                                            context)
                                                        ?.current!
                                                        .variantColor),
                                              ),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${Utils.strToMM(expenses[index].amount.toString())} ကျပ်",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: NeumorphicTheme.of(
                                                              context)
                                                          ?.current!
                                                          .variantColor),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: expenses[index]
                                                                  .name!
                                                                  .length >
                                                              22
                                                          ? 8
                                                          : 0),
                                                  child: IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        size: 20,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        XataRepository()
                                                            .deleteExpenseByID(
                                                                expenses[index]
                                                                    .id
                                                                    .toString())
                                                            .then((value) {
                                                          if (value.statusCode
                                                              .toString()
                                                              .startsWith(
                                                                  "2")) {
                                                            Utils.messageSuccessNoPopDialog(
                                                                "အသုံးစားရိတ် ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
                                                                context,
                                                                "အိုကေ",
                                                                Colors.black);
                                                            calculateLeftBalance();
                                                            callAPI("");
                                                          }
                                                        });
                                                      }),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    })),
                              ),
                              Visibility(
                                visible: expenses.isNotEmpty,
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 12, bottom: 12),
                                  child: Divider(
                                    color: Colors.black,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 12),
                                height: 30,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "စုစုပေါင်း ကုန်ကျငွေ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NeumorphicTheme.of(context)
                                              ?.current!
                                              .variantColor),
                                    ),
                                    Text(
                                      "${Utils.strToMM(totalExpense.toString())} ကျပ်",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NeumorphicTheme.of(context)
                                              ?.current!
                                              .variantColor),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 12),
                                height: 30,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "စာရင်းပိတ် လက်ကျန်ငွေ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NeumorphicTheme.of(context)
                                              ?.current!
                                              .variantColor),
                                    ),
                                    Text(
                                      "${Utils.strToMM(thisMonthLeftBalance.toString())} ကျပ်",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NeumorphicTheme.of(context)
                                              ?.current!
                                              .variantColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(
                              Responsive.isMobile(context) ? 8 : 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "စုစုပေါင်း",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: NeumorphicTheme.of(context)
                                        ?.current!
                                        .variantColor),
                              ),
                              Text(
                                "${Utils.strToMM((totalDonation + leftBalance).toString())} ကျပ်",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: NeumorphicTheme.of(context)
                                        ?.current!
                                        .variantColor),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(
                              Responsive.isMobile(context) ? 8 : 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "စုစုပေါင်း",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: NeumorphicTheme.of(context)
                                        ?.current!
                                        .variantColor),
                              ),
                              Text(
                                "${Utils.strToMM((totalDonation + leftBalance).toString())} ကျပ်",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: NeumorphicTheme.of(context)
                                        ?.current!
                                        .variantColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewDonarScreen(),
                            ),
                          );
                          calculateLeftBalance();
                          callAPI("");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0))),
                          child: Row(
                            children: const [
                              SizedBox(
                                width: 20,
                              ),
                              Icon(Icons.calculate_outlined,
                                  color: Colors.white),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 12, bottom: 12, left: 12),
                                  child: Text(
                                    "အလှူရှင် ထည့်မည်",
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.white),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewExpenseRecordScreen(),
                            ),
                          );
                          calculateLeftBalance();
                          callAPI("");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0))),
                          child: Row(
                            children: const [
                              SizedBox(
                                width: 20,
                              ),
                              Icon(Icons.calculate_outlined,
                                  color: Colors.white),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 12, bottom: 12, left: 12),
                                  child: Text(
                                    "အသုံးစာရင်း ထည့်မည်",
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.white),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: GestureDetector(
                          onTap: () {
                            XataRepository()
                                .getClosingBalance(month + 1, selectedYear)
                                .then((value) {
                              if (XataClosingBalanceResponse.fromJson(
                                      jsonDecode(value.body))
                                  .records!
                                  .isEmpty) {
                                XataRepository()
                                    .uploadNewClosingBalance(
                                        jsonEncode(<String, dynamic>{
                                  "month": "${month + 1}-$selectedYear",
                                  "amount": thisMonthLeftBalance,
                                }))
                                    .then((value) {
                                  Utils.messageSuccessNoPopDialog(
                                      "စာရင်းပိတ်ခြင်း \nအောင်မြင်ပါသည်။",
                                      context,
                                      "အိုကေ",
                                      Colors.black);
                                  calculateLeftBalance();
                                  callAPI("");
                                });
                              } else {
                                XataRepository()
                                    .updatewClosingBalance(
                                        XataClosingBalanceResponse.fromJson(
                                                jsonDecode(value.body))
                                            .records![0]
                                            .id
                                            .toString(),
                                        jsonEncode(<String, dynamic>{
                                          "month": "${month + 1}-$selectedYear",
                                          "amount": thisMonthLeftBalance,
                                        }))
                                    .then((value) {
                                  Utils.messageSuccessNoPopDialog(
                                      "စာရင်းပိတ်ခြင်း \nအောင်မြင်ပါသည်။",
                                      context,
                                      "အိုကေ",
                                      Colors.black);
                                  calculateLeftBalance();
                                  callAPI("");
                                });
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0))),
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 20,
                                ),
                                Icon(Icons.calculate_outlined,
                                    color: Colors.white),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 12, bottom: 12, left: 12),
                                    child: Text(
                                      "ယခုလ အတွက် စာရင်းပိတ်မည်",
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
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0))),
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 20,
                                ),
                                Icon(Icons.exit_to_app, color: Colors.white),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 12, bottom: 12, left: 12),
                                    child: Text(
                                      "ပင်မစာမျက်နှာသို့ ထွက်မည်",
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
                  ],
                )
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

  convertToMMMonthName(int month) {
    //convert month index int to  name with Format "MMM"
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
