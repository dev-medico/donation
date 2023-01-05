import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:merchant/data/response/xata_donation_list_response.dart';
import 'package:merchant/donation_list_response.dart';

class SimpleBarChartBlood extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool? animate;

  const SimpleBarChartBlood(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SimpleBarChartBlood.withSampleData(List<DonationRecord> data) {
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
      List<DonationRecord> data) {
    List<OrdinalSales> sales = [];

    List<String> bloodTypes = [
      "A (Rh +)",
      "B (Rh +)",
      "O (Rh +)",
      "AB (Rh +)",
      "A (Rh -)",   
      "B (Rh -)",
       "O (Rh -)",
      "AB (Rh -)"
    ];

    for (var bloodType in bloodTypes) {
      if (data
          .where((element) => element.member!.bloodType.toString() == bloodType)
          .isNotEmpty) {
        sales.add(OrdinalSales(
            bloodType,
            data
                .where((element) => element.member!.bloodType.toString() == bloodType)
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
