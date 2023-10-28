import 'dart:developer';

import 'package:donation/realm/schemas.dart';
import 'package:flutter/material.dart';
import 'package:donation/utils/utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class ExpenseMobileDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  ExpenseMobileDataSource({required List<ExpensesRecord> expenseData}) {
    for (int i = 0; i < expenseData.length; i++) {
      _expenseData.add(DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'အကြောင်းအရာ',
            value: "      ${expenseData[i].name}\t\t"),
        DataGridCell<String>(
            columnName: 'ကုန်ကျစရိတ်',
            value: "    ${expenseData[i].amount.toString()}\t\t"),
      ]));
    }
  }

  final List<DataGridRow> _expenseData = [];

  @override
  List<DataGridRow> get rows => _expenseData;

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
