import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/report_service.dart';
import 'package:donation/src/features/services/request_give_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

final requestGiveStatsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final reportService = ref.read(reportServiceProvider);
    return await reportService.getRequestGiveStats();
  } catch (e) {
    throw Exception('Failed to load request/give stats: $e');
  }
});

class ChartData {
  ChartData(this.x, this.y, this.y1);
  final String x;
  final double? y;
  final double? y1;
}

class BloodRequestGiveChartScreen extends ConsumerStatefulWidget {
  const BloodRequestGiveChartScreen({super.key});

  @override
  ConsumerState<BloodRequestGiveChartScreen> createState() =>
      _BloodRequestGiveChartScreenState();
}

class _BloodRequestGiveChartScreenState
    extends ConsumerState<BloodRequestGiveChartScreen> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(enable: true, format: 'point.x : point.y');
  }

  @override
  Widget build(BuildContext context) {
    final requestGiveStats = ref.watch(requestGiveStatsProvider);

    return InkWell(
      borderRadius:
          BorderRadius.circular(Responsive.isMobile(context) ? 12 : 16),
      onTap: () {
        _showAddRequestGiveDialog(context, ref);
      },
      child: Container(
        height: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.height * 0.6
            : MediaQuery.of(context).size.height * 0.5,
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.43,
        child: Stack(
          children: [
              requestGiveStats.when(
        data: (data) {
          final chartData = data
              .map((item) => ChartData(
                    "${item['month']}/${item['year']}",
                    (item['request'] as num).toDouble(),
                    (item['give'] as num).toDouble(),
                  ))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "သွေးတောင်းခံ/လှူဒါန်းမှု အခြေအနေ",
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.isMobile(context) ? 10 : 8),
                Expanded(
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    tooltipBehavior: _tooltip,
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                    ),
                    series: <CartesianSeries>[
                      ColumnSeries<ChartData, String>(
                        name: 'တောင်းခံ',
                        color: Colors.red,
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                      ),
                      ColumnSeries<ChartData, String>(
                        name: 'လှူဒါန်း',
                        color: Colors.green,
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              error.toString().replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
            // Add button overlay - smaller with top padding
            Positioned(
              top: 12,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRequestGiveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddRequestGiveDialog(
        ref: ref,
        onAdded: () {
          // Refresh the chart data
          ref.invalidate(requestGiveStatsProvider);
        },
      ),
    );
  }
}

// Add Request Give Dialog Widget
class _AddRequestGiveDialog extends StatefulWidget {
  final WidgetRef ref;
  final VoidCallback onAdded;

  const _AddRequestGiveDialog({
    required this.ref,
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
        'request': int.parse(_requestController.text),
        'give': int.parse(_giveController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };

      // Call the API service to create request give
      final service = widget.ref.read(requestGiveServiceProvider);
      await service.createRequestGive(data);

      Navigator.pop(context);
      widget.onAdded();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('သွေးတောင်းခံ/လှူဒါန်းမှု မှတ်တမ်း အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ'),
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
