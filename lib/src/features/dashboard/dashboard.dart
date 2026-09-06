import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:donation/data/repository/repository.dart';
import 'package:donation/data/response/xata_donation_list_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/dashboard/ui/dashboard_card.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/donation/blood_request_give_chart.dart';
import 'package:donation/src/features/finder/blood_donation_pie_chart.dart';
import 'package:donation/src/features/finder/request_give_list_screen.dart';
import 'package:donation/src/features/services/report_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class DashBoardScreen extends ConsumerStatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);
  static const routeName = "/dashboard";

  @override
  ConsumerState<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends ConsumerState<DashBoardScreen> {
  late int totalMember = 0;
  late int totalDonar = 0;
  late int totalDonation = 0;
  late int totalPatient = 0;
  late int totalSpecialEvents = 0;
  bool finance = false;
  List<DonationRecord> dataList = [];
  List<DonationRecord> data = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final reportService = ref.read(reportServiceProvider);
      final stats = await reportService.getDashboardStats();

      setState(() {
        totalMember = stats['totalMember'] ?? 0;
        // 'donations' is the blood donation record COUNT shown as "ကြိမ်";
        // 'totalDonations' is the money-ledger sum in kyat (desktop finance).
        totalDonation = stats['donations'] ?? 0;
        totalPatient = stats['totalPatient'] ?? 0;
        final specialEventCount = stats['totalSpecialEvents'];
        totalSpecialEvents = specialEventCount is num
            ? specialEventCount.toInt()
            : int.tryParse(specialEventCount?.toString() ?? '') ?? 0;
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
    }
  }

  callAPI(String after) {
    if (after.isEmpty) {
      setState(() {
        dataList = [];
        data = [];
      });
    }
    XataRepository().getDonationsList(after).then((response) {
      setState(() {
        dataList.addAll(
            XataDonationListResponse.fromJson(jsonDecode(response.body))
                .records!);
      });

      if (XataDonationListResponse.fromJson(jsonDecode(response.body))
              .meta!
              .page!
              .more ??
          false) {
        callAPI(XataDonationListResponse.fromJson(jsonDecode(response.body))
            .meta!
            .page!
            .cursor!);
      } else {
        data = [];
        for (int i = 0; i < dataList.length; i++) {
          //get current year
          var date = DateTime.now().toLocal();
          String donationYear = DateFormat('yyyy').format(date);

          var tempDate = "";
          if (dataList[i].date!.toString().contains("T")) {
            tempDate = dataList[i].date!.toString().split("T")[0];
          } else if (dataList[i].date!.toString().contains(" ")) {
            tempDate = dataList[i].date!.toString().split(" ")[0];
          }

          if (tempDate.split("-")[0] == donationYear) {
            setState(() {
              data.add(dataList[i]);
            });
          }
        }

        setState(() {
          data = data.reversed.toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        // On phones the dashboard is the home tab of the zoom drawer; give it
        // a menu button so the drawer is reachable without the swipe gesture.
        leading: Responsive.isMobile(context) &&
                ref.watch(drawerControllerProvider) != null
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: 'မီနူး',
                onPressed: () =>
                    ref.read(drawerControllerProvider)?.toggle?.call(),
              )
            : null,
        title: const Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: Text("RED Juniors Blood Care Unit",
              style: TextStyle(fontSize: 17, color: Colors.white)),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          Padding(
            padding: EdgeInsets.only(
                right: Responsive.isMobile(context) ? 16.0 : 30),
            child: SvgPicture.asset(
              "assets/images/noti.svg",
              width: 26,
            ),
          ),
        ],
      ),
      body: Responsive.isMobile(context)
          // Phone: 2-column grid of equal-height cards. Cards are Expanded
          // internally, so each pair must sit directly in a Row (an Expanded
          // card inside a Column here has unbounded height and crashes the
          // ListView).
          ? ListView(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 24),
              children: [
                Row(
                  children: [
                    DashboardCard(
                      index: 0,
                      color: primaryDark,
                      title: "အဖွဲ့၀င် စာရင်း",
                      subtitle: "စုစုပေါင်း အရေအတွက်",
                      amount: "${Utils.strToMM(totalMember.toString())} ဦး",
                      amountColor: Colors.black,
                    ),
                    DashboardCard(
                      index: 1,
                      color: primaryDark,
                      title: "သွေးလှူမှု မှတ်တမ်း",
                      subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                      amount:
                          "${Utils.strToMM(totalDonation.toString())} ကြိမ်",
                      amountColor: Colors.blue,
                    ),
                  ],
                ),
                Row(
                  children: [
                    DashboardCard(
                      index: 2,
                      color: primaryDark,
                      title: "လူနာစာရင်း",
                      subtitle: "စုစုပေါင်း အရေအတွက်",
                      amount: "${Utils.strToMM(totalPatient.toString())} ဦး",
                      amountColor: Colors.black,
                    ),
                    DashboardCard(
                      key: const ValueKey('dashboard-special-event-card'),
                      index: 2,
                      color: primaryDark,
                      title: "ထူးခြားဖြစ်စဉ်",
                      subtitle: "စုစုပေါင်း မှတ်တမ်း",
                      amount:
                          "${Utils.strToMM(totalSpecialEvents.toString())} ခု",
                      amountColor: Colors.black,
                    ),
                  ],
                ),
                Row(
                  children: [
                    DashboardCard(
                      index: 3,
                      color: primaryDark,
                      title: "ရ/သုံး ငွေစာရင်း",
                      subtitle: "အသေးစိတ် ကြည့်မည်",
                      amount: "",
                      amountColor: Colors.black,
                    ),
                    DashboardCard(
                      index: 4,
                      color: primaryDark,
                      title: "သွေးတောင်းခံ/လှူဒါန်းမှု",
                      subtitle: "အသေးစိတ် ကြည့်မည်",
                      amount: "",
                      amountColor: Colors.black,
                    ),
                  ],
                ),
                // Request Give Chart
                const Padding(
                  padding: EdgeInsets.only(top: 12, right: 12),
                  child: BloodRequestGiveChartScreen(),
                ),
                // Disease Chart
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: BloodDonationPieChart(),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.only(left: 20.0, top: 24),
                      child: Row(
                        children: [
                          DashboardCard(
                            index: 0,
                            color: primaryDark,
                            title: "အဖွဲ့၀င် စာရင်း",
                            subtitle: "စုစုပေါင်း အရေအတွက်",
                            amount:
                                "${Utils.strToMM(totalMember.toString())} ဦး",
                            amountColor: Colors.black,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          DashboardCard(
                            index: 1,
                            color: primaryDark,
                            title: "သွေးလှူမှု မှတ်တမ်း",
                            subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                            amount:
                                "${Utils.strToMM(totalDonation.toString())} ကြိမ်",
                            amountColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 12, right: 12, top: 20, bottom: 8),
                      width: MediaQuery.of(context).size.width / 2.15,
                      height: 1,
                      color: Colors.grey,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.only(left: 20.0, bottom: 12),
                      child: Row(
                        children: [
                          DashboardCard(
                            key: const ValueKey('dashboard-special-event-card'),
                            index: 2,
                            color: primaryDark,
                            title: "ထူးခြားဖြစ်စဉ်",
                            subtitle: "စုစုပေါင်း မှတ်တမ်း",
                            amount:
                                "${Utils.strToMM(totalSpecialEvents.toString())} ခု",
                            amountColor: Colors.black,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          DashboardCard(
                            index: 3,
                            color: primaryDark,
                            title: "ရ/သုံး ငွေစာရင်း",
                            subtitle: "အသေးစိတ် ကြည့်မည်",
                            amount: "",
                            amountColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 12, right: 12, top: 20, bottom: 8),
                      width: MediaQuery.of(context).size.width / 2.15,
                      height: 1,
                      color: Colors.grey,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.only(left: 20.0, bottom: 12),
                      child: Row(
                        children: [
                          DashboardCard(
                            index: 4,
                            color: primaryDark,
                            title: "သွေးတောင်းခံ/လှူဒါန်းမှု",
                            subtitle: "အသေးစိတ် ကြည့်မည်",
                            amount: "",
                            amountColor: Colors.black,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          DashboardCard(
                            index: 2,
                            color: primaryDark,
                            title: "လူနာစာရင်း",
                            subtitle: "စုစုပေါင်း အရေအတွက်",
                            amount:
                                "${Utils.strToMM(totalPatient.toString())} ဦး",
                            amountColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Charts column for Desktop
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Request Give Chart for Desktop
                        const Padding(
                          padding: EdgeInsets.only(top: 12, right: 20),
                          child: BloodRequestGiveChartScreen(),
                        ),
                        // Disease Chart for Desktop
                        Padding(
                          padding: EdgeInsets.only(top: 12, right: 20),
                          child: BloodDonationPieChart(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RequestGiveListScreen(),
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_calendar_outlined),
        label: const Text(
          'နေ့စဉ်မှတ်တမ်း',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        tooltip: 'နေ့စဉ် သွေးတောင်းခံ/လှူဒါန်းမှု မှတ်တမ်းဖြည့်မည်',
      ),
    );
  }
}
