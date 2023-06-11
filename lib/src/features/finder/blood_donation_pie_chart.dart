/// Package imports
import 'dart:math';

import 'package:donation/src/features/finder/common_chart_data.dart';
import 'package:flutter/material.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';

class DonationModel {
  String? disease;
  double? quantity;

  DonationModel({
    this.disease,
    this.quantity,
  });
}

class BloodDonationPieChart extends StatefulWidget {
  final List<DonationModel>? donations;
  BloodDonationPieChart({
    super.key,
    required this.donations,
  });

  @override
  State<BloodDonationPieChart> createState() => _BloodDonationPieChartState();
}

class _BloodDonationPieChartState extends State<BloodDonationPieChart> {
  _BloodDonationPieChartState();
  List<String>? _positionList;
  List<String>? _connectorLineList;
  late String _selectedPosition;
  late String _connectorLine;
  late bool isZeroVisible;
  late ChartDataLabelPosition _labelPosition;
  late ConnectorType _connectorType;
  late String _selectedOverflowMode;
  late OverflowMode _overflowMode;
  List<String>? _overflowModeList;
  TooltipBehavior? _tooltipBehavior;

  @override
  void dispose() {
    _positionList!.clear();
    _connectorLineList!.clear();
    _overflowModeList!.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text("လှူဒါန်းမှု အများဆုံး ရောဂါများ"),
        ),
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.01,
            ),
            Expanded(child: _buildSmartLabelPieChart()),
          ],
        ),
      ],
    );
  }

  /// Returns the circular charts with pie series.
  SfCircularChart _buildSmartLabelPieChart() {
    List<ChartData> dataList = [];
    // get total of all products amount
    double totalAmount = widget.donations!.fold<double>(
        0, (previousValue, element) => previousValue + element.quantity!);
    widget.donations!.forEach((element) {
      dataList.add(ChartData(
        x: element.disease,
        y: calculatePercentage(element.quantity!, totalAmount),
      ));
    });
    return SfCircularChart(
      tooltipBehavior: _tooltipBehavior,
      legend: Legend(
        isVisible: true,
        isResponsive: true,
      ),
      series: <CircularSeries<ChartData, String>>[
        DoughnutSeries<ChartData, String>(
          dataSource: dataList,
          enableTooltip: true,
          radius: '90%',
          dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelIntersectAction: LabelIntersectAction.none,
              overflowMode: _overflowMode,
              showZeroValue: !isZeroVisible ? true : false,
              labelPosition: ChartDataLabelPosition.outside,
              connectorLineSettings:
                  ConnectorLineSettings(type: ConnectorType.line)),
          pointColorMapper: (datum, index) => generateRandomColor(),

          // dataLabelSettings: const DataLabelSettings(
          //     isVisible: true,
          //     useSeriesColor: true,
          //     labelPosition: ChartDataLabelPosition.inside),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
        )
      ],
    );
  }

  int calculatePercentage(double amount, double totalAmount) {
    return ((amount / totalAmount) * 100).round();
  }

  generateRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  @override
  void initState() {
    _selectedPosition = 'outside';
    _connectorLine = 'curve';
    isZeroVisible = false;
    _positionList = <String>['outside', 'inside'].toList();
    _connectorLineList = <String>['curve', 'line'].toList();
    _labelPosition = ChartDataLabelPosition.outside;
    _connectorType = ConnectorType.curve;
    _selectedOverflowMode = 'none';
    _overflowMode = OverflowMode.none;
    _overflowModeList = <String>['shift', 'none', 'hide', 'trim'].toList();
    _tooltipBehavior =
        TooltipBehavior(enable: true, format: 'point.x : point.y%');
    super.initState();
  }
}
