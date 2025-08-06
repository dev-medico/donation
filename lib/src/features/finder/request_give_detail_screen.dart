import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:donation/src/features/services/request_give_service.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

// Provider for detailed report data - using String key for proper caching
final detailedReportProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, key) async {
  // Parse the key to extract year and month
  final parts = key.split('-');
  final year = parts[0] != 'null' ? int.parse(parts[0]) : null;
  final month = parts.length > 1 && parts[1] != 'null' ? int.parse(parts[1]) : null;
  
  final service = ref.read(requestGiveServiceProvider);
  return service.getDetailedReport(year: year, month: month);
});

class RequestGiveDetailScreen extends ConsumerStatefulWidget {
  const RequestGiveDetailScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RequestGiveDetailScreen> createState() => _RequestGiveDetailScreenState();
}

class _RequestGiveDetailScreenState extends ConsumerState<RequestGiveDetailScreen> {
  int selectedYear = DateTime.now().year;
  int? selectedMonth;
  bool isYearlyView = true;

  final monthNames = [
    'ဇန်နဝါရီ', 'ဖေဖော်ဝါရီ', 'မတ်', 'ဧပြီ', 'မေ', 'ဇွန်',
    'ဇူလိုင်', 'ဩဂုတ်', 'စက်တင်ဘာ', 'အောက်တိုဘာ', 'နိုဝင်ဘာ', 'ဒီဇင်ဘာ'
  ];

  @override
  Widget build(BuildContext context) {
    // Create a unique key string for the provider
    final providerKey = isYearlyView 
        ? '$selectedYear-null'
        : '$selectedYear-$selectedMonth';
    
    final reportData = ref.watch(detailedReportProvider(providerKey));

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
          'သွေးတောင်းခံ/လှူဒါန်းမှု အသေးစိတ်',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _showYearMonthPicker,
          ),
        ],
      ),
      body: Column(
        children: [
          // View Toggle
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('နှစ်ချုပ်'),
                        icon: Icon(Icons.calendar_today, size: 18),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('လအလိုက်'),
                        icon: Icon(Icons.calendar_month, size: 18),
                      ),
                    ],
                    selected: {isYearlyView},
                    onSelectionChanged: (Set<bool> selection) {
                      setState(() {
                        isYearlyView = selection.first;
                        if (isYearlyView) {
                          selectedMonth = null;
                        } else {
                          selectedMonth = DateTime.now().month;
                        }
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return primaryColor;
                          }
                          return Colors.white;
                        },
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          }
                          return Colors.black87;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Year/Month selector
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    isYearlyView
                        ? '$selectedYear ခုနှစ်'
                        : '${monthNames[selectedMonth! - 1]} $selectedYear',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Report Content
          Expanded(
            child: reportData.when(
              data: (data) {
                if (isYearlyView) {
                  return _buildYearlyView(data);
                } else {
                  return _buildMonthlyView(data);
                }
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error: $error'),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(detailedReportProvider);
                      },
                      child: Text('ပြန်လည်ကြိုးစားမည်'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRequestGiveDialog(),
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'အသစ်ထည့်မည်',
      ),
    );
  }

  void _showAddRequestGiveDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AddRequestGiveDialog(
        onAdded: () {
          // Refresh the report data
          ref.invalidate(detailedReportProvider);
        },
      ),
    );
    
    if (result == true) {
      // Refresh data if something was added
      ref.invalidate(detailedReportProvider);
    }
  }

  Widget _buildYearlyView(Map<String, dynamic> data) {
    final monthlyData = (data['monthlyData'] as List<dynamic>?) ?? [];
    final yearlyTotal = data['yearlyTotal'] ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Yearly Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.summarize, color: primaryColor),
                      SizedBox(width: 8),
                      Text(
                        '$selectedYear နှစ်ချုပ်',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'တောင်းခံမှု',
                          yearlyTotal['totalrequest']?.toString() ?? '0',
                          Colors.orange,
                          Icons.call_received,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'လှူဒါန်းမှု',
                          yearlyTotal['totalgive']?.toString() ?? '0',
                          Colors.green,
                          Icons.volunteer_activism,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Monthly Breakdown
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'လအလိုက် အချက်အလက်',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (monthlyData.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'ဤနှစ်အတွက် အချက်အလက်မရှိပါ',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...monthlyData.map((monthData) {
                      final month = int.parse(monthData['month'].toString());
                      final request = monthData['totalrequest'] ?? 0;
                      final give = monthData['totalgive'] ?? 0;

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              isYearlyView = false;
                              selectedMonth = month;
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
                            monthNames[month - 1],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(Icons.call_received, size: 14, color: Colors.orange),
                              SizedBox(width: 4),
                              Text('$request'),
                              SizedBox(width: 16),
                              Icon(Icons.volunteer_activism, size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text('$give'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: primaryColor),
                            onPressed: () => _showEditDialog(month, request, give),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyView(Map<String, dynamic> data) {
    final records = (data['records'] as List<dynamic>?) ?? [];
    final summary = data['summary'] ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Monthly Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryColor),
                      SizedBox(width: 8),
                      Text(
                        '${monthNames[selectedMonth! - 1]} $selectedYear',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.edit, color: primaryColor),
                        onPressed: () => _showEditDialog(
                          selectedMonth!,
                          summary['totalRequest'] ?? 0,
                          summary['totalGive'] ?? 0,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'တောင်းခံမှု',
                          summary['totalRequest']?.toString() ?? '0',
                          Colors.orange,
                          Icons.call_received,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'လှူဒါန်းမှု',
                          summary['totalGive']?.toString() ?? '0',
                          Colors.green,
                          Icons.volunteer_activism,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Daily Records (if any)
          if (records.isNotEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list_alt, color: primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'နေ့စဉ် မှတ်တမ်းများ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ...records.map((record) {
                      final date = DateTime.parse(record['date']);
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            DateFormat('dd MMM yyyy').format(date),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(Icons.call_received, size: 14, color: Colors.orange),
                              SizedBox(width: 4),
                              Text('${record['request'] ?? 0}'),
                              SizedBox(width: 16),
                              Icon(Icons.volunteer_activism, size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text('${record['give'] ?? 0}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showYearMonthPicker() {
    showDialog(
      context: context,
      builder: (context) {
        int tempYear = selectedYear;
        int? tempMonth = isYearlyView ? null : selectedMonth;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('ရက်စွဲရွေးချယ်ပါ'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year selector
                  Row(
                    children: [
                      Text('နှစ်: '),
                      SizedBox(width: 16),
                      DropdownButton<int>(
                        value: tempYear,
                        items: List.generate(
                          10,
                          (index) => DropdownMenuItem(
                            value: DateTime.now().year - index,
                            child: Text('${DateTime.now().year - index}'),
                          ),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            tempYear = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  if (!isYearlyView) ...[
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('လ: '),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<int>(
                            value: tempMonth,
                            isExpanded: true,
                            items: List.generate(
                              12,
                              (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text(monthNames[index]),
                              ),
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                tempMonth = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('မလုပ်တော့ပါ'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedYear = tempYear;
                      if (!isYearlyView) {
                        selectedMonth = tempMonth;
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: Text('ရွေးချယ်မည်'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(int month, int currentRequest, int currentGive) async {
    final requestController = TextEditingController(text: currentRequest.toString());
    final giveController = TextEditingController(text: currentGive.toString());

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${monthNames[month - 1]} အချက်အလက်ပြင်ဆင်မည်'),
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
              // Check if record exists and create/update
              final service = ref.read(requestGiveServiceProvider);
              try {
                final monthlyData = await service.getOrCreateMonthly(
                  year: selectedYear,
                  month: month,
                );

                final data = monthlyData['data'];
                final isNew = monthlyData['isNew'] ?? false;

                final requestGiveData = {
                  'request': int.tryParse(requestController.text) ?? 0,
                  'give': int.tryParse(giveController.text) ?? 0,
                  'date': '${selectedYear.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01',
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
                ref.invalidate(detailedReportProvider);
                Navigator.pop(context, true);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('အချက်အလက်ပြင်ဆင်ပြီးပါပြီ'),
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

// Add Request Give Dialog Widget
class _AddRequestGiveDialog extends StatefulWidget {
  final VoidCallback onAdded;

  const _AddRequestGiveDialog({
    required this.onAdded,
  });

  @override
  State<_AddRequestGiveDialog> createState() => _AddRequestGiveDialogState();
}

class _AddRequestGiveDialogState extends State<_AddRequestGiveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _requestController = TextEditingController();
  final _giveController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('သွေးတောင်းခံ/လှူဒါန်းမှု မှတ်တမ်းအသစ်'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month picker
              InkWell(
                onTap: () async {
                  final picked = await showMonthPicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
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
                        DateFormat('MMM yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_month),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Request amount field
              TextFormField(
                controller: _requestController,
                decoration: const InputDecoration(
                  labelText: 'တောင်းခံသည့် အရေအတွက်',
                  border: OutlineInputBorder(),
                  suffixText: 'ကြိမ်',
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

              // Give amount field
              TextFormField(
                controller: _giveController,
                decoration: const InputDecoration(
                  labelText: 'လှူဒါန်းခဲ့သည့် အရေအတွက်',
                  border: OutlineInputBorder(),
                  suffixText: 'ကြိမ်',
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('မလုပ်တော့ပါ'),
        ),
        Consumer(
          builder: (context, ref, child) {
            return ElevatedButton(
              onPressed: _isLoading ? null : () => _submit(ref),
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
            );
          }
        ),
      ],
    );
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'request': int.parse(_requestController.text),
        'give': int.parse(_giveController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };

      // Call the API service to create request give
      final service = ref.read(requestGiveServiceProvider);
      await service.createRequestGive(data);

      Navigator.pop(context, true);
      widget.onAdded();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'သွေးတောင်းခံ/လှူဒါန်းမှု မှတ်တမ်း အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ'),
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
    _requestController.dispose();
    _giveController.dispose();
    super.dispose();
  }
}