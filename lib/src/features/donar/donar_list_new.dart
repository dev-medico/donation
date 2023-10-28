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
import 'package:donation/src/features/donar/new_donar.dart';
import 'package:donation/src/features/donar/new_expense_record.dart';
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
            Expanded(
              child: donarData.when(
                data: (results) {
                  if (results.isEmpty) {
                    return Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0))),
                            margin: const EdgeInsets.only(
                              left: 15,
                              top: 12,
                            ),
                            width: 164,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                var data = ref.watch(donationByYearProvider(
                                    int.parse(years[_yearSelected])));
                                List<Donation> yearData = [];
                                data.forEach((element) {
                                  yearData.add(element);
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BloodDonationReportScreen(
                                              month: _monthSelected,
                                              isYearly: true,
                                              year: years[_yearSelected],
                                              data: yearData,
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
                                            "နှစ်ချုပ် ရှင်းတမ်း",
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
                        Center(
                            child: Text(years[_yearSelected] +
                                " " +
                                months[_monthSelected] +
                                " လ အတွက် အလှူရှင်ရှင်းတမ်း မရှိသေးပါ။")),
                      ],
                    );
                  } else {
                    return expenseData.when(
                      data: (expenseResults) {
                        return Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12.0))),
                                    margin: const EdgeInsets.only(
                                      left: 15,
                                      top: 12,
                                    ),
                                    width: 164,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        var data = ref.watch(
                                            donationByYearProvider(int.parse(
                                                years[_yearSelected])));
                                        List<Donation> yearData = [];
                                        data.forEach((element) {
                                          yearData.add(element);
                                        });
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BloodDonationReportScreen(
                                                      month: _monthSelected,
                                                      isYearly: true,
                                                      year:
                                                          years[_yearSelected],
                                                      data: yearData,
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
                                                      top: 12,
                                                      bottom: 12,
                                                      left: 12),
                                                  child: Text(
                                                    "နှစ်ချုပ် ရှင်းတမ်း",
                                                    textScaleFactor: 1.0,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: Colors.white),
                                                  )),
                                            ],
                                          )),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12.0))),
                                    margin: const EdgeInsets.only(
                                      left: 15,
                                      top: 12,
                                    ),
                                    width: 160,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             BloodDonationReportScreen(
                                        //               isYearly: false,
                                        //               month: _monthSelected,
                                        //               year: years[_yearSelected],
                                        //               data: results,
                                        //             )));
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
                                                      left: 12),
                                                  child: Text(
                                                    "လချုပ် ရှင်းတမ်း",
                                                    textScaleFactor: 1.0,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: Colors.white),
                                                  )),
                                            ],
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                width: double.infinity,
                                height: double.infinity,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left:
                                          Responsive.isMobile(context) ? 8 : 12,
                                      top:
                                          Responsive.isMobile(context) ? 8 : 12,
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
                        );
                      },
                      error: (Object error, StackTrace stackTrace) {
                        return Center(child: Text(error.toString()));
                      },
                      loading: () {
                        return Container();
                      },
                    );
                  }
                },
                error: (Object error, StackTrace stackTrace) {
                  return Center(child: Text(error.toString()));
                },
                loading: () {
                  return Container();
                },
              ),
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

    int totalDonation = 0;
    int longTextCount = 0;
    int totalExpense = 0;

    data.forEach((element) {
      totalDonation += element.amount!;
    });

    expenses.forEach((element) {
      totalExpense += element.amount!;
    });

    if (Responsive.isMobile(context)) {
      return Container(
        margin: EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
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

            /// calculateLeftBalance();
            // callAPI("");
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
                  source: Responsive.isMobile(context)
                      ? donarMobileDataSource
                      : donarDataSource,
                  onCellTap: (details) async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditDonarScreen(
                                  donar:
                                      data[details.rowColumnIndex.rowIndex - 1],
                                )));
                    // calculateLeftBalance();
                    // callAPI("");
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
              )),
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
                        "${"${Utils.strToMM(years[_yearSelected].toString())} ${convertToMMMonthName(_monthSelected)}"} လ စာရင်းရှင်းတမ်း",
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
                                                            //  calculateLeftBalance();
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
                                                            //    //  calculateLeftBalance();
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
                              // calculateLeftBalance();
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
                              //  calculateLeftBalance();
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
                  ],
                ),
              ))
        ],
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
