import 'dart:developer';

import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donation/blood_donation_list_new_style.dart';
import 'package:flutter/material.dart';
import 'package:donation/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DonationDataSource extends DataGridSource {
  //List<DonationRecord>
  /// Creates the employee data source class with required details.

  // convert 2022-02-31 to 31 Feb 2022

  String convertDate(String date) {
    log("Smp = $date");
    if (date != "null") {
      var dateSplit = date.split('-');
      var year = dateSplit[0];
      var month = dateSplit[1];
      var day = dateSplit[2];
      var monthName = '';
      switch (month) {
        case '01':
          monthName = 'Jan';
          break;
        case '02':
          monthName = 'Feb';
          break;
        case '03':
          monthName = 'Mar';
          break;
        case '04':
          monthName = 'Apr';
          break;
        case '05':
          monthName = 'May';
          break;
        case '06':
          monthName = 'Jun';
          break;
        case '07':
          monthName = 'Jul';
          break;
        case '08':
          monthName = 'Aug';
          break;
        case '09':
          monthName = 'Sep';
          break;
        case '10':
          monthName = 'Oct';
          break;
        case '11':
          monthName = 'Nov';
          break;
        case '12':
          monthName = 'Dec';
          break;
      }
      return '$day $monthName $year';
    } else {
      return "";
    }
  }

  DonationDataSource(
      {required List<Donation> donationData, required WidgetRef ref}) {
    _donationData = donationData.map<DataGridRow>((e) {
      var member = ref
          .read(membersProvider)
          .where((data) => data.id.toString() == e.member.toString()
            ..toString())
          .first;
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'ရက်စွဲ',
            value: DateFormat('dd-MM-yyyy')
                .format(DateTime.parse(e.donationDate.toString()))),
        DataGridCell<String>(
            columnName: 'သွေးအလှူရှင်',
            value: "        ${member.name.toString()}        "),
        DataGridCell<String>(
            columnName: 'သွေးအုပ်စု', value: member.bloodType.toString()),
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
