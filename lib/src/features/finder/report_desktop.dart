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
import 'package:donation/realm/realm_services.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/responsive_row_column.dart';
// import 'package:realm/realm.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:donation/core/api/api_response.dart';
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

class ReportDesktopScreen extends ConsumerStatefulWidget {
  const ReportDesktopScreen({super.key});

  @override
  ConsumerState<ReportDesktopScreen> createState() =>
      _ReportDesktopScreenState();
}

class _ReportDesktopScreenState extends ConsumerState<ReportDesktopScreen> {
  int totalMembers = 0;
  int totalBloodDonations = 0;
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
          totalBloodDonations = data['donations'] ?? 0;
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
        ResponsiveRowColumnItem(
            child: ResponsiveRowColumn(
          layout: Responsive.isDesktop(context)
              ? ResponsiveRowColumnType.ROW
              : ResponsiveRowColumnType.COLUMN,
          children: [
            ResponsiveRowColumnItem(
              rowFlex: Responsive.isMobile(context) ? null : 1,
              child: Container(
                height: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.height * 0.37
                    : MediaQuery.of(context).size.height * 0.37,
                width: Responsive.isMobile(context)
                    ? null
                    : MediaQuery.of(context).size.width * 0.43,
                margin: EdgeInsets.only(
                  left: Responsive.isMobile(context) ? 20 : 30,
                ),
                child: Responsive.isMobile(context)
                    ? Row(
                        children: [
                          DashboardCard(
                            index: 0,
                            color: primaryDark,
                            title: Responsive.isMobile(context)
                                ? "အဖွဲ့၀င် \nစာရင်း"
                                : "အဖွဲ့၀င် စာရင်း",
                            subtitle: "စုစုပေါင်း",
                            amount: totalMembers.toString(),
                            amountColor: Colors.black,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          DashboardCard(
                            index: 1,
                            color: primaryDark,
                            title: "သွေးလှူမှု မှတ်တမ်း",
                            subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                            amount: totalBloodDonations.toString(),
                            amountColor: Colors.blue,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 12,
                          ),
                          DashboardCard(
                            index: 0,
                            color: primaryDark,
                            title: Responsive.isMobile(context)
                                ? "အဖွဲ့၀င် \nစာရင်း"
                                : "အဖွဲ့၀င် စာရင်း",
                            subtitle: "စုစုပေါင်း",
                            amount: totalMembers.toString(),
                            amountColor: Colors.black,
                          ),
                          SizedBox(
                            height: 12,
                          ),
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
                        ],
                      ),
              ),
            ),
            ResponsiveRowColumnItem(
              rowFlex: Responsive.isMobile(context) ? null : 1,
              child: Container(
                height: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.height * 0.37
                    : MediaQuery.of(context).size.height * 0.37,
                width: Responsive.isMobile(context)
                    ? null
                    : MediaQuery.of(context).size.width * 0.43,
                child: Responsive.isMobile(context)
                    ? Row(
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
                          SizedBox(
                            width: 12,
                          ),
                          DashboardCard(
                            index: 3,
                            color: primaryDark,
                            title: "ရ/သုံး ငွေစာရင်း",
                            subtitle: "အသေးစိတ်",
                            amount: totalDonations.toString() +
                                '/' +
                                totalExpenses.toString(),
                            amountColor: Colors.black,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 12,
                          ),
                          DashboardCard(
                            index: 1,
                            color: primaryDark,
                            title: "သွေးလှူမှု မှတ်တမ်း",
                            subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                            amount: totalBloodDonations.toString(),
                            amountColor: Colors.blue,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          DashboardCard(
                            index: 3,
                            color: primaryDark,
                            title: "ရ/သုံး ငွေစာရင်း",
                            subtitle: totalDonations.toString(),
                            amount: totalExpenses.toString(),
                            amountColor: Colors.black,
                          ),
                        ],
                      ),
              ),
            ),
            ResponsiveRowColumnItem(
                rowFlex: Responsive.isMobile(context) ? null : 2,
                child: Container(
                  height: Responsive.isMobile(context)
                      ? null
                      : MediaQuery.of(context).size.height * 0.34,
                  width: Responsive.isMobile(context)
                      ? null
                      : MediaQuery.of(context).size.width * 0.43,
                  margin: EdgeInsets.only(
                      top: 20,
                      left: 10,
                      right: 10,
                      bottom: Responsive.isMobile(context) ? 20 : 0),
                  child: _buildChartButton(
                    child: BloodDonationPieChart(),
                  ),
                )),
            ResponsiveRowColumnItem(
                rowFlex: Responsive.isMobile(context) ? null : 2,
                child: Container(
                  height: Responsive.isMobile(context)
                      ? null
                      : MediaQuery.of(context).size.height * 0.34,
                  width: Responsive.isMobile(context)
                      ? null
                      : MediaQuery.of(context).size.width * 0.43,
                  margin: EdgeInsets.only(
                      top: 20,
                      left: 10,
                      right: 20,
                      bottom: Responsive.isMobile(context) ? 20 : 0),
                  child: _buildChartButton(
                    child: BloodDonationGenderPieChart(),
                  ),
                ))
          ],
        )),
        ResponsiveRowColumnItem(
            child: ResponsiveRowColumn(
          layout: Responsive.isDesktop(context)
              ? ResponsiveRowColumnType.ROW
              : ResponsiveRowColumnType.COLUMN,
          children: [
            ResponsiveRowColumnItem(
              rowFlex: Responsive.isMobile(context) ? null : 3,
              child: Container(
                margin: EdgeInsets.only(
                    top: 20,
                    left: Responsive.isMobile(context) ? 20 : 30,
                    right: 10),
                child: DonationChartByBlood(
                  fromDashboard: true,
                ),
              ),
            ),
            ResponsiveRowColumnItem(
              rowFlex: Responsive.isMobile(context) ? null : 3,
              child: Container(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  height: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.height * 0.65
                      : MediaQuery.of(context).size.height * 0.52,
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width * 0.9
                      : MediaQuery.of(context).size.width * 0.43,

                  child: DonationChartByHospital(
                  ),
                ),
              ),
            ),
            // ResponsiveRowColumnItem(
            //   rowFlex: Responsive.isMobile(context) ? null : 3,
            //   child: Container(
            //     margin: EdgeInsets.only(
            //         top: 20,
            //         left: 10,
            //         right: 10,
            //         bottom: Responsive.isMobile(context) ? 20 : 0),
            //     child: fluent.Button(
            //       style: NeumorphicStyle(
            //         color: Colors.white,
            //         boxShape: NeumorphicBoxShape.roundRect(
            //             BorderRadius.circular(
            //                 Responsive.isMobile(context) ? 12 : 16)),
            //         depth: 4,
            //         intensity: 0.8,
            //         shadowDarkColor: Colors.black,
            //         shadowLightColor: Colors.white,
            //       ),
            //       onPressed: () async {},
            //       child: MostBloodDonationMembers(),
            //     ),
            //   ),
            // ),
            ResponsiveRowColumnItem(
                rowFlex: Responsive.isMobile(context) ? null : 3,
                child: Container(
                  margin: EdgeInsets.only(
                      top: 20,
                      left: 10,
                      right: 20,
                      bottom: Responsive.isMobile(context) ? 20 : 0),
                  child: _buildChartButton(
                    child: BloodRequestGiveChartScreen(),
                  ),
                ))
          ],
        )),
      ],
    );
  }
}
