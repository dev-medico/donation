import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/report_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final requestGiveStatsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final reportService = ref.read(reportServiceProvider);
    return await reportService.getRequestGiveStats();
  } catch (e) {
    throw Exception('Failed to load request/give stats: $e');
  }
});

class ChartData {
  ChartData(this.x, this.y, this.y1);
  final String x;
  final double? y;
  final double? y1;
}

class BloodRequestGiveChartScreen extends ConsumerStatefulWidget {
  const BloodRequestGiveChartScreen({super.key});

  @override
  ConsumerState<BloodRequestGiveChartScreen> createState() =>
      _BloodRequestGiveChartScreenState();
}

class _BloodRequestGiveChartScreenState
    extends ConsumerState<BloodRequestGiveChartScreen> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(enable: true, format: 'point.x : point.y');
  }

  @override
  Widget build(BuildContext context) {
    final requestGiveStats = ref.watch(requestGiveStatsProvider);

    return Container(
      height: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.height * 0.6
          : MediaQuery.of(context).size.height * 0.5,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.43,
      child: Material(
        elevation: 4,
        borderRadius:
            BorderRadius.circular(Responsive.isMobile(context) ? 12 : 16),
        color: Colors.white,
        child: requestGiveStats.when(
          data: (data) {
            final chartData = data
                .map((item) => ChartData(
                      "${item['month']}/${item['year']}",
                      (item['request'] as num).toDouble(),
                      (item['give'] as num).toDouble(),
                    ))
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "သွေးတောင်းခံ/လှူဒါန်းမှု အခြေအနေ",
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.isMobile(context) ? 10 : 8),
                  Expanded(
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      tooltipBehavior: _tooltip,
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<ChartData, String>(
                          name: 'တောင်းခံ',
                          color: Colors.red,
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                        ),
                        ColumnSeries<ChartData, String>(
                          name: 'လှူဒါန်း',
                          color: Colors.green,
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      ),
    );
  }
}
