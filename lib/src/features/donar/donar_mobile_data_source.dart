import 'dart:developer';

import 'package:donation/realm/schemas.dart';
import 'package:flutter/material.dart';
import 'package:donation/utils/utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class DonarMobileDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  DonarMobileDataSource({required List<DonarRecord> donarData}) {
    for (int i = 0; i < donarData.length; i++) {
      _donarData.add(DataGridRow(cells: [
        DataGridCell<String>(columnName: 'အမည်', value: "${donarData[i].name}"),
        DataGridCell<String>(
            columnName: 'အလှူငွေ',
            value: "  ${donarData[i].amount.toString()}\t"),
      ]));
    }
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
        child: Text(
          e.value.toString(),
        ),
      );
    }).toList());
  }
}
