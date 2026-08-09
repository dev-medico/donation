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
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MoneyDonorListScreen extends ConsumerStatefulWidget {
  const MoneyDonorListScreen({super.key});
  static const routeName = "/money-donor-list";

  @override
  ConsumerState<MoneyDonorListScreen> createState() =>
      _MoneyDonorListScreenState();
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
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
        _isInitialLoad = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      setState(() {
        _searchQuery = query;
        _allDonors.clear();
        _donorDataSource = null;
        _currentPage = 0;
        _hasMore = true;
        _isInitialLoad = true;
      });
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
      ).then((_) => _refreshDonors());
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

    if (Responsive.isMobile(context)) {
      return _buildMobileList();
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
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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

  Widget _buildMobileList() {
    if (_allDonors.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshDonors,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 72, 16, 96),
          children: [
            Icon(
              Icons.volunteer_activism_outlined,
              size: 52,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              'အလှူရှင်မတွေ့ပါ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final itemCount = _allDonors.length + (_isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: _refreshDonors,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 96),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == _allDonors.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == _allDonors.length - 1 ? 0 : 10,
            ),
            child: _buildMobileDonorCard(_allDonors[index], index),
          );
        },
      ),
    );
  }

  Widget _buildMobileDonorCard(MoneyDonor donor, int index) {
    final name = donor.name?.trim();
    final phone = donor.phone?.trim();
    final address = donor.address?.trim();

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _showDonorDetail(donor),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name == null || name.isEmpty ? 'အမည်မသိ' : name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    if (phone != null && phone.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      _buildMobileMetaRow(Icons.phone_outlined, phone),
                    ],
                    if (address != null && address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildMobileMetaRow(
                        Icons.location_on_outlined,
                        address,
                        maxLines: 2,
                      ),
                    ],
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_formatAmount(donor.totalAmount)} ကျပ်',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${donor.donationCount ?? 0} ကြိမ်',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMetaRow(
    IconData icon,
    String value, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 14, color: Colors.grey[500]),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  String _formatAmount(double? amount) {
    return NumberFormat('#,###').format(amount ?? 0);
  }

  Future<void> _refreshDonors() async {
    _currentPage = 0;
    _hasMore = true;
    _isLoadingMore = false;
    await _fetchPage(0);
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
