import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:donation/src/features/services/request_give_service.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

// Provider for detailed report data - using String key for proper caching
final requestGiveReportProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, key) async {
  try {
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
      body: Column(
        children: [
          // Toggle buttons for နှစ်ချုပ် and လချုပ်
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        color: showYearlyView ? primaryColor : Colors.white,
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
                          Text(
                            'နှစ်ချုပ် မှတ်တမ်း',
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
                        color: !showYearlyView ? primaryColor : Colors.white,
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
                          Text(
                            'လချုပ် မှတ်တမ်း',
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
                      color:
                          _yearSelected == index ? primaryColor : Colors.white,
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
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: reportData.when(
              data: (data) {
                if (showYearlyView) {
                  return _buildYearlyView(data, selectedYear);
                } else {
                  return _buildMonthlyView(data, selectedYear, _monthSelected!);
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
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error loading data'),
                      Text(error.toString(), style: TextStyle(fontSize: 12)),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(null),
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'အသစ်ထည့်မည်',
      ),
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
        child: Column(children: [
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
                  child:
                      Icon(Icons.calendar_today, color: primaryColor, size: 20),
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
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
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
                          Icon(Icons.call_received,
                              color: Colors.orange, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'တောင်းခံမှု',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        totalRequest.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
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
                          Icon(Icons.volunteer_activism,
                              color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'လှူဒါန်းမှု',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            totalGive.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '($yearlyPercentage%)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                      final give =
                          monthData['totalgive'] ?? monthData['totalGive'] ?? 0;
                      
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
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                          icon: Icon(Icons.edit, color: primaryColor, size: 20),
                          onPressed: () => _showAddEditDialog(monthData,
                              month: month, year: year),
                        ),
                      );
                    },
                  ),
          ),
        ],));
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
                      onPressed: () => _showAddEditDialog(
                        {'request': totalRequest, 'give': totalGive},
                        month: month,
                        year: year,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
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
                                Icon(Icons.call_received,
                                    color: Colors.orange, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'တောင်းခံမှု',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              totalRequest.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
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
                                Icon(Icons.volunteer_activism,
                                    color: Colors.green, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'လှူဒါန်းမှု',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  totalGive.toString(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '($monthlyPercentage%)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
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
    );
  }

  void _showAddEditDialog(Map<String, dynamic>? existingData,
      {int? month, int? year}) async {
    final selectedYear = year ?? int.parse(years[_yearSelected]);
    final selectedMonth = month ??
        (_monthSelected != null ? _monthSelected! + 1 : DateTime.now().month);

    final requestController = TextEditingController(
        text: existingData != null
            ? (existingData['totalrequest'] ??
                    existingData['totalRequest'] ??
                    existingData['request'] ??
                    0)
                .toString()
            : '0');
    final giveController = TextEditingController(
        text: existingData != null
            ? (existingData['totalgive'] ??
                    existingData['totalGive'] ??
                    existingData['give'] ??
                    0)
                .toString()
            : '0');

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${monthsMM[selectedMonth - 1]} $selectedYear'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: requestController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'တောင်းခံမှု',
                prefixIcon: Icon(Icons.call_received, color: Colors.orange),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: giveController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'လှူဒါန်းမှု',
                prefixIcon: Icon(Icons.volunteer_activism, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('မလုပ်တော့ပါ'),
          ),
          ElevatedButton(
            onPressed: () async {
              final service = ref.read(requestGiveServiceProvider);
              try {
                // Check if record exists
                final monthlyData = await service.getOrCreateMonthly(
                  year: selectedYear,
                  month: selectedMonth,
                );

                final data = monthlyData['data'];
                final isNew = monthlyData['isNew'] ?? false;

                final requestGiveData = {
                  'request': int.tryParse(requestController.text) ?? 0,
                  'give': int.tryParse(giveController.text) ?? 0,
                  'date':
                      '${selectedYear.toString().padLeft(4, '0')}-${selectedMonth.toString().padLeft(2, '0')}-01',
                };

                if (isNew) {
                  await service.createRequestGive(requestGiveData);
                } else {
                  await service.updateRequestGive(
                    data['id'].toString(),
                    requestGiveData,
                  );
                }

                // Refresh the data
                ref.invalidate(requestGiveReportProvider);
                Navigator.pop(context, true);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('အချက်အလက်သိမ်းဆည်းပြီးပါပြီ'),
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
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text('သိမ်းဆည်းမည်'),
          ),
        ],
      ),
    );
  }
}
