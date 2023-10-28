import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BloodRequestGiveChartScreen extends StatefulWidget {
  const BloodRequestGiveChartScreen({super.key});

  @override
  State<BloodRequestGiveChartScreen> createState() =>
      _BloodRequestGiveChartScreenState();
}

class _BloodRequestGiveChartScreenState
    extends State<BloodRequestGiveChartScreen> {
  late List<ChartData> data;
  late TooltipBehavior _tooltip;

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = <ChartData>[
      ChartData('Jan', 128, 90),
      ChartData('Feb', 123, 92),
      ChartData('Mar', 107, 45),
      ChartData('Apr', 87, 60),
      ChartData('May', 120, 80),
      ChartData('June', 95, 70),
      ChartData('July', 80, 55),
      ChartData('Aug', 110, 75),
      ChartData('Sept', 135, 90),
      ChartData('Oct', 150, 100),
      ChartData('Nov', 120, 80),
      ChartData('Dec', 100, 70),
    ];
    return Container(
      height: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.height * 0.6
          : MediaQuery.of(context).size.height * 0.5,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.43,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              "သွေးတောင်းခံ/လှူဒါန်းမှု အခြေအနေ",
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 16.5 : 17.5,
                  color: primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: Responsive.isMobile(context) ? 10 : 8,
          ),
          Expanded(
            child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<ChartData, String>(
                      color: Colors.green,
                      dataSource: chartData,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y),
                  ColumnSeries<ChartData, String>(
                      color: Colors.red,
                      dataSource: chartData,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y1),
                ]),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(
    this.x,
    this.y,
    this.y1,
  );
  final String x;
  final double? y;
  final double? y1;
}
