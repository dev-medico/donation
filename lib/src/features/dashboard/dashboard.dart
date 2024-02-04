import 'dart:convert';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:donation/data/repository/repository.dart';
import 'package:donation/data/response/xata_donation_list_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/dashboard/ui/dashboard_card.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
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
    DateTime date = DateTime.now().toLocal();
    String dateFormat = DateFormat('dd MMM yyyy ( EEEE )').format(date);

    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
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
          ? ListView(
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
                                "${Utils.strToMM(totalDonation.toString())} ကြိမ်",
                            amountColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12.0, top: 8, bottom: 12),
                      child: Row(
                        children: [
                          Column(
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
                          DashboardCard(
                            index: 4,
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
                  ],
                ),
                // Padding(
                //   padding: const EdgeInsets.all(12),
                //   child: DonationChartByBlood(
                //     data: data,
                //     fromDashboard: true,
                //   ),
                // ),
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
                // Expanded(
                //     flex: 1,
                //     child: Container(
                //       margin: const EdgeInsets.only(top: 12),
                //       padding: const EdgeInsets.all(20.0),
                //       child: DonationChartByBlood(
                //         data: data,
                //         fromDashboard: true,
                //       ),
                //     )),
              ],
            ),
    );
  }
}
