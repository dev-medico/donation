import 'package:flutter/material.dart';
import 'package:merchant/donation_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/dashboard/ui/simple_chart_blood.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:intl/intl.dart';

class DonationChartByBlood extends StatefulWidget {
  final List<DonationData> data;
  bool? fromDashboard;
  DonationChartByBlood({Key? key, required this.data, this.fromDashboard})
      : super(key: key);

  @override
  State<DonationChartByBlood> createState() => _DonationChartByBloodState();
}

class _DonationChartByBloodState extends State<DonationChartByBlood> {
  List<String> bloodTypes = [
    "A (Rh +)",
    "A (Rh -)",
    "B (Rh +)",
    "B (Rh -)",
    "AB (Rh +)",
    "AB (Rh -)",
    "O (Rh +)",
    "O (Rh -)"
  ];
  String? donationYear;

  @override
  void initState() {
    super.initState();
    var date = DateTime.now();
    donationYear = DateFormat('yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 18 : 20),
      margin: const EdgeInsets.all(
        2,
      ),
      decoration: shadowDecoration(Colors.white),
      child: ListView(
        physics: Responsive.isMobile(context)
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(
            widget.fromDashboard ?? false
                ? "$donationYear ခုနှစ် သွေးအုပ်စုအလိုက် လှူဒါန်းမှု မှတ်တမ်း"
                : "သွေးအုပ်စုအလိုက် မှတ်တမ်း",
            style: TextStyle(
                fontSize: Responsive.isMobile(context) ? 16.5 : 17.5,
                color: primaryColor,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: Responsive.isMobile(context) ? 10 : 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "သွေးအမျိုးအစား",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "အရေအတွက်",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: Responsive.isMobile(context)
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 12.0, right: 12, left: 8),
            itemCount: bloodTypes.length,
            itemBuilder: (BuildContext context, int index) {
              return Visibility(
                visible: widget.data
                    .where((element) =>
                        element.memberBloodType == bloodTypes[index])
                    .isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bloodTypes[index],
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 15 : 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.data
                            .where((element) =>
                                element.memberBloodType == bloodTypes[index])
                            .length
                            .toString(),
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 15 : 16,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 12, right: 16, top: 8, bottom: 8),
            width: double.infinity,
            height: 1,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "စုစုပေါင်း အရေအတွက်",
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  widget.data.length.toString(),
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 12, right: 16, bottom: 8),
            width: double.infinity,
            height: 1,
            color: Colors.white,
          ),
          Container(
              margin: EdgeInsets.only(
                top: Responsive.isMobile(context) ? 0 : 20,
                left: Responsive.isMobile(context) ? 0 : 20,
                right: Responsive.isMobile(context)
                    ? 0
                    : MediaQuery.of(context).size.width * 0.05,
              ),
              height: MediaQuery.of(context).size.height / 2.65,
              child: SimpleBarChartBlood.withSampleData(widget.data))
        ],
      ),
    );
  }
}
