/// Package imports
import 'dart:math';

import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/finder/common_chart_data.dart';
import 'package:donation/src/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';

class DonationModel {
  String? gender;
  double? quantity;
  double? total;

  DonationModel({this.gender, this.quantity, this.total});
}

class BloodDonationGenderPieChart extends ConsumerStatefulWidget {
  BloodDonationGenderPieChart({
    super.key,
  });

  @override
  ConsumerState<BloodDonationGenderPieChart> createState() =>
      _BloodDonationGenderPieChartState();
}

class _BloodDonationGenderPieChartState
    extends ConsumerState<BloodDonationGenderPieChart> {
  _BloodDonationGenderPieChartState();
  List<DonationModel> donations = [];
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
    var maleData = ref.watch(donationsProviderByGender("male")).length;
    var femaleData = ref.watch(donationsProviderByGender("female")).length;
    var averageAge = ref.watch(averageAgeOfMemberProvider);

    //calculate male Percent from maleData and femaleData Lenght Total
    double malePercent = 0;

    double femalePercent = 0;
    if (maleData != 0) {
      malePercent = (maleData / (maleData + femaleData)) * 100;
    }

    if (femaleData != 0) {
      femalePercent = (femaleData / (maleData + femaleData)) * 100;
    }

    if (donations.isEmpty) {
      donations.add(DonationModel(
          gender: "male", quantity: malePercent, total: maleData.toDouble()));
      donations.add(DonationModel(
          gender: "female",
          quantity: femalePercent,
          total: femaleData.toDouble()));
    }

    // sort donations list by quantity
    donations.sort((a, b) => b.quantity!.compareTo(a.quantity!));
    //get only top 5 donations
    donations = donations.length > 8 ? donations.sublist(0, 2) : donations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text("ပျမ်းမျှ အသက်"),
        ),
        SizedBox(
          height: 4,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(
            averageAge.toString() + " နှစ်",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        // Padding(
        //   padding: const EdgeInsets.only(left: 30),
        //   child: Text("ကျား/မ အလိုက် လှူဒါန်းမှုများ"),
        // ),
        Row(
          children: [
            Container(
              width: 0,
            ),
            Expanded(
                child:
                    Container(height: 200, child: _buildSmartLabelPieChart())),
          ],
        ),
      ],
    );
  }

  /// Returns the circular charts with pie series.
  SfCircularChart _buildSmartLabelPieChart() {
    List<ChartData> dataList = [];
    // get total of all products amount
    double totalAmount = donations.fold<double>(
        0, (previousValue, element) => previousValue + element.quantity!);
    donations.forEach((element) {
      dataList.add(ChartData(
        x: (element.gender == "male" ? "ကျား" : "မ     ") +
            " -   " +
            element.total!.truncate().toString(),
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
          radius: '80%',
          dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelIntersectAction: LabelIntersectAction.none,
              overflowMode: _overflowMode,
              showZeroValue: !isZeroVisible ? true : false,
              labelPosition: ChartDataLabelPosition.outside,
              connectorLineSettings:
                  ConnectorLineSettings(type: ConnectorType.line)),
          pointColorMapper: (datum, index) =>
              index.isEven ? Colors.blue : Colors.pink,

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
