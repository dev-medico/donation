import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merchant/data/repository/merchant.dart';
import 'package:merchant/data/response/label_count_response/label_count_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/dashboard/ui/dashboard_card.dart';
import 'package:merchant/src/features/dashboard/ui/dashboard_card_shimmer.dart';
import 'package:merchant/src/features/dashboard/ui/dashboard_chart.dart';
import 'package:merchant/src/features/dashboard/ui/dashboard_error.dart';
import 'package:merchant/src/features/dashboard/ui/dashboard_label_card.dart';
import 'package:merchant/src/features/dashboard/ui/dashboard_label_shimmer.dart';
import 'package:merchant/src/features/dashboard/ui/dashboard_loading.dart';
import 'package:merchant/src/features/donar/donar_list.dart';
import 'package:merchant/src/features/donation/blood_donation_list.dart';
import 'package:merchant/src/features/member/member_list.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DashBoardScreen extends StatefulWidget {
  DashBoardScreen({Key? key}) : super(key: key);
  static const routeName = "/dashboard";

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  late int totalMember = 0;
  late int totalDonar = 0;
  late int totalDonation = 0;
  bool finance = false;

  @override
  void initState() {
    super.initState();
    initial();
  }

  initial() async {
    var date = DateTime.now();
    String donationYear = DateFormat('yyyy').format(date);

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('members').get();
    QuerySnapshot querySnapshotDonar =
        await FirebaseFirestore.instance.collection('donors').get();
    QuerySnapshot querySnapshotDonation = await FirebaseFirestore.instance
        .collection('blood_donations')
        .where('year', isEqualTo: int.parse(donationYear))
        .get();
    setState(() {
      totalMember = querySnapshot.size;
      totalDonar = querySnapshotDonar.size;
      totalDonation = querySnapshotDonation.size;
    });
    
  }

  VoidCallback refresh() => initial();

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    String dateFormat = DateFormat('dd MMM yyyy ( EEEE )').format(date);

    return Scaffold(
        backgroundColor: NeumorphicTheme.of(context)?.current!.accentColor,
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text("Safe Blood Admin",
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
            ? ListView(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 8),
                        child: Row(
                          children: [
                            DashBoardCard(
                                0,
                                primaryDark,
                                "အဖွဲ့၀င် စာရင်း",
                                Utils.strToMM(totalMember.toString()) + " ဦး",
                                Colors.black),
                            DashBoardCard(
                              1,
                              primaryDark,
                              "သွေးလှူမှု မှတ်တမ်း",
                              Utils.strToMM(totalDonation.toString()) +
                                  " ကြိမ်",
                              Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, top: 8, bottom: 12),
                        child: Row(
                          children: [
                            DashBoardCard(
                              2,
                              primaryDark,
                              "အလှူရှင်များ",
                              Utils.strToMM(totalDonar.toString()) + " ဦး",
                              Colors.black,
                            ),
                            DashBoardCard(
                              3,
                              primaryDark,
                              "ရ/သုံး ငွေစာရင်း",
                              "ဇန်န၀ါရီလ",
                              Colors.black,
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   height: 118,
                      //   child: ListView(
                      //     shrinkWrap: true,
                      //     padding: const EdgeInsets.only(left: 10.0, top: 4),
                      //     scrollDirection: Axis.horizontal,
                      //     children: [
                      //       DashBoardLabelCard(
                      //         icon: "assets/images/lb_delivered.svg",
                      //         title: "ရောဂါ မှတ်တမ်း",
                      //         status: "m_delivered_count",
                      //         count: "၂၀",
                      //         countColor: greenDark,
                      //       ),
                      //       DashBoardLabelCard(
                      //         icon: "assets/images/lb_delivering.svg",
                      //         title: "ကျား/မ မှတ်တမ်း",
                      //         status: "m_process_count",
                      //         count: "၄၀/၈၉",
                      //         countColor: blueColor,
                      //       ),
                      //       DashBoardLabelCard(
                      //         icon: "assets/images/lb_pending.svg",
                      //         title: "ထူးခြားဖြစ်စဉ်",
                      //         status: "m_pending_count",
                      //         count: "၁၂",
                      //         countColor: secondColor,
                      //       ),
                      //       const DashBoardLabelCard(
                      //         icon: "assets/images/lb_return.svg",
                      //         title: "ဒေသအလိုက်",
                      //         status: "m_returned_count",
                      //         count: "၃၄",
                      //         countColor: Colors.red,
                      //       ),
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                  DashBoardChart(date: dateFormat),
                ],
              )
            : Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.only(left: 20.0, top: 24),
                        child: Row(
                          children: [
                            DashBoardCard(
                                0,
                                primaryDark,
                                "အဖွဲ့၀င် စာရင်း",
                                Utils.strToMM(totalMember.toString()) + " ဦး",
                                Colors.black),
                            const SizedBox(
                              width: 12,
                            ),
                            DashBoardCard(
                              1,
                              primaryDark,
                              "သွေးလှူမှု မှတ်တမ်း",
                              Utils.strToMM(totalDonation.toString()) +
                                  " ကြိမ်",
                              Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.only(
                            left: 20.0, top: 12, bottom: 12),
                        child: Row(
                          children: [
                            DashBoardCard(
                              2,
                              primaryDark,
                              "အလှူရှင်များ",
                              Utils.strToMM(totalDonar.toString()) + " ဦး",
                              Colors.black,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            DashBoardCard(
                              3,
                              primaryDark,
                              "ရ/သုံး ငွေစာရင်း",
                              "ဇန်န၀ါရီလ",
                              Colors.black,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 12, right: 12, top: 8, bottom: 8),
                        width: MediaQuery.of(context).size.width / 2.15,
                        height: 1,
                        color: Colors.grey,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          DashBoardLabelCard(
                            icon: "assets/images/record.svg",
                            title: "ရောဂါ မှတ်တမ်း",
                            status: "m_delivered_count",
                            count: "၂၀",
                            countColor: greenDark,
                          ),
                          const SizedBox(
                            width: 24,
                          ),
                          DashBoardLabelCard(
                            icon: "assets/images/gender.svg",
                            title: "ကျား/မ မှတ်တမ်း",
                            status: "m_process_count",
                            count: "၄၀/၈၉",
                            countColor: blueColor,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          DashBoardLabelCard(
                            icon: "assets/images/special.svg",
                            title: "ထူးခြားဖြစ်စဉ်",
                            status: "m_pending_count",
                            count: "၁၂",
                            countColor: secondColor,
                          ),
                          const SizedBox(
                            width: 24,
                          ),
                          const DashBoardLabelCard(
                            icon: "assets/images/region.svg",
                            title: "ဒေသအလိုက်",
                            status: "m_returned_count",
                            count: "၃၄",
                            countColor: Colors.red,
                          ),
                        ],
                      )
                    ],
                  ),
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: DashBoardChart(date: dateFormat),
                      )),
                ],
              ));
  }

  Widget DashBoardCard(
      int index, Color color, String title, String amount, Color amountColor) {
    return Expanded(
      child: Container(
        height: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.height / 7.75
            : MediaQuery.of(context).size.height / 5.6,
        margin: const EdgeInsets.only(top: 12, right: 12),
        child: NeumorphicButton(
          onPressed: () async {
            if (index == 0) {
              await Navigator.pushNamed(context, MemberList.routeName);
              QuerySnapshot querySnapshot =
                  await FirebaseFirestore.instance.collection('members').get();

              setState(() {
                totalMember = querySnapshot.size;
              });
            } else if (index == 1) {
              await Navigator.pushNamed(context, BloodDonationList.routeName);
              var date = DateTime.now();
              String donationYear = DateFormat('yyyy').format(date);
              QuerySnapshot querySnapshotDonation = await FirebaseFirestore
                  .instance
                  .collection('blood_donations')
                  .where('year', isEqualTo: int.parse(donationYear))
                  .get();
              setState(() {
                totalDonation = querySnapshotDonation.size;
              });
            } else if (index == 2) {
              await Navigator.pushNamed(context, DonarList.routeName);

              QuerySnapshot querySnapshotDonar =
                  await FirebaseFirestore.instance.collection('donors').get();

              setState(() {
                totalDonar = querySnapshotDonar.size;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color:
                          NeumorphicTheme.of(context)?.current!.variantColor),
                ),
                const Spacer(),
                Text(
                  amount,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: NeumorphicTheme.of(context)
                          ?.current!
                          .defaultTextColor),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
