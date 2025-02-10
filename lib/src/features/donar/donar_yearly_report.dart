import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';

class DonationYearlyReport extends StatelessWidget {
  int openingBalance;
  List<int>? monthlyDonation;
  List<int>? monthlyExpense;
  int? closingBalance;
  int? totalExpense;
  int? totalDonationAmount;
  int? selectedYear;
  DonationYearlyReport(
      {Key? key,
      required this.openingBalance,
      required this.monthlyDonation,
      required this.monthlyExpense,
      required this.closingBalance,
      required this.totalDonationAmount,
      required this.totalExpense,
      required this.selectedYear})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        title: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text("ရ/သုံး ငွေစာရင်း",
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 15, color: Colors.white)),
        ),
      ),
      body: Container(
        decoration: shadowDecoration(Colors.white),
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20, top: 12),
        margin: EdgeInsets.only(
            left: Responsive.isMobile(context)
                ? 12
                : MediaQuery.of(context).size.width * 0.15,
            right: Responsive.isMobile(context)
                ? 12
                : MediaQuery.of(context).size.width * 0.15,
            top: 20,
            bottom: 20),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
                "${"${Utils.strToMM(selectedYear.toString())} "} ခုနှစ် တစ်နှစ်တာ အလှူငွေ ရရှိမှုနှင့် \n အသုံးစရိတ် စာရင်းရှင်းတမ်း",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    height: 1.7,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(
              height: 24,
            ),

            //New
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: const Text(
                        "ဝင်ငွေ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontFamily: "Times New Roman",
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: const Text(
                        "အသုံးစရိတ်",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontFamily: "Times New Roman",
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 26,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Responsive.isMobile(context)
                                      ? "${Utils.strToMM((selectedYear! - 1).toString())} လက်ကျန်ငွေ"
                                      : "${Utils.strToMM((selectedYear! - 1).toString())} စာရင်းဖွင့်လက်ကျန်ငွေ",
                                  style: TextStyle(
                                      fontSize: Responsive.isMobile(context)
                                          ? 14
                                          : 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Text(
                                  "${Utils.strToMM(openingBalance.toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: Responsive.isMobile(context) ? 8 : 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: monthlyDonation!.length * 26 + 40,
                                  child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: monthlyDonation!.length,
                                      itemBuilder: ((context, index) {
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 2),
                                          height: 26,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                convertToMMMonthName(index),
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                "${Utils.strToMM(monthlyDonation![index].toString())} ကျပ်",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        );
                                      })),
                                ),
                                Visibility(
                                  visible: monthlyDonation!.isNotEmpty,
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.only(top: 12, bottom: 12),
                                    child: Divider(
                                      color: Colors.black,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 26,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Responsive.isMobile(context)
                                            ? "အလှူငွေ စုစုပေါင်း"
                                            : "ယခုနှစ် အလှူငွေ စုစုပေါင်း",
                                        style: TextStyle(
                                            fontSize:
                                                Responsive.isMobile(context)
                                                    ? 14
                                                    : 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Text(
                                        "${Utils.strToMM(totalDonationAmount.toString())} ကျပ်",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: Responsive.isMobile(context) ? 12 : 20,
                          top: Responsive.isMobile(context) ? 8 : 12,
                          bottom: Responsive.isMobile(context) ? 8 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: monthlyExpense!.length * 26 + 40,
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: monthlyExpense!.length,
                                itemBuilder: ((context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 2, right: 12),
                                    height: 26,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          convertToMMMonthName(index),
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          "${Utils.strToMM(monthlyExpense![index].toString())} ကျပ်",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  );
                                })),
                          ),
                          Visibility(
                            visible: monthlyDonation!.isNotEmpty,
                            child: const Padding(
                              padding: EdgeInsets.only(top: 12, bottom: 12),
                              child: Divider(
                                color: Colors.black,
                                height: 1.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 12),
                            height: 26,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "စုစုပေါင်း ကုန်ကျငွေ",
                                  style: TextStyle(
                                      fontSize: Responsive.isMobile(context)
                                          ? 14
                                          : 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Text(
                                  "${Utils.strToMM(totalExpense.toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 12),
                            height: 26,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Responsive.isMobile(context)
                                      ? "လက်ကျန်ငွေ"
                                      : "စာရင်းပိတ် လက်ကျန်ငွေ",
                                  style: TextStyle(
                                      fontSize: Responsive.isMobile(context)
                                          ? 14
                                          : 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Text(
                                  "${Utils.strToMM(closingBalance.toString())} ကျပ်",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "စုစုပေါင်း",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(
                            "${Utils.strToMM((totalDonationAmount! + openingBalance).toString())} ကျပ်",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "စုစုပေါင်း",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(
                            "${Utils.strToMM((totalDonationAmount! + openingBalance).toString())} ကျပ်",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  convertToMMMonthName(int month) {
    //convert month index int to  name with Format "MMM"
    if (month == 0) return "ဇန်နဝါရီ";
    if (month == 1) return "ဖေဖော်ဝါရီ";
    if (month == 2) return "မတ်";
    if (month == 3) return "ဧပြီ";
    if (month == 4) return "မေ";
    if (month == 5) return "ဇွန်";
    if (month == 6) return "ဇူလိုင်";
    if (month == 7) return "ဩဂုတ်";
    if (month == 8) return "စက်တင်ဘာ";
    if (month == 9) return "အောက်တိုဘာ";
    if (month == 10) return "နိုဝင်ဘာ";
    if (month == 11) return "ဒီဇင်ဘာ";
  }
}
