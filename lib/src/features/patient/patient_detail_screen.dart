import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/providers/patient_provider.dart';
import 'package:donation/src/features/patient/patient_form.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final int patientId;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildDonationHistorySection(),
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
            _buildInfoRow(Icons.cake, 'အသက်', _patient!.age ?? '-'),
            _buildInfoRow(
              Icons.wc,
              'ကျား/မ',
              _patient!.gender == 'male' ? 'ကျား' : (_patient!.gender == 'female' ? 'မ' : '-'),
            ),
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
                'လှူဒါန်းမှုမှတ်တမ်း ${_patient!.donationCount ?? 0} ခု ရှိပါသည်',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
