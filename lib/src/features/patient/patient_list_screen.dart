import 'dart:async';

import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/providers/patient_provider.dart';
import 'package:donation/src/features/patient/patient_data_source.dart';
import 'package:donation/src/features/donation/donation_list.dart';
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
    print('DEBUG: _fetchPage called with pageKey: $pageKey, searchQuery: $_searchQuery');
    try {
      print('DEBUG: Calling patientServiceProvider.getPatients...');
      final result = await ref.read(patientServiceProvider).getPatients(
        page: pageKey,
        limit: _pageSize,
        q: _searchQuery,
      );
      
      print('DEBUG: API Response received: $result');
      print('DEBUG: Result type: ${result.runtimeType}');
      
      final patients = result['patients'] as List<Patient>;
      final hasMore = result['hasMore'] as bool;
      
      print('DEBUG: Parsed patients count: ${patients.length}');
      print('DEBUG: Has more pages: $hasMore');

      if (pageKey == 0) {
        _allPatients = patients;
      } else {
        _allPatients.addAll(patients);
      }
      
      print('DEBUG: Total patients in _allPatients: ${_allPatients.length}');
      
      // Update data source for table view
      _patientDataSource = PatientDataSource(patientData: _allPatients);
      
      setState(() {
        _isInitialLoad = false; // Set to false after first load completes
        _hasMore = hasMore;
        _currentPage = pageKey;
        _isLoadingMore = false;
      }); // Force UI update

      print('DEBUG: Has more pages: $hasMore, current page: $pageKey');
    } catch (error, stackTrace) {
      print('ERROR: Failed to fetch patients: $error');
      print('STACK TRACE: $stackTrace');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    // Cancel the previous timer if user is still typing
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    
    // Start a new timer that will trigger the search after 500ms of no typing
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
            child: _buildTableView(),
          ),
        ],
      ),
    );
  }

  void _showPatientDetail(Patient patient) {
    // Navigate to patient donation history
    Navigator.pushNamed(
      context,
      DonationListScreen.routeName,
      arguments: {'patientName': patient.patientName},
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
              hintText: 'လူနာအမည်၊ ရောဂါ၊ ဆေးရုံ သို့မဟုတ် လိပ်စာဖြင့် ရှာဖွေရန်',
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
              setState(() {}); // Update UI to show/hide clear button
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
              columnWidthMode: Responsive.isMobile(context)
                  ? ColumnWidthMode.auto
                  : ColumnWidthMode.fitByCellValue,
              columns: <GridColumn>[
          GridColumn(
              columnName: 'လူနာအမည်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'လူနာအမည်',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ))),
          GridColumn(
              columnName: 'အသက်',
              width: 100,
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'အသက်',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ))),
          GridColumn(
              columnName: 'ရောဂါ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'ရောဂါ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ))),
          GridColumn(
              columnName: 'ဆေးရုံ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'ဆေးရုံ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ))),
          GridColumn(
              columnName: 'သွေးအုပ်စု',
              width: Responsive.isMobile(context) ? 90 : double.nan,
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'သွေးအုပ်စု',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ))),
          if (!Responsive.isMobile(context)) ...[
            GridColumn(
                columnName: 'လိပ်စာ',
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'လိပ်စာ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
            GridColumn(
                columnName: 'လှူဒါန်းမှု',
                width: 100,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'လှူဒါန်းမှု',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
            GridColumn(
                columnName: 'နောက်ဆုံးလှူဒါန်းသည့်ရက်',
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'နောက်ဆုံးရက်',
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