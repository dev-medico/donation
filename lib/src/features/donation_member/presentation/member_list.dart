import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/domain/member_range.dart';
import 'package:donation/src/features/donation_member/domain/member_list_data_source.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/member_detail.dart';
import 'package:donation/src/features/donation_member/presentation/new_member.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:donation/src/features/services/member_service.dart'
    as member_service;
import 'package:donation/utils/Colors.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:donation/src/features/donation_member/domain/member_repository.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:donation/utils/nrc_data.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:donation/data/response/township_response/township_response.dart';
import 'package:donation/data/response/township_response/datum.dart';

class MemberListScreen extends ConsumerStatefulWidget {
  static const routeName = "/members";
  final bool fromHome;

  const MemberListScreen({Key? key, this.fromHome = false}) : super(key: key);

  @override
  _MemberListScreenState createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  // Blood types list - remains constant
  List<String> bloodTypes = [
    "A (Rh +)",
    "B (Rh +)",
    "AB (Rh +)",
    "O (Rh +)",
    "A (Rh -)",
    "B (Rh -)",
    "AB (Rh -)",
    "O (Rh -)",
  ];
  MemberListDataSource? memberDataDataSource;
  TextStyle tabStyle = const TextStyle(fontSize: 16);
  final searchController = TextEditingController();
  final birthDateController = TextEditingController();
  final phoneController = TextEditingController();
  final fatherNameController = TextEditingController();
  final bloodBankCardController = TextEditingController();
  final memberIdController = TextEditingController();

  Timer? _debounceTimer;
  bool _isAdvancedSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    // Reset filter states - NO longer fetching all members
    ref.read(memberBloodTypeFilterProvider.notifier).state =
        "သွေးအုပ်စုဖြင့် ရှာဖွေမည်";
    ref.read(memberSearchQueryProvider.notifier).state = '';
    ref.read(selectedMemberRangeProvider.notifier).state = null;

    // Clear the search controller
    searchController.clear();
  }

  // Refresh ranges when blood type filter changes
  void _refreshRanges() {
    ref.invalidate(memberRangesProvider);
    ref.read(selectedMemberRangeProvider.notifier).state = null;
  }

  // Refresh member list for the selected range
  void _refreshMembers() {
    ref.invalidate(rangedMemberListProvider);
  }

  @override
  void dispose() {
    searchController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    fatherNameController.dispose();
    bloodBankCardController.dispose();
    memberIdController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the API-based providers
    final rangesAsync = ref.watch(memberRangesProvider);
    final membersAsync = ref.watch(rangedMemberListProvider);
    final selectedBloodType = ref.watch(memberBloodTypeFilterProvider);
    final selectedRange = ref.watch(selectedMemberRangeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryDark],
        ))),
        centerTitle: true,
        leading: widget.fromHome && Responsive.isMobile(context)
            ? Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    // Clear all filters before going back
                    resetFilterProviders(ref);
                    searchController.clear();
                    Navigator.pop(context);
                  },
                ),
              ),
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("အဖွဲ့၀င်များ",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 16,
                  color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              // Refresh ranges and members
              ref.invalidate(memberRangesProvider);
              ref.invalidate(rangedMemberListProvider);
            },
          ),
        ],
      ),
      body: _buildBody(rangesAsync, membersAsync, selectedBloodType, selectedRange),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          // Reset filters before navigating to member creation screen
          resetFilterProviders(ref);

          // Clear filter input fields
          searchController.clear();

          // Navigate to member creation screen
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => NewMemberTemporaryScreen(),
            ),
          )
              .then((result) {
            // If a new member was created, refresh the list
            if (result == true) {
              // Reset search controller
              searchController.clear();

              // Reset all filters
              resetFilterProviders(ref);

              // Refresh ranges from API
              ref.invalidate(memberRangesProvider);

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('အဖွဲ့၀င်အသစ် ထည့်သွင်းခြင်း အောင်မြင်ပါသည်။'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
      AsyncValue<List<MemberRange>> rangesAsync,
      AsyncValue<List<Member>> membersAsync,
      String selectedBloodType,
      MemberRange? selectedRange) {
    // Handle ranges loading/error state
    return rangesAsync.when(
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              'အဖွဲ့၀င် အုပ်စုများ ရယူနေပါသည်...',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            )
          ],
        ),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 8),
            Text(
              'အမှား - $error',
              style: TextStyle(fontSize: 16, color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(memberRangesProvider);
              },
              icon: Icon(Icons.refresh),
              label: Text('ပြန်လည်ကြိုးစားမည်'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      data: (ranges) {
        // Handle members based on whether a range is selected
        return membersAsync.when(
          loading: () => _buildMainContent(ranges, [], selectedBloodType, selectedRange, isLoading: true),
          error: (error, _) => _buildMainContent(ranges, [], selectedBloodType, selectedRange, error: error.toString()),
          data: (members) => _buildMainContent(ranges, members, selectedBloodType, selectedRange),
        );
      },
    );
  }

  Widget _buildMainContent(
      List<MemberRange> ranges,
      List<Member> members,
      String selectedBloodType,
      MemberRange? selectedRange,
      {bool isLoading = false, String? error}) {
    return Column(
      children: [
        // Filters section with scroll
        SingleChildScrollView(
          child: Column(
            children: [
          Responsive.isMobile(context)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2.3,
                              margin: const EdgeInsets.only(top: 12, right: 4),
                              child: ranges.isNotEmpty
                                  ? DropdownButtonFormField<MemberRange>(
                                      value: selectedRange,
                                      dropdownColor: Colors.white,
                                      focusColor: Colors.white,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.only(
                                            top: 16,
                                            left: 20,
                                            bottom: 16,
                                            right: 12),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      isExpanded: true,
                                      hint: const Text(
                                        "အမှတ်စဥ် အလိုက်ကြည့်မည်",
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black45,
                                      ),
                                      iconSize: 30,
                                      items: [
                                        DropdownMenuItem<MemberRange>(
                                          value: null,
                                          child: Text(
                                            "အမှတ်စဥ် အလိုက်ကြည့်မည်",
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        ...ranges.map(
                                            (item) => DropdownMenuItem<MemberRange>(
                                                  value: item,
                                                  child: Text(
                                                    "${item.label} (${item.count})",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                )),
                                      ],
                                      onChanged: (value) {
                                        ref
                                            .read(selectedMemberRangeProvider
                                                .notifier)
                                            .state = value;
                                      },
                                    )
                                  : Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "အမှတ်စဥ် မရှိပါ",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700]),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2.3,
                              margin: const EdgeInsets.only(
                                top: 12,
                                left: 4,
                              ),
                              child: DropdownButtonFormField<String>(
                                value: bloodTypes.contains(selectedBloodType)
                                    ? selectedBloodType
                                    : "သွေးအုပ်စုဖြင့် ရှာဖွေမည်",
                                dropdownColor: Colors.white,
                                focusColor: Colors.white,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      top: 12, left: 16, bottom: 12, right: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black45,
                                ),
                                iconSize: 30,
                                items: [
                                  DropdownMenuItem(
                                    value: "သွေးအုပ်စုဖြင့် ရှာဖွေမည်",
                                    child: Text(
                                      "သွေးအုပ်စုဖြင့် ရှာဖွေမည်",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  ...bloodTypes
                                      .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          )),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    ref
                                        .read(memberBloodTypeFilterProvider
                                            .notifier)
                                        .state = value;
                                    // Refresh ranges based on new blood type
                                    _refreshRanges();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Search and Advanced Search Section
                    Container(
                      margin:
                          const EdgeInsets.only(left: 16, right: 16, top: 8),
                      child: Column(
                        children: [
                          // Main search with toggle button
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: searchController,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black),
                                  onChanged: (val) {
                                    if (_debounceTimer?.isActive ?? false) {
                                      _debounceTimer?.cancel();
                                    }

                                    _debounceTimer = Timer(
                                        const Duration(milliseconds: 500), () {
                                      ref
                                          .read(memberSearchQueryProvider
                                              .notifier)
                                          .state = val;
                                      // Refresh members with new search query
                                      _refreshMembers();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
                                    hintStyle: const TextStyle(
                                        color: Colors.black, fontSize: 15.0),
                                    fillColor: Colors.white,
                                    filled: true,
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.search,
                                        color: primaryColor,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                        left: 20, right: 20, top: 4, bottom: 4),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                  ),
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isAdvancedSearchExpanded =
                                        !_isAdvancedSearchExpanded;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _isAdvancedSearchExpanded
                                        ? primaryColor
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _isAdvancedSearchExpanded
                                        ? Icons.filter_list_off
                                        : Icons.filter_list,
                                    color: _isAdvancedSearchExpanded
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Advanced search fields
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: _isAdvancedSearchExpanded ? null : 0,
                            child: _isAdvancedSearchExpanded
                                ? Container(
                                    margin: EdgeInsets.only(top: 12),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Column(
                                      children: [
                                        // First row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildSearchField(
                                                "ဖုန်းနံပါတ်",
                                                phoneController,
                                                (val) {
                                                  ref
                                                      .read(
                                                          memberPhoneSearchProvider
                                                              .notifier)
                                                      .state = val;
                                                  _refreshMembers();
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: _buildSearchField(
                                                "အဖေနာမည်",
                                                fatherNameController,
                                                (val) {
                                                  ref
                                                      .read(
                                                          memberFatherNameSearchProvider
                                                              .notifier)
                                                      .state = val;
                                                  _refreshMembers();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        // Second row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildSearchField(
                                                "သွေးဘဏ်ကတ်နံပါတ်",
                                                bloodBankCardController,
                                                (val) {
                                                  ref
                                                      .read(
                                                          memberBloodBankCardSearchProvider
                                                              .notifier)
                                                      .state = val;
                                                  _refreshMembers();
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: _buildSearchField(
                                                "အဖွဲ့ဝင် အမှတ်စဉ်",
                                                memberIdController,
                                                (val) {
                                                  ref
                                                      .read(memberIdSearchProvider
                                                          .notifier)
                                                      .state = val;
                                                  _refreshMembers();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        // Third row - Birthdate
                                        _buildSearchField(
                                          "မွေးသက္ကရာဇ်",
                                          birthDateController,
                                          (val) {
                                            ref
                                                .read(
                                                    memberBirthDateSearchProvider
                                                        .notifier)
                                                .state = val;
                                            _refreshMembers();
                                          },
                                        ),
                                        SizedBox(height: 12),
                                        // Clear filters button
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () {
                                              birthDateController.clear();
                                              phoneController.clear();
                                              fatherNameController.clear();
                                              bloodBankCardController.clear();
                                              memberIdController.clear();
                                              ref
                                                  .read(
                                                      memberBirthDateSearchProvider
                                                          .notifier)
                                                  .state = '';
                                              ref
                                                  .read(
                                                      memberPhoneSearchProvider
                                                          .notifier)
                                                  .state = '';
                                              ref
                                                  .read(
                                                      memberFatherNameSearchProvider
                                                          .notifier)
                                                  .state = '';
                                              ref
                                                  .read(
                                                      memberBloodBankCardSearchProvider
                                                          .notifier)
                                                  .state = '';
                                              ref
                                                  .read(memberIdSearchProvider
                                                      .notifier)
                                                  .state = '';
                                              _refreshMembers();
                                            },
                                            icon:
                                                Icon(Icons.clear_all, size: 20),
                                            label: Text("ရှင်းလင်းမည်"),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First row with dropdowns and search
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 5,
                          height: 50,
                          margin: const EdgeInsets.only(top: 28, left: 24),
                          child: ranges.isNotEmpty
                              ? DropdownButtonFormField<MemberRange>(
                                  value: selectedRange,
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        top: 16,
                                        left: 20,
                                        bottom: 16,
                                        right: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  isExpanded: true,
                                  hint: const Text(
                                    "အမှတ်စဥ် အလိုက်ကြည့်မည်",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: 30,
                                  items: [
                                    DropdownMenuItem<MemberRange>(
                                      value: null,
                                      child: Text(
                                        "အမှတ်စဥ် အလိုက်ကြည့်မည်",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    ...ranges
                                        .map((item) => DropdownMenuItem<MemberRange>(
                                              value: item,
                                              child: Text(
                                                "${item.label} (${item.count})",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            )),
                                  ],
                                  onChanged: (value) {
                                    ref
                                        .read(
                                            selectedMemberRangeProvider.notifier)
                                        .state = value;
                                  },
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        "အမှတ်စဥ် မရှိပါ",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700]),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 5,
                          margin: const EdgeInsets.only(top: 28, left: 20),
                          child: DropdownButtonFormField<String>(
                            value: bloodTypes.contains(selectedBloodType)
                                ? selectedBloodType
                                : "သွေးအုပ်စုဖြင့် ရှာဖွေမည်",
                            dropdownColor: Colors.white,
                            focusColor: Colors.white,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  top: 16, left: 20, bottom: 16, right: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            isExpanded: true,
                            hint: Text(
                              selectedBloodType,
                              style: const TextStyle(fontSize: 14),
                            ),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black45,
                            ),
                            iconSize: 30,
                            items: [
                              DropdownMenuItem(
                                value: "သွေးအုပ်စုဖြင့် ရှာဖွေမည်",
                                child: Text(
                                  "သွေးအုပ်စုဖြင့် ရှာဖွေမည်",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              ...bloodTypes
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(
                                        memberBloodTypeFilterProvider.notifier)
                                    .state = value;
                                _refreshRanges();
                              }
                            },
                            onSaved: (value) {},
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 5,
                          margin: const EdgeInsets.only(
                              right: 40, top: 28, left: 20),
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: TextFormField(
                            autofocus: false,
                            controller: searchController,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black),
                            onChanged: (val) {
                              if (_debounceTimer?.isActive ?? false) {
                                _debounceTimer?.cancel();
                              }

                              _debounceTimer =
                                  Timer(const Duration(milliseconds: 500), () {
                                ref
                                    .read(memberSearchQueryProvider.notifier)
                                    .state = val;
                                _refreshMembers();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
                              hintStyle: const TextStyle(
                                  color: Colors.black, fontSize: 15.0),
                              fillColor: Colors.white.withOpacity(0.2),
                              filled: true,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.search,
                                  color: primaryColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 4, bottom: 4),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey)),
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey)),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        // Advanced search toggle button
                        Container(
                          margin: const EdgeInsets.only(top: 28),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isAdvancedSearchExpanded =
                                    !_isAdvancedSearchExpanded;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isAdvancedSearchExpanded
                                    ? primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _isAdvancedSearchExpanded
                                    ? Icons.filter_list_off
                                    : Icons.filter_list,
                                color: _isAdvancedSearchExpanded
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Advanced search fields for desktop
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: _isAdvancedSearchExpanded ? null : 0,
                      child: _isAdvancedSearchExpanded
                          ? Container(
                              margin:
                                  EdgeInsets.only(left: 24, right: 40, top: 16),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildSearchField(
                                          "ဖုန်းနံပါတ်",
                                          phoneController,
                                          (val) {
                                            ref
                                                .read(memberPhoneSearchProvider
                                                    .notifier)
                                                .state = val;
                                            _refreshMembers();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildSearchField(
                                          "အဖေနာမည်",
                                          fatherNameController,
                                          (val) {
                                            ref
                                                .read(
                                                    memberFatherNameSearchProvider
                                                        .notifier)
                                                .state = val;
                                            _refreshMembers();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildSearchField(
                                          "သွေးဘဏ်ကတ်နံပါတ်",
                                          bloodBankCardController,
                                          (val) {
                                            ref
                                                .read(
                                                    memberBloodBankCardSearchProvider
                                                        .notifier)
                                                .state = val;
                                            _refreshMembers();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildSearchField(
                                          "အဖွဲ့ဝင် အမှတ်စဉ်",
                                          memberIdController,
                                          (val) {
                                            ref
                                                .read(memberIdSearchProvider
                                                    .notifier)
                                                .state = val;
                                            _refreshMembers();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: _buildSearchField(
                                          "မွေးသက္ကရာဇ်",
                                          birthDateController,
                                          (val) {
                                            ref
                                                .read(
                                                    memberBirthDateSearchProvider
                                                        .notifier)
                                                .state = val;
                                            _refreshMembers();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () {
                                              birthDateController.clear();
                                              phoneController.clear();
                                              fatherNameController.clear();
                                              bloodBankCardController.clear();
                                              memberIdController.clear();
                                              ref
                                                  .read(
                                                      memberBirthDateSearchProvider
                                                          .notifier)
                                                  .state = '';
                                              ref
                                                  .read(
                                                      memberPhoneSearchProvider
                                                          .notifier)
                                                  .state = '';
                                              ref
                                                  .read(
                                                      memberFatherNameSearchProvider
                                                          .notifier)
                                                  .state = '';
                                              ref
                                                  .read(
                                                      memberBloodBankCardSearchProvider
                                                          .notifier)
                                                  .state = '';
                                              ref
                                                  .read(memberIdSearchProvider
                                                      .notifier)
                                                  .state = '';
                                              _refreshMembers();
                                            },
                                            icon:
                                                Icon(Icons.clear_all, size: 20),
                                            label: Text("ရှင်းလင်းမည်"),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Add spacing between search UI and table
        SizedBox(height: 12),
        // Data table - shows prompt when no range selected
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8),
            child: _buildTableContent(members, selectedRange, isLoading, error),
          ),
        ),
      ],
    );
  }

  /// Build table content based on state
  Widget _buildTableContent(List<Member> members, MemberRange? selectedRange, bool isLoading, String? error) {
    // Show error message if there's an error
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 8),
            Text(
              'အမှား - $error',
              style: TextStyle(fontSize: 16, color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(rangedMemberListProvider);
              },
              icon: Icon(Icons.refresh),
              label: Text('ပြန်လည်ကြိုးစားမည်'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Show loading indicator when loading members for a range
    if (isLoading && selectedRange != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              'အဖွဲ့၀င်များ ရယူနေပါသည်...',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            )
          ],
        ),
      );
    }

    // Show prompt to select a range if no range selected
    if (selectedRange == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'အမှတ်စဥ် အုပ်စုတစ်ခု ရွေးချယ်ပါ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'အဖွဲ့၀င်များကို ကြည့်ရှုရန် အမှတ်စဥ် dropdown မှ ရွေးချယ်ပါ',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show the data table with members
    return buildSimpleTable(members);
  }

  Widget _buildSearchField(String label, TextEditingController controller,
      Function(String) onChanged) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Colors.black),
      onChanged: (val) {
        if (_debounceTimer?.isActive ?? false) {
          _debounceTimer?.cancel();
        }
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          onChanged(val);
        });
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey[700]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  Widget buildSimpleTable(List<Member> members) {
    memberDataDataSource = MemberListDataSource(memberData: members);

    return Container(
      margin: EdgeInsets.only(right: Responsive.isMobile(context) ? 16 : 16),
      child: SfDataGrid(
              source: memberDataDataSource!,
              onCellTap: (details) async {
                if (details.rowColumnIndex.rowIndex == 0) return;

                final member = members[details.rowColumnIndex.rowIndex - 1];

                if (member.id != null) {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => MemberDetailScreen(
                        memberId: member.id.toString(),
                      ),
                    ),
                  )
                      .then((_) {
                    // When returning from detail screen, refresh ranges and clear filters
                    ref.invalidate(memberRangesProvider);
                    ref.invalidate(rangedMemberListProvider);

                    // Clear search field
                    searchController.clear();
                  });
                }
              },
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              columnWidthMode: Responsive.isMobile(context)
                  ? ColumnWidthMode.auto
                  : ColumnWidthMode.fitByCellValue,
              columns: <GridColumn>[
                GridColumn(
                    columnName: 'အမှတ်စဥ်',
                    label: Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        color: primaryColor,
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'အမှတ်စဥ်',
                          style: TextStyle(color: Colors.white),
                        ))),
                GridColumn(
                    columnName: 'အမည်',
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'အမည်',
                          style: TextStyle(color: Colors.white),
                        ))),
                GridColumn(
                    columnName: 'အဖအမည်',
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'အဖအမည်',
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ))),
                GridColumn(
                    columnName: 'သွေးအုပ်စု',
                    width: 100,
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'သွေးအုပ်စု',
                          style: TextStyle(color: Colors.white),
                        ))),
                GridColumn(
                    columnName: 'မှတ်ပုံတင်အမှတ်',
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'မှတ်ပုံတင်အမှတ်',
                          style: TextStyle(color: Colors.white),
                        ))),
                GridColumn(
                    columnName: 'သွေးဘဏ်ကတ်',
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'သွေးဘဏ်ကတ်',
                          style: TextStyle(color: Colors.white),
                        ))),
                GridColumn(
                    columnName: 'သွေးလှူမှုကြိမ်ရေ',
                    width: 120,
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'သွေးလှူမှုကြိမ်ရေ',
                          style: TextStyle(color: Colors.white),
                        ))),
                GridColumn(
                    columnName: 'မွေးသက္ကရာဇ်',
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'မွေးသက္ကရာဇ်',
                          style: TextStyle(color: Colors.white),
                        ))),
                GridColumn(
                    columnName: 'ဖုန်းနံပါတ်',
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'ဖုန်းနံပါတ်',
                          style: TextStyle(color: Colors.white),
                        ))),
                GridColumn(
                    columnName: 'နေရပ်လိပ်စာ',
                    label: Container(
                        color: primaryColor,
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'နေရပ်လိပ်စာ',
                          style: TextStyle(color: Colors.white),
                        ))),
              ],
            ),
    );
  }
}

// A temporary screen to simulate the new member functionality
class NewMemberTemporaryScreen extends StatefulWidget {
  @override
  _NewMemberTemporaryScreenState createState() =>
      _NewMemberTemporaryScreenState();
}

class _NewMemberTemporaryScreenState extends State<NewMemberTemporaryScreen> {
  final nameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final phoneController = TextEditingController();
  final extraPhoneController = TextEditingController();
  final bloodBankCardController = TextEditingController();
  final memberCountController = TextEditingController();
  final nrcController = TextEditingController(); // For the number part only
  final homeNoController = TextEditingController();
  final streetController = TextEditingController();
  final quarterController = TextEditingController();
  final townshipController = TextEditingController();
  final birthDateController = TextEditingController();

  // NRC selection variables
  int nrcValue = 0; // 0 for normal NRC, 1 for MME
  String? nrc_initial_options_Value = "၁၀"; // Default to Yangon
  String? nrc_region_state_options_Value = "မလမ";
  String? nrc_type_options_Value = "နိုင်";
  late List<DropdownMenuItem<String>> nrc_initial_options_dropDownMenuItems;
  late List<DropdownMenuItem<String>>
      nrc_region_state_options_dropDownMenuItems;
  late List<DropdownMenuItem<String>> nrc_type_options_dropDownMenuItems;

  String selectedBloodType = "A (Rh +)";
  int genderValue = 0; // 0 for male, 1 for female
  bool extraPhone = false;
  String birthDate = "မွေးသက္ကရာဇ်";

  List<String> bloodTypes = [
    "A (Rh +)",
    "B (Rh +)",
    "AB (Rh +)",
    "O (Rh +)",
    "A (Rh -)",
    "B (Rh -)",
    "AB (Rh -)",
    "O (Rh -)",
  ];

  // Use NRC data from utility
  List<String> nrc_initial_options = NrcData.nrc_initial_options;
  List<String> nrc_type_options = NrcData.nrc_type_options;

  // Map of state codes to township lists
  Map<String, List<String>> townshipMap = NrcData.commonTownshipMap;

  // Add nameChecked variable
  bool nameChecked = false;
  bool isSearchingMember = false;

  // Township data
  late TownshipResponse townshipResponse;
  List<String> townships = <String>[];

  @override
  void initState() {
    super.initState();
    // Initialize NRC dropdown items
    nrc_initial_options_dropDownMenuItems = getNrcInitialDropdownItems();
    nrc_type_options_dropDownMenuItems = getNrcTypeDropdownItems();
    nrc_region_state_options_dropDownMenuItems =
        getNrcRegionStateDropdownItems("၁၀"); // Default to Yangon

    // Load township data
    _loadTownshipData();
  }

  Future<void> _loadTownshipData() async {
    final String response =
        await rootBundle.loadString('assets/json/township.json');
    townshipResponse = TownshipResponse.fromJson(json.decode(response));
    if (townshipResponse.data != null) {
      setState(() {
        townships = townshipResponse.data!
            .map((datum) => datum.township ?? '')
            .where((township) => township.isNotEmpty)
            .toSet() // Remove duplicates
            .toList()
          ..sort(); // Sort alphabetically
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryDark],
        ))),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("အဖွဲ့၀င်အသစ် ထည့်သွင်းမည်",
              style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left half - Member Info Card
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Image.asset("assets/images/card.png", width: 54),
                          const SizedBox(width: 16),
                          Text(
                            "အဖွဲ့၀င်အသစ် အချက်အလက်များ",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 12),

                      // Replace name input field with a Row that includes check button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Text(
                                "အမည်",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 116, 112, 112),
                                ),
                              ),
                            ),
                            const Text("-",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black)),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: nameController,
                                      onChanged: (val) {
                                        setState(() {
                                          nameChecked = false;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  nameChecked
                                      ? Image.asset(
                                          "assets/images/checked.png",
                                          height: 24,
                                          width: 24,
                                        )
                                      : Consumer(
                                          builder: (context, ref, child) {
                                          return GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTap: () => isSearchingMember
                                                ? null
                                                : _checkExistingMember(
                                                    context, ref),
                                            child: isSearchingMember
                                                ? SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              primaryColor),
                                                    ))
                                                : Image.asset(
                                                    "assets/images/magnifier.png",
                                                    height: 24,
                                                    width: 24,
                                                  ),
                                          );
                                        }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildInputRow("အဖအမည်", fatherNameController),

                      // Birth Date Picker
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Text("မွေးသက္ကရာဇ်",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
                            ),
                            const Text("-",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black)),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: InkWell(
                                onTap: () => _showDatePicker(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    birthDate,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Blood Type Dropdown
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Text("သွေးအုပ်စု",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
                            ),
                            const Text("-",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black)),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: DropdownButtonFormField<String>(
                                value: selectedBloodType,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  isDense: true,
                                ),
                                items: bloodTypes.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type,
                                        style: TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedBloodType = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // NRC Selection - replaces the single NRC field with proper format
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, bottom: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    "နိုင်ငံသားစီစစ်ရေးကတ်ပြားအမှတ်",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 116, 112, 112)),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "(ဖြည့်စွက်ရန် မလိုအပ်ပါ)",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                // Radio buttons for NRC type
                                Radio(
                                  value: 0,
                                  groupValue: nrcValue,
                                  activeColor: primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      nrcValue = 0;
                                    });
                                  },
                                ),
                                Text("မှတ်ပုံတင်အမှတ်",
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(width: 12),
                                Radio(
                                  value: 1,
                                  groupValue: nrcValue,
                                  activeColor: primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      nrcValue = 1;
                                    });
                                  },
                                ),
                                Text("MME", style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            nrcValue == 0
                                ? Container(
                                    margin: const EdgeInsets.only(
                                        left: 8, right: 8, top: 8),
                                    child: Row(
                                      children: [
                                        // Township Code Dropdown
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: DropdownButton(
                                            value: nrc_initial_options_Value,
                                            items:
                                                nrc_initial_options_dropDownMenuItems,
                                            underline: SizedBox(),
                                            onChanged: (value) =>
                                                nrcInitialOptionsChanged(value),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 4, right: 4),
                                          child: Text("/",
                                              style: TextStyle(fontSize: 18)),
                                        ),
                                        // Township Name Dropdown
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: DropdownButton(
                                            value:
                                                nrc_region_state_options_Value,
                                            items:
                                                nrc_region_state_options_dropDownMenuItems,
                                            underline: SizedBox(),
                                            onChanged: (value) =>
                                                nrcRegionStateOptionsChanged(
                                                    value),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 4, right: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: DropdownButton(
                                            value: nrc_type_options_Value,
                                            items:
                                                nrc_type_options_dropDownMenuItems,
                                            underline: SizedBox(),
                                            onChanged: (value) =>
                                                nrcTypeOptionsChanged(value),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 35,
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            child: TextFormField(
                                              controller: nrcController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 10),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.only(
                                        left: 8, right: 8, top: 8),
                                    child: Row(
                                      children: [
                                        Text("MME - ",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        Expanded(
                                          child: Container(
                                            height: 35,
                                            child: TextFormField(
                                              controller: nrcController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 10),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),

                      // Gender Radio Buttons
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Text("လိင်အမျိုးအစား",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
                            ),
                            const Text("-",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black)),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Radio(
                                    value: 0,
                                    groupValue: genderValue,
                                    activeColor: primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        genderValue = 0;
                                      });
                                    },
                                  ),
                                  Text("ကျား", style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 16),
                                  Radio(
                                    value: 1,
                                    groupValue: genderValue,
                                    activeColor: primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        genderValue = 1;
                                      });
                                    },
                                  ),
                                  Text("မ", style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildInputRow("ဖုန်းနံပါတ်", phoneController),

                      // Extra Phone Toggle
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Text("အခြားဖုန်းနံပါတ်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                  SizedBox(width: 8),
                                  Switch(
                                    value: extraPhone,
                                    activeColor: primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        extraPhone = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Text("-",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black)),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: extraPhone
                                  ? TextFormField(
                                      controller: extraPhoneController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ),
                          ],
                        ),
                      ),

                      _buildInputRow(
                          "သွေးဘဏ်ကတ်နံပါတ်", bloodBankCardController),
                      _buildInputRow(
                        "ယခင်သွေးလှူအကြိမ်",
                        memberCountController,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputRow("အိမ်အမှတ်", homeNoController),
                      _buildInputRow("လမ်းအမည်", streetController),
                      _buildInputRow("ရပ်ကွက်/ရွာအမည်", quarterController),

                      // Township TypeAheadField
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Text("မြို့နယ်",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
                            ),
                            const Text("-",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black)),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: TypeAheadField<String>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: townshipController,
                                  decoration: InputDecoration(
                                    hintText: 'မြို့နယ်ရွေးချယ်ပါ',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                suggestionsCallback: (pattern) {
                                  List<String> suggestions = [];
                                  
                                  // First, get မော်လမြိုင် townships
                                  var mawlamyineItems = townships.where((item) => 
                                    item.contains('မော်လမြိုင်'));
                                  
                                  // Then get other townships
                                  var otherItems = townships.where((item) => 
                                    !item.contains('မော်လမြိုင်'));
                                  
                                  if (pattern.isEmpty) {
                                    // Show မော်လမြိုင် townships first
                                    suggestions.addAll(mawlamyineItems);
                                    suggestions.addAll(otherItems.take(10 - suggestions.length));
                                  } else {
                                    // Filter by pattern but still prioritize မော်လမြိုင်
                                    var filteredMawlamyine = mawlamyineItems.where((item) =>
                                      item.toLowerCase().contains(pattern.toLowerCase()));
                                    var filteredOthers = otherItems.where((item) =>
                                      item.toLowerCase().contains(pattern.toLowerCase()));
                                    suggestions.addAll(filteredMawlamyine);
                                    suggestions.addAll(filteredOthers);
                                  }
                                  
                                  return suggestions.take(10).toList();
                                },
                                itemBuilder: (context, String township) {
                                  return ListTile(
                                    dense: true,
                                    title: Text(township,
                                        style: TextStyle(fontSize: 14)),
                                  );
                                },
                                onSuggestionSelected: (String township) {
                                  townshipController.text = township;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 12),

                      // Submit Button
                      Consumer(builder: (context, ref, child) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => nameChecked
                                ? _saveMember(context, ref)
                                : _showNameCheckRequiredDialog(context),
                            child: Text(
                              "ထည့်သွင်းမည်",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Right side - empty space or instruction
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "အကူအညီ",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                        SizedBox(height: 12),
                        Container(height: 1, color: Colors.grey.shade200),
                        SizedBox(height: 12),
                        Text(
                          "• မှတ်ပုံတင်အမှတ် ဖြည့်သွင်းပါ",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "• အမည်နှင့် အဖအမည် မဖြစ်မနေ ဖြည့်သွင်းပေးပါ",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "• သွေးအုပ်စု ရွေးချယ်ပေးပါ",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "• ဖုန်းနံပါတ် ဖြည့်သွင်းပေးပါ",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller,
      {String? hintText, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(label,
                style: TextStyle(
                    fontSize: 14, color: Color.fromARGB(255, 116, 112, 112))),
          ),
          const Text("-", style: TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        birthDate = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Methods to handle NRC dropdown changes
  void nrcInitialOptionsChanged(String? value) {
    if (value != null) {
      setState(() {
        nrc_initial_options_Value = value;
        nrc_region_state_options_dropDownMenuItems =
            getNrcRegionStateDropdownItems(value);
        nrc_region_state_options_Value =
            nrc_region_state_options_dropDownMenuItems[0].value;
      });
    }
  }

  void nrcRegionStateOptionsChanged(String? value) {
    if (value != null) {
      setState(() {
        nrc_region_state_options_Value = value;
      });
    }
  }

  void nrcTypeOptionsChanged(String? value) {
    if (value != null) {
      setState(() {
        nrc_type_options_Value = value;
      });
    }
  }

  // Helper methods to create dropdown items
  List<DropdownMenuItem<String>> getNrcInitialDropdownItems() {
    return NrcData.nrc_initial_options.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> getNrcTypeDropdownItems() {
    return NrcData.nrc_type_options.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> getNrcRegionStateDropdownItems(
      String stateCode) {
    // Get the township list from the NrcData utility if available, otherwise fall back to common township map
    List<String> townshipList = NrcData.stateToTownshipMap[stateCode] ??
        NrcData.commonTownshipMap[stateCode] ??
        NrcData.mon; // Default to Mon townships

    return townshipList.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );
    }).toList();
  }

  // Get complete NRC string
  String _getCompleteNrc() {
    return NrcData.getCompleteNrc(
        nrcValue,
        nrc_initial_options_Value ?? "",
        nrc_region_state_options_Value ?? "",
        nrc_type_options_Value ?? "",
        nrcController.text);
  }

  // Update the _checkExistingMember method to check by name, father name, and blood type
  Future<void> _checkExistingMember(BuildContext context, WidgetRef ref) async {
    // Check if name is entered
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အမည် ဖြည့်သွင်းပေးပါ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set searching state
    setState(() {
      isSearchingMember = true;
    });

    try {
      // Get repository instance
      final memberRepository = ref.read(memberRepositoryProvider);

      // Call the API to check for existing members
      final result = await memberRepository.checkMemberExists(
        nameController.text,
        fatherName: fatherNameController.text,
        bloodType: selectedBloodType == "သွေးအုပ်စု" ? null : selectedBloodType,
      );

      // Reset searching state
      setState(() {
        isSearchingMember = false;
      });

      // Check if members were found
      if (result['exists'] == true) {
        // Get the list of matching members
        final List<Member> matchingMembers = result['members'] as List<Member>;

        // Show dialog with matching members
        _showMembersFoundDialog(context, matchingMembers);
      } else {
        // No matching members found, set nameChecked to true
        setState(() {
          nameChecked = true;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'ဤအမည်ဖြင့် အဖွဲ့ဝင် မရှိသေးပါ။ ဆက်လက် ဖြည့်သွင်းနိုင်ပါသည်။'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Reset searching state
      setState(() {
        isSearchingMember = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Update the _showMembersFoundDialog to display more detailed information and highlight exact matches
  void _showMembersFoundDialog(BuildContext context, List<Member> members) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth =
        Responsive.isMobile(context) ? screenWidth * 0.9 : screenWidth * 0.5;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding:
              EdgeInsets.symmetric(horizontal: (screenWidth - dialogWidth) / 2),
          child: Container(
            width: dialogWidth,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        "assets/images/list_exist.png",
                        height: 30,
                        width: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "အဖွဲ့ဝင် ရှိပြီးသားစာရင်း",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                // Divider
                const SizedBox(height: 8),
                Divider(height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 8),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    "အောက်ပါအဖွဲ့ဝင်များနှင့် ကိုက်ညီနေပါသည်",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Member list
                Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: members.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                      indent: 12,
                      endIndent: 12,
                    ),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      // Check if this is an exact match
                      bool isExactMatch = member.name?.toLowerCase() ==
                              nameController.text.toLowerCase() &&
                          (fatherNameController.text.isEmpty ||
                              member.fatherName?.toLowerCase() ==
                                  fatherNameController.text.toLowerCase());

                      return Container(
                        decoration: isExactMatch
                            ? BoxDecoration(
                                color: primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(4),
                              )
                            : null,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Row(
                            children: [
                              if (isExactMatch)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "အတိအကျ",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  member.name ?? '',
                                  style: TextStyle(
                                    fontWeight: isExactMatch
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isExactMatch ? primaryColor : null,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "အဖအမည်: ${member.fatherName ?? '-'}",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    "သွေးအမျိုးအစား: ${member.bloodType ?? '-'}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (member.memberId != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "အဖွဲ့၀င်အမှတ်: ${member.memberId}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  Text(
                                    "မွေးသက္ကရာဇ်: ${member.birthDate ?? '-'}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                // Navigate to member detail
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemberDetailScreen(
                                      memberId: member.id.toString(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          onTap: () {
                            // Navigate to member detail
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemberDetailScreen(
                                  memberId: member.id.toString(),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Action buttons
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "ထပ်မံရှာဖွေမည်",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "အသစ်ထည့်သွင်းမည်",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          nameChecked = true;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add method to show name check required dialog
  void _showNameCheckRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "အမည်စစ်ဆေးရန် လိုအပ်ပါသည်",
            style: TextStyle(fontSize: 16),
          ),
          content: Text(
              "အဖွဲ့ဝင်အသစ် မထည့်သွင်းမီ အမည်စစ်ဆေးရန် လိုအပ်ပါသည်။ အမည်ပြီးသည့်နောက် စစ်ဆေးခလုတ်ကို နှိပ်ပါ။"),
          actions: [
            TextButton(
              child: Text("အိုကေ"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveMember(BuildContext context, WidgetRef ref) async {
    // Verify that name checking was performed
    if (!nameChecked) {
      _showNameCheckRequiredDialog(context);
      return;
    }

    // Validate required fields
    if (nameController.text.isEmpty ||
        fatherNameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အမည်, အဖအမည်, နှင့် ဖုန်းနံပါတ် ဖြည့်သွင်းပေးပါ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // For blood type validation
    if (selectedBloodType == "သွေးအုပ်စု") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('သွေးအုပ်စု ရွေးချယ်ပေးပါ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Format the address
      final address = [
        homeNoController.text,
        streetController.text,
        quarterController.text,
        townshipController.text,
      ].where((part) => part.isNotEmpty).join('၊ ');

      // Format the birth date (convert from d/m/y to y-m-d format for API)
      String? formattedBirthDate;
      if (birthDate != "မွေးသက္ကရာဇ်") {
        final parts = birthDate.split('/');
        if (parts.length == 3) {
          formattedBirthDate = "${parts[2]}-${parts[1]}-${parts[0]}";
        }
      }

      // Create member data for API - matching exactly what MemberController.php expects
      final memberData = {
        'name': nameController.text,
        'father_name': fatherNameController.text,
        'blood_type': selectedBloodType,
        'nrc': _getCompleteNrc(),
        'phone': phoneController.text,
        'phone_2': extraPhone ? extraPhoneController.text : null,
        'blood_bank_card': bloodBankCardController.text,
        'member_count': memberCountController.text.isEmpty
            ? '0'
            : memberCountController.text,
        'birth_date': formattedBirthDate,
        'gender': genderValue == 0 ? 'male' : 'female',
        'address': address,
      };

      print("Creating member with data: $memberData");

      // Use the member service to create the member
      final memberService = ref.read(member_service.memberServiceProvider);
      final response = await memberService.createMember(memberData);

      print("Member creation response: $response");

      // Refresh the member list
      await ref.read(refreshMembersProvider)();

      // Pop the loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အဖွဲ့၀င်အသစ် ထည့်သွင်းခြင်း အောင်မြင်ပါသည်။'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Return true to indicate a successful creation
      Navigator.pop(context, true);
    } catch (e) {
      // Pop the loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အဖွဲ့၀င်အသစ် ထည့်သွင်းခြင်း မအောင်မြင်ပါ - Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
