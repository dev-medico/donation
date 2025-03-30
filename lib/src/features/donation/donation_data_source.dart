// import 'dart:developer';

import 'package:donation/realm/schemas.dart' hide Donation;
import 'package:flutter/material.dart';
import 'package:donation/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
import 'package:donation/src/features/member/providers/member_providers.dart';
import 'package:donation/src/features/member/models/member.dart';

class DonationDataSource extends DataGridSource {
  //List<DonationRecord>
  /// Creates the employee data source class with required details.

  // convert 2022-02-31 to 31 Feb 2022

  String convertDate(String date) {
    // log("Smp = $date");
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
    // Fetch member list
    final memberAsyncValue = ref.read(memberListProvider);

    _donationData = donationData.map<DataGridRow>((e) {
      // Default values when member data is not available
      String memberName = "        -        ";
      String bloodType = "    -   ";

      // Try to find the member associated with this donation
      if (e.member != null && memberAsyncValue is AsyncData) {
        final membersList = memberAsyncValue.value ?? [];
        final memberId = e.member;

        for (final member in membersList) {
          if (member.id != null && member.id == memberId) {
            // Use null-safe operators when accessing member properties
            final name = member.name;
            memberName = "        ${name ?? '-'}        ";
            bloodType = member.bloodType ?? "    -   ";
            break;
          }
        }
      }

      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'ရက်စွဲ',
            value: e.donationDate != null
                ? DateFormat('dd-MM-yyyy').format(e.donationDate!)
                : "    -   "),
        DataGridCell<String>(columnName: 'သွေးအလှူရှင်', value: memberName),
        DataGridCell<String>(columnName: 'သွေးအုပ်စု', value: bloodType),
        DataGridCell<String>(
            columnName: 'လှူဒါန်းသည့်နေရာ',
            value: e.hospital == null || e.hospital!.isEmpty
                ? "                                "
                : "        ${e.hospital}        "),
        DataGridCell<String>(
            columnName: 'လူနာအမည်',
            value: e.patientName == null || e.patientName!.isEmpty
                ? "                 "
                : e.patientName.toString()),
        DataGridCell<String>(
            columnName: 'လိပ်စာ',
            value:
                e.patientAddress == null || e.patientAddress.toString() == "၊"
                    ? "                                "
                    : "     ${e.patientAddress}    "),
        DataGridCell<String>(
            columnName: 'အသက်',
            value: e.patientAge == null || e.patientAge!.isEmpty
                ? "                 "
                : "  ${Utils.strToMM(e.patientAge.toString())}   "),
        DataGridCell<String>(
            columnName: 'ဖြစ်ပွားသည့်ရောဂါ',
            value: e.patientDisease == null || e.patientDisease!.isEmpty
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
