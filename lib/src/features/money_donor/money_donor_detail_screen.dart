import 'package:donation/src/features/money_donor/models/money_donor.dart';
import 'package:donation/src/features/money_donor/providers/money_donor_provider.dart';
import 'package:donation/src/features/money_donor/money_donor_form.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class MoneyDonorDetailScreen extends ConsumerStatefulWidget {
  final int donorId;

  const MoneyDonorDetailScreen({
    super.key,
    required this.donorId,
  });

  static const routeName = "/money-donor-detail";

  @override
  ConsumerState<MoneyDonorDetailScreen> createState() => _MoneyDonorDetailScreenState();
}

class _MoneyDonorDetailScreenState extends ConsumerState<MoneyDonorDetailScreen> {
  MoneyDonor? _donor;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDonor();
  }

  Future<void> _loadDonor() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final donor = await ref.read(moneyDonorServiceProvider).getMoneyDonor(widget.donorId);
      setState(() {
        _donor = donor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _editDonor() {
    if (_donor == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoneyDonorFormScreen(
          donor: _donor,
          onSaved: () {
            _loadDonor();
          },
        ),
      ),
    );
  }

  Future<void> _deleteDonor() async {
    if (_donor == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('အတည်ပြုပါ'),
        content: Text('${_donor!.name} ကို ဖျက်ရန် သေချာပါသလား?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('မလုပ်ပါ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ဖျက်မည်'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await ref.read(moneyDonorServiceProvider).deleteMoneyDonor(_donor!.id!);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('အောင်မြင်စွာ ဖျက်ပြီးပါပြီ')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ဖျက်ရန် မအောင်မြင်ပါ: $e')),
          );
        }
      }
    }
  }

  String _formatAmount(double? amount) {
    if (amount == null) return '0';
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text(
          'ငွေအလှူရှင်အချက်အလက်',
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
        actions: [
          if (_donor != null) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _editDonor,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteDonor,
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDonor,
              child: const Text('ပြန်လည်ကြိုးစားရန်'),
            ),
          ],
        ),
      );
    }

    if (_donor == null) {
      return const Center(child: Text('ငွေအလှူရှင်မတွေ့ပါ'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildDonationSummary(),
          const SizedBox(height: 16),
          _buildDonationHistorySection(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final isOrg = _donor!.isOrganization ?? false;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isOrg ? Colors.purple.shade100 : Colors.green.shade100,
                  child: Icon(
                    isOrg ? Icons.business : Icons.person,
                    size: 30,
                    color: isOrg ? Colors.purple.shade700 : Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _donor!.name ?? 'အမည်မသိ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOrg ? Colors.purple.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOrg ? 'အဖွဲ့အစည်း' : 'လူပုဂ္ဂိုလ်',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOrg ? Colors.purple.shade700 : Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            if (_donor!.phone != null && _donor!.phone!.isNotEmpty)
              _buildInfoRow(Icons.phone, 'ဖုန်း', _donor!.phone!),
            _buildInfoRow(Icons.location_on, 'လိပ်စာ', _donor!.address ?? '-'),
            if (_donor!.note != null && _donor!.note!.isNotEmpty)
              _buildInfoRow(Icons.note, 'မှတ်ချက်', _donor!.note!),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationSummary() {
    return Card(
      elevation: 2,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.monetization_on, size: 40, color: Colors.green.shade700),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatAmount(_donor!.totalAmount)} ကျပ်',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    'စုစုပေါင်းလှူဒါန်းမှု',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 80,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 40, color: primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    '${_donor!.donationCount ?? 0}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    'လှူဒါန်းမှုအကြိမ်',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationHistorySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'လှူဒါန်းမှုမှတ်တမ်း',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'လှူဒါန်းမှုမှတ်တမ်း ${_donor!.donationCount ?? 0} ခု ရှိပါသည်',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
