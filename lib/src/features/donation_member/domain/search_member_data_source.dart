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
                  columnName: 'အဖအမည်', value: member.fatherName ?? ''),
              DataGridCell<String>(
                  columnName: 'သွေးအုပ်စု', value: member.bloodType ?? ''),
              DataGridCell<String>(
                  columnName: 'မှတ်ပုံတင်အမှတ်', value: member.nrc ?? ''),
              DataGridCell<String>(
                  columnName: 'သွေးဘဏ်ကတ်', value: member.bloodBankCard ?? ''),
              DataGridCell<String>(
                  columnName: 'သွေးလှူမှုကြိမ်ရေ',
                  value: member.memberCount ?? ''),
              DataGridCell<String>(
                  columnName: 'မွေးသက္ကရာဇ်', value: member.birthDate ?? ''),
              DataGridCell<String>(
                  columnName: 'ဖုန်းနံပါတ်', value: member.phone ?? ''),
              DataGridCell<String>(
                  columnName: 'နေရပ်လိပ်စာ', value: member.address ?? ''),
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
