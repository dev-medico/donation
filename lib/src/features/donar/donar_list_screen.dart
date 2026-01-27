import 'package:donation/responsive.dart';
import 'package:donation/src/common_widgets/common_tab_bar.dart';
import 'package:donation/src/features/donar/providers/yearly_report_provider.dart';
import 'package:donation/src/features/donar/yearly_report_screen.dart';
import 'package:donation/src/features/services/donar_record_service.dart';
import 'package:donation/src/features/services/expense_record_service.dart';
import 'package:donation/src/features/money_donor/models/money_donor.dart';
import 'package:donation/src/features/money_donor/providers/money_donor_provider.dart';
import 'package:donation/src/features/money_donor/money_donor_form.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
            child: Padding(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: Colors.green[700],
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'အလှူ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${Utils.strToMM(_calculateTotal(donors, 'amount').toString())}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: Colors.red[700],
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'အသုံး',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${Utils.strToMM(_calculateTotal(expenses, 'amount').toString())}',
                                style: TextStyle(
                                  fontSize: 12,
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
          ),

          // Tables section (responsive)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Responsive.isMobile(context)
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          // Donors table (mobile)
                          SizedBox(
                            height: 280,
                            child: _buildDonarSection(donors, month, Colors.green),
                          ),
                          const SizedBox(height: 16),
                          // Expenses table (mobile)
                          SizedBox(
                            height: 280,
                            child: _buildExpenseSection(expenses, month, Colors.red),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Donors table (desktop)
                        Expanded(
                          child: _buildDonarSection(donors, month, Colors.green),
                        ),
                        const SizedBox(width: 16),
                        // Expenses table (desktop)
                        Expanded(
                          child: _buildExpenseSection(expenses, month, Colors.red),
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
            GridColumn(
                columnName: 'edit',
                width: 50,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 16,
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
            GridColumn(
                columnName: 'edit',
                width: 50,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 16,
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
    showDialog(
      context: context,
      builder: (context) => _EditDonorRecordDialog(
        donor: donor,
        year: int.parse(years[_yearSelected]),
        onUpdated: () async {
          final month = _monthSelected + 1;
          donorsByMonth.remove(month);
          setState(() { isLoading = true; });
          try {
            await _loadMonthData(month);
            final selectedYear = int.parse(years[_yearSelected]);
            ref.invalidate(yearlyReportProvider(selectedYear));
            final reportData =
                await ref.read(yearlyReportProvider(selectedYear).future);
            _calculateBalances(reportData);
          } finally {
            setState(() { isLoading = false; });
          }
        },
      ),
    );
  }

  void _showEditExpenseDialog(dynamic expense) {
    showDialog(
      context: context,
      builder: (context) => _EditExpenseRecordDialog(
        expense: expense,
        year: int.parse(years[_yearSelected]),
        onUpdated: () async {
          final month = _monthSelected + 1;
          expensesByMonth.remove(month);
          setState(() { isLoading = true; });
          try {
            await _loadMonthData(month);
            final selectedYear = int.parse(years[_yearSelected]);
            ref.invalidate(yearlyReportProvider(selectedYear));
            final reportData =
                await ref.read(yearlyReportProvider(selectedYear).future);
            _calculateBalances(reportData);
          } finally {
            setState(() { isLoading = false; });
          }
        },
      ),
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

  // Selected money donor
  MoneyDonor? _selectedMoneyDonor;
  bool _showMoneyDonorForm = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
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

              // Name field - use TypeAhead for donors, regular TextField for expenses
              if (_isDonor)
                TypeAheadFormField<MoneyDonor>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'အလှူရှင် အမည်',
                      hintText: 'ရှာဖွေရန် အမည်ရိုက်ထည့်ပါ',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) return [];
                    try {
                      final service = ref.read(moneyDonorServiceProvider);
                      return await service.searchMoneyDonors(pattern);
                    } catch (e) {
                      print('Error searching donors: $e');
                      return [];
                    }
                  },
                  itemBuilder: (context, MoneyDonor donor) {
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(donor.name ?? '')),
                          if (donor.isOrganization == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'အဖွဲ့အစည်း',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: donor.phone != null ? Text(donor.phone!) : null,
                      dense: true,
                    );
                  },
                  onSuggestionSelected: (MoneyDonor donor) {
                    setState(() {
                      _selectedMoneyDonor = donor;
                      _nameController.text = donor.name ?? '';
                    });
                  },
                  noItemsFoundBuilder: (context) {
                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('မတွေ့ပါ'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.add_circle, color: Colors.green),
                          title: const Text('အလှူရှင်အသစ် ထည့်ရန်'),
                          onTap: () {
                            // Close the dialog first
                            Navigator.of(context).pop();
                            // Navigate to money donor form
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MoneyDonorFormScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ဖြည့်သွင်းရန် လိုအပ်ပါသည်';
                    }
                    return null;
                  },
                )
              else
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'အသုံးစရိတ် အကြောင်းအရာ',
                    border: OutlineInputBorder(),
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
        ),

        // Money donor form overlay
        if (_showMoneyDonorForm)
          MoneyDonorFormDialog(
            onSaved: (MoneyDonor newDonor) {
              setState(() {
                _selectedMoneyDonor = newDonor;
                _nameController.text = newDonor.name ?? '';
                _showMoneyDonorForm = false;
              });
            },
            onCancel: () {
              setState(() {
                _showMoneyDonorForm = false;
              });
            },
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
      final data = <String, dynamic>{
        'name': _nameController.text,
        'amount': int.parse(_amountController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };

      // Add money_donor_id if a donor was selected
      if (_isDonor && _selectedMoneyDonor?.id != null) {
        data['money_donor_id'] = _selectedMoneyDonor!.id!;
      }

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

// Money Donor Form Dialog Widget for inline creation
class MoneyDonorFormDialog extends ConsumerStatefulWidget {
  final Function(MoneyDonor) onSaved;
  final VoidCallback onCancel;

  const MoneyDonorFormDialog({
    Key? key,
    required this.onSaved,
    required this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<MoneyDonorFormDialog> createState() => _MoneyDonorFormDialogState();
}

class _MoneyDonorFormDialogState extends ConsumerState<MoneyDonorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isOrganization = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveDonor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'note': _noteController.text.trim(),
        'is_organization': _isOrganization,
      };

      final service = ref.read(moneyDonorServiceProvider);
      final newDonor = await service.createMoneyDonor(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('အလှူရှင်အသစ် အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaved(newDonor);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('သိမ်းဆည်းရန် မအောင်မြင်ပါ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_add, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'အလှူရှင်အသစ် ထည့်သွင်းရန်',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onCancel,
                    ),
                  ],
                ),
              ),

              // Form content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'အမည် *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'အမည် ထည့်သွင်းပါ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Phone field
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'ဖုန်းနံပါတ်',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),

                        // Organization toggle
                        SwitchListTile(
                          title: const Text('အဖွဲ့အစည်း'),
                          subtitle: Text(
                            _isOrganization ? 'အဖွဲ့အစည်း/ကုမ္ပဏီ' : 'လူပုဂ္ဂိုလ်',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          value: _isOrganization,
                          onChanged: (value) {
                            setState(() => _isOrganization = value);
                          },
                          activeColor: primaryColor,
                        ),
                        const SizedBox(height: 12),

                        // Address field
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'လိပ်စာ',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),

                        // Note field
                        TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'မှတ်ချက်',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : widget.onCancel,
                      child: const Text('မလုပ်တော့ပါ'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveDonor,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Donor Record Dialog
class _EditDonorRecordDialog extends ConsumerStatefulWidget {
  final dynamic donor;
  final int year;
  final Future<void> Function() onUpdated;

  const _EditDonorRecordDialog({
    required this.donor,
    required this.year,
    required this.onUpdated,
  });

  @override
  ConsumerState<_EditDonorRecordDialog> createState() =>
      _EditDonorRecordDialogState();
}

class _EditDonorRecordDialogState
    extends ConsumerState<_EditDonorRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.donor['amount']?.toString() ?? '';
    _selectedDate = DateTime.parse(widget.donor['date']);
  }

  String get _donorName {
    if (widget.donor['moneyDonor'] != null &&
        widget.donor['moneyDonor']['name'] != null) {
      return widget.donor['moneyDonor']['name'];
    }
    return widget.donor['name'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryDark],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'အလှူမှတ်တမ်း ပြင်ဆင်ရန်',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Donor name (read-only)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'အလှူရှင်',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _donorName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Amount field
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'ငွေပမာဏ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixText: 'ကျပ်',
                          prefixIcon: const Icon(Icons.attach_money),
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

                      const SizedBox(height: 18),

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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 20, color: Colors.grey[600]),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ရက်စွဲ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(_selectedDate),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('မလုပ်တော့ပါ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = <String, dynamic>{
        'amount': int.parse(_amountController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };

      final service = ref.read(donarRecordServiceProvider);
      await service.updateDonarRecord(
          widget.donor['id'].toString(), data);

      if (mounted) {
        Navigator.pop(context);
        widget.onUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('အလှူမှတ်တမ်း အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ပြင်ဆင်ရန် မအောင်မြင်ပါ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

// Edit Expense Record Dialog
class _EditExpenseRecordDialog extends ConsumerStatefulWidget {
  final dynamic expense;
  final int year;
  final Future<void> Function() onUpdated;

  const _EditExpenseRecordDialog({
    required this.expense,
    required this.year,
    required this.onUpdated,
  });

  @override
  ConsumerState<_EditExpenseRecordDialog> createState() =>
      _EditExpenseRecordDialogState();
}

class _EditExpenseRecordDialogState
    extends ConsumerState<_EditExpenseRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.expense['name'] ?? '';
    _amountController.text = widget.expense['amount']?.toString() ?? '';
    _selectedDate = DateTime.parse(widget.expense['date']);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryDark],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'အသုံးစရိတ် ပြင်ဆင်ရန်',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field (editable for expenses)
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'အကြောင်းအရာ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ဖြည့်သွင်းရန် လိုအပ်ပါသည်';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // Amount field
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'ငွေပမာဏ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixText: 'ကျပ်',
                          prefixIcon: const Icon(Icons.attach_money),
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

                      const SizedBox(height: 18),

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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 20, color: Colors.grey[600]),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ရက်စွဲ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(_selectedDate),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('မလုပ်တော့ပါ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = <String, dynamic>{
        'name': _nameController.text,
        'amount': int.parse(_amountController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };

      final service = ref.read(expenseRecordServiceProvider);
      await service.updateExpenseRecord(
          widget.expense['id'].toString(), data);

      if (mounted) {
        Navigator.pop(context);
        widget.onUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('အသုံးစရိတ် အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ပြင်ဆင်ရန် မအောင်မြင်ပါ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
