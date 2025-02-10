// import 'dart:developer';

// import 'package:donation/realm/schemas.dart';
// import 'package:donation/src/providers/providers.dart';
// import 'package:flutter/material.dart';
// import 'package:donation/utils/utils.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:intl/intl.dart';

// class PatientDataSource extends DataGridSource {
//   /// Creates the employee data source class with required details.
//   PatientDataSource({required List<Patient> patient}) {
//     for (int i = 0; i < patient.length; i++) {
//       _patient.add(DataGridRow(cells: [
//         DataGridCell<String>(
//             columnName: 'စဥ်',
//             value: "   ${Utils.strToMM((i + 1).toString())}   "),
//         DataGridCell<String>(
//             columnName: 'အမည်', value: "  ${patient[i].patientName}\t\t"),
//         DataGridCell<String>(
//             columnName: 'အကြိမ်ရေ',
//             value: " \t\t\t\t   ${patient[i].donatedCount}  \t\t"),
//         DataGridCell<String>(
//             columnName: 'လှူဒါန်းသည့်နေရာ',
//             value: "  ${patient[i].hospital}\t\t"),
//         DataGridCell<String>(
//             columnName: 'ဖြစ်ပွားသည့်ရောဂါ',
//             value: "  ${patient[i].patientDisease}\t\t"),
//         DataGridCell<String>(
//             columnName: 'အသက်', value: "  ${patient[i].patientAge}\t\t"),
//         DataGridCell<String>(
//             columnName: 'နေရပ်လိပ်စာ',
//             value: "  ${patient[i].patientAddress}\t\t"),
//       ]));
//     }
//   }

//   final List<DataGridRow> _patient = [];

//   @override
//   List<DataGridRow> get rows => _patient;

//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//         cells: row.getCells().map<Widget>((e) {
//       log(e.value.runtimeType.toString());
//       return Container(
//         alignment: Utils.isNumeric(e.value.toString())
//             ? Alignment.centerRight
//             : Alignment.centerLeft,
//         padding: const EdgeInsets.all(8.0),
//         child: Text(
//           e.value.toString(),
//         ),
//       );
//     }).toList());
//   }
// }
