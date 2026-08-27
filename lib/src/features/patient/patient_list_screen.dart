import 'dart:async';

import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/providers/patient_provider.dart';
import 'package:donation/src/features/patient/patient_data_source.dart';
import 'package:donation/src/features/patient/patient_form.dart';
import 'package:donation/src/features/patient/patient_detail_screen.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/responsive.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:donation/utils/age_utils.dart';
import 'package:donation/src/ui/blood_chip.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key, this.fromHome = false});
  final bool fromHome;
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
        leading: widget.fromHome && Responsive.isMobile(context)
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: 'မီနူး',
                onPressed: () =>
                    ref.read(drawerControllerProvider)?.toggle?.call(),
              )
            : null,
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
      padding: Responsive.isMobile(context)
          ? const EdgeInsets.fromLTRB(12, 10, 12, 6)
          : const EdgeInsets.all(16.0),
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

  /// Compact phone rows: blood chip, name over age/gender/address, donation
  /// count. Shares [_scrollController] so infinite scroll keeps working.
  Widget _buildMobilePatientList() {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 88),
      itemCount: _allPatients.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final patient = _allPatients[index];
        // detailed:true carries its own unit (နှစ်/လ/ရက်); legacy fallback
        // strings may already include one (e.g. "20 ရက်"), so append nothing.
        final age = displayAge(patient.birthDate, fallbackAge: patient.age);
        final gender = patient.gender == 'male'
            ? 'ကျား'
            : patient.gender == 'female'
                ? 'မ'
                : '';
        final secondary = [
          if (age.isNotEmpty) age,
          if (gender.isNotEmpty) gender,
          if ((patient.address ?? '').trim().isNotEmpty)
            patient.address!.trim(),
        ].join(' · ');
        final count = patient.donationCount ?? 0;
        return InkWell(
          onTap: () => _showPatientDetail(patient),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                BloodChip(bloodType: patient.bloodType),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      if (secondary.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          secondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$count ကြိမ်',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor),
                  ),
                ],
                Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
              ],
            ),
          ),
        );
      },
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

    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          Expanded(child: _buildMobilePatientList()),
          if (_isLoadingMore)
            Container(
              padding: const EdgeInsets.all(12.0),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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
