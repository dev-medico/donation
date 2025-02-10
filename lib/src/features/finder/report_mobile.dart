import 'package:donation/realm/schemas.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/dashboard/ui/dashboard_card.dart';
import 'package:donation/src/features/donation/blood_request_give_chart.dart';
import 'package:donation/src/features/donation/donation_chart_by_blood.dart';
import 'package:donation/src/features/donation/donation_chart_by_hospital.dart';
import 'package:donation/src/features/finder/blood_donation_gender_pie_chart.dart';
import 'package:donation/src/features/finder/blood_donation_pie_chart.dart';
import 'package:donation/src/features/finder/most_blood_donation_member.dart';
import 'package:donation/src/features/finder/new_request_give.dart';
import 'package:donation/src/features/finder/request_give_report.dart';
import 'package:donation/src/providers/providers.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/responsive_row_column.dart';
import 'package:dio/dio.dart';
import 'package:donation/core/api/api_response.dart';

class DashboardStats {
  final int totalMembers;
  final int totalDonations;
  final int totalPatients;
  final List<dynamic> donations;

  DashboardStats({
    required this.totalMembers,
    required this.totalDonations,
    required this.totalPatients,
    required this.donations,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalMembers: json['total_members'] ?? 0,
      totalDonations: json['total_donations'] ?? 0,
      totalPatients: json['total_patients'] ?? 0,
      donations: json['donations'] ?? [],
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
  List<dynamic> donationList = [];
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

      final dio = Dio();
      final response = await dio.get(
        'https://your-yii2-backend/api/v1/dashboard/stats',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer YOUR_AUTH_TOKEN', // Get from your auth service
          },
        ),
      );

      final apiResponse = ApiResponse<DashboardStats>.fromJson(
        response.data,
        (json) => DashboardStats.fromJson(json),
      );

      if (apiResponse.success) {
        setState(() {
          totalMembers = apiResponse.data?.totalMembers ?? 0;
          totalDonations = apiResponse.data?.totalDonations ?? 0;
          totalPatients = apiResponse.data?.totalPatients ?? 0;
          donationList = apiResponse.data?.donations ?? [];
          isLoading = false;
        });
      } else {
        print('Failed to load dashboard data: ${apiResponse.message}');
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

  Widget _buildChartButton({
    required Widget child,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Responsive.isMobile(context) ? 12 : 16,
          ),
        ),
        elevation: 4,
      ),
      onPressed: onPressed ?? () {},
      child: child,
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
          child: _buildChartButton(
            child: Container(), // BloodDonationPieChart(),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: _buildChartButton(
            child: Container(), // BloodDonationGenderPieChart(),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Container(), // DonationChartByBlood(),
        ),
        Container(
          margin: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Container(
            height: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.height * 0.65
                : MediaQuery.of(context).size.height * 0.52,
            width: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width * 0.9
                : MediaQuery.of(context).size.width * 0.43,
            child: Container(), // DonationChartByHospital(),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4, left: 20, right: 20, bottom: 20),
          child: _buildChartButton(
            child: Container(), // BloodRequestGiveChartScreen(),
          ),
        ),
      ],
    );
  }
}
