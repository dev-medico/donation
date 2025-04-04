/// Package imports
import 'dart:math';

import 'package:donation/src/features/finder/common_chart_data.dart';
import 'package:donation/src/features/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';

class DonationModel {
  String? gender;
  int? quantity;
  int? percentage;

  DonationModel({this.gender, this.quantity, this.percentage});
}

final genderStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  try {
    final reportService = ref.read(reportServiceProvider);
    return await reportService.getGenderStats();
  } catch (e) {
    throw Exception('Failed to load gender stats: $e');
  }
});

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
    _positionList?.clear();
    _connectorLineList?.clear();
    _overflowModeList?.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final genderStats = ref.watch(genderStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        genderStats.when(
          data: (data) {
            final genderData =
                List<Map<String, dynamic>>.from(data['genderStats']);
            final maleData = genderData.firstWhere(
                (d) => d['patient_gender'] == 'male',
                orElse: () => {'quantity': 0, 'percentage': 0});
            final femaleData = genderData.firstWhere(
                (d) => d['patient_gender'] == 'female',
                orElse: () => {'quantity': 0, 'percentage': 0});
            final averageAge = data['averageAge'] as int;
            final totalDonations = data['totalDonations'] as int;
            final totalMembers = data['totalMembers'] as int;
            final ageRanges = Map<String, int>.from(data['ageRanges']);

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Row(
                        children: [
                          Text("ပျမ်းမျှ အသက်"),
                          SizedBox(height: 4),
                          Text(
                            "$averageAge နှစ်",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        children: [
                          Text("ကျား - ${maleData['quantity']}"),
                          SizedBox(width: 8),
                          Text("မ - ${femaleData['quantity']}"),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Row(
                //   children: [
                //     Container(width: 0),
                //     Expanded(
                //       child: Container(
                //         height: 200,
                //         child: _buildGenderPieChart(genderData),
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(height: 16),
                // Padding(
                //   padding: const EdgeInsets.only(left: 30),
                //   child: Text("အသက်အပိုင်းအခြား အလိုက် အဖွဲ့ဝင်များ"),
                // ),
                // SizedBox(height: 8),
                Row(
                  children: [
                    Container(width: 0),
                    Expanded(
                      child: Container(
                        height: 200,
                        child: _buildAgeGroupPieChart(ageRanges, totalMembers),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                error.toString().replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  SfCircularChart _buildGenderPieChart(List<Map<String, dynamic>> genderData) {
    List<ChartData> dataList = [];

    genderData.forEach((data) {
      dataList.add(ChartData(
        x: "${data['patient_gender'] == 'male' ? 'ကျား' : 'မ'} - ${data['quantity']}",
        y: data['percentage'] as int,
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
              index == 0 ? Colors.blue : Colors.pink,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
        )
      ],
    );
  }

  SfCircularChart _buildAgeGroupPieChart(
      Map<String, int> ageRanges, int totalMembers) {
    List<ChartData> dataList = [];

    ageRanges.forEach((range, count) {
      final percent = totalMembers > 0 ? (count / totalMembers) * 100 : 0;
      dataList.add(ChartData(
        x: "$range - $count",
        y: percent.round(),
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
          pointColorMapper: (datum, index) => _getAgeRangeColor(index),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
        )
      ],
    );
  }

  Color _getAgeRangeColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    return colors[index % colors.length];
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
