import 'dart:convert';
import 'dart:developer';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merchant/data/repository/repository.dart';
import 'package:merchant/data/response/total_data_response.dart';
import 'package:merchant/data/response/xata_donation_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/donar/donar_list.dart';
import 'package:merchant/src/features/donation/blood_donation_list_new_style.dart';
import 'package:merchant/src/features/donation/donation_chart_by_blood.dart';
import 'package:merchant/src/features/new_features/member/member_list_new_style.dart';
import 'package:merchant/src/features/special_event/event_list.dart';
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
  List<DonationRecord> dataList = [];
  List<DonationRecord> data = [];

  @override
  void initState() {
    super.initState();

    initial();
  }

  initial() async {
    callAPI("");
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
          var date = DateTime.now();
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

  VoidCallback refresh() => initial();

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();
    String dateFormat = DateFormat('dd MMM yyyy ( EEEE )').format(date);

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 254, 252, 231),
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
                                "စုစုပေါင်း အရေအတွက်",
                                "${Utils.strToMM(totalMember.toString())} ဦး",
                                Colors.black),
                            DashBoardCard(
                              1,
                              primaryDark,
                              "သွေးလှူမှု မှတ်တမ်း",
                              "စုစုပေါင်း အကြိမ်ရေ",
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
                              "",
                              Colors.black,
                            ),
                            DashBoardCard(
                              3,
                              primaryDark,
                              "ရ/သုံး ငွေစာရင်း",
                              "",
                              "",
                              Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DonationChartByBlood(
                      data: data,
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
                            DashBoardCard(
                                0,
                                primaryDark,
                                "အဖွဲ့၀င် စာရင်း",
                                "စုစုပေါင်း အရေအတွက်",
                                "${Utils.strToMM(totalMember.toString())} ဦး",
                                Colors.black),
                            const SizedBox(
                              width: 12,
                            ),
                            DashBoardCard(
                              1,
                              primaryDark,
                              "သွေးလှူမှု မှတ်တမ်း",
                              "စုစုပေါင်း အကြိမ်ရေ",
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
                              "အသေးစိတ် ကြည့်မည်",
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
                              "အသေးစိတ် ကြည့်မည်",
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
                          data: data,
                          fromDashboard: true,
                        ),
                      )),
                ],
              ));
  }

  Widget DashBoardCard(int index, Color color, String title, String subtitle,
      String amount, Color amountColor) {
    return Expanded(
      child: Container(
        height: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.height / 4.75
            : amount == ""
                ? MediaQuery.of(context).size.height / 5.2
                : MediaQuery.of(context).size.height / 4,
        margin: const EdgeInsets.only(top: 12, right: 12),
        child: NeumorphicButton(
          onPressed: () async {
            if (index == 0) {
              await Navigator.pushNamed(context, MemberListNewStyle.routeName);
              initial();
            } else if (index == 1) {
              await Navigator.pushNamed(
                  context, BloodDonationListNewStyle.routeName);
              initial();
            } else if (index == 2) {
              await Navigator.pushNamed(
                  context, EventListScreen.routeName);
              initial();
            } else if (index == 3) {
              await Navigator.pushNamed(context, DonarList.routeName);
              initial();
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
                      fontSize: Responsive.isMobile(context) ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color:
                          NeumorphicTheme.of(context)?.current!.variantColor),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 14 : 16,
                      color:
                          NeumorphicTheme.of(context)?.current!.variantColor),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  amount,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 17 : 20,
                      fontWeight: FontWeight.bold,
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
