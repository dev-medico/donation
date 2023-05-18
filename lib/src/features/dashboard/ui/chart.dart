// import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:donation/utils/Colors.dart';

// class StackedBarChart extends StatelessWidget {
//   final List<charts.Series<dynamic, String>> seriesList;
//   final bool animate;

//   StackedBarChart(this.seriesList, {required this.animate});

//   /// Creates a stacked [BarChart] with sample data and no transition.
//   factory StackedBarChart.withSampleData() {
//     return StackedBarChart(
//       _createSampleData(),
//       animate: false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return charts.BarChart(
//       seriesList,
//       animate: animate,
//       barGroupingType: charts.BarGroupingType.stacked,
//     );
//   }

//   /// Create series list with multiple series
//   static List<charts.Series<OrdinalSales, String>> _createSampleData() {
//     final desktopSalesData = [
//       OrdinalSales('1\nWed', 30),
//       OrdinalSales('2\nThu', 25),
//       OrdinalSales('3\nFri', 20),
//       OrdinalSales('4\nSat', 15),
//       OrdinalSales('5\nSun', 25),
//       OrdinalSales('6\nMon', 30),
//       OrdinalSales('7\nTue', 35),
//       OrdinalSales('8\nWed', 20),
//       OrdinalSales('9\nThu', 25),
//       OrdinalSales('10\nFri', 30),
//     ];

//     final tableSalesData = [
//       OrdinalSales('1\nWed', 20),
//       OrdinalSales('2\nThu', 25),
//       OrdinalSales('3\nFri', 40),
//       OrdinalSales('4\nSat', 55),
//       OrdinalSales('5\nSun', 35),
//       OrdinalSales('6\nMon', 50),
//       OrdinalSales('7\nTue', 35),
//       OrdinalSales('8\nWed', 20),
//       OrdinalSales('9\nThu', 25),
//       OrdinalSales('10\nFri', 60),
//     ];

//     // final mobileSalesData = [
//     //   OrdinalSales('2014', 10),
//     //   OrdinalSales('2015', 15),
//     //   OrdinalSales('2016', 50),
//     //   OrdinalSales('2017', 45),
//     // ];

//     return [
//       charts.Series<OrdinalSales, String>(
//         id: 'Desktop',
//         seriesColor: charts.ColorUtil.fromDartColor(blueColor),
//         domainFn: (OrdinalSales sales, _) => sales.year,
//         measureFn: (OrdinalSales sales, _) => sales.sales,
//         data: desktopSalesData,
//       ),
//       charts.Series<OrdinalSales, String>(
//         id: 'Tablet',
//         seriesColor: charts.ColorUtil.fromDartColor(orangePale),
//         domainFn: (OrdinalSales sales, _) => sales.year,
//         measureFn: (OrdinalSales sales, _) => sales.sales,
//         data: tableSalesData,
//       ),
//       // charts.Series<OrdinalSales, String>(
//       //   id: 'Mobile',
//       //   domainFn: (OrdinalSales sales, _) => sales.year,
//       //   measureFn: (OrdinalSales sales, _) => sales.sales,
//       //   data: mobileSalesData,
//       // ),
//     ];
//   }
// }

// /// Sample ordinal data type.
// class OrdinalSales {
//   final String year;
//   final int sales;

//   OrdinalSales(this.year, this.sales);
// }
