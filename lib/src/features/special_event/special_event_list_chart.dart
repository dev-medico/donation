import 'package:donation/realm/schemas.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/finder/provider/request_give_provider.dart';
import 'package:donation/src/features/special_event/special_event_provider.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SpecialEventChartScreen extends ConsumerStatefulWidget {
  const SpecialEventChartScreen({super.key});

  @override
  ConsumerState<SpecialEventChartScreen> createState() =>
      _SpecialEventChartScreenState();
}

class _SpecialEventChartScreenState
    extends ConsumerState<SpecialEventChartScreen> {
  late List<ChartData> data;
  late TooltipBehavior _tooltip;
  List<SpecialEventChartData> specialEventChartDatas = [];

  @override
  Widget build(BuildContext context) {
    var specialEvents = ref.watch(specialEventsDataProvider);
    int retroTotal = 0;
    int hbsAgTotal = 0;
    int hcvAbTotal = 0;
    int vdrlTotal = 0;
    int mpTotal = 0;
    int haemoTotal = 0;
    specialEventChartDatas.clear();
    specialEvents.forEach((element) {
      //get total of each special event like retro test, covid test, etc
      retroTotal += element.retroTest ?? 0;
      hbsAgTotal += element.hbsAg ?? 0;
      hcvAbTotal += element.hcvAb ?? 0;
      vdrlTotal += element.vdrlTest ?? 0;
      mpTotal += element.mpIct ?? 0;
      haemoTotal += element.haemoglobin ?? 0;
    });

    specialEventChartDatas.add(SpecialEventChartData(
      "Retro Test",
      retroTotal.toString(),
    ));
    specialEventChartDatas.add(SpecialEventChartData(
      "Hbs Ag",
      hbsAgTotal.toString(),
    ));
    specialEventChartDatas.add(SpecialEventChartData(
      "HCV Ab",
      hcvAbTotal.toString(),
    ));
    specialEventChartDatas.add(SpecialEventChartData(
      "VDRL Test",
      vdrlTotal.toString(),
    ));
    specialEventChartDatas.add(SpecialEventChartData(
      "M.P(I.C.T)",
      mpTotal.toString(),
    ));
    specialEventChartDatas.add(SpecialEventChartData(
      "Hb%",
      haemoTotal.toString(),
    ));

    final List<ChartData> chartData = <ChartData>[];
    specialEventChartDatas.forEach((element) {
      chartData.add(ChartData(
        "${element.name.toString()}",
        double.parse(element.quantity.toString()),
      ));
    });
    if (Responsive.isMobile(context)) {
      return ListView(
        children: [
          chartView(chartData),
          detailView(specialEventChartDatas.toSet().toList())
        ],
      );
    } else {
      return Row(
        children: [
          chartView(chartData),
          detailView(specialEventChartDatas.toSet().toList())
        ],
      );
    }
  }

  chartView(List<ChartData> chartData) {
    return Container(
      height: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.height * 0.6
          : MediaQuery.of(context).size.height * 0.7,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.38,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              "ဖြစ်စဥ်ပြ ဇယား",
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                  color: primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: Responsive.isMobile(context) ? 10 : 24,
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
                ]),
          ),
          SizedBox(
            height: Responsive.isMobile(context) ? 10 : 24,
          ),
        ],
      ),
    );
  }

  detailView(List<SpecialEventChartData> specialEventChartDatas) {
    var total = 0;
    specialEventChartDatas.forEach((element) {
      total += int.parse(element.quantity);
    });
    return Container(
      height: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.height * 0.6
          : MediaQuery.of(context).size.height * 0.7,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.38,
      child: ListView(
        padding: EdgeInsets.only(left: 30, top: 30),
        physics: Responsive.isMobile(context)
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Text(
            "ဖြစ်စဥ် အလိုက် မှတ်တမ်း",
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ဖြစ်စဥ်",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "အရေအတွက်",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 12.0, right: 12, left: 8),
            itemCount: specialEventChartDatas.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      specialEventChartDatas[index].name,
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 15 : 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      specialEventChartDatas[index].quantity.toString(),
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 15 : 16,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 12, right: 16, top: 8, bottom: 8),
            width: double.infinity,
            height: 1,
            color: Colors.grey,
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 12, top: 8, right: 20, bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "စုစုပေါင်း အရေအတွက်",
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  total.toString(),
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpecialEventChartData {
  SpecialEventChartData(
    this.name,
    this.quantity,
  );
  final String name;
  final String quantity;
}

class ChartData {
  ChartData(
    this.x,
    this.y,
  );
  final String x;
  final double? y;
}
