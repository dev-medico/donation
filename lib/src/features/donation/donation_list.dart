// import 'dart:developer';

import 'package:donation/responsive.dart';
import 'package:donation/src/common_widgets/common_tab_bar.dart';
import 'package:donation/src/features/donation/blood_donation_report.dart';
import 'package:donation/src/features/donation/donation_data_source.dart';
import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/donation/new_blood_donation.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:donation/src/features/services/donation_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DonationListScreen extends ConsumerStatefulWidget {
  const DonationListScreen({super.key, this.fromHome = false});
  static const routeName = "/donations";
  final bool fromHome;

  @override
  ConsumerState<DonationListScreen> createState() => _DonationListScreenState();
}

class _DonationListScreenState extends ConsumerState<DonationListScreen> {
  int _yearSelected = 0;
  int _monthSelected = DateTime.now().month - 1;
  List<String> years = [
    "2025",
    "2024",
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
    var donationData = ref.watch(donationsByMonthYearProvider(
        (month: _monthSelected + 1, year: int.parse(years[_yearSelected]))));
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewBloodDonationScreen(),
            ),
          );
          // Refresh the list after returning from new donation screen
          ref.refresh(donationsByMonthYearProvider((
            month: _monthSelected + 1,
            year: int.parse(years[_yearSelected])
          )));
        },
        child: const Icon(Icons.add),
      ),
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
          child: Text("သွေးလှူဒါန်းမှုစာရင်း",
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
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    width: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width * 1.8
                        : MediaQuery.of(context).size.width * 0.8,
                    height: Responsive.isMobile(context) ? 40 : 60,
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
              child: donationData.when(
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
                                var data = ref.watch(donationsByYearProvider(
                                    int.parse(years[_yearSelected])));
                                List<Donation> yearData = [];
                                if (data.value != null) {
                                  yearData = List.from(data.value!);
                                }
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
                                            "နှစ်ချုပ် မှတ်တမ်း",
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
                                " လ အတွက် သွေးလှူရှင်မှတ်တမ်း မရှိသေးပါ။")),
                      ],
                    );
                  } else {
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
                                        donationsByYearProvider(
                                            int.parse(years[_yearSelected])));
                                    List<Donation> yearData = [];
                                    if (data.value != null) {
                                      yearData = List.from(data.value!);
                                    }
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
                                                  top: 12,
                                                  bottom: 12,
                                                  left: 12),
                                              child: Text(
                                                "နှစ်ချုပ် မှတ်တမ်း",
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BloodDonationReportScreen(
                                                  isYearly: false,
                                                  month: _monthSelected,
                                                  year: years[_yearSelected],
                                                  data: results,
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
                                                "လချုပ် မှတ်တမ်း",
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
                                  left: Responsive.isMobile(context) ? 8 : 12,
                                  top: Responsive.isMobile(context) ? 8 : 12,
                                  bottom: 12),
                              child: buildSimpleTable(results),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
                error: (Object error, StackTrace stackTrace) {
                  print('Error in donation list: $error');
                  print('Stack trace: $stackTrace');
                  // Rethrow the error for better debugging
                  throw error;
                },
                loading: () {
                  final loadingStatus =
                      ref.watch(donationLoadingStatusProvider);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          loadingStatus.isNotEmpty
                              ? loadingStatus
                              : 'Loading...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSimpleTable(List<Donation> data) {
    DonationDataSource memberDataDataSource =
        DonationDataSource(donationData: data, ref: ref);
    return Container(
      margin: EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
      child: SfDataGrid(
        source: memberDataDataSource,
        onCellTap: (details) async {
          if (details.rowColumnIndex.rowIndex > 0) {
            final index = details.rowColumnIndex.rowIndex - 1;
            if (index < data.length) {
              // Create a new donation instance to ensure type compatibility
              final donation = data[index];
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DonationDetailScreen(
                            data: donation,
                          )));
              // Refresh the list after returning from detail screen
              ref.refresh(donationsByMonthYearProvider((
                month: _monthSelected + 1,
                year: int.parse(years[_yearSelected])
              )));
            }
          }
        },
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: Responsive.isMobile(context)
            ? ColumnWidthMode.auto
            : ColumnWidthMode.fitByCellValue,
        columns: <GridColumn>[
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
              columnName: 'သွေးအလှူရှင်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'သွေးအလှူရှင်',
                    style: TextStyle(color: Colors.white),
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
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'လှူဒါန်းသည့်နေရာ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'လှူဒါန်းသည့်နေရာ',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'လူနာအမည်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'လူနာအမည်',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'လိပ်စာ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'လိပ်စာ',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'အသက်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'အသက်',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'ဖြစ်ပွားသည့်ရောဂါ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'ဖြစ်ပွားသည့်ရောဂါ',
                    style: TextStyle(color: Colors.white),
                  ))),
        ],
      ),
    );
  }
}
