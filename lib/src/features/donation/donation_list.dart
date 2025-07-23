// import 'dart:developer';

import 'package:donation/responsive.dart';
import 'package:donation/src/common_widgets/common_tab_bar.dart';
import 'package:donation/src/features/donation/blood_donation_report.dart';
import 'package:donation/src/features/donation/donation_data_source.dart';
import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/donation/new_blood_donation.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
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

class _DonationListScreenState extends ConsumerState<DonationListScreen>
    with SingleTickerProviderStateMixin {
  int _yearSelected = 0;
  int _monthSelected = DateTime.now().month - 1;
  late TabController _tabController;

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
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: _monthSelected,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _monthSelected = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Select Year',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    final isSelected =
                        int.parse(year) == int.parse(years[_yearSelected]);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _yearSelected = index;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            year,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

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
          ref.invalidate(donationsByMonthYearProvider);
        },
        child: const Icon(Icons.add),
      ),
      appBar: Responsive.isMobile(context)
          ? null
          : AppBar(
              flexibleSpace: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [primaryColor, primaryDark],
              ))),
              leading: Padding(
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
                    textScaler: TextScaler.linear(1.0),
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white)),
              ),
            ),
      body: Container(
        margin: EdgeInsets.all(isMobile ? 0 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year selector - show dropdown for mobile, tabs for desktop
            if (isMobile) ...[
              // Mobile year selector
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: InkWell(
                  onTap: _showYearPicker,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Year: ${years[_yearSelected]}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: primaryColor, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Mobile month tabs
              Container(
                height: 32,
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: primaryColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: primaryColor,
                  ),
                  tabs: months
                      .map((month) => Tab(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(month,
                                  style: const TextStyle(fontSize: 11)),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ] else ...[
              // Desktop year tabs
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
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
              // Desktop month tabs
              Container(
                margin: EdgeInsets.only(top: 8),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 60,
                child: CommonTabBar(
                  underline: false,
                  listWidget: [
                    for (int i = 0; i < months.length; i++)
                      CommonTabBarWidget(
                        color: primaryColor,
                        underline: false,
                        name: months[i],
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
            ],
            Expanded(
              child: donationData.when(
                data: (results) {
                  if (results.isEmpty) {
                    return Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            height: isMobile ? 42 : 60,
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(isMobile ? 8 : 12))),
                            margin: EdgeInsets.only(
                              left: isMobile ? 12 : 15,
                              top: isMobile ? 8 : 12,
                            ),
                            width: isMobile ? 140 : 164,
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
                                    children: [
                                      SizedBox(
                                        width: isMobile ? 8 : 12,
                                      ),
                                      Icon(Icons.list_alt_outlined,
                                          color: Colors.white, size: isMobile ? 18 : 24),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              top: isMobile ? 8 : 12, 
                                              bottom: isMobile ? 8 : 12, 
                                              left: isMobile ? 8 : 12),
                                          child: Text(
                                            "နှစ်ချုပ် မှတ်တမ်း",
                                            textScaler: TextScaler.linear(1.0),
                                            style: TextStyle(
                                                fontSize: isMobile ? 12 : 15,
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
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(isMobile ? 8 : 12))),
                                margin: EdgeInsets.only(
                                  left: isMobile ? 12 : 15,
                                  top: isMobile ? 8 : 12,
                                ),
                                width: isMobile ? 140 : 164,
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
                                        children: [
                                          SizedBox(
                                            width: isMobile ? 8 : 12,
                                          ),
                                          Icon(Icons.list_alt_outlined,
                                              color: Colors.white, size: isMobile ? 18 : 24),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: isMobile ? 8 : 12,
                                                  bottom: isMobile ? 8 : 12,
                                                  left: isMobile ? 8 : 12),
                                              child: Text(
                                                "နှစ်ချုပ် မှတ်တမ်း",
                                                textScaler:
                                                    TextScaler.linear(1.0),
                                                style: TextStyle(
                                                    fontSize: isMobile ? 12 : 15,
                                                    color: Colors.white),
                                              )),
                                        ],
                                      )),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(isMobile ? 8 : 12))),
                                margin: EdgeInsets.only(
                                  left: isMobile ? 8 : 15,
                                  top: isMobile ? 8 : 12,
                                ),
                                width: isMobile ? 130 : 160,
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
                                        children: [
                                          SizedBox(
                                            width: isMobile ? 8 : 12,
                                          ),
                                          Icon(Icons.list_alt_outlined,
                                              color: Colors.white, size: isMobile ? 18 : 24),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: isMobile ? 8 : 12,
                                                  bottom: isMobile ? 8 : 12,
                                                  left: isMobile ? 8 : 12),
                                              child: Text(
                                                "လချုပ် မှတ်တမ်း",
                                                textScaler:
                                                    TextScaler.linear(1.0),
                                                style: TextStyle(
                                                    fontSize: isMobile ? 12 : 15,
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
                                  left: isMobile ? 4 : 12,
                                  right: isMobile ? 4 : 0,
                                  top: isMobile ? 4 : 12,
                                  bottom: isMobile ? 4 : 12),
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
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    DonationDataSource memberDataDataSource =
        DonationDataSource(donationData: data, ref: ref);

    // Unified responsive data grid for all devices
    return Container(
      margin: EdgeInsets.only(right: isMobile ? 0 : 20),
      child: SfDataGrid(
        source: memberDataDataSource,
        headerRowHeight: isMobile ? 36 : 56,
        rowHeight: isMobile ? 32 : 52,
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
              ref.invalidate(donationsByMonthYearProvider);
            }
          }
        },
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: isMobile
            ? ColumnWidthMode.none
            : (isTablet ? ColumnWidthMode.fill : ColumnWidthMode.fitByCellValue),
        columns: <GridColumn>[
          GridColumn(
              columnName: 'ရက်စွဲ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    'ရက်စွဲ',
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 14),
                  ))),
          GridColumn(
              columnName: 'သွေးအလှူရှင်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    'သွေးအလှူရှင်',
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 14),
                  ))),
          GridColumn(
              columnName: 'သွေးအုပ်စု',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    'သွေးအုပ်စု',
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 14),
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'လှူဒါန်းသည့်နေရာ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    'လှူဒါန်းသည့်နေရာ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 11 : 14,
                    ),
                  ))),
          GridColumn(
              columnName: 'လူနာ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    'လူနာ',
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 14),
                  ))),
          GridColumn(
              columnName: 'လိပ်စာ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    'လိပ်စာ',
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 14),
                  ))),
          GridColumn(
              columnName: 'အသက်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    'အသက်',
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 14),
                  ))),
          GridColumn(
              columnName: 'ဖြစ်ပွားသည့်ရောဂါ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    'ဖြစ်ပွားသည့်ရောဂါ',
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 14),
                  ))),
        ],
      ),
    );
  }
}
