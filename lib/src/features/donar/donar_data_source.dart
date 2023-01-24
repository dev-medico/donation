import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:merchant/data/response/xata_donors_list_response.dart';
import 'package:merchant/utils/utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class DonarDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  DonarDataSource({required List<DonorData> donarData}) {
    for (int i = 0; i < donarData.length; i++) {
      _donarData.add(DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'စဥ်',
            value: "   ${Utils.strToMM((i + 1).toString())}   "),
        DataGridCell<String>(
            columnName: 'ရက်စွဲ',
            value:
                "        ${DateFormat('dd MMM yyyy').format(DateTime.parse((donarData[i].date!.replaceAll("T", " ")).replaceAll("Z", "")))}        "),
        DataGridCell<String>(
            columnName: 'အမည်', value: "      ${donarData[i].name}\t\t\t\t"),
        DataGridCell<String>(
            columnName: 'အလှူငွေ',
            value: "    ${donarData[i].amount.toString()}\t\t"),
      ]));
    }
    // _donarData = donarData
    //     .map<DataGridRow>((e) => DataGridRow(cells: [
    //           DataGridCell<String>(columnName: 'စဥ်', value: "   ${e.id}   "),
    //           DataGridCell<String>(
    //               columnName: 'ရက်စွဲ',
    //               value:
    //                   "        ${DateFormat('dd MMM yyyy').format(DateTime.parse((e.date!.replaceAll("T", " ")).replaceAll("Z", "")))}        "),
    //           DataGridCell<String>(
    //               columnName: 'အမည်', value: "      ${e.name}\t\t\t\t"),
    //           DataGridCell<String>(
    //               columnName: 'အလှူငွေ',
    //               value: "    ${e.amount.toString()}\t\t"),
    //         ]))
    //     .toList();
  }

  final List<DataGridRow> _donarData = [];

  @override
  List<DataGridRow> get rows => _donarData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      log(e.value.runtimeType.toString());
      return Container(
        alignment: Utils.isNumeric(e.value.toString())
            ? Alignment.centerRight
            : Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
