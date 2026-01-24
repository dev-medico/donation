import 'package:donation/src/features/money_donor/models/money_donor.dart';
import 'package:donation/src/features/money_donor/providers/money_donor_provider.dart';
import 'package:donation/src/features/money_donor/money_donor_form.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/responsive.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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
  List<dynamic> _donations = [];
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

      // Try to load donation history
      List<dynamic> donations = [];
      try {
        final report = await ref.read(moneyDonorServiceProvider).getReport(widget.donorId);
        donations = report['donations'] ?? [];
      } catch (e) {
        // If report fails, continue without donation history
        print('Failed to load donation history: $e');
      }

      setState(() {
        _donor = donor;
        _donations = donations;
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
          'အလှူရှင်အချက်အလက်',
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
      return const Center(child: Text('အလှူရှင်မတွေ့ပါ'));
    }

    // Use different layouts for mobile vs desktop
    if (Responsive.isMobile(context)) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Summary card at top (fixed)
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSummaryCard(),
        ),
        // Donation history fills remaining space
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildDonationHistorySection(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Centered container with half width
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              children: [
                // Summary card at top
                _buildSummaryCard(),
                const SizedBox(height: 16),
                // Donation history fills remaining space
                Expanded(
                  child: _buildDonationHistorySection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Name and contact info
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    Icons.person,
                    size: 28,
                    color: Colors.green.shade700,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_donor!.phone != null && _donor!.phone!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                _donor!.phone!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_donor!.address != null && _donor!.address!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _donor!.address!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Summary stats row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                              Icons.monetization_on,
                              color: Colors.green[700],
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'စုစုပေါင်း',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_formatAmount(_donor!.totalAmount)} ကျပ်',
                          style: TextStyle(
                            fontSize: 14,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                              Icons.receipt_long,
                              color: primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'အကြိမ်',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_donor!.donationCount ?? 0}',
                          style: TextStyle(
                            fontSize: 14,
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

            if (_donor!.note != null && _donor!.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _donor!.note!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDonationHistorySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade50,
                  Colors.green.shade100.withOpacity(0.5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.volunteer_activism,
                    size: 20,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'လှူဒါန်းမှုမှတ်တမ်း',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_donations.length} ကြိမ်',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table content - fills remaining space
          Expanded(
            child: _buildDonationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsList() {
    if (_donations.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 12),
              Text(
                'လှူဒါန်းမှုမှတ်တမ်း မရှိသေးပါ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dataSource = _DonationHistoryDataSource(donationData: _donations);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: SfDataGrid(
        source: dataSource,
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.none,
        rowHeight: 52,
        headerRowHeight: 48,
        columns: <GridColumn>[
          GridColumn(
              columnName: 'no',
              width: 60,
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'စဥ်',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ))),
          GridColumn(
              columnName: 'date',
              width: 130,
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'ရက်စွဲ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ))),
          GridColumn(
              columnName: 'amount',
              width: 140,
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'အလှူငွေ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ))),
        ],
      ),
    );
  }
}

// Data source for donation history table
class _DonationHistoryDataSource extends DataGridSource {
  _DonationHistoryDataSource({required List<dynamic> donationData}) {
    _donationData = donationData
        .asMap()
        .entries
        .map<DataGridRow>((entry) {
          final index = entry.key;
          final donation = entry.value;
          return DataGridRow(cells: [
            DataGridCell<int>(columnName: 'no', value: index + 1),
            DataGridCell<String>(columnName: 'date', value: _formatDate(donation['date'])),
            DataGridCell<String>(columnName: 'amount', value: _formatAmount(donation['amount'])),
          ]);
        })
        .toList();
  }

  List<DataGridRow> _donationData = [];

  @override
  List<DataGridRow> get rows => _donationData;

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      if (date is String) {
        final parsed = DateTime.parse(date);
        return DateFormat('dd MMM yyyy').format(parsed);
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    final formatter = NumberFormat('#,###');
    if (amount is int) {
      return formatter.format(amount);
    } else if (amount is double) {
      return formatter.format(amount);
    }
    return amount.toString();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final rowIndex = _donationData.indexOf(row);
    final isEven = rowIndex % 2 == 0;

    return DataGridRowAdapter(
        color: isEven ? Colors.white : Colors.grey.shade50,
        cells: row.getCells().map<Widget>((dataGridCell) {
      final columnName = dataGridCell.columnName;
      final value = dataGridCell.value.toString();

      if (columnName == 'no') {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.green[700],
              ),
            ),
          ),
        );
      }

      if (columnName == 'amount') {
        return Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$value ကျပ်',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.green[700],
              ),
            ),
          ),
        );
      }

      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[800],
          ),
        ),
      );
    }).toList());
  }
}
