import 'package:donation/responsive.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class YearlyReport extends StatefulWidget {
  const YearlyReport(
      {super.key, required this.yearSelected, required this.year});
  final int yearSelected;
  final String year;

  @override
  State<YearlyReport> createState() => _YearlyReportState();
}

class _YearlyReportState extends State<YearlyReport> {
  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return Container(
        decoration: shadowDecoration(Colors.white),
        // padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20, top: 12),
        margin: EdgeInsets.only(left: Responsive.isMobile(context) ? 0 : 30),
        child: Column(
          children: [
            Text(" နှစ် စာရင်းရှင်းတမ်း",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: NeumorphicTheme.of(context)?.current!.variantColor)),
            const SizedBox(
              height: 12,
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
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
                          color: Colors.black,
                          fontSize: 16,
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
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "စာရင်းဖွင့်လက်ကျန်ငွေ",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  " ကျပ်",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          SizedBox(
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ယခုလ အလှူငွေ စုစုပေါင်း",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  " ကျပ်",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
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
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicTheme.of(context)
                                    ?.current!
                                    .variantColor),
                          ),
                          Text(
                            " ကျပ်",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicTheme.of(context)
                                    ?.current!
                                    .variantColor),
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
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                      child: const Text(
                        "အသုံးစရိတ်",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
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
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: Responsive.isMobile(context) ? 8 : 12,
                          top: Responsive.isMobile(context) ? 8 : 12,
                          bottom: Responsive.isMobile(context) ? 8 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 12),
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "စုစုပေါင်း ကုန်ကျငွေ",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  " ကျပ်",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 12),
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "စာရင်းပိတ် လက်ကျန်ငွေ",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  " ကျပ်",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
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
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicTheme.of(context)
                                    ?.current!
                                    .variantColor),
                          ),
                          Text(
                            " ကျပ်",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicTheme.of(context)
                                    ?.current!
                                    .variantColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: shadowDecoration(Colors.white),
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20, top: 12),
        margin: EdgeInsets.only(left: Responsive.isMobile(context) ? 0 : 30),
        child: Column(
          children: [
            Text("${widget.year} နှစ် စာရင်းရှင်းတမ်း",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: NeumorphicTheme.of(context)?.current!.variantColor)),
            const SizedBox(
              height: 40,
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
                      child: const Text(
                        "ဝင်ငွေ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "စာရင်းဖွင့်လက်ကျန်ငွေ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  " ကျပ်",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          SizedBox(
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ယခုလ အလှူငွေ စုစုပေါင်း",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  " ကျပ်",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: Responsive.isMobile(context) ? 8 : 12,
                          top: Responsive.isMobile(context) ? 8 : 12,
                          bottom: Responsive.isMobile(context) ? 8 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 12),
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "စုစုပေါင်း ကုန်ကျငွေ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  " ကျပ်",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 12),
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "စာရင်းပိတ် လက်ကျန်ငွေ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
                                ),
                                Text(
                                  " ကျပ်",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: NeumorphicTheme.of(context)
                                          ?.current!
                                          .variantColor),
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
                                color: NeumorphicTheme.of(context)
                                    ?.current!
                                    .variantColor),
                          ),
                          Text(
                            " ကျပ်",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicTheme.of(context)
                                    ?.current!
                                    .variantColor),
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
                                color: NeumorphicTheme.of(context)
                                    ?.current!
                                    .variantColor),
                          ),
                          Text(
                            " ကျပ်",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: NeumorphicTheme.of(context)
                                    ?.current!
                                    .variantColor),
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
      );
    }
  }
}
