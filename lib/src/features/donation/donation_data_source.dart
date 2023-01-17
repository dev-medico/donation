import 'package:flutter/material.dart';
import 'package:merchant/data/response/xata_donation_list_response.dart';
import 'package:merchant/utils/utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DonationDataSource extends DataGridSource {
  //List<DonationRecord>
  /// Creates the employee data source class with required details.

  DonationDataSource({required List<DonationRecord> memberData}) {
    _memberData = memberData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'ရက်စွဲ',
                  value: e.date!.contains("T")
                      ? e.date.toString().split("T")[0]
                      : e.date!.contains(" ")
                          ? e.date.toString().split(" ")[0]
                          : e.date.toString()),
              DataGridCell<String>(
                  columnName: '"သွေးအလှူရှင်"',
                  value: e.member!.name.toString()),
              DataGridCell<String>(
                  columnName: 'သွေးအုပ်စု', value: e.member!.bloodType),
              DataGridCell<String>(
                  columnName: 'လှူဒါန်းသည့်နေရာ', value: e.hospital),
              DataGridCell<String>(
                  columnName: 'လူနာအမည်', value: e.patientName),
              DataGridCell<String>(
                  columnName: 'လိပ်စာ', value: e.patientAddress),
              DataGridCell<String>(
                  columnName: 'အသက်',
                  value: Utils.strToMM(e.patientAge.toString())),
              DataGridCell<String>(
                  columnName: 'ဖြစ်ပွားသည့်ရောဂါ', value: e.patientDisease),
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
