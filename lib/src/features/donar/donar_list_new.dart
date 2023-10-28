import 'dart:developer';

import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/common_widgets/common_tab_bar.dart';
import 'package:donation/src/features/donar/controller/dona_data_provider.dart';
import 'package:donation/src/features/donar/controller/donar_list_controller.dart';
import 'package:donation/src/features/donar/donar_data_source.dart';
import 'package:donation/src/features/donar/donar_mobile_data_source.dart';
import 'package:donation/src/features/donar/edit_donar.dart';
import 'package:donation/src/features/donar/edit_expense.dart';
import 'package:donation/src/features/donar/expense_data_source.dart';
import 'package:donation/src/features/donar/expense_mobile_data_source.dart';
import 'package:donation/src/features/donar/monthly_report_dialog.dart';
import 'package:donation/src/features/donar/new_donar.dart';
import 'package:donation/src/features/donar/new_expense_record.dart';
import 'package:donation/src/features/donar/yearly_report.dart';
import 'package:donation/src/features/donation/blood_donation_report.dart';
import 'package:donation/src/features/donation/controller/donation_list_controller.dart';
import 'package:donation/src/features/donation/controller/donation_provider.dart';
import 'package:donation/src/features/donation/donation_data_source.dart';
import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/src/features/donation/new_blood_donation.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class DonarListNewScreen extends ConsumerStatefulWidget {
  const DonarListNewScreen({super.key, this.fromHome = false});
  static const routeName = "/donar-list-new";
  final bool fromHome;

  @override
  ConsumerState<DonarListNewScreen> createState() => _DonarListNewScreenState();
}

class _DonarListNewScreenState extends ConsumerState<DonarListNewScreen> {
  int _yearSelected = 0;
  int typeSelected = 0;
  List<String> types = [
    "ရရှိ ငွေစာရင်း",
    "အသုံးစရိတ် ငွေစာရင်း",
  ];
  int _monthSelected = DateTime.now().month - 1;
  List<String> years = [
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

  @override
  Widget build(BuildContext context) {
    var donarData = ref.watch(donarListProvider(DonarFilterModel(
        year: int.parse(years[_yearSelected]), month: _monthSelected + 1)));
    var expenseData = ref.watch(expenseListProvider(DonarFilterModel(
        year: int.parse(years[_yearSelected]), month: _monthSelected + 1)));
    var leftBalance = ref.read(closingBalanceDataProvider(
        (year: int.parse(years[_yearSelected]), month: _monthSelected + 1)));
    var currentleftBalance = ref.read(closingBalanceDataProvider(
        (year: int.parse(years[_yearSelected]), month: _monthSelected + 2)));

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
          child: Text("ရ/သုံး ငွေစာရင်း",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 16,
                  color: Colors.white)),
        ),
      ),
      floatingActionButton: Responsive.isMobile(context)
          ? FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () async {
                if (typeSelected == 0) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewDonarScreen(),
                    ),
                  );
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewExpenseRecordScreen(),
                    ),
                  );
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Container(
        margin: EdgeInsets.all(Responsive.isMobile(context) ? 8 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: Responsive.isMobile(context) ? 40 : 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    width: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width * 1.8
                        : MediaQuery.of(context).size.width * 0.8,
                    height: 60,
                    child: CommonTabBar(
                      underline: false,
                      listWidget: [
                        for (int i = 0; i < years.length; i++)
                          CommonTabBarWidget(
                            underline: false,
                            name: years[i],
                            isSelected: _yearSelected,
                            i: i,
                            onTap: () {
                              _yearSelected = i;

                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              width: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 1.8
                  : MediaQuery.of(context).size.width * 0.8,
              height: Responsive.isMobile(context) ? 40 : 60,
              child: CommonTabBar(
                underline: false,
                listWidget: [
                  for (int i = 0; i < months.length; i++)
                    CommonTabBarWidget(
                      color: primaryColor,
                      underline: false,
                      name: Responsive.isMobile(context)
                          ? monthsMobile[i]
                          : months[i],
                      isSelected: _monthSelected,
                      i: i,
                      onTap: () {
                        _monthSelected = i;

                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
            donarData.when(
              data: (results) {
                return expenseData.when(
                  data: (expenseResults) {
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: shadowDecorationWithBorder(
                                        Colors.white, primaryColor),
                                    margin: EdgeInsets.only(
                                      top: 12,
                                    ),
                                    width: 164,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                MonthlyReportDialog(
                                                  title: "နှစ်ချုပ် ရှင်းတမ်း",
                                                  child: YearlyReport(yearSelected: _yearSelected , year: years[_yearSelected],),
                                                ));
                                      },
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 12,
                                              ),
                                              Icon(Icons.list_alt_outlined,
                                                  color: primaryColor),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 8,
                                                      bottom: 8,
                                                      left: 12),
                                                  child: Text(
                                                    "နှစ်ချုပ် ရှင်းတမ်း",
                                                    textScaleFactor: 1.0,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: primaryColor),
                                                  )),
                                            ],
                                          )),
                                    ),
                                  ),
                                  Container(
                                    decoration: shadowDecorationWithBorder(
                                        Colors.white, primaryColor),
                                    margin: const EdgeInsets.only(
                                      left: 15,
                                      top: 12,
                                    ),
                                    width: 160,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        int totalDonation = 0;
                                        int longTextCount = 0;
                                        int totalExpense = 0;

                                        results.forEach((element) {
                                          totalDonation += element.amount!;
                                        });

                                        expenseResults.forEach((element) {
                                          totalExpense += element.amount!;
                                        });
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                MonthlyReportDialog(
                                                  title: "လချုပ် ရှင်းတမ်း",
                                                  child: monthlyReport(
                                                      leftBalance,
                                                      totalDonation,
                                                      totalExpense,
                                                      currentleftBalance),
                                                ));
                                      },
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 12,
                                              ),
                                              Icon(Icons.list_alt_outlined,
                                                  color: primaryColor),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 8,
                                                      bottom: 8,
                                                      left: 12),
                                                  child: Text(
                                                    "လချုပ် ရှင်းတမ်း",
                                                    textScaleFactor: 1.0,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: primaryColor),
                                                  )),
                                            ],
                                          )),
                                    ),
                                  ),
                                  if (!Responsive.isMobile(context))
                                    Row(
                                      children: [
                                        Container(
                                          decoration:
                                              shadowDecorationWithBorder(
                                                  Colors.white, primaryColor),
                                          margin: const EdgeInsets.only(
                                            left: 15,
                                            top: 12,
                                          ),
                                          width: 186,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewDonarScreen(),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Icon(Icons.calculate_outlined,
                                                    color: primaryColor),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8,
                                                        bottom: 8,
                                                        left: 12),
                                                    child: Text(
                                                      "အလှူရှင် ထည့်မည်",
                                                      textScaleFactor: 1.0,
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          color: primaryColor),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Container(
                                          decoration:
                                              shadowDecorationWithBorder(
                                                  Colors.white, primaryColor),
                                          margin: const EdgeInsets.only(
                                            top: 12,
                                          ),
                                          width: 220,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewExpenseRecordScreen(),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Icon(Icons.calculate_outlined,
                                                    color: primaryColor),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8,
                                                        bottom: 8,
                                                        left: 12),
                                                    child: Text(
                                                      "အသုံးစာရင်း ထည့်မည်",
                                                      textScaleFactor: 1.0,
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          color: primaryColor),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (Responsive.isMobile(context))
                            Container(
                              width: Responsive.isMobile(context)
                                  ? MediaQuery.of(context).size.width * 0.84
                                  : MediaQuery.of(context).size.width * 0.8,
                              height: 40,
                              margin: EdgeInsets.only(top: 20),
                              child: CommonTabBar(
                                underline: false,
                                listWidget: [
                                  for (int i = 0; i < types.length; i++)
                                    CommonTabBarWidget(
                                      underline: false,
                                      name: types[i],
                                      isSelected: typeSelected,
                                      i: i,
                                      onTap: () {
                                        typeSelected = i;

                                        setState(() {});
                                      },
                                    ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: Responsive.isMobile(context)
                                              ? 8
                                              : 12,
                                          top: Responsive.isMobile(context)
                                              ? 8
                                              : 12,
                                          bottom: 12),
                                      child: buildSimpleTable(
                                          results,
                                          expenseResults,
                                          leftBalance,
                                          currentleftBalance),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  error: (Object error, StackTrace stackTrace) {
                    return Center(child: Text(error.toString()));
                  },
                  loading: () {
                    return Container();
                  },
                );
              },
              error: (Object error, StackTrace stackTrace) {
                return Center(child: Text(error.toString()));
              },
              loading: () {
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  buildSimpleTable(List<DonarRecord> data, List<ExpensesRecord> expenses,
      int leftBalance, int thisMonthLeftBalance) {
    DonarDataSource donarDataSource = DonarDataSource(donarData: data);
    DonarMobileDataSource donarMobileDataSource =
        DonarMobileDataSource(donarData: data);

    ExpenseDataSource expenseDataSource =
        ExpenseDataSource(expenseData: expenses);
    ExpenseMobileDataSource expenseMobileDataSource =
        ExpenseMobileDataSource(expenseData: expenses);

    if (Responsive.isMobile(context)) {
      if (typeSelected == 0) {
        if (data.isEmpty) {
          return Center(
              child: Text(years[_yearSelected] +
                  " " +
                  months[_monthSelected] +
                  " လ အတွက် အလှူရှင်မှတ်တမ်း မရှိသေးပါ။"));
        } else {
          return Container(
            margin:
                EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
            child: SfDataGrid(
              source: Responsive.isMobile(context)
                  ? donarMobileDataSource
                  : donarDataSource,
              onCellTap: (details) async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditDonarScreen(
                              donar: data[details.rowColumnIndex.rowIndex - 1],
                            )));
              },
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              columnWidthMode: Responsive.isMobile(context)
                  ? ColumnWidthMode.fitByCellValue
                  : ColumnWidthMode.fitByCellValue,
              columns: <GridColumn>[
                if (!Responsive.isMobile(context))
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
                if (!Responsive.isMobile(context))
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
          );
        }
      } else {
        if (expenses.isEmpty) {
          return Center(
              child: Text(years[_yearSelected] +
                  " " +
                  months[_monthSelected] +
                  " လ အတွက် အသုံးစရိတ်မှတ်တမ်း မရှိသေးပါ။"));
        } else {
          return Container(
            margin:
                EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
            child: SfDataGrid(
              source: Responsive.isMobile(context)
                  ? expenseMobileDataSource
                  : expenseDataSource,
              onCellTap: (details) async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditExpenseScreen(
                              expense:
                                  expenses[details.rowColumnIndex.rowIndex - 1],
                            )));
              },
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              columnWidthMode: Responsive.isMobile(context)
                  ? ColumnWidthMode.fill
                  : ColumnWidthMode.auto,
              columns: <GridColumn>[
                if (!Responsive.isMobile(context))
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
                if (!Responsive.isMobile(context))
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
                    columnName: 'အကြောင်းအရာ',
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'အကြောင်းအရာ',
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'ကုန်ကျစရိတ်',
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'ကုန်ကျစရိတ်',
                          style: TextStyle(color: Colors.white),
                        ))),
              ],
            ),
          );
        }
      }
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              flex: 9,
              child: (data.isEmpty)
                  ? Center(
                      child: Text(years[_yearSelected] +
                          " " +
                          months[_monthSelected] +
                          " လ အတွက် အလှူရှင်မှတ်တမ်း မရှိသေးပါ။"))
                  : Container(
                      margin: EdgeInsets.only(
                          right: Responsive.isMobile(context) ? 20 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            types[0],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Expanded(
                            child: SfDataGrid(
                              source: Responsive.isMobile(context)
                                  ? donarMobileDataSource
                                  : donarDataSource,
                              onCellTap: (details) async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditDonarScreen(
                                              donar: data[details
                                                      .rowColumnIndex.rowIndex -
                                                  1],
                                            )));
                              },
                              gridLinesVisibility: GridLinesVisibility.both,
                              headerGridLinesVisibility:
                                  GridLinesVisibility.both,
                              columnWidthMode: Responsive.isMobile(context)
                                  ? ColumnWidthMode.fitByCellValue
                                  : ColumnWidthMode.fitByCellValue,
                              columns: <GridColumn>[
                                if (!Responsive.isMobile(context))
                                  GridColumn(
                                      columnName: 'စဥ်',
                                      label: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          color: primaryColor,
                                          padding: const EdgeInsets.all(8.0),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'စဥ်',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ))),
                                if (!Responsive.isMobile(context))
                                  GridColumn(
                                      columnName: 'ရက်စွဲ',
                                      label: Container(
                                          color: primaryColor,
                                          padding: const EdgeInsets.all(8.0),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'ရက်စွဲ',
                                            style:
                                                TextStyle(color: Colors.white),
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
                        ],
                      ),
                    )),
          Expanded(
            flex: 9,
            child: (expenses.isEmpty)
                ? Center(
                    child: Text(years[_yearSelected] +
                        " " +
                        months[_monthSelected] +
                        " လ အတွက် အသုံးစရိတ်မှတ်တမ်း မရှိသေးပါ။"))
                : Container(
                    margin: EdgeInsets.only(
                        right: Responsive.isMobile(context) ? 20 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          types[1],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Expanded(
                          child: SfDataGrid(
                            source: Responsive.isMobile(context)
                                ? expenseMobileDataSource
                                : expenseDataSource,
                            onCellTap: (details) async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditExpenseScreen(
                                            expense: expenses[details
                                                    .rowColumnIndex.rowIndex -
                                                1],
                                          )));
                            },
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            columnWidthMode: Responsive.isMobile(context)
                                ? ColumnWidthMode.fill
                                : ColumnWidthMode.auto,
                            columns: <GridColumn>[
                              if (!Responsive.isMobile(context))
                                GridColumn(
                                    columnName: 'စဥ်',
                                    label: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        color: primaryColor,
                                        padding: const EdgeInsets.all(8.0),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'စဥ်',
                                          style: TextStyle(color: Colors.white),
                                        ))),
                              if (!Responsive.isMobile(context))
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
                                  columnName: 'အကြောင်းအရာ',
                                  label: Container(
                                      color: primaryColor,
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'အကြောင်းအရာ',
                                        style: TextStyle(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ))),
                              GridColumn(
                                  columnName: 'ကုန်ကျစရိတ်',
                                  label: Container(
                                      color: primaryColor,
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'ကုန်ကျစရိတ်',
                                        style: TextStyle(color: Colors.white),
                                      ))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      );
    }
  }

 

  Widget monthlyReport(int leftBalance, int totalDonation, int totalExpense,
      int thisMonthLeftBalance) {
    if (Responsive.isMobile(context)) {
      return Container(
        decoration: shadowDecoration(Colors.white),
        // padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20, top: 12),
        margin: EdgeInsets.only(left: Responsive.isMobile(context) ? 0 : 30),
        child: Column(
          children: [
            Text(
                "${"${Utils.strToMM(years[_yearSelected].toString())} ${convertToMMMonthName(_monthSelected)}"} လ စာရင်းရှင်းတမ်း",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: NeumorphicTheme.of(context)?.current!.variantColor)),
            const SizedBox(
              height: 12,
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: const Text(
                        "ဝင်ငွေ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
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
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "စာရင်းဖွင့်လက်ကျန်ငွေ",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  "${Utils.strToMM(leftBalance.toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 13,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ယခုလ အလှူငွေ စုစုပေါင်း",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  "${Utils.strToMM(totalDonation.toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 13,
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
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "စုစုပေါင်း",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicTheme.of(context)
                                    ?.current!
                                    .variantColor),
                          ),
                          Text(
                            "${Utils.strToMM((totalDonation + leftBalance).toString())} ကျပ်",
                            style: TextStyle(
                                fontSize: 14,
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
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: const Text(
                        "အသုံးစရိတ်",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
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
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: Responsive.isMobile(context) ? 8 : 12,
                          top: Responsive.isMobile(context) ? 8 : 12,
                          bottom: Responsive.isMobile(context) ? 8 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 12),
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "စုစုပေါင်း ကုန်ကျငွေ",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  "${Utils.strToMM(totalExpense.toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 13,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "စာရင်းပိတ် လက်ကျန်ငွေ",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  "${Utils.strToMM((thisMonthLeftBalance).toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 13,
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
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "စုစုပေါင်း",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicTheme.of(context)
                                    ?.current!
                                    .variantColor),
                          ),
                          Text(
                            "${Utils.strToMM((totalDonation + leftBalance).toString())} ကျပ်",
                            style: TextStyle(
                                fontSize: 14,
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
          ],
        ),
      );
    } else {
      return Container(
        decoration: shadowDecoration(Colors.white),
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20, top: 12),
        margin: EdgeInsets.only(left: Responsive.isMobile(context) ? 0 : 30),
        child: Column(
          children: [
            Text(
                "${"${Utils.strToMM(years[_yearSelected].toString())} ${convertToMMMonthName(_monthSelected)}"} လ စာရင်းရှင်းတမ်း",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: NeumorphicTheme.of(context)?.current!.variantColor)),
            const SizedBox(
              height: 40,
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
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
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
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
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
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Container(
                            padding: const EdgeInsets.only(right: 12),
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  "${Utils.strToMM((thisMonthLeftBalance).toString())} ကျပ်",
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
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
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
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
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
          ],
        ),
      );
    }
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
