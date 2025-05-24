import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation/blood_request_give_chart.dart';
import 'package:donation/src/features/services/request_give_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

final requestGiveListProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final service = ref.read(requestGiveServiceProvider);
  return await service.getRequestGives();
});

class RequestGiveListScreen extends ConsumerStatefulWidget {
  const RequestGiveListScreen({super.key});
  static const routeName = "/request-give-list";

  @override
  ConsumerState<RequestGiveListScreen> createState() =>
      _RequestGiveListScreenState();
}

class _RequestGiveListScreenState extends ConsumerState<RequestGiveListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text(
          "သွေးတောင်းခံ/လှူဒါန်းမှု မှတ်တမ်း",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Chart Section
          if (!Responsive.isMobile(context)) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: BloodRequestGiveChartScreen(),
            ),
            const Divider(),
          ],

          // List Section
          Expanded(
            child: ref.watch(requestGiveListProvider).when(
                  data: (requestGives) {
                    if (requestGives.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'သွေးတောင်းခံ/လှူဒါန်းမှု မှတ်တမ်း မရှိသေးပါ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: requestGives.length,
                      itemBuilder: (context, index) {
                        final item = requestGives[index];
                        return _buildRequestGiveCard(item);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${error.toString().replaceAll('Exception: ', '')}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(requestGiveListProvider);
                          },
                          child: const Text('ပြန်လည်ကြိုးစားမည်'),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRequestGiveDialog();
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'သွေးတောင်းခံ/လှူဒါန်းမှု ထည့်သွင်းမည်',
      ),
    );
  }

  Widget _buildRequestGiveCard(Map<String, dynamic> item) {
    final date = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
    final request = item['request'] ?? 0;
    final give = item['give'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ID: ${item['id'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.request_page,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'တောင်းခံ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          '$request ကြိမ်',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.volunteer_activism,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'လှူဒါန်း',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '$give ကြိမ်',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
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
    );
  }

  void _showAddRequestGiveDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddRequestGiveDialog(
        ref: ref,
        onAdded: () {
          // Refresh the list
          ref.invalidate(requestGiveListProvider);
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
              // Date picker
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