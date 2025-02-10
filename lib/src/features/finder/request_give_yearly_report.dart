// import 'package:donation/responsive.dart';
// import 'package:donation/src/features/finder/provider/request_give_provider.dart';
// import 'package:donation/utils/tool_widgets.dart';
// import 'package:donation/utils/utils.dart';
// import 'package:fluent_ui/fluent_ui.dart' as fluent;
// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// class RequestGiveYearlyReport extends ConsumerStatefulWidget {
//   const RequestGiveYearlyReport({super.key, required this.year});
//   final String year;

//   @override
//   ConsumerState<RequestGiveYearlyReport> createState() =>
//       _RequestGiveYearlyReportState();
// }

// class _RequestGiveYearlyReportState
//     extends ConsumerState<RequestGiveYearlyReport> {
//   @override
//   Widget build(BuildContext context) {
//     var data = ref.watch(requestGiveByYearProvider(int.parse(widget.year)));

//     if (data.isEmpty) {
//       return Container(
//         margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
//         child: Center(
//             child: Text(
//                 widget.year + " အတွက် သွေးတောင်းခံ/လှူဒါန်းမှု မရှိသေးပါ။")),
//       );
//     } else {
//       int totalRequest = 0;
//       int totalGive = 0;
//       data.forEach((element) {
//         totalRequest += element.request ?? 0;
//         totalGive += element.give ?? 0;
//       });
//       return Container(
//         width: Responsive.isMobile(context)
//             ? MediaQuery.of(context).size.width * 0.9
//             : MediaQuery.of(context).size.width * 0.6,
//         decoration: shadowDecoration(Colors.white),
//         padding: const EdgeInsets.only(
//           left: 8,
//           right: 8,
//           bottom: 20,
//         ),
//         margin: EdgeInsets.only(left: 0, top: 30),
//         child: Column(
//           children: [
//             Text("${widget.year} နှစ် သွေး တောင်းခံ/လှူဒါန်းမှု",
//                 style: TextStyle(
//                     fontSize: Responsive.isMobile(context) ? 16 : 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black)),
//             const SizedBox(
//               height: 20,
//             ),
//             Table(
//               border: TableBorder.all(),
//               columnWidths: const <int, TableColumnWidth>{
//                 0: FlexColumnWidth(),
//                 1: FlexColumnWidth(),
//               },
//               defaultVerticalAlignment: TableCellVerticalAlignment.top,
//               children: <TableRow>[
//                 TableRow(
//                   children: <Widget>[
//                     Padding(
//                       padding:
//                           EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
//                       child: const Text(
//                         "လ",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
//                       child: const Text(
//                         "သွေးတောင်းခံမှု",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
//                       child: const Text(
//                         "သွေးလှုဒါန်းမှု",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
//                       child: const Text(
//                         "ပေးနိုင်ခဲ့သည့် ရာခိုင်နှုန်း",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             Table(
//               border: TableBorder.all(),
//               columnWidths: const <int, TableColumnWidth>{
//                 0: FlexColumnWidth(),
//               },
//               defaultVerticalAlignment: TableCellVerticalAlignment.top,
//               children: <TableRow>[
//                 TableRow(
//                   children: <Widget>[
//                     Container(
//                         height: data.length * 40,
//                         // padding: EdgeInsets.all(Responsive.isMobile(context) ? 8 : 12),
//                         child: ListView.builder(
//                             itemCount: data.length,
//                             padding: EdgeInsets.only(top: 20),
//                             itemBuilder: (context, index) {
//                               return Row(
//                                 children: <Widget>[
//                                   Expanded(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(
//                                           Responsive.isMobile(context) ? 8 : 4),
//                                       child: Text(
//                                         convertToMMMonthName(
//                                             data[index].date!.toLocal().month -
//                                                 1),
//                                         // convertEnToMMMonthName(data[index]
//                                         //     .date!
//                                         //     .toLocal()
//                                         //     .month
//                                         //     .toString()),
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(
//                                           Responsive.isMobile(context) ? 8 : 4),
//                                       child: Text(
//                                         data[index].request == 0
//                                             ? "-"
//                                             : Utils.strToMM(
//                                                 data[index].request.toString()),
//                                         textAlign: TextAlign.end,
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 12,
//                                   ),
//                                   Expanded(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(
//                                           Responsive.isMobile(context) ? 8 : 4),
//                                       child: Text(
//                                         data[index].give == 0
//                                             ? "-"
//                                             : Utils.strToMM(
//                                                 data[index].give.toString()),
//                                         textAlign: TextAlign.end,
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 12,
//                                   ),
//                                   Expanded(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(
//                                           Responsive.isMobile(context) ? 8 : 4),
//                                       child: Text(
//                                         calculatePercent(
//                                             data[index].request ?? 0,
//                                             data[index].give ?? 0),
//                                         textAlign: TextAlign.end,
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 12,
//                                   ),
//                                 ],
//                               );
//                             })),
//                   ],
//                 ),
//               ],
//             ),
//             Table(
//               border: TableBorder.all(),
//               columnWidths: const <int, TableColumnWidth>{
//                 0: FlexColumnWidth(),
//                 1: FlexColumnWidth(),
//               },
//               defaultVerticalAlignment: TableCellVerticalAlignment.top,
//               children: <TableRow>[
//                 TableRow(
//                   children: <Widget>[
//                     Padding(
//                       padding: EdgeInsets.all(4),
//                       child: Text(
//                         "စုစုပေါင်း",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(
//                           left: 4, right: 20, top: 4, bottom: 4),
//                       child: Text(
//                         totalRequest == 0
//                             ? "-"
//                             : Utils.strToMM(totalRequest.toString()),
//                         textAlign: TextAlign.end,
//                         style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(
//                           left: 4, right: 20, top: 4, bottom: 4),
//                       child: Text(
//                         totalGive == 0
//                             ? "-"
//                             : Utils.strToMM(totalGive.toString()),
//                         textAlign: TextAlign.end,
//                         style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(
//                           left: 4, right: 20, top: 4, bottom: 4),
//                       child: Text(
//                         calculatePercent(totalRequest, totalGive),
//                         textAlign: TextAlign.end,
//                         style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   calculatePercent(int request, int give) {
//     if (request == 0) {
//       return "-";
//     } else {
//       return "${Utils.strToMM(((give / request) * 100).toStringAsFixed(0))} %";
//     }
//   }

//   convertToMMMonthName(int month) {
//     if (month == 0) return "ဇန်နဝါရီ";
//     if (month == 1) return "ဖေဖော်ဝါရီ";
//     if (month == 2) return "မတ်";
//     if (month == 3) return "ဧပြီ";
//     if (month == 4) return "မေ";
//     if (month == 5) return "ဇွန်";
//     if (month == 6) return "ဇူလိုင်";
//     if (month == 7) return "ဩဂုတ်";
//     if (month == 8) return "စက်တင်ဘာ";
//     if (month == 9) return "အောက်တိုဘာ";
//     if (month == 10) return "နိုဝင်ဘာ";
//     if (month == 11) return "ဒီဇင်ဘာ";
//   }

//   convertEnToMMMonthName(String month) {
//     if (month == "January") return "ဇန်နဝါရီ";
//     if (month == "February") return "ဖေဖော်ဝါရီ";
//     if (month == "March") return "မတ်";
//     if (month == "April") return "ဧပြီ";
//     if (month == "May") return "မေ";
//     if (month == "June") return "ဇွန်";
//     if (month == "July") return "ဇူလိုင်";
//     if (month == "August") return "ဩဂုတ်";
//     if (month == "September") return "စက်တင်ဘာ";
//     if (month == "October") return "အောက်တိုဘာ";
//     if (month == "November") return "နိုဝင်ဘာ";
//     if (month == "December") return "ဒီဇင်ဘာ";
//   }
// }
