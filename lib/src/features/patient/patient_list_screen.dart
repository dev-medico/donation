import 'dart:async';

import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/providers/patient_provider.dart';
import 'package:donation/src/features/patient/patient_data_source.dart';
import 'package:donation/src/features/patient/patient_form.dart';
import 'package:donation/src/features/patient/patient_detail_screen.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/responsive.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});
  static const routeName = "/patient-list";

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  static const _pageSize = 20;
  String _searchQuery = '';
  PatientDataSource? _patientDataSource;
  List<Patient> _allPatients = [];
  bool _isInitialLoad = true;
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchPage(0);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
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

      if (pageKey == 0) {
        _allPatients = patients;
      } else {
        _allPatients.addAll(patients);
      }

      _patientDataSource = PatientDataSource(patientData: _allPatients);

      setState(() {
        _isInitialLoad = false;
        _hasMore = hasMore;
        _currentPage = pageKey;
        _isLoadingMore = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      _allPatients.clear();
      _currentPage = 0;
      _hasMore = true;
      _fetchPage(0);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showPatientDetail(Patient patient) {
    if (patient.id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDetailScreen(
            patientId: patient.id!,
            onChanged: () {
              _fetchPage(0); // Refresh list when patient is edited or deleted
            },
          ),
        ),
      );
    }
  }

  void _showCreatePatientForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientFormScreen(
          onSaved: () {
            _fetchPage(0);
          },
        ),
      ),
    );
  }

  void _showEditPatientForm(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientFormScreen(
          patient: patient,
          onSaved: () {
            _fetchPage(0);
          },
        ),
      ),
    );
  }

  Future<void> _deletePatient(Patient patient) async {
    if (patient.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('အတည်ပြုပါ'),
        content: Text('${patient.name} ကို ဖျက်ရန် သေချာပါသလား?'),
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
        final success = await ref.read(patientServiceProvider).deletePatient(patient.id!);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('အောင်မြင်စွာ ဖျက်ပြီးပါပြီ')),
          );
          _fetchPage(0);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ဖျက်ရန် မအောင်မြင်ပါ: $e')),
        );
      }
    }
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePatientForm,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildTableView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: StatefulBuilder(
        builder: (context, setState) {
          return TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'လူနာအမည်၊ ဖုန်း သို့မဟုတ် လိပ်စာဖြင့် ရှာဖွေရန်',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {});
              _onSearchChanged(value);
            },
          );
        },
      ),
    );
  }

  Widget _buildTableView() {
    if (_isInitialLoad && _patientDataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_patientDataSource == null && _allPatients.isEmpty) {
      return const Center(
        child: Text('လူနာမတွေ့ပါ'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: Responsive.isMobile(context) ? 8 : 16,
              right: Responsive.isMobile(context) ? 8 : 16,
            ),
            child: SfDataGrid(
              source: _patientDataSource!,
              verticalScrollController: _scrollController,
              onCellTap: (details) {
                if (details.rowColumnIndex.rowIndex == 0) return;

                final patientIndex = details.rowColumnIndex.rowIndex - 1;
                if (patientIndex < _allPatients.length) {
                  final patient = _allPatients[patientIndex];
                  _showPatientDetail(patient);
                }
              },
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              // Grow rows to fit wrapped content so long Myanmar names/addresses
              // are not clipped by a fixed row height.
              onQueryRowHeight: (details) {
                if (details.rowIndex == 0) return 56.0; // header
                final h = details.getIntrinsicRowHeight(details.rowIndex);
                return h < 49.0 ? 49.0 : h;
              },
              columnWidthMode: Responsive.isMobile(context)
                  ? ColumnWidthMode.auto
                  : ColumnWidthMode.fitByCellValue,
              columns: <GridColumn>[
                GridColumn(
                    columnName: 'no',
                    width: 60,
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'No',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'name',
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'အမည်',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'phone',
                    width: 120,
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'ဖုန်း',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'gender',
                    width: 80,
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'ကျား/မ',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'bloodType',
                    width: 100,
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'သွေးအုပ်စု',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'age',
                    width: 80,
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'အသက်',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
                if (!Responsive.isMobile(context)) ...[
                  GridColumn(
                      columnName: 'address',
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'လိပ်စာ',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ))),
                  GridColumn(
                      columnName: 'donationCount',
                      width: 100,
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'လှူဒါန်းမှု',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ))),
                ],
              ],
            ),
          ),
        ),
        if (_isLoadingMore)
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  void _loadMore() {
    if (!_isLoadingMore && _hasMore) {
      setState(() {
        _isLoadingMore = true;
      });
      _fetchPage(_currentPage + 1);
    }
  }
}
