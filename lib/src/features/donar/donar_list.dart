import 'dart:convert';
import 'dart:developer';

import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donar/controller/dona_data_provider.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:donation/data/repository/repository.dart';
import 'package:donation/data/response/xata_closing_balance_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/donar/donar_data_source.dart';
import 'package:donation/src/features/donar/donar_yearly_report.dart';
import 'package:donation/src/features/donar/edit_donar.dart';
import 'package:donation/src/features/donar/new_donar.dart';
import 'package:donation/src/features/donar/new_expense_record.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:tab_container/tab_container.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class DonarList extends ConsumerStatefulWidget {
  static const routeName = "/donars";

  const DonarList({Key? key}) : super(key: key);

  @override
  _DonarListState createState() => _DonarListState();
}

class _DonarListState extends ConsumerState<DonarList> {
  bool firstTime = true;
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

  List<DonarRecord> oldDonarsData = [];
  List<ExpensesRecord> oldExpenseRecordData = [];

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

  List<DonarRecord> dataSegments1 = [];
  List<DonarRecord> dataSegments2 = [];
  List<DonarRecord> dataSegments3 = [];
  List<DonarRecord> dataSegments4 = [];
  List<DonarRecord> dataSegments5 = [];
  List<DonarRecord> dataSegments6 = [];
  List<DonarRecord> dataSegments7 = [];
  List<DonarRecord> dataSegments8 = [];
  List<DonarRecord> dataSegments9 = [];
  List<DonarRecord> dataSegments10 = [];
  List<DonarRecord> dataSegments11 = [];
  List<DonarRecord> dataSegments12 = [];

  List<ExpensesRecord> expensedataSegments1 = [];
  List<ExpensesRecord> expensedataSegments2 = [];
  List<ExpensesRecord> expensedataSegments3 = [];
  List<ExpensesRecord> expensedataSegments4 = [];
  List<ExpensesRecord> expensedataSegments5 = [];
  List<ExpensesRecord> expensedataSegments6 = [];
  List<ExpensesRecord> expensedataSegments7 = [];
  List<ExpensesRecord> expensedataSegments8 = [];
  List<ExpensesRecord> expensedataSegments9 = [];
  List<ExpensesRecord> expensedataSegments10 = [];
  List<ExpensesRecord> expensedataSegments11 = [];
  List<ExpensesRecord> expensedataSegments12 = [];
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

  List<DonarRecord> data = [];
  List<ExpensesRecord> expensesData = [];

  tabCreate() => Scaffold(
        backgroundColor: Colors.white,
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
                                  : MediaQuery.of(context).size.width / 17,
                              height: 44,
                              decoration: shadowDecorationOnlyTop(
                                  rangesSelect[index]
                                      ? Colors.red.withOpacity(0.6)
                                      : const Color(0xffe3e3e3)),
                              child: Center(
                                  child: Text(
                                ranges[index],
                                style: TextStyle(
                                    fontSize: 15,
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
                                            fontSize: 14.0,
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
                        fontSize: 14,
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

  calculateLeftBalance() {
    for (int month = 0; month < 12; month++) {
      var leftBalance = ref.read(closingBalanceDataProvider(
          (month: month + 1, year: int.parse(selectedYear))));

      log("Left Balance - ${month + 1} - $selectedYear" + leftBalance.toString());

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
  }

  // callAPI(String after) {
  //   if (after.isEmpty) {
  //     setState(() {
  //       data = [];
  //     });
  //   }
  //   XataRepository().getDonorsList(after).then((response) {
  //     logger.i(response.body);

  //     setState(() {
  //       data.addAll(XataDonorsListResponse.fromJson(jsonDecode(response.body))
  //           .records!);
  //     });

  //     if (XataDonorsListResponse.fromJson(jsonDecode(response.body))
  //             .meta!
  //             .page!
  //             .more ??
  //         false) {
  //       callAPI(XataDonorsListResponse.fromJson(jsonDecode(response.body))
  //           .meta!
  //           .page!
  //           .cursor!);
  //     } else {
  //       setState(() {
  //         dataFullLoaded = true;
  //       });
  //       data.forEach((element) {
  //         ref.watch(realmProvider)!.createDonar(DonarRecord(
  //               ObjectId(),
  //               name: element.name,
  //               amount: element.amount,
  //               date: DateTime.parse(
  //                   (element.date!.replaceAll("T", " ")).replaceAll("Z", "")),
  //             ));
  //       });

  //       callExpenseAPI("");
  //     }
  //   });
  // }

  // callExpenseAPI(String after) {
  //   if (after.isEmpty) {
  //     setState(() {
  //       expensesData = [];
  //     });
  //   }
  //   XataRepository().getExpensesList(after).then((response) {
  //     logger.i(response.body);

  //     setState(() {
  //       expensesData.addAll(
  //           XataDonorsListResponse.fromJson(jsonDecode(response.body))
  //               .records!);
  //     });

  //     if (XataDonorsListResponse.fromJson(jsonDecode(response.body))
  //             .meta!
  //             .page!
  //             .more ??
  //         false) {
  //       callExpenseAPI(
  //           XataDonorsListResponse.fromJson(jsonDecode(response.body))
  //               .meta!
  //               .page!
  //               .cursor!);
  //     } else {
  //       setState(() {
  //         dataExpenseFullLoaded = true;
  //       });
  //       expensesData.forEach((element) {
  //         ref.watch(realmProvider)!.createExpenseRecord(ExpensesRecord(
  //               ObjectId(),
  //               name: element.name,
  //               amount: element.amount,
  //               date: DateTime.parse(
  //                   (element.date!.replaceAll("T", " ")).replaceAll("Z", "")),
  //             ));
  //       });
  //       sortBySegments();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    final results = ref.watch(donarsDataProvider);
    final expenses = ref.watch(expensesDataProvider);

    if (firstTime) {
      oldDonarsData.clear();
      oldExpenseRecordData.clear();
      results.forEach((element) {
        oldDonarsData.add(element);
      });
      expenses.forEach((element) {
        oldExpenseRecordData.add(element);
      });
      data.addAll(oldDonarsData);
      expensesData.addAll(oldExpenseRecordData);
      setState(() {
        firstTime = false;
      });
      calculateLeftBalance();
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
         leading:Responsive.isMobile(context) ? Padding(
          padding: const EdgeInsets.only(top: 4, left: 8),
          child: Humberger(
            onTap: () {
              ref.watch(drawerControllerProvider)!.toggle!.call();
            },
          ),
        ):null,
        title: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text("ရ/သုံး ငွေစာရင်း",
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      ),
      body: tabCreate(),
    );
  }

  sortBySegments() {
    List<DonarRecord> filterData1 = [];
    List<DonarRecord> filterData2 = [];
    List<DonarRecord> filterData3 = [];
    List<DonarRecord> filterData4 = [];
    List<DonarRecord> filterData5 = [];
    List<DonarRecord> filterData6 = [];
    List<DonarRecord> filterData7 = [];
    List<DonarRecord> filterData8 = [];
    List<DonarRecord> filterData9 = [];
    List<DonarRecord> filterData10 = [];
    List<DonarRecord> filterData11 = [];
    List<DonarRecord> filterData12 = [];

    for (int i = 0; i < data.length; i++) {
      var tempDate = DateFormat('MMM yyyy').format(data[i].date!);
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

    List<ExpensesRecord> expensefilterData1 = [];
    List<ExpensesRecord> expensefilterData2 = [];
    List<ExpensesRecord> expensefilterData3 = [];
    List<ExpensesRecord> expensefilterData4 = [];
    List<ExpensesRecord> expensefilterData5 = [];
    List<ExpensesRecord> expensefilterData6 = [];
    List<ExpensesRecord> expensefilterData7 = [];
    List<ExpensesRecord> expensefilterData8 = [];
    List<ExpensesRecord> expensefilterData9 = [];
    List<ExpensesRecord> expensefilterData10 = [];
    List<ExpensesRecord> expensefilterData11 = [];
    List<ExpensesRecord> expensefilterData12 = [];

    for (int i = 0; i < expensesData.length; i++) {
      var tempDate = DateFormat('MMM yyyy').format(expensesData[i].date!);
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

  buildSimpleTable(List<DonarRecord> data, List<ExpensesRecord> expenses,
      int month, int leftBalance) {
    
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

    DonarDataSource donarDataSource = DonarDataSource(donarData: data);

    if (Responsive.isMobile(context)) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Container(
              margin: EdgeInsets.only(
                  right: Responsive.isMobile(context) ? 20 : 20),
              child: SfDataGrid(
                source: donarDataSource,
                onCellTap: (details) async {
                  Logger logger = Logger();
                  logger.i(details.rowColumnIndex.rowIndex);

                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditDonarScreen(
                                donar:
                                    data[details.rowColumnIndex.rowIndex - 1],
                              )));
                  calculateLeftBalance();
                  // callAPI("");
                },
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                columnWidthMode: Responsive.isMobile(context)
                    ? ColumnWidthMode.auto
                    : ColumnWidthMode.fitByCellValue,
                columns: <GridColumn>[
                  GridColumn(
                      columnName: 'စဥ်',
                      label: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'စဥ်',
                            style: TextStyle(color: Colors.white),
                          ))),
                  GridColumn(
                      columnName: 'ရက်စွဲ',
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'ရက်စွဲ',
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
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'အလှူငွေ',
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'အလှူငွေ',
                            style: TextStyle(color: Colors.white),
                          ))),
                ],
              ),
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
                                "အသုံးစရိတ်",
                                textAlign: TextAlign.center,
                                style: TextStyle(
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
                                                                "အသုံးစရိတ်အား ဖျက်မည်မှာ \nသေချာပါသလား?",
                                                                context,
                                                                "အိုကေ",
                                                                Colors.black,
                                                                () {
                                                              ref
                                                                  .watch(
                                                                      realmProvider)!
                                                                  .deleteExpenseRecord(
                                                                      expenses[
                                                                          index]);
                                                              calculateLeftBalance();
                                                              Utils.messageSuccessSinglePopDialog(
                                                                  "အသုံးစရိတ် ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
                                                                  context,
                                                                  "အိုကေ",
                                                                  Colors.black);

                                                              // XataRepository()
                                                              //     .deleteExpenseByID(
                                                              //         expenses[
                                                              //                 index]
                                                              //             .id
                                                              //             .toString())
                                                              //     .then(
                                                              //         (value) {
                                                              //   if (value
                                                              //       .statusCode
                                                              //       .toString()
                                                              //       .startsWith(
                                                              //           "2")) {
                                                              //     Utils.messageSuccessNoPopDialog(
                                                              //         "အသုံးစရိတ် ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
                                                              //         context,
                                                              //         "အိုကေ",
                                                              //         Colors
                                                              //             .black);
                                                              //     calculateLeftBalance();
                                                              //     // callAPI("");
                                                              //   }
                                                              // });
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
                              // callAPI("");
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
                              // callAPI("");
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
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(),
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
            flex: 9,
            child: Container(
              margin: EdgeInsets.only(
                  right: Responsive.isMobile(context) ? 20 : 20),
              child: SfDataGrid(
                source: donarDataSource,
                onCellTap: (details) async {
                  Logger logger = Logger();
                  logger.i(details.rowColumnIndex.rowIndex);

                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditDonarScreen(
                                donar:
                                    data[details.rowColumnIndex.rowIndex - 1],
                              )));
                  calculateLeftBalance();
                  // callAPI("");
                },
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                columnWidthMode: Responsive.isMobile(context)
                    ? ColumnWidthMode.auto
                    : ColumnWidthMode.fitByCellValue,
                columns: <GridColumn>[
                  GridColumn(
                      columnName: 'စဥ်',
                      label: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'စဥ်',
                            style: TextStyle(color: Colors.white),
                          ))),
                  GridColumn(
                      columnName: 'ရက်စွဲ',
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'ရက်စွဲ',
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
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'အလှူငွေ',
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'အလှူငွေ',
                            style: TextStyle(color: Colors.white),
                          ))),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 10,
              child: Container(
                decoration: shadowDecoration(Colors.white),
                padding: const EdgeInsets.only(
                    left: 8, right: 8, bottom: 20, top: 12),
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
                                "အသုံးစရိတ်",
                                textAlign: TextAlign.center,
                                style: TextStyle(
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
                                                        fontSize: 15,
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
                                                          fontSize: 15,
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
                                                            size: 20,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () {
                                                            ref
                                                                .watch(
                                                                    realmProvider)!
                                                                .deleteExpenseRecord(
                                                                    expenses[
                                                                        index]);
                                                            calculateLeftBalance();
                                                            Utils.messageSuccessSinglePopDialog(
                                                                "အသုံးစရိတ် ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
                                                                context,
                                                                "အိုကေ",
                                                                Colors.black);
                                                            // XataRepository()
                                                            //     .deleteExpenseByID(
                                                            //         expenses[
                                                            //                 index]
                                                            //             .id
                                                            //             .toString())
                                                            //     .then((value) {
                                                            //   if (value
                                                            //       .statusCode
                                                            //       .toString()
                                                            //       .startsWith(
                                                            //           "2")) {
                                                            //     Utils.messageSuccessNoPopDialog(
                                                            //         "အသုံးစရိတ် ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
                                                            //         context,
                                                            //         "အိုကေ",
                                                            //         Colors
                                                            //             .black);
                                                            //     calculateLeftBalance();
                                                            //     // callAPI("");
                                                            //   }
                                                            // });
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              // callAPI("");
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
                              // callAPI("");
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
                                      // callAPI("");
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
                                      // callAPI("");
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
                                          "ပင်မစာမျက်နှာသို့ ထွက်မည်",
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
    }
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
