import 'package:donation/responsive.dart';
import 'package:donation/src/features/dashboard/ui/dashboard_card.dart';
import 'package:donation/src/features/donation/blood_request_give_chart.dart';
import 'package:donation/src/features/donation/donation_chart_by_blood.dart';
import 'package:donation/src/features/donation/donation_chart_by_hospital.dart';
import 'package:donation/src/features/finder/blood_donation_gender_pie_chart.dart';
import 'package:donation/src/features/finder/blood_donation_pie_chart.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/core/api/api_client.dart';

class DashboardStats {
  final int totalMembers;
  final int totalDonations;
  final int totalPatients;
  final int totalExpenses;
  final int donations;

  DashboardStats({
    required this.totalMembers,
    required this.totalDonations,
    required this.totalPatients,
    required this.totalExpenses,
    required this.donations,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalMembers: json['totalMember'] ?? 0,
      totalDonations: json['totalDonations'] ?? 0,
      totalPatients: json['totalPatient'] ?? 0,
      totalExpenses: json['totalExpenses'] ?? 0,
      donations: json['donations'] ?? 0,
    );
  }
}

class ReportMobileScreen extends ConsumerStatefulWidget {
  const ReportMobileScreen({super.key});

  @override
  ConsumerState<ReportMobileScreen> createState() => _ReportMobileScreenState();
}

class _ReportMobileScreenState extends ConsumerState<ReportMobileScreen> {
  int totalMembers = 0;
  int totalDonations = 0;
  int totalPatients = 0;
  int totalExpenses = 0;
  int donationCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final apiClient = ApiClient();
      final response = await apiClient.get<Map<String, dynamic>>(
        '/report/dashboard',
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        final data = response.data!['data'];
        setState(() {
          totalMembers = data['totalMember'] ?? 0;
          totalDonations = data['totalDonations'] ?? 0;
          totalPatients = data['totalPatient'] ?? 0;
          totalExpenses = data['totalExpenses'] ?? 0;
          donationCount = data['donations'] ?? 0;
          isLoading = false;
        });
      } else {
        print('Failed to load dashboard data: ${response.data?['message']}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // A plain white card. The charts used to sit inside an ElevatedButton,
  // which tinted their text with the button's foreground colour and spent
  // 24px of horizontal padding on each side of a phone screen.
  Widget _buildChartCard({required Widget child}) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(
        Responsive.isMobile(context) ? 12 : 16,
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          margin: EdgeInsets.only(left: 20, right: 12),
          child: Row(
            children: [
              DashboardCard(
                index: 0,
                color: primaryDark,
                title: Responsive.isMobile(context)
                    ? "အဖွဲ့၀င် စာရင်း"
                    : "အဖွဲ့၀င် စာရင်း",
                subtitle: "စုစုပေါင်း",
                amount: totalMembers.toString(),
                amountColor: Colors.black,
              ),
              SizedBox(width: 12),
              DashboardCard(
                index: 1,
                color: primaryDark,
                title: "သွေးလှူမှတ်တမ်း",
                subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                amount: totalDonations.toString(),
                amountColor: Colors.blue,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 20, right: 12),
          child: Row(
            children: [
              DashboardCard(
                index: 2,
                color: primaryDark,
                title: Responsive.isMobile(context)
                    ? "လူနာ \nစာရင်း"
                    : "လူနာ စာရင်း",
                subtitle: "စုစုပေါင်း",
                amount: totalPatients.toString(),
                amountColor: Colors.black,
              ),
              SizedBox(width: 12),
              DashboardCard(
                index: 3,
                color: primaryDark,
                title: "ရ/သုံး ငွေစာရင်း",
                subtitle: "-",
                amount: "-",
                amountColor: Colors.black,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: _buildChartCard(
            child: BloodDonationPieChart(),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: _buildChartCard(
            child: BloodDonationGenderPieChart(),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: DonationChartByBlood(),
        ),
        Container(
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: DonationChartByHospital(),
        ),
        Container(
          margin: EdgeInsets.only(top: 4, left: 20, right: 20, bottom: 20),
          child: _buildChartCard(
            child:  BloodRequestGiveChartScreen(),
          ),
        ),
      ],
    );
  }
}
