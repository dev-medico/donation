import 'package:donation/realm/schemas.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/dashboard/ui/dashboard_card.dart';
import 'package:donation/src/features/donation/donation_chart_by_blood.dart';
import 'package:donation/src/features/finder/donation_by_disease_chart.dart';
import 'package:donation/src/providers/providers.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    var totalMember = ref.watch(totalMembersProvider);
    var totalDonations = ref.watch(totalDonationsProvider);
    var donations = ref.watch(donationsProvider);

    List<Donation> donationList = [];
    donations.forEach((element) {
      donationList.add(element);
    });
    return Scaffold(
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
          child: Text("Red Junior Dashboard",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 16,
                  color: Colors.white)),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Responsive.isMobile(context)
              ? ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 8),
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
                              DashboardCard(
                                index: 1,
                                color: primaryDark,
                                title: "သွေးလှူမှု မှတ်တမ်း",
                                subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                                amount:
                                    "${Utils.strToMM(totalDonations.toString())} ကြိမ်",
                                amountColor: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, top: 8, bottom: 12),
                          child: Row(
                            children: [
                              DashboardCard(
                                index: 2,
                                color: primaryDark,
                                title: "ထူးခြားဖြစ်စဉ်",
                                subtitle: "",
                                amount: "",
                                amountColor: Colors.black,
                              ),
                              DashboardCard(
                                index: 3,
                                color: primaryDark,
                                title: "ရ/သုံး ငွေစာရင်း",
                                subtitle: "",
                                amount: "",
                                amountColor: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: DonationChartByBlood(
                        data: donationList,
                        fromDashboard: true,
                      ),
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
                                    "${Utils.strToMM(totalDonations.toString())} ကြိမ်",
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
                          padding:
                              const EdgeInsets.only(left: 20.0, bottom: 12),
                          child: Row(
                            children: [
                              DashboardCard(
                                index: 2,
                                color: primaryDark,
                                title: "ထူးခြားဖြစ်စဉ်",
                                subtitle: "အသေးစိတ် ကြည့်မည်",
                                amount: "",
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
                      ],
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(20.0),
                        child: DonationChartByBlood(
                          data: donationList,
                          fromDashboard: true,
                        ),
                      ),
                    ),
                  ],
                ),
          DonationByDiseaseScreen()
        ],
      ),
    );
  }
}
