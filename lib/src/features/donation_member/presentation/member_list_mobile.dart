import 'dart:async';
import 'dart:developer' as dev;
import 'package:donation/src/common_widgets/mobile_card.dart';
import 'package:donation/src/common_widgets/mobile_list_item.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/member_detail.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mobile-optimized member list screen
class MemberListMobileScreen extends ConsumerStatefulWidget {
  const MemberListMobileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MemberListMobileScreen> createState() => _MemberListMobileScreenState();
}

class _MemberListMobileScreenState extends ConsumerState<MemberListMobileScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isSearching = false;

  final List<String> bloodTypes = [
    "All",
    "A (Rh +)",
    "B (Rh +)",
    "AB (Rh +)",
    "O (Rh +)",
    "A (Rh -)",
    "B (Rh -)",
    "AB (Rh -)",
    "O (Rh -)",
  ];

  @override
  void initState() {
    super.initState();
    // Schedule the data initialization after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _initializeData() async {
    try {
      await ref.read(loadMembersProvider)(false);
    } catch (e) {
      dev.log("Error loading member data: $e");
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(memberSearchQueryProvider.notifier).state = query;
      _filterMembers();
    });
  }

  void _filterMembers() {
    // Use the updateFilteredMembers function from the provider
    updateFilteredMembers(ref);
  }

  void _makePhoneCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(filteredMemberListProvider);
    final isLoading = ref.watch(memberLoadingProvider);
    final selectedBloodType = ref.watch(memberBloodTypeFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: const Text(
          'အဖွဲ့ဝင် စာရင်း',
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewMemberTemporaryScreen(),
                ),
              );
              if (result == true) {
                _initializeData();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Blood type filter dropdown
                DropdownButtonFormField<String>(
                  value: selectedBloodType.isEmpty || selectedBloodType == 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်'
                      ? 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်'
                      : selectedBloodType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်',
                      child: Text('သွေးအုပ်စုဖြင့် ရှာဖွေမည်'),
                    ),
                    ...bloodTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(memberBloodTypeFilterProvider.notifier).state =
                          value == 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်' ? '' : value;
                      _filterMembers();
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Member count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Text(
              'စုစုပေါင်း အဖွဲ့ဝင် (${members.length}) ဦး',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Table
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(loadMembersProvider)(true);
              },
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : members.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? 'ရှာဖွေမှု ရလဒ် မရှိပါ'
                                    : 'အဖွဲ့ဝင် မရှိသေးပါ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewMemberTemporaryScreen(),
                                    ),
                                  );
                                  if (result == true) {
                                    _initializeData();
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('အဖွဲ့ဝင်အသစ် ထည့်သွင်းမည်'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.only(bottom: 80),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(primaryColor),
                              headingTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              columnSpacing: 16,
                              dataRowMinHeight: 48,
                              dataRowMaxHeight: 60,
                              columns: const [
                                DataColumn(label: Text('အမှတ်စဥ်')),
                                DataColumn(label: Text('အမည်')),
                                DataColumn(label: Text('အဖအမည်')),
                                DataColumn(label: Text('သွေးအုပ်စု')),
                                DataColumn(label: Text('ဖုန်းနံပါတ်')),
                                DataColumn(label: Text('လှူခဲ့သည့်ကြိမ်')),
                                DataColumn(label: Text('လုပ်ဆောင်ချက်')),
                              ],
                              rows: members.map((member) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(
                                      member.memberId ?? '',
                                      style: const TextStyle(fontSize: 13),
                                    )),
                                    DataCell(
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MemberDetailScreen(
                                                memberId: member.id ?? '',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          member.name ?? '-',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(
                                      member.fatherName ?? '-',
                                      style: const TextStyle(fontSize: 13),
                                    )),
                                    DataCell(Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        member.bloodType ?? '-',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )),
                                    DataCell(Text(
                                      member.phone ?? '-',
                                      style: const TextStyle(fontSize: 13),
                                    )),
                                    DataCell(Text(
                                      member.totalCount ?? '0',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.visibility,
                                              color: primaryColor,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => MemberDetailScreen(
                                                    memberId: member.id ?? '',
                                                  ),
                                                ),
                                              );
                                            },
                                            tooltip: 'ကြည့်မည်',
                                            padding: const EdgeInsets.all(4),
                                            constraints: const BoxConstraints(),
                                          ),
                                          if (member.phone != null)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.phone,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                              onPressed: () => _makePhoneCall(member.phone),
                                              tooltip: 'ဖုန်းခေါ်မည်',
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewMemberTemporaryScreen(),
            ),
          );

          if (result == true) {
            _initializeData();
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

}

/// Alternative list view with sections
class MemberListWithSections extends ConsumerWidget {
  final List<Member> members;

  const MemberListWithSections({
    Key? key,
    required this.members,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group members by blood type
    final groupedMembers = <String, List<Member>>{};
    for (final member in members) {
      final bloodType = member.bloodType ?? 'Unknown';
      groupedMembers[bloodType] = [...(groupedMembers[bloodType] ?? []), member];
    }

    final sortedGroups = groupedMembers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      itemCount: sortedGroups.length,
      itemBuilder: (context, groupIndex) {
        final group = sortedGroups[groupIndex];
        final groupMembers = group.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobileSectionHeader(
              title: '${group.key} (${groupMembers.length})',
            ),
            ...groupMembers.map((member) => MemberCard(
              key: ValueKey(member.memberId),
              name: member.name ?? 'Unknown',
              memberId: member.memberId,
              bloodType: member.bloodType,
              phone: member.phone,
              lastDonation: member.lastDate,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemberDetailScreen(
                      memberId: member.id ?? '',
                    ),
                  ),
                );
              },
            )).toList(),
          ],
        );
      },
    );
  }
}
