import 'package:flutter/material.dart';
import 'package:merchant/data/response/xata_donors_list_response.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class DonarDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  DonarDataSource({required List<DonorData> donarData}) {
    _donarData = donarData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'စဥ်', value: "   ${e.id}   "),
              DataGridCell<String>(
                  columnName: 'ရက်စွဲ',
                  value:
                      "        ${DateFormat('dd MMM yyyy').format(DateTime.parse((e.date!.replaceAll("T", " ")).replaceAll("Z", "")))}        "),
              DataGridCell<String>(
                  columnName: 'အမည်', value: "      ${e.name}\t\t\t\t"),
              DataGridCell<String>(
                  columnName: 'အလှူငွေ', value: e.amount.toString()),
            ]))
        .toList();
  }

  List<DataGridRow> _donarData = [];

  @override
  List<DataGridRow> get rows => _donarData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
