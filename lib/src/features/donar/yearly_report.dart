import 'package:donation/responsive.dart';
import 'package:donation/src/features/donar/controller/yearly_report_controller.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class YearlyReport extends ConsumerStatefulWidget {
  const YearlyReport(
      {super.key, required this.yearSelected, required this.year});
  final int yearSelected;
  final String year;

  @override
  ConsumerState<YearlyReport> createState() => _YearlyReportState();
}

class _YearlyReportState extends ConsumerState<YearlyReport> {
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(yearlyReportControllerProvider(int.parse(widget.year)))
        .when(data: (data) {
      int totalDonation = 0;
      int totalExpense = 0;
      data.forEach((element) {
        totalDonation += element.totalDonation ?? 0;
        totalExpense += element.totalExpenses ?? 0;
      });
      if (Responsive.isMobile(context)) {
        return Container(
          decoration: shadowDecoration(Colors.white),
          padding: const EdgeInsets.only(
            bottom: 20,
          ),
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Text("${widget.year} နှစ် စာရင်းရှင်းတမ်း",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          NeumorphicTheme.of(context)?.current!.variantColor)),
              const SizedBox(
                height: 8,
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
                        padding: EdgeInsets.all(4),
                        child: const Text(
                          "လ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: const Text(
                          "ဝင်ငွေ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: const Text(
                          "အသုံးစရိတ်",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
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
                      Container(
                          height: data.length * 37,
                          // padding: EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                          child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Text(
                                          convertEnToMMMonthName(
                                              data[index].month.toString()),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Text(
                                          data[index].totalDonation == 0
                                              ? "-"
                                              : Utils.strToMM(data[index]
                                                  .totalDonation
                                                  .toString()),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Text(
                                          data[index].totalExpenses == 0
                                              ? "-"
                                              : Utils.strToMM(data[index]
                                                  .totalExpenses
                                                  .toString()),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                );
                              })),
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
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "စုစုပေါင်း",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: NeumorphicTheme.of(context)
                                  ?.current!
                                  .variantColor),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          totalDonation == 0
                              ? "-"
                              : Utils.strToMM(totalDonation.toString()),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: NeumorphicTheme.of(context)
                                  ?.current!
                                  .variantColor),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          totalExpense == 0
                              ? "-"
                              : Utils.strToMM(totalExpense.toString()),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: NeumorphicTheme.of(context)
                                  ?.current!
                                  .variantColor),
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
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            bottom: 20,
          ),
          margin: EdgeInsets.only(left: Responsive.isMobile(context) ? 0 : 30),
          child: Column(
            children: [
              Text("${widget.year} နှစ် စာရင်းရှင်းတမ်း",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color:
                          NeumorphicTheme.of(context)?.current!.variantColor)),
              const SizedBox(
                height: 8,
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
                        padding: EdgeInsets.all(
                            Responsive.isMobile(context) ? 8 : 12),
                        child: const Text(
                          "လ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(
                            Responsive.isMobile(context) ? 8 : 12),
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
                        padding: EdgeInsets.all(
                            Responsive.isMobile(context) ? 8 : 12),
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
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.top,
                children: <TableRow>[
                  TableRow(
                    children: <Widget>[
                      Container(
                          height: data.length * 42,
                          // padding: EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
                          child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            Responsive.isMobile(context)
                                                ? 8
                                                : 4),
                                        child: Text(
                                          convertEnToMMMonthName(
                                              data[index].month.toString()),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            Responsive.isMobile(context)
                                                ? 8
                                                : 4),
                                        child: Text(
                                          data[index].totalDonation == 0
                                              ? "-"
                                              : Utils.strToMM(data[index]
                                                  .totalDonation
                                                  .toString()),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            Responsive.isMobile(context)
                                                ? 8
                                                : 4),
                                        child: Text(
                                          data[index].totalExpenses == 0
                                              ? "-"
                                              : Utils.strToMM(data[index]
                                                  .totalExpenses
                                                  .toString()),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                  ],
                                );
                              })),
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
                        padding: EdgeInsets.all(
                            Responsive.isMobile(context) ? 8 : 12),
                        child: Text(
                          "စုစုပေါင်း",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: NeumorphicTheme.of(context)
                                  ?.current!
                                  .variantColor),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(
                            Responsive.isMobile(context) ? 8 : 12),
                        child: Text(
                          totalDonation == 0
                              ? "-"
                              : Utils.strToMM(totalDonation.toString()),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: NeumorphicTheme.of(context)
                                  ?.current!
                                  .variantColor),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(
                            Responsive.isMobile(context) ? 8 : 12),
                        child: Text(
                          totalExpense == 0
                              ? "-"
                              : Utils.strToMM(totalExpense.toString()),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: NeumorphicTheme.of(context)
                                  ?.current!
                                  .variantColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }
    }, error: (e, stack) {
      return Text(e.toString());
    }, loading: () {
      return Container();
    });
  }

  convertEnToMMMonthName(String month) {
    if (month == "January") return "ဇန်နဝါရီ";
    if (month == "February") return "ဖေဖော်ဝါရီ";
    if (month == "March") return "မတ်";
    if (month == "April") return "ဧပြီ";
    if (month == "May") return "မေ";
    if (month == "June") return "ဇွန်";
    if (month == "July") return "ဇူလိုင်";
    if (month == "August") return "ဩဂုတ်";
    if (month == "September") return "စက်တင်ဘာ";
    if (month == "October") return "အောက်တိုဘာ";
    if (month == "November") return "နိုဝင်ဘာ";
    if (month == "December") return "ဒီဇင်ဘာ";
  }
}
