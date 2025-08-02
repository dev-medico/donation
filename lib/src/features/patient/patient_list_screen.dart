import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/providers/patient_provider.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});
  static const routeName = "/patient-list";

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  static const _pageSize = 20;
  final PagingController<int, Patient> _pagingController =
      PagingController(firstPageKey: 0);
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final result = await ref.read(patientServiceProvider).getPatients(
        page: pageKey,
        limit: _pageSize,
        q: _searchQuery,
      );

      final patients = result['patients'] as List<Patient>;
      final hasMore = result['hasMore'] as bool;

      if (hasMore) {
        _pagingController.appendPage(patients, pageKey + 1);
      } else {
        _pagingController.appendLastPage(patients);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

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
          "လူနာစာရင်း",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: PagedListView<int, Patient>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<Patient>(
                itemBuilder: (context, patient, index) => _PatientCard(patient: patient),
                firstPageErrorIndicatorBuilder: (context) => Center(
                  child: Text('Error: ${_pagingController.error}'),
                ),
                noItemsFoundIndicatorBuilder: (context) => const Center(
                  child: Text('လူနာမတွေ့ပါ'),
                ),
                newPageProgressIndicatorBuilder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'လူနာအမည်၊ ရောဂါ၊ ဆေးရုံ သို့မဟုတ် လိပ်စာဖြင့် ရှာဖွေရန်',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;

  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    patient.patientName ?? 'Unknown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (patient.bloodGroup != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      patient.bloodGroup!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'အသက်', patient.patientAge ?? '-'),
            _buildInfoRow(Icons.local_hospital, 'ရောဂါ', patient.patientDisease ?? '-'),
            _buildInfoRow(Icons.business, 'ဆေးရုံ', patient.hospital ?? '-'),
            _buildInfoRow(Icons.location_on, 'လိပ်စာ', patient.patientAddress ?? '-'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'စုစုပေါင်း လှူဒါန်းမှု: ${patient.donationCount ?? 0} ကြိမ်',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (patient.latestDonationDate != null)
                  Text(
                    'နောက်ဆုံးလှူဒါန်းမှု: ${_formatDate(patient.latestDonationDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}