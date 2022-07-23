import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:merchant/donation_list_response.dart';

class SimpleBarChartBlood extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool? animate;

  const SimpleBarChartBlood(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SimpleBarChartBlood.withSampleData(List<DonationData> data) {
    return SimpleBarChartBlood(
      chartWithData(data),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalSales, String>> chartWithData(
      List<DonationData> data) {
    List<OrdinalSales> sales = [];

    List<String> bloodTypes = [
      "A (Rh +)",
      "A (Rh -)",
      "B (Rh +)",
      "B (Rh -)",
      "AB (Rh +)",
      "AB (Rh -)",
      "O (Rh +)",
      "O (Rh -)"
    ];

    for (var bloodType in bloodTypes) {
      if (data
          .where((element) => element.memberBloodType == bloodType)
          .isNotEmpty) {
        sales.add(OrdinalSales(
            bloodType,
            data
                .where((element) => element.memberBloodType == bloodType)
                .length));
      }
    }

    return [
      charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: sales,
      )
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
