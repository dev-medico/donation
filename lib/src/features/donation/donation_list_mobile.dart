import 'package:donation/src/common_widgets/mobile_app_bar.dart';
import 'package:donation/src/common_widgets/mobile_card.dart';
import 'package:donation/src/common_widgets/mobile_list_item.dart';
import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/donation/new_blood_donation.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// Mobile-optimized donation list screen
class DonationListMobileScreen extends ConsumerStatefulWidget {
  const DonationListMobileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DonationListMobileScreen> createState() => _DonationListMobileScreenState();
}

class _DonationListMobileScreenState extends ConsumerState<DonationListMobileScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month - 1;
  
  final List<int> years = List.generate(
    15, 
    (index) => DateTime.now().year - index,
  );
  
  final List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: _selectedMonth,
    );
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedMonth = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Select Year',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    final isSelected = year == _selectedYear;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedYear = year;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        color: isSelected ? Colors.red.withValues(alpha: 0.1) : null,
                        child: Row(
                          children: [
                            Text(
                              year.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.red : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check, color: Colors.red),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final donationsAsync = ref.watch(donationsByMonthYearProvider((
      month: _selectedMonth + 1,
      year: _selectedYear,
    )));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: MobileAppBar(
        title: 'Blood Donations',
        actions: [
          TextButton.icon(
            onPressed: _showYearPicker,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              _selectedYear.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              indicatorWeight: 3,
              tabs: months.map((month) => Tab(text: month)).toList(),
            ),
          ),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(12, (monthIndex) {
          final monthDonations = ref.watch(donationsByMonthYearProvider((
            month: monthIndex + 1,
            year: _selectedYear,
          )));
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(donationsByMonthYearProvider((
                month: monthIndex + 1,
                year: _selectedYear,
              )));
            },
            child: monthDonations.when(
              data: (donations) {
                if (donations.isEmpty) {
                  return MobileEmptyState(
                    title: 'No donations yet',
                    subtitle: 'No blood donations recorded for ${months[monthIndex]} $_selectedYear',
                    icon: Icon(
                      Icons.bloodtype_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    actionLabel: 'Add Donation',
                    onAction: () => _navigateToNewDonation(),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final donation = donations[index];
                    return DonationCard(
                      key: ValueKey(donation.id),
                      donorName: donation.memberObj?.name ?? 'Unknown Donor',
                      date: _formatDate(donation.donationDate),
                      hospital: donation.hospital,
                      patientName: donation.patientName,
                      bloodType: donation.memberObj?.bloodType,
                      status: 'Completed',
                      onTap: () => _navigateToDonationDetail(donation),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text('Failed to load donations'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.refresh(donationsByMonthYearProvider((
                          month: monthIndex + 1,
                          year: _selectedYear,
                        )));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewDonation,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _navigateToNewDonation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewBloodDonationScreen(),
      ),
    );
    
    if (result == true) {
      // Refresh the current month's data
      ref.refresh(donationsByMonthYearProvider((
        month: _selectedMonth + 1,
        year: _selectedYear,
      )));
    }
  }

  void _navigateToDonationDetail(Donation donation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationDetailScreen(data: donation),
      ),
    );
  }
}

/// Alternative timeline view for donations
class DonationTimelineView extends ConsumerWidget {
  final List<Donation> donations;
  final VoidCallback? onRefresh;
  
  const DonationTimelineView({
    Key? key,
    required this.donations,
    this.onRefresh,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group donations by date
    final groupedDonations = <String, List<Donation>>{};
    
    for (final donation in donations) {
      final dateKey = DateFormat('dd MMM yyyy').format(donation.donationDate ?? DateTime.now());
      groupedDonations[dateKey] = [...(groupedDonations[dateKey] ?? []), donation];
    }
    
    final sortedDates = groupedDonations.keys.toList()
      ..sort((a, b) => DateFormat('dd MMM yyyy').parse(b).compareTo(
            DateFormat('dd MMM yyyy').parse(a),
          ));
    
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final dateDonations = groupedDonations[date] ?? [];
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Donations for this date
              ...dateDonations.map((donation) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTimelineItem(context, donation),
              )).toList(),
              
              if (index < sortedDates.length - 1)
                const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildTimelineItem(BuildContext context, Donation donation) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailScreen(data: donation),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Blood drop icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bloodtype,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(width: 16),
            
            // Donation info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.memberObj?.name ?? 'Unknown Donor',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (donation.memberObj?.bloodType != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            donation.memberObj?.bloodType ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (donation.hospital != null)
                        Expanded(
                          child: Text(
                            donation.hospital ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}