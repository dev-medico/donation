// import 'package:flutter/material.dart';
// import 'package:donation/realm/schemas.dart';
// import 'package:donation/utils/utils.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:intl/intl.dart';

import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class SearchMemberDataSource extends DataGridSource {
  SearchMemberDataSource({required List<Member> memberData}) {
    _memberData = memberData
        .map<DataGridRow>((member) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'အမှတ်စဥ်', value: member.memberId ?? ''),
              DataGridCell<String>(
                  columnName: 'အမည်', value: member.name ?? ''),
              DataGridCell<String>(
                  columnName: 'လှူဒါန်းခဲ့သည့်ရက်',
                  value: member.lastDate != null
                      ? DateFormat('dd-MM-yyyy')
                          .format(DateTime.parse(member.lastDate!))
                      : ''),
              DataGridCell<String>(
                  columnName: 'သွေးအုပ်စု', value: member.bloodType ?? ''),
              DataGridCell<String>(
                  columnName: 'မှတ်ပုံတင်အမှတ်', value: member.nrc ?? ''),
              DataGridCell<String>(
                  columnName: 'ဖုန်းနံပါတ်', value: member.phone ?? ''),
              DataGridCell<String>(
                  columnName: 'အခြေအနေ', value: member.status ?? ''),
              DataGridCell<String>(
                  columnName: 'မှတ်ချက်', value: member.note ?? ''),
            ]))
        .toList();
  }

  List<DataGridRow> _memberData = [];

  @override
  List<DataGridRow> get rows => _memberData;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          dataGridCell.value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList());
  }
}
