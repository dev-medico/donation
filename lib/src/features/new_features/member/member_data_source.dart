import 'package:flutter/material.dart';
import 'package:merchant/data/response/member_response.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MemberDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  MemberDataSource({required List<MemberData> memberData}) {
    _memberData = memberData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'အမှတ်စဥ်', value: e.memberId),
              DataGridCell<String>(columnName: 'အမည်', value: e.name),
              DataGridCell<String>(columnName: 'အဖအမည်', value: e.fatherName),
              DataGridCell<String>(
                  columnName: 'သွေးအုပ်စု', value: e.bloodType),
              DataGridCell<String>(columnName: 'မှတ်ပုံတင်အမှတ်', value: e.nrc),
              DataGridCell<String>(
                  columnName: 'သွေးဘဏ်ကတ်', value: e.bloodBankCard),
              DataGridCell<int>(
                  columnName: 'သွေးလှူမှုကြိမ်ရေ', value: e.totalCount),
            ]))
        .toList();
  }

  List<DataGridRow> _memberData = [];

  @override
  List<DataGridRow> get rows => _memberData;

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
