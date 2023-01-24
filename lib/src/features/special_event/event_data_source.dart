import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:merchant/data/response/special_event_list_response.dart';
import 'package:merchant/utils/utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class EventDataSource extends DataGridSource {
  EventDataSource({required List<SpecialEventData> specialEvent}) {
    for (int i = 0; i < specialEvent.length; i++) {
      _specialEvent.add(DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'စဥ်',
            value: "   ${Utils.strToMM((i + 1).toString())}   "),
        DataGridCell<String>(
            columnName: '        ရက်စွဲ        ',
            value: "        ${specialEvent[i].date}        "),
        DataGridCell<String>(
            columnName: 'Retro Test\n ခုခံအားကျဆင်းမှု \nကူးစက်ရောဂါ',
            value:
                "      ${specialEvent[i].retroTest == 0 ? "-" : Utils.strToMM(specialEvent[i].retroTest.toString())}\t\t\t\t"),
        DataGridCell<String>(
            columnName: 'Hbs Ag\n အသည်းရောင် \nအသားဝါ(ဘီ)ပိုး',
            value:
                "      ${specialEvent[i].hbsAg == 0 ? "-" : Utils.strToMM(specialEvent[i].hbsAg.toString())}\t\t\t\t"),
        DataGridCell<String>(
            columnName: 'HCV Ab\n အသည်းရောင် \nအသားဝါ(စီ)ပိုး',
            value:
                "      ${specialEvent[i].hcvAb == 0 ? "-" : Utils.strToMM(specialEvent[i].hcvAb.toString())}\t\t\t\t"),
        DataGridCell<String>(
            columnName: 'VDRL Test\n ကာလသားရောဂါ',
            value:
                "      ${specialEvent[i].vdrlTest == 0 ? "-" : Utils.strToMM(specialEvent[i].vdrlTest.toString())}\t\t\t\t"),
        DataGridCell<String>(
            columnName: 'M.P ( I.C.T )\n ငှက်ဖျားရောဂါ',
            value:
                "      ${specialEvent[i].mpIct == 0 ? "-" : Utils.strToMM(specialEvent[i].mpIct.toString())}\t\t\t\t"),
        DataGridCell<String>(
            columnName: 'Haemoglobin ( Hb% )\n သွေးအားရာခိုင်နှုန်း',
            value:
                "      ${specialEvent[i].haemoglobin == 0 ? "-" : Utils.strToMM(specialEvent[i].retroTest.toString())}\t\t\t\t"),
        DataGridCell<String>(
            columnName: 'Lab Name\n ဓါတ်ခွဲခန်းအမည်',
            value: "      ${specialEvent[i].labName}\t\t\t\t"),
        DataGridCell<String>(
            columnName: 'Total\n စုစုပေါင်း',
            value:
                "      ${specialEvent[i].total == 0 ? "-" : Utils.strToMM(specialEvent[i].total.toString())}\t\t\t\t"),
      ]));
    }
  }

  final List<DataGridRow> _specialEvent = [];

  @override
  List<DataGridRow> get rows => _specialEvent;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      log(e.value.runtimeType.toString());
      return Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
