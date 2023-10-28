import 'package:donation/realm/schemas.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/dashboard/ui/dashboard_card.dart';
import 'package:donation/src/features/donation/blood_request_give_chart.dart';
import 'package:donation/src/features/donation/donation_chart_by_blood.dart';
import 'package:donation/src/features/finder/blood_donation_gender_pie_chart.dart';
import 'package:donation/src/features/finder/blood_donation_pie_chart.dart';
import 'package:donation/src/features/finder/most_blood_donation_member.dart';
import 'package:donation/src/providers/providers.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/responsive_row_column.dart';

class ReportMobileScreen extends ConsumerStatefulWidget {
  const ReportMobileScreen({super.key});

  @override
  ConsumerState<ReportMobileScreen> createState() => _ReportMobileScreenState();
}

class _ReportMobileScreenState extends ConsumerState<ReportMobileScreen> {
  @override
  Widget build(BuildContext context) {
    var totalMember = ref.watch(totalMembersProvider);
    var totalDonations = ref.watch(totalDonationsProvider);
    var donations = ref.watch(donationsProvider);

    List<Donation> donationList = [];
    donations.forEach((element) {
      donationList.add(element);
    });

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
                amount: "${Utils.strToMM(totalMember.toString())} ဦး",
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
                amount: "${Utils.strToMM(totalDonations.toString())} ကြိမ်",
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
                title: "ထူးခြားဖြစ်စဉ်",
                subtitle: "",
                amount: "",
                amountColor: Colors.black,
              ),
              SizedBox(
                width: 12,
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
        Container(
          margin: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: NeumorphicButton(
              style: NeumorphicStyle(
                color: Colors.white,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(
                    Responsive.isMobile(context) ? 12 : 16)),
                depth: 4,
                intensity: 0.8,
                shadowDarkColor: Colors.black,
                shadowLightColor: Colors.white,
              ),
              onPressed: () async {},
              child: BloodDonationPieChart()),
        ),
        Container(
          margin: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: NeumorphicButton(
              style: NeumorphicStyle(
                color: Colors.white,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(
                    Responsive.isMobile(context) ? 12 : 16)),
                depth: 4,
                intensity: 0.8,
                shadowDarkColor: Colors.black,
                shadowLightColor: Colors.white,
              ),
              onPressed: () async {},
              child: BloodDonationGenderPieChart()),
        ),
        Container(
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: DonationChartByBlood(
            data: donationList,
            fromDashboard: true,
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: NeumorphicButton(
            style: NeumorphicStyle(
              color: Colors.white,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(
                  Responsive.isMobile(context) ? 12 : 16)),
              depth: 4,
              intensity: 0.8,
              shadowDarkColor: Colors.black,
              shadowLightColor: Colors.white,
            ),
            onPressed: () async {},
            child: MostBloodDonationMembers(),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: NeumorphicButton(
            style: NeumorphicStyle(
              color: Colors.white,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(
                  Responsive.isMobile(context) ? 12 : 16)),
              depth: 4,
              intensity: 0.8,
              shadowDarkColor: Colors.black,
              shadowLightColor: Colors.white,
            ),
            onPressed: () async {},
            child: BloodRequestGiveChartScreen(),
          ),
        )
      ],
    );
  }
}
