// import 'package:flutter/material.dart';
// import 'package:donation/realm/schemas.dart';
// import 'package:donation/utils/utils.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// class MemberDataSource extends DataGridSource {
//   /// Creates the employee data source class with required details.
//   MemberDataSource({required List<Member> memberData}) {
//     _memberData = memberData
//         .map<DataGridRow>((e) => DataGridRow(cells: [
//               DataGridCell<String>(
//                   columnName: 'အမှတ်စဥ်', value: "   ${e.memberId}   "),
//               DataGridCell<String>(
//                   columnName: 'အမည်', value: "      ${e.name}\t\t\t\t"),
//               DataGridCell<String>(
//                   columnName: 'အဖအမည်',
//                   value: "        ${e.fatherName}        "),
//               DataGridCell<String>(
//                   columnName: 'သွေးအုပ်စု',
//                   value: "  " + e.bloodType.toString() + "  "),
//               DataGridCell<String>(columnName: 'မှတ်ပုံတင်အမှတ်', value: e.nrc),
//               DataGridCell<String>(
//                   columnName: 'သွေးဘဏ်ကတ်',
//                   value: "      ${e.bloodBankCard}    "),
//               DataGridCell<String>(
//                   columnName: 'သွေးလှူမှုကြိမ်ရေ',
//                   value: "       ${e.totalCount.toString()}        "),
//               DataGridCell<String>(
//                   columnName: 'မွေးသက္ကရာဇ်',
//                   value: "       ${e.birthDate.toString()}        "),
//               DataGridCell<String>(
//                   columnName: 'ဖုန်းနံပါတ်',
//                   value: "       ${e.phone.toString().replaceAll(" ", "")}   "),
//               DataGridCell<String>(
//                   columnName: 'နေရပ်လိပ်စာ',
//                   value: "  ${e.address.toString()}    "),
//             ]))
//         .toList();
//   }

//   List<DataGridRow> _memberData = [];

//   @override
//   List<DataGridRow> get rows => _memberData;

//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//         cells: row.getCells().map<Widget>((e) {
//       return Container(
//         alignment: Utils.isNumeric(e.value.toString().replaceAll("-", "")) ||
//                 e.value.toString().contains(" ကြိမ်") ||
//                 e.columnName == "သွေးအုပ်စု" ||
//                 e.columnName == "နေရပ်လိပ်စာ" ||
//                 e.columnName == "ဖုန်းနံပါတ်"
//             ? Alignment.centerRight
//             : Alignment.centerLeft,
//         padding: const EdgeInsets.all(8.0),
//         child: Text(e.value.toString()),
//       );
//     }).toList());
//   }
// }
