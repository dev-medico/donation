import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/request_give_service.dart';
import 'package:donation/src/features/finder/request_give_list_screen.dart';

// Provider for detailed report data - using String key for proper caching
final requestGiveReportProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, key) async {
  try {
    ref.watch(requestGiveRevisionProvider);
    // Parse the key to extract year and month
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month =
        parts.length > 1 && parts[1] != 'null' ? int.parse(parts[1]) : null;

    print('Fetching report for year: $year, month: $month');

    final service = ref.read(requestGiveServiceProvider);
    final result = await service.getDetailedReport(year: year, month: month);

    print('Report data received: $result');

    // If the result is empty, return default structure
    if (result.isEmpty) {
      return {
        'monthlyData': [],
        'yearlyTotal': {'totalrequest': 0, 'totalgive': 0},
        'year': year,
      };
    }

    return result;
  } catch (e) {
    print('Error in requestGiveReportProvider: $e');
    throw e;
  }
});

class RequestGiveDetailScreenNew extends ConsumerStatefulWidget {
  const RequestGiveDetailScreenNew({Key? key}) : super(key: key);

  @override
  ConsumerState<RequestGiveDetailScreenNew> createState() =>
      _RequestGiveDetailScreenNewState();
}

class _RequestGiveDetailScreenNewState
    extends ConsumerState<RequestGiveDetailScreenNew> {
  int _yearSelected = 0;
  int? _monthSelected;
  bool showYearlyView = true;

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

  @override
  Widget build(BuildContext context) {
    final selectedYear = int.parse(years[_yearSelected]);
    final providerKey = showYearlyView
        ? '$selectedYear-null'
        : '$selectedYear-${_monthSelected! + 1}';

    final reportData = ref.watch(requestGiveReportProvider(providerKey));

    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
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
        title: Text(
          'တောင်းခံ/လှူဒါန်းမှု အစီရင်ခံစာ',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final contentWidth = isMobile
              ? double.infinity
              : MediaQuery.of(context).size.width * 0.7;

          return Column(
            children: [
              // Toggle buttons for နှစ်ချုပ် and လချုပ်
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: contentWidth,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showYearlyView = true;
                            });
                          },
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color:
                                  showYearlyView ? primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: showYearlyView
                                    ? primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: showYearlyView
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'နှစ်ချုပ် မှတ်တမ်း',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: showYearlyView
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontWeight: showYearlyView
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showYearlyView = false;
                              if (_monthSelected == null) {
                                _monthSelected = DateTime.now().month - 1;
                              }
                            });
                          },
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color:
                                  !showYearlyView ? primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !showYearlyView
                                    ? primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 16,
                                  color: !showYearlyView
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'လချုပ် မှတ်တမ်း',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: !showYearlyView
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontWeight: !showYearlyView
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Year selector tabs
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                margin: const EdgeInsets.all(8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _yearSelected = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _yearSelected == index
                              ? primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _yearSelected == index
                                ? primaryColor
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            years[index],
                            style: TextStyle(
                              color: _yearSelected == index
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: _yearSelected == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Month selector (if not yearly view)
              if (!showYearlyView)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _monthSelected = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: _monthSelected == index
                                ? primaryColor
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              months[index],
                              style: TextStyle(
                                color: _monthSelected == index
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: _monthSelected == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Main content area - left aligned with half screen width
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: contentWidth,
                    child: reportData.when(
                      data: (data) {
                        if (showYearlyView) {
                          return _buildYearlyView(data, selectedYear);
                        } else {
                          return _buildMonthlyView(
                              data, selectedYear, _monthSelected!);
                        }
                      },
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (error, stack) {
                        print('Error: $error');
                        print('Stack: $stack');
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text('Error loading data'),
                              Text(error.toString(),
                                  style: TextStyle(fontSize: 12)),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  ref.invalidate(requestGiveReportProvider);
                                },
                                child: Text('ပြန်လည်ကြိုးစားမည်'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openWorksheet,
        backgroundColor: primaryColor,
        child: Icon(Icons.edit_calendar_outlined, color: Colors.white),
        tooltip: 'နေ့စဉ်မှတ်တမ်း ဖြည့်မည်',
      ),
    );
  }

  Widget _buildTotalsCards({
    required Object totalRequest,
    required Object totalGive,
    required String percentage,
  }) {
    Widget requestCard() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.call_received, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'တောင်းခံမှု',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                totalRequest.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget giveCard() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.volunteer_activism,
                    color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'လှူဒါန်းမှု',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text(
                  totalGive.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '($percentage%)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            children: [
              SizedBox(width: double.infinity, child: requestCard()),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: giveCard()),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: requestCard()),
            const SizedBox(width: 12),
            Expanded(child: giveCard()),
          ],
        );
      },
    );
  }

  Widget _buildYearlyView(Map<String, dynamic> data, int year) {
    final monthlyData = (data['monthlyData'] as List<dynamic>?) ?? [];
    final yearlyTotal = data['yearlyTotal'] ?? {};

    // Handle both uppercase and lowercase field names from API
    final totalRequest = yearlyTotal['totalrequest'] ??
        yearlyTotal['totalRequest'] ??
        yearlyTotal['total_request'] ??
        0;
    final totalGive = yearlyTotal['totalgive'] ??
        yearlyTotal['totalGive'] ??
        yearlyTotal['total_give'] ??
        0;

    // Calculate percentage for yearly total
    final yearlyPercentage = totalRequest > 0
        ? ((totalGive / totalRequest) * 100).toStringAsFixed(1)
        : '0.0';

    return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Year header
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calendar_today,
                        color: primaryColor, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '$year နှစ်ချုပ်',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Totals cards
            _buildTotalsCards(
              totalRequest: totalRequest,
              totalGive: totalGive,
              percentage: yearlyPercentage,
            ),

            SizedBox(height: 16),

            // Monthly list header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'လအလိုက် အချက်အလက်',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Monthly data list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: monthlyData.isEmpty
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'ဤနှစ်အတွက် အချက်အလက်မရှိပါ',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: monthlyData.length,
                      itemBuilder: (context, index) {
                        final monthData = monthlyData[index];
                        final month = int.parse(monthData['month'].toString());
                        final request = monthData['totalrequest'] ??
                            monthData['totalRequest'] ??
                            0;
                        final give = monthData['totalgive'] ??
                            monthData['totalGive'] ??
                            0;

                        // Calculate percentage for this month
                        final monthlyPercentage = request > 0
                            ? ((give / request) * 100).toStringAsFixed(1)
                            : '0.0';

                        return ListTile(
                          onTap: () {
                            setState(() {
                              showYearlyView = false;
                              _monthSelected = month - 1;
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: Text(
                              month.toString(),
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            monthsMM[month - 1],
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(Icons.call_received,
                                  size: 14, color: Colors.orange),
                              SizedBox(width: 4),
                              Text(request.toString(),
                                  style: TextStyle(color: Colors.orange)),
                              SizedBox(width: 16),
                              Icon(Icons.volunteer_activism,
                                  size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text(give.toString(),
                                  style: TextStyle(color: Colors.green)),
                              SizedBox(width: 16),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$monthlyPercentage%',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon:
                                Icon(Icons.edit, color: primaryColor, size: 20),
                            onPressed: () =>
                                _openWorksheet(month: month, year: year),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ));
  }

  Widget _buildMonthlyView(
      Map<String, dynamic> data, int year, int monthIndex) {
    final summary = data['summary'] ?? {};
    final month = monthIndex + 1;

    final totalRequest = summary['totalRequest'] ?? 0;
    final totalGive = summary['totalGive'] ?? 0;

    // Calculate percentage for monthly total
    final monthlyPercentage = totalRequest > 0
        ? ((totalGive / totalRequest) * 100).toStringAsFixed(1)
        : '0.0';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Month header with totals
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: primaryColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '${monthsMM[monthIndex]} $year',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.edit, color: primaryColor),
                      onPressed: () => _openWorksheet(month: month, year: year),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildTotalsCards(
                  totalRequest: totalRequest,
                  totalGive: totalGive,
                  percentage: monthlyPercentage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWorksheet({int? month, int? year}) async {
    final selectedYear = year ?? int.parse(years[_yearSelected]);
    final selectedMonth = month ??
        (_monthSelected != null ? _monthSelected! + 1 : DateTime.now().month);
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => RequestGiveListScreen(
          initialMonth: DateTime(selectedYear, selectedMonth),
        ),
      ),
    );
    if (mounted) ref.invalidate(requestGiveReportProvider);
  }
}
