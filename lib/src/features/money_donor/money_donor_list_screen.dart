import 'dart:async';

import 'package:donation/src/features/money_donor/models/money_donor.dart';
import 'package:donation/src/features/money_donor/providers/money_donor_provider.dart';
import 'package:donation/src/features/money_donor/money_donor_data_source.dart';
import 'package:donation/src/features/money_donor/money_donor_form.dart';
import 'package:donation/src/features/money_donor/money_donor_detail_screen.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/responsive.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MoneyDonorListScreen extends ConsumerStatefulWidget {
  const MoneyDonorListScreen({super.key});
  static const routeName = "/money-donor-list";

  @override
  ConsumerState<MoneyDonorListScreen> createState() => _MoneyDonorListScreenState();
}

class _MoneyDonorListScreenState extends ConsumerState<MoneyDonorListScreen> {
  static const _pageSize = 20;
  String _searchQuery = '';
  MoneyDonorDataSource? _donorDataSource;
  List<MoneyDonor> _allDonors = [];
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
      final result = await ref.read(moneyDonorServiceProvider).getMoneyDonors(
        page: pageKey,
        limit: _pageSize,
        q: _searchQuery,
      );

      final donors = result['donors'] as List<MoneyDonor>;
      final hasMore = result['hasMore'] as bool;

      if (pageKey == 0) {
        _allDonors = donors;
      } else {
        _allDonors.addAll(donors);
      }

      _donorDataSource = MoneyDonorDataSource(donorData: _allDonors);

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
      _allDonors.clear();
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

  void _showDonorDetail(MoneyDonor donor) {
    if (donor.id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoneyDonorDetailScreen(donorId: donor.id!),
        ),
      );
    }
  }

  void _showCreateDonorForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoneyDonorFormScreen(
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
        centerTitle: true,
        title: const Text(
          "အလှူရှင်များ",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDonorForm,
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
              hintText: 'အမည်၊ ဖုန်း သို့မဟုတ် လိပ်စာဖြင့် ရှာဖွေရန်',
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
    if (_isInitialLoad && _donorDataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_donorDataSource == null && _allDonors.isEmpty) {
      return const Center(
        child: Text('အလှူရှင်မတွေ့ပါ'),
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
              source: _donorDataSource!,
              verticalScrollController: _scrollController,
              onCellTap: (details) {
                if (details.rowColumnIndex.rowIndex == 0) return;

                final donorIndex = details.rowColumnIndex.rowIndex - 1;
                if (donorIndex < _allDonors.length) {
                  final donor = _allDonors[donorIndex];
                  _showDonorDetail(donor);
                }
              },
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              columnWidthMode: Responsive.isMobile(context)
                  ? ColumnWidthMode.auto
                  : ColumnWidthMode.fitByCellValue,
              columns: <GridColumn>[
                GridColumn(
                    columnName: 'id',
                    width: 60,
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'စဥ်',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
                GridColumn(
                    columnName: 'name',
                    minimumWidth: Responsive.isMobile(context) ? 200 : 380,
                    columnWidthMode: ColumnWidthMode.fill,
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
                    columnName: 'totalAmount',
                    width: 130,
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'စုစုပေါင်း',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
                if (!Responsive.isMobile(context)) ...[
                  GridColumn(
                      columnName: 'donationCount',
                      width: 100,
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'အကြိမ်',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ))),
                  GridColumn(
                      columnName: 'address',
                      minimumWidth: 200,
                      label: Container(
                          color: primaryColor,
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'လိပ်စာ',
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
