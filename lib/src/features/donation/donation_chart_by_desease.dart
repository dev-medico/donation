import 'package:flutter/material.dart';
import 'package:merchant/data/response/xata_donation_list_response.dart';
import 'package:merchant/donation_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';

class DonationChartByDisease extends StatefulWidget {
  final List<DonationRecord> data;
  const DonationChartByDisease({Key? key, required this.data})
      : super(key: key);

  @override
  State<DonationChartByDisease> createState() => _DonationChartByDiseaseState();
}

class _DonationChartByDiseaseState extends State<DonationChartByDisease> {
  List<String> diseases = [];

  @override
  void initState() {
    super.initState();
    for (var element in widget.data) {
      diseases.add(element.patientDisease!);
    }

    //delete duplicate from diseases
    diseases = diseases.toSet().toList();
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
        shrinkWrap: true,
        children: [
          Text(
            "ဖြစ်ပွားသည့်ရောဂါ အလိုက် မှတ်တမ်း",
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 16.5 : 17.5,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: Responsive.isMobile(context) ? 10 : 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ဖြစ်ပွားသည့်ရောဂါ",
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 12.0, right: 12, left: 8),
            itemCount: diseases.length,
            itemBuilder: (BuildContext context, int index) {
              return Visibility(
                visible: widget.data
                    .where(
                        (element) => element.patientDisease == diseases[index])
                    .isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        diseases[index] == "" ? "-" : diseases[index],
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 15 : 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.data
                            .where((element) =>
                                element.patientDisease == diseases[index])
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
            padding:
                const EdgeInsets.only(left: 12, top: 8, right: 20, bottom: 30),
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
        ],
      ),
    );
  }
}
