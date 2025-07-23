import 'package:donation/responsive.dart';
import 'package:donation/src/features/dashboard/ui/responsive_dashboard_card.dart';
import 'package:donation/src/features/donation/blood_request_give_chart.dart';
import 'package:donation/src/features/donation/donation_chart_by_blood.dart';
import 'package:donation/src/features/donation/donation_chart_by_hospital.dart';
import 'package:donation/src/features/finder/blood_donation_gender_pie_chart.dart';
import 'package:donation/src/features/finder/blood_donation_pie_chart.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:donation/core/api/api_client.dart';

class ReportNewScreen extends ConsumerStatefulWidget {
  const ReportNewScreen({
    super.key,
  });

  @override
  ConsumerState<ReportNewScreen> createState() => _ReportNewScreenState();
}

class _ReportNewScreenState extends ConsumerState<ReportNewScreen> {
  int totalMembers = 0;
  int totalBloodDonations = 0;
  int totalDonations = 0;
  int totalPatients = 0;
  int totalExpenses = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    _loadDashboardData();
  }

  checkInternetConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == false) {
      Utils.messageDialog(
          "Poor Internet Connection! Please check with your Internet",
          context,
          "အိုကေ",
          Colors.black);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: Responsive.isMobile(context)
          ? null
          : AppBar(
              flexibleSpace: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [primaryColor, primaryDark],
              ))),
              leading: Responsive.isMobile(context)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Humberger(
                        onTap: () {
                          ref.watch(drawerControllerProvider)?.toggle?.call();
                        },
                      ),
                    )
                  : null,
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text("RED Juniors Blood Care Unit",
                    textScaler: TextScaler.linear(1.0),
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 15 : 16,
                        color: Colors.white)),
              ),
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildResponsiveBody(),
    );
  }

  Widget _buildResponsiveBody() {
    final isMobile = Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          // Dashboard Cards Row 1
          _buildDashboardCards(),
          SizedBox(height: isMobile ? 16 : 24),
          // Charts Section
          _buildChartsSection(),
        ],
      ),
    );
  }

  Widget _buildDashboardCards() {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ResponsiveDashboardCard(
                  index: 0,
                  color: primaryDark,
                  title: "အဖွဲ့၀င်\nစာရင်း",
                  subtitle: "စုစုပေါင်း",
                  amount: totalMembers.toString(),
                  amountColor: Colors.black,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ResponsiveDashboardCard(
                  index: 1,
                  color: primaryDark,
                  title: "သွေးလှူမှု\nမှတ်တမ်း",
                  subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                  amount: totalBloodDonations.toString(),
                  amountColor: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ResponsiveDashboardCard(
                  index: 2,
                  color: primaryDark,
                  title: "လူနာ\nစာရင်း",
                  subtitle: "စုစုပေါင်း",
                  amount: totalPatients.toString(),
                  amountColor: Colors.black,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ResponsiveDashboardCard(
                  index: 3,
                  color: primaryDark,
                  title: "ရ/သုံး\nငွေစာရင်း",
                  subtitle: "အသေးစိတ်",
                  amount: "$totalDonations/$totalExpenses",
                  amountColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Desktop layout - 2x2 grid
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                ResponsiveDashboardCard(
                  index: 0,
                  color: primaryDark,
                  title: "အဖွဲ့၀င် စာရင်း",
                  subtitle: "စုစုပေါင်း",
                  amount: totalMembers.toString(),
                  amountColor: Colors.black,
                ),
                SizedBox(height: 12),
                ResponsiveDashboardCard(
                  index: 2,
                  color: primaryDark,
                  title: "လူနာ စာရင်း",
                  subtitle: "စုစုပေါင်း",
                  amount: totalPatients.toString(),
                  amountColor: Colors.black,
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                ResponsiveDashboardCard(
                  index: 1,
                  color: primaryDark,
                  title: "သွေးလှူမှု မှတ်တမ်း",
                  subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                  amount: totalBloodDonations.toString(),
                  amountColor: Colors.blue,
                ),
                SizedBox(height: 12),
                ResponsiveDashboardCard(
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
        ],
      );
    }
  }

  Widget _buildChartsSection() {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BloodDonationPieChart(),
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BloodDonationGenderPieChart(),
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BloodRequestGiveChartScreen(),
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DonationChartByBlood(),
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DonationChartByHospital(),
            ),
          ),
        ],
      );
    } else {
      // Desktop layout - 2 columns
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BloodDonationPieChart(),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BloodDonationGenderPieChart(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BloodRequestGiveChartScreen(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DonationChartByBlood(),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DonationChartByHospital(),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}
