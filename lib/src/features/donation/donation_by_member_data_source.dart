import 'package:donation/realm/schemas.dart';
import 'package:flutter/material.dart';
import 'package:donation/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DonationByMemberDataSource extends DataGridSource {
  DonationByMemberDataSource(
      {required List<Donation> donationData, required WidgetRef ref}) {
    _donationData = donationData.map<DataGridRow>((e) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'ရက်စွဲ',
            value: DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(e.donationDate.toString()))),
        DataGridCell<String>(
            columnName: 'လှူဒါန်းသည့်နေရာ',
            value: e.hospital!.isEmpty
                ? "                                "
                : "        ${e.hospital}        "),
        DataGridCell<String>(
            columnName: 'လူနာအမည်',
            value: e.patientName!.isEmpty
                ? "                 "
                : e.patientName.toString()),
        DataGridCell<String>(
            columnName: 'လိပ်စာ',
            value: e.patientAddress.toString() == "၊"
                ? "                                "
                : "     ${e.patientAddress}    "),
        DataGridCell<String>(
            columnName: 'အသက်',
            value: e.patientAge.toString().isEmpty
                ? "                 "
                : "  ${Utils.strToMM(e.patientAge.toString())}   "),
        DataGridCell<String>(
            columnName: 'ဖြစ်ပွားသည့်ရောဂါ',
            value: e.patientDisease!.isEmpty
                ? "                                "
                : "     ${e.patientDisease}     "),
      ]);
    }).toList();
  }

  List<DataGridRow> _donationData = [];

  @override
  List<DataGridRow> get rows => _donationData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
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
