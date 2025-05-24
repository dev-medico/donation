import 'package:donation/responsive.dart';
import 'package:donation/src/common_widgets/common_tab_bar.dart';
import 'package:donation/src/features/donar/donar_yearly_report.dart';
import 'package:donation/src/features/donar/providers/yearly_report_provider.dart';
import 'package:donation/src/features/donar/yearly_report_screen.dart';
import 'package:donation/src/features/services/donar_record_service.dart';
import 'package:donation/src/features/services/expense_record_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:donation/src/features/donar/donar_data_source_new.dart';

class DonarListScreen extends ConsumerStatefulWidget {
  const DonarListScreen({Key? key, this.fromHome = false}) : super(key: key);
  static const routeName = "/donar-list";
  final bool fromHome;

  @override
  ConsumerState<DonarListScreen> createState() => _DonarListScreenState();
}

class _DonarListScreenState extends ConsumerState<DonarListScreen> {
  int _yearSelected = 0;
  int _monthSelected = DateTime.now().month - 1;

  List<String> years =
      List.generate(13, (index) => (DateTime.now().year - index).toString());

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
    "DEC"
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
    "12"
  ];

  List<String> monthsMM = [
    "ဇန်နဝါရီ",
    "ဖေဖော်ဝါရီ",
    "မတ်",
    "ဧပြီ",
    "မေ",
    "ဇွန်",
    "ဇူလိုင်",
    "ဩဂုတ်",
    "စက်တင်ဘာ",
    "အောက်တိုဘာ",
    "နိုဝင်ဘာ",
    "ဒီဇင်ဘာ"
  ];

  bool isLoading = false;
  Map<int, List<dynamic>> donorsByMonth = {};
  Map<int, List<dynamic>> expensesByMonth = {};
  Map<int, int> openingBalanceByMonth = {};
  Map<int, int> closingBalanceByMonth = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final selectedYear = int.parse(years[_yearSelected]);

      // Load yearly report data to get monthly stats
      final reportData =
          await ref.read(yearlyReportProvider(selectedYear).future);

      // Calculate opening and closing balances
      _calculateBalances(reportData);

      // Load only the current selected month data
      await _loadMonthData(_monthSelected + 1);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMonthData(int month) async {
    final donarService = ref.read(donarRecordServiceProvider);
    final expenseService = ref.read(expenseRecordServiceProvider);

    try {
      final selectedYear = int.parse(years[_yearSelected]);

      // Get start and end dates for the month
      final startDate = DateTime(selectedYear, month, 1);
      final endDate = DateTime(selectedYear, month + 1, 0);

      // Fetch donors for the month
      final donors = await donarService.getDonarRecords(
        startDate: DateFormat('yyyy-MM-dd').format(startDate),
        endDate: DateFormat('yyyy-MM-dd').format(endDate),
        limit: 1000,
      );

      // Fetch expenses for the month
      final expenses = await expenseService.getExpenseRecords(
        startDate: DateFormat('yyyy-MM-dd').format(startDate),
        endDate: DateFormat('yyyy-MM-dd').format(endDate),
        limit: 1000,
      );

      setState(() {
        donorsByMonth[month] = donors;
        expensesByMonth[month] = expenses;
      });
    } catch (e) {
      print('Error loading month $month data: $e');
    }
  }

  void _calculateBalances(YearlyReportData reportData) {
    int runningBalance = reportData.openingBalance;

    for (int month = 1; month <= 12; month++) {
      openingBalanceByMonth[month] = runningBalance;

      final monthDonation = reportData.monthlyDonation[month - 1];
      final monthExpense = reportData.monthlyExpense[month - 1];

      runningBalance = runningBalance + monthDonation - monthExpense;
      closingBalanceByMonth[month] = runningBalance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.fromHome
          ? null
          : AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [primaryColor, primaryDark],
                  ),
                ),
              ),
              centerTitle: true,
              title: const Text(
                "ရ/သုံး ငွေစာရင်း",
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: _showYearlyReport,
                ),
              ],
            ),
      body: Stack(
        children: [
          Column(
            children: [
              // Year selector
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                margin: const EdgeInsets.all(8),
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
                              onTap: () async {
                                _yearSelected = i;
                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  final selectedYear =
                                      int.parse(years[_yearSelected]);

                                  // Load yearly report data to get monthly stats
                                  final reportData = await ref.read(
                                      yearlyReportProvider(selectedYear)
                                          .future);

                                  // Calculate opening and closing balances
                                  _calculateBalances(reportData);

                                  // Clear previous month data
                                  donorsByMonth.clear();
                                  expensesByMonth.clear();

                                  // Load only the current selected month data
                                  await _loadMonthData(_monthSelected + 1);
                                } catch (e) {
                                  print('Error loading year data: $e');
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Month selector
              Container(
                margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
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
                        onTap: () async {
                          _monthSelected = i;
                          final month = i + 1;

                          // Check if data for this month is already loaded
                          if (!donorsByMonth.containsKey(month) ||
                              !expensesByMonth.containsKey(month)) {
                            setState(() {
                              isLoading = true;
                            });

                            try {
                              await _loadMonthData(month);
                            } catch (e) {
                              print('Error loading month data: $e');
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          } else {
                            setState(() {});
                          }
                        },
                      ),
                  ],
                ),
              ),

              // Month content
              Expanded(
                child: _buildMonthContent(_monthSelected + 1),
              ),
            ],
          ),

          // Loading indicator
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMonthContent(int month) {
    final donors = donorsByMonth[month] ?? [];
    final expenses = expensesByMonth[month] ?? [];
    final openingBalance = openingBalanceByMonth[month] ?? 0;
    final closingBalance = closingBalanceByMonth[month] ?? 0;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Summary card - More compact design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Month header - Slimmer
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.symmetric(vertical: 8),
                //   decoration: BoxDecoration(
                //     color: primaryColor.withOpacity(0.1),
                //     borderRadius: const BorderRadius.only(
                //       topLeft: Radius.circular(12),
                //       topRight: Radius.circular(12),
                //     ),
                //   ),
                //   child: Text(
                //     '${monthsMM[month - 1]}လ',
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //       fontSize: 14,
                //       fontWeight: FontWeight.bold,
                //       color: primaryColor,
                //     ),
                //   ),
                // ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Opening and Closing balance in one row - Space efficient
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.blue[700],
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'စာရင်းဖွင့်',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${Utils.strToMM(openingBalance.toString())}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance,
                                        color: primaryColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'စာရင်းပိတ်',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${Utils.strToMM(closingBalance.toString())}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Donations and Expenses in a row - Compact
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.green[700],
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'အလှူ',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${Utils.strToMM(_calculateTotal(donors, 'amount').toString())}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.red[700],
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'အသုံး',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${Utils.strToMM(_calculateTotal(expenses, 'amount').toString())}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Side by side tables for donors and expenses (responsive)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Responsive.isMobile(context)
                  ? Column(
                      children: [
                        // Donors table (mobile - top half)
                        Expanded(
                          child:
                              _buildDonarSection(donors, month, Colors.green),
                        ),
                        const SizedBox(height: 16),
                        // Expenses table (mobile - bottom half)
                        Expanded(
                          child:
                              _buildExpenseSection(expenses, month, Colors.red),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Donors table (desktop - left half)
                        Expanded(
                          child:
                              _buildDonarSection(donors, month, Colors.green),
                        ),

                        const SizedBox(width: 16),

                        // Expenses table (desktop - right half)
                        Expanded(
                          child:
                              _buildExpenseSection(expenses, month, Colors.red),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorsList(List<dynamic> donors, int month) {
    if (donors.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('ဤလအတွက် အလှူရှင်မှတ်တမ်း မရှိသေးပါ'),
          ),
        ),
      );
    }

    final dataSource = DonarDataSource(donarData: donors);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: SfDataGrid(
          source: dataSource,
          onCellTap: (details) {
            if (details.rowColumnIndex.rowIndex > 0) {
              final index = details.rowColumnIndex.rowIndex - 1;
              if (index < donors.length) {
                _showEditDonorDialog(donors[index]);
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
                columnName: 'စဥ်',
                label: Container(
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
    );
  }

  Widget _buildExpensesList(List<dynamic> expenses, int month) {
    if (expenses.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('ဤလအတွက် အသုံးစရိတ်မှတ်တမ်း မရှိသေးပါ'),
          ),
        ),
      );
    }

    final dataSource = ExpenseDataSource(expenseData: expenses);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: SfDataGrid(
          source: dataSource,
          onCellTap: (details) {
            if (details.rowColumnIndex.rowIndex > 0) {
              final index = details.rowColumnIndex.rowIndex - 1;
              if (index < expenses.length) {
                _showEditExpenseDialog(expenses[index]);
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
                columnName: 'စဥ်',
                label: Container(
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
                columnName: 'အကြောင်းအရာ',
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'အကြောင်းအရာ',
                      style: TextStyle(color: Colors.white),
                    ))),
            GridColumn(
                columnName: 'အသုံးစရိတ်',
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'အသုံးစရိတ်',
                      style: TextStyle(color: Colors.white),
                    ))),
          ],
        ),
      ),
    );
  }

  int _calculateTotal(List<dynamic> items, String field) {
    return items.fold(0, (sum, item) => sum + (item[field] as int? ?? 0));
  }

  Widget _buildDonarSection(
      List<dynamic> donors, int month, MaterialColor color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Donors header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.volunteer_activism,
                  size: 18,
                  color: color[700],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'အလှူရှင်',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color[700],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${donors.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Donors table content
        Expanded(
          child: _buildDonorsList(donors, month),
        ),
      ],
    );
  }

  Widget _buildExpenseSection(
      List<dynamic> expenses, int month, MaterialColor color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expenses header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 18,
                  color: color[700],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'အသုံးစရိတ်',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color[700],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${expenses.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Expenses table content
        Expanded(
          child: _buildExpensesList(expenses, month),
        ),
      ],
    );
  }

  void _showYearlyReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const YearlyReportScreen(),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddRecordDialog(
        year: int.parse(years[_yearSelected]),
        onAdded: () {
          // Reload only the current month data
          _loadMonthData(_monthSelected + 1);
        },
      ),
    );
  }

  void _showEditDonorDialog(dynamic donor) {
    // TODO: Implement edit donor dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit donor feature coming soon')),
    );
  }

  void _showEditExpenseDialog(dynamic expense) {
    // TODO: Implement edit expense dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit expense feature coming soon')),
    );
  }
}

// Add record dialog widget
class _AddRecordDialog extends ConsumerStatefulWidget {
  final int year;
  final VoidCallback onAdded;

  const _AddRecordDialog({
    required this.year,
    required this.onAdded,
  });

  @override
  ConsumerState<_AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends ConsumerState<_AddRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isDonor = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(_isDonor ? 'အလှူရှင် မှတ်တမ်းအသစ်' : 'အသုံးစရိတ် မှတ်တမ်းအသစ်'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type selector
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('အလှူရှင်'),
                      value: true,
                      groupValue: _isDonor,
                      onChanged: (value) {
                        setState(() {
                          _isDonor = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('အသုံးစရိတ်'),
                      value: false,
                      groupValue: _isDonor,
                      onChanged: (value) {
                        setState(() {
                          _isDonor = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText:
                      _isDonor ? 'အလှူရှင် အမည်' : 'အသုံးစရိတ် အကြောင်းအရာ',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ဖြည့်သွင်းရန် လိုအပ်ပါသည်';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'ငွေပမာဏ',
                  border: OutlineInputBorder(),
                  suffixText: 'ကျပ်',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ဖြည့်သွင်းရန် လိုအပ်ပါသည်';
                  }
                  if (int.tryParse(value) == null) {
                    return 'ကိန်းဂဏန်းသာ ထည့်သွင်းပါ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(widget.year, 1, 1),
                    lastDate: DateTime(widget.year, 12, 31),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('မလုပ်တော့ပါ'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'သိမ်းမည်',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'name': _nameController.text,
        'amount': int.parse(_amountController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };

      if (_isDonor) {
        final service = ref.read(donarRecordServiceProvider);
        await service.createDonarRecord(data);
      } else {
        final service = ref.read(expenseRecordServiceProvider);
        await service.createExpenseRecord(data);
      }

      Navigator.pop(context);
      widget.onAdded();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isDonor
                ? 'အလှူရှင်မှတ်တမ်း အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ'
                : 'အသုံးစရိတ်မှတ်တမ်း အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
