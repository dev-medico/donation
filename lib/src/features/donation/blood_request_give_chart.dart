// import 'package:donation/realm/schemas.dart';
// import 'package:donation/responsive.dart';
// import 'package:donation/src/features/finder/provider/request_give_provider.dart';
// import 'package:donation/utils/Colors.dart';
// import 'package:flutter/material.dart';
// import 'package:fluent_ui/fluent_ui.dart' as fluent;
// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class BloodRequestGiveChartScreen extends ConsumerStatefulWidget {
//   const BloodRequestGiveChartScreen({super.key});

//   @override
//   ConsumerState<BloodRequestGiveChartScreen> createState() =>
//       _BloodRequestGiveChartScreenState();
// }

// class _BloodRequestGiveChartScreenState
//     extends ConsumerState<BloodRequestGiveChartScreen> {
//   late List<ChartData> data;
//   late TooltipBehavior _tooltip;
//   List<RequestGive> requestGives = [];

//   @override
//   Widget build(BuildContext context) {
//     var requestGivesData = ref.watch(requestGiveProvider);
//     requestGivesData.forEach((element) {
//       requestGives.add(element);
//     });
//     requestGives.sort((a, b) => a.date!.compareTo(b.date!));

//     final List<ChartData> chartData = <ChartData>[];
//     requestGives.forEach((element) {
//       chartData.add(ChartData(
//           "${element.date!.toLocal().month.toString()}/${element.date!.toLocal().year.toString()}",
//           element.request!.toDouble(),
//           element.give!.toDouble()));
//     });
//     return Container(
//       height: Responsive.isMobile(context)
//           ? MediaQuery.of(context).size.height * 0.6
//           : MediaQuery.of(context).size.height * 0.5,
//       width: Responsive.isMobile(context)
//           ? MediaQuery.of(context).size.width * 0.9
//           : MediaQuery.of(context).size.width * 0.43,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 8,
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 16),
//             child: Text(
//               "သွေးတောင်းခံ/လှူဒါန်းမှု အခြေအနေ",
//               style: TextStyle(
//                   fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
//                   color: primaryColor,
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//           SizedBox(
//             height: Responsive.isMobile(context) ? 10 : 8,
//           ),
//           Expanded(
//             child: SfCartesianChart(
//                 primaryXAxis: CategoryAxis(),
//                 series: <CartesianSeries>[
//                   ColumnSeries<ChartData, String>(
//                       color: Colors.green,
//                       dataSource: chartData,
//                       xValueMapper: (ChartData data, _) => data.x,
//                       yValueMapper: (ChartData data, _) => data.y),
//                   ColumnSeries<ChartData, String>(
//                       color: Colors.red,
//                       dataSource: chartData,
//                       xValueMapper: (ChartData data, _) => data.x,
//                       yValueMapper: (ChartData data, _) => data.y1),
//                 ]),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChartData {
//   ChartData(
//     this.x,
//     this.y,
//     this.y1,
//   );
//   final String x;
//   final double? y;
//   final double? y1;
// }
