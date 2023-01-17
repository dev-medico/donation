import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:merchant/data/response/xata_donation_list_response.dart';
import 'package:merchant/utils/utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DonationDataSource extends DataGridSource {
  //List<DonationRecord>
  /// Creates the employee data source class with required details.

  // convert 2022-02-31 to 31 Feb 2022

  String convertDate(String date) {
    log("Smp = $date");
    if (date != "null") {
      var dateSplit = date.split(' ');
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

  DonationDataSource({required List<DonationRecord> donationData}) {
    _donationData = donationData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'ရက်စွဲ',
                  value: convertDate(e.date!.contains("T")
                      ? e.date.toString().split("T")[0]
                      : e.date!.contains(" ")
                          ? e.date.toString().split(" ")[0]
                          : e.date.toString())),
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

  List<DataGridRow> _donationData = [];

  @override
  List<DataGridRow> get rows => _donationData;

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
