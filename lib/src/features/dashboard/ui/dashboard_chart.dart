import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';

class DashBoardChart extends StatelessWidget {
  final String date;
  const DashBoardChart({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 18 : 30),
      margin: const EdgeInsets.all(
        12,
      ),
      decoration: shadowDecoration(Colors.white),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ယခုလ သွေးလှူရှင်များ",
                style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                  color: primaryColor,
                ),
              ),
              SvgPicture.asset(
                "assets/images/calendar.svg",
                height: Responsive.isMobile(context) ? 24 : 30,
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(
                left: Responsive.isMobile(context) ? 12 : 24,
                right: Responsive.isMobile(context) ? 12 : 24,
                top: Responsive.isMobile(context) ? 8 : 20,
                bottom: Responsive.isMobile(context) ? 8 : 20),
            margin: EdgeInsets.only(
              top: Responsive.isMobile(context) ? 20 : 30,
            ),
            decoration: normalDecoration(whitePale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: Responsive.isMobile(context) ? 20 : 28,
                      height: Responsive.isMobile(context) ? 20 : 28,
                      color: blueColor,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Text(
                      "အမျိုးသား သွေးလှူရှင်",
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 15 : 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  "- ဦး",
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15 : 16,
                    color: blueColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                left: Responsive.isMobile(context) ? 12 : 24,
                right: Responsive.isMobile(context) ? 12 : 24,
                top: Responsive.isMobile(context) ? 8 : 20,
                bottom: Responsive.isMobile(context) ? 8 : 20),
            margin: EdgeInsets.only(
              top: Responsive.isMobile(context) ? 20 : 20,
            ),
            decoration: normalDecoration(whitePale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: Responsive.isMobile(context) ? 20 : 28,
                      height: Responsive.isMobile(context) ? 20 : 28,
                      color: orangePale,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Text(
                      "အမျိုးသမီး သွေးလှူရှင်",
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 15 : 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  "- ဦး",
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15 : 16,
                    color: blueColor,
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //     margin: EdgeInsets.only(
          //       top: Responsive.isMobile(context) ? 0 : 20,
          //       left: Responsive.isMobile(context) ? 0 : 20,
          //       right: Responsive.isMobile(context) ? 0 : 8,
          //     ),
          //     height: MediaQuery.of(context).size.height / 2.5,
          //     child: StackedBarChart.withSampleData())
        ],
      ),
    );
  }
}
