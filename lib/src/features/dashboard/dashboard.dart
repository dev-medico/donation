import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merchant/data/repository/repository.dart';
import 'package:merchant/data/response/total_data_response.dart';
import 'package:merchant/donation_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/donar/donar_list.dart';
import 'package:merchant/src/features/donation/blood_donation_list_new_style.dart';
import 'package:merchant/src/features/donation/donation_chart_by_blood.dart';
import 'package:merchant/src/features/new_features/member/member_list_new_style.dart';
import 'package:merchant/src/features/special_event/special_event_list.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/utils.dart';
import 'package:intl/intl.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);
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
    FirebaseFirestore.instance
        .collection('member_count')
        .doc("donation_string")
        .get()
        .then((value) {
      var members = value['donations'];
      setState(() {
        var data = DonationListResponse.fromJson(jsonDecode(members)).data!;

        for (int i = 0; i < data.length; i++) {
          //get current year
          var date = DateTime.now();
          String donationYear = DateFormat('yyyy').format(date);
          if (data[i].date!.split(" ")[2] == donationYear) {
            dataList.add(data[i]);
          }
        }

        dataList = dataList.reversed.toList();
      });
    });
    initial();
  }

  initial() async {
    XataRepository().getMembersTotal().then((value) {
      setState(() {
        totalMember = int.parse(
            TotalDataResponse.fromJson(jsonDecode(value.body))
                .records!
                .first
                .value
                .toString());
      });
    });
    XataRepository().getDonationsTotal().then((value) {
      setState(() {
        totalDonation = int.parse(
            TotalDataResponse.fromJson(jsonDecode(value.body))
                .records!
                .first
                .value
                .toString());
      });
    });
    // FirebaseFirestore.instance
    //     .collection('member_count')
    //     .doc("member_string")
    //     .get()
    //     .then((value) {
    //   var members = value['members'];
    //   var data = MemberListResponse.fromJson(jsonDecode(members)).data!;

    //   setState(() {
    //     totalMember = data.length;
    //   });
    // });

    // FirebaseFirestore.instance
    //     .collection('member_count')
    //     .doc("donation_string")
    //     .get()
    //     .then((value) {
    //   var donations = value['donations'];
    //   var data = DonationListResponse.fromJson(jsonDecode(donations)).data!;

    //   setState(() {
    //     totalDonation = data.length;
    //   });
    // });
  }

  VoidCallback refresh() => initial();
  List<DonationData> dataList = [];

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    String dateFormat = DateFormat('dd MMM yyyy ( EEEE )').format(date);

    return Scaffold(
        backgroundColor: NeumorphicTheme.of(context)?.current!.accentColor,
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text("Red Juniors Admin",
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
                                "${Utils.strToMM(totalMember.toString())} ဦး",
                                Colors.black),
                            DashBoardCard(
                              1,
                              primaryDark,
                              "သွေးလှူမှု မှတ်တမ်း",
                              "${Utils.strToMM(totalDonation.toString())} ကြိမ်",
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
                              "ထူးခြားဖြစ်စဉ်",
                              "",
                              Colors.black,
                            ),
                            DashBoardCard(
                              3,
                              primaryDark,
                              "ရ/သုံး ငွေစာရင်း",
                              "",
                              Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  DonationChartByBlood(
                    data: dataList,
                    fromDashboard: true,
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
                            DashBoardCard(
                                0,
                                primaryDark,
                                "အဖွဲ့၀င် စာရင်း",
                                "${Utils.strToMM(totalMember.toString())} ဦး",
                                Colors.black),
                            const SizedBox(
                              width: 12,
                            ),
                            DashBoardCard(
                              1,
                              primaryDark,
                              "သွေးလှူမှု မှတ်တမ်း",
                              "${Utils.strToMM(totalDonation.toString())} ကြိမ်",
                              Colors.blue,
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
                            DashBoardCard(
                              2,
                              primaryDark,
                              "ထူးခြားဖြစ်စဉ်",
                              "",
                              Colors.black,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            DashBoardCard(
                              3,
                              primaryDark,
                              "ရ/သုံး ငွေစာရင်း",
                              "",
                              Colors.black,
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
                          data: dataList,
                          fromDashboard: true,
                        ),
                      )),
                ],
              ));
  }

  Widget DashBoardCard(
      int index, Color color, String title, String amount, Color amountColor) {
    return Expanded(
      child: Container(
        height: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.height / 4.75
            : MediaQuery.of(context).size.height / 4,
        margin: const EdgeInsets.only(top: 12, right: 12),
        child: NeumorphicButton(
          onPressed: () async {
            if (index == 0) {
              // await Navigator.pushNamed(context, BloodDonationList.routeName);
              await Navigator.pushNamed(context, MemberListNewStyle.routeName);
              XataRepository().getMembersTotal().then((value) {
                setState(() {
                  totalMember = int.parse(
                      TotalDataResponse.fromJson(jsonDecode(value.body))
                          .records!
                          .first
                          .value
                          .toString());
                });
              });
            } else if (index == 1) {
              await Navigator.pushNamed(
                  context, BloodDonationListNewStyle.routeName);
              XataRepository().getDonationsTotal().then((value) {
                setState(() {
                  totalDonation = int.parse(
                      TotalDataResponse.fromJson(jsonDecode(value.body))
                          .records!
                          .first
                          .value
                          .toString());
                });
              });
            } else if (index == 2) {
              Navigator.pushNamed(context, SpecialEventListScreen.routeName);
            } else if (index == 3) {
              Navigator.pushNamed(context, DonarList.routeName);
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
