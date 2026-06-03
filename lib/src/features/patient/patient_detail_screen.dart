import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/providers/patient_provider.dart';
import 'package:donation/src/features/patient/patient_form.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/age_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final int patientId;
  final VoidCallback? onChanged;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
    this.onChanged,
  });

  static const routeName = "/patient-detail";

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  Patient? _patient;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final patient = await ref.read(patientServiceProvider).getPatient(widget.patientId);
      setState(() {
        _patient = patient;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _editPatient() {
    if (_patient == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientFormScreen(
          patient: _patient,
          onSaved: () {
            _loadPatient();
            widget.onChanged?.call(); // Notify list to refresh
          },
        ),
      ),
    );
  }

  Future<void> _deletePatient() async {
    if (_patient == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('အတည်ပြုပါ'),
        content: Text('${_patient!.name} ကို ဖျက်ရန် သေချာပါသလား?'),
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
        final success = await ref.read(patientServiceProvider).deletePatient(_patient!.id!);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('အောင်မြင်စွာ ဖျက်ပြီးပါပြီ')),
          );
          widget.onChanged?.call(); // Notify list to refresh
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

  void _viewDonationDetail(Donation donation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationDetailScreen(
          data: donation,
        ),
      ),
    );
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
          'လူနာအချက်အလက်',
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
        actions: [
          if (_patient != null) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _editPatient,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deletePatient,
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
              onPressed: _loadPatient,
              child: const Text('ပြန်လည်ကြိုးစားရန်'),
            ),
          ],
        ),
      );
    }

    if (_patient == null) {
      return const Center(child: Text('လူနာမတွေ့ပါ'));
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
        // Info card at top
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildInfoCard(),
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
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              children: [
                // Info card at top
                _buildInfoCard(),
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

  Widget _buildInfoCard() {
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
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(
                    _patient!.gender == 'male' ? Icons.man : Icons.woman,
                    size: 30,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patient!.name ?? 'အမည်မသိ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_patient!.phone != null && _patient!.phone!.isNotEmpty)
                        Text(
                          _patient!.phone!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow(Icons.cake, 'အသက်',
                displayAge(_patient!.birthDate, fallbackAge: _patient!.age, empty: '-')),
            _buildInfoRow(
              Icons.wc,
              'ကျား/မ',
              _patient!.gender == 'male' ? 'ကျား' : (_patient!.gender == 'female' ? 'မ' : '-'),
            ),
            if (_patient!.bloodType != null && _patient!.bloodType!.isNotEmpty)
              _buildInfoRow(Icons.bloodtype, 'သွေးအုပ်စု', _patient!.bloodType!),
            _buildInfoRow(Icons.location_on, 'လိပ်စာ', _patient!.address ?? '-'),
            if (_patient!.medicalNotes != null && _patient!.medicalNotes!.isNotEmpty)
              _buildInfoRow(Icons.medical_information, 'ကျန်းမာရေးမှတ်တမ်း', _patient!.medicalNotes!),
            _buildInfoRow(
              Icons.bloodtype,
              'စုစုပေါင်းလှူဒါန်းမှု',
              '${_patient!.donationCount ?? 0} ကြိမ်',
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
            width: 120,
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
    final donations = _patient!.donations ?? [];

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
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
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
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bloodtype,
                    size: 20,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'လှူဒါန်းမှုမှတ်တမ်း',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${donations.length} ကြိမ်',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table content - fills remaining space
          Expanded(
            child: donations.isEmpty
                ? _buildEmptyState()
                : _buildDonationTable(donations),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  Widget _buildDonationTable(List<Donation> donations) {
    final dataSource = _PatientDonationDataSource(
      donationData: donations,
      onRowTap: _viewDonationDetail,
    );

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
        onCellTap: (details) {
          if (details.rowColumnIndex.rowIndex == 0) return;
          final donorIndex = details.rowColumnIndex.rowIndex - 1;
          if (donorIndex < donations.length) {
            _viewDonationDetail(donations[donorIndex]);
          }
        },
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
              ),
            ),
          ),
          GridColumn(
            columnName: 'date',
            width: 120,
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
              ),
            ),
          ),
          GridColumn(
            columnName: 'member',
            minimumWidth: 180,
            columnWidthMode: ColumnWidthMode.fill,
            label: Container(
              color: primaryColor,
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'သွေးလှူဒါန်းသူ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          GridColumn(
            columnName: 'bloodType',
            width: 100,
            label: Container(
              color: primaryColor,
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'သွေးအုပ်စု',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          GridColumn(
            columnName: 'hospital',
            width: 150,
            label: Container(
              color: primaryColor,
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text(
                'ဆေးရုံ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data source for donation history table
class _PatientDonationDataSource extends DataGridSource {
  final Function(Donation) onRowTap;

  _PatientDonationDataSource({
    required List<Donation> donationData,
    required this.onRowTap,
  }) {
    _donationData = donationData;
    _dataGridRows = donationData
        .asMap()
        .entries
        .map<DataGridRow>((entry) {
          final index = entry.key;
          final donation = entry.value;
          return DataGridRow(cells: [
            DataGridCell<int>(columnName: 'no', value: index + 1),
            DataGridCell<String>(columnName: 'date', value: _formatDate(donation.donationDate)),
            DataGridCell<String>(columnName: 'member', value: donation.memberObj?.name ?? '-'),
            DataGridCell<String>(columnName: 'bloodType', value: donation.memberObj?.bloodType ?? '-'),
            DataGridCell<String>(columnName: 'hospital', value: donation.hospital ?? '-'),
          ]);
        })
        .toList();
  }

  List<Donation> _donationData = [];
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final rowIndex = _dataGridRows.indexOf(row);
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
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: primaryColor,
                ),
              ),
            ),
          );
        }

        if (columnName == 'bloodType') {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: primaryColor,
                ),
              ),
            ),
          );
        }

        return Container(
          alignment: columnName == 'member' ? Alignment.centerLeft : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
              fontWeight: columnName == 'member' ? FontWeight.w500 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}
