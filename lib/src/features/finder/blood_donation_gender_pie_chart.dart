
import 'package:donation/responsive.dart';
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
  late bool isZeroVisible;
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
            final totalMembers = data['totalMembers'] as int;
            final ageRanges = Map<String, int>.from(data['ageRanges']);

            final mobile = Responsive.isMobile(context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Wraps onto a second line on narrow phones instead of
                // overflowing the card.
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text("ပျမ်းမျှ အသက်"),
                        SizedBox(width: 6),
                        Text(
                          "$averageAge နှစ်",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("ကျား - ${maleData['quantity']}"),
                        SizedBox(width: 12),
                        Text("မ - ${femaleData['quantity']}"),
                      ],
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
                SizedBox(
                  height: mobile ? 220 : 200,
                  child: _buildAgeGroupPieChart(
                    ageRanges,
                    totalMembers,
                    mobile: mobile,
                  ),
                ),
                // On phones the chart's own legend gets clipped at the card
                // edge, so the entries are laid out here and wrap freely.
                if (mobile) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      for (final (index, entry) in ageRanges.entries.indexed)
                        _LegendEntry(
                          color: _getAgeRangeColor(index),
                          label: "${entry.key} - ${entry.value}",
                        ),
                    ],
                  ),
                ],
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

  SfCircularChart _buildAgeGroupPieChart(
      Map<String, int> ageRanges, int totalMembers,
      {required bool mobile}) {
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
        // Phones draw their own wrapping legend under the chart instead.
        // isResponsive must be off whenever the legend is hidden: the chart
        // library's responsive check dereferences the (absent) legend box
        // and throws a null-check error.
        isVisible: !mobile,
        isResponsive: !mobile,
      ),
      series: <CircularSeries<ChartData, String>>[
        DoughnutSeries<ChartData, String>(
          dataSource: dataList,
          enableTooltip: true,
          // Leaves room for the outside labels on narrow phones.
          radius: mobile ? '70%' : '80%',
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
          dataLabelMapper: (ChartData data, _) => '${data.y}%',
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
    isZeroVisible = false;
    _positionList = <String>['outside', 'inside'].toList();
    _connectorLineList = <String>['curve', 'line'].toList();
    _overflowMode = OverflowMode.none;
    _overflowModeList = <String>['shift', 'none', 'hide', 'trim'].toList();
    _tooltipBehavior =
        TooltipBehavior(enable: true, format: 'point.x : point.y%');
    super.initState();
  }
}

/// A legend swatch (ring in the slice colour) followed by its label.
class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
