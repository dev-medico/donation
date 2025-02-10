// import 'package:flutter/material.dart';
// import 'package:donation/realm/schemas.dart';
// import 'package:donation/utils/utils.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:intl/intl.dart';

// class SearchMemberDataSource extends DataGridSource {
//   /// Creates the employee data source class with required details.
//   SearchMemberDataSource({required List<Member> memberData}) {
//     _memberData = memberData.map<DataGridRow>((e) {
//       String date = "      -      ";
//       if (DateFormat('dd MMM yyyy').format(e.lastDate!).toString() !=
//           "01 Jan 2010") {
//         date = DateFormat('dd MMM yyyy').format(e.lastDate!.toLocal());
//       }
//       return DataGridRow(cells: [
//         DataGridCell<String>(
//             columnName: 'အမှတ်စဥ်', value: "   ${e.memberId}   "),
//         DataGridCell<String>(
//             columnName: 'အမည်', value: "      ${e.name}\t\t\t\t"),
//         DataGridCell<String>(
//             columnName: 'လှူဒါန်းခဲ့သည့်ရက်', value: "        $date        "),
//         DataGridCell<String>(
//             columnName: 'သွေးအုပ်စု',
//             value: "  " + e.bloodType.toString() + "  "),
//         DataGridCell<String>(columnName: 'မှတ်ပုံတင်အမှတ်', value: e.nrc),
//         DataGridCell<String>(
//             columnName: 'ဖုန်းနံပါတ်', value: "      ${e.phone}    "),
//         DataGridCell<String>(
//             columnName: 'အခြေအနေ', value: "${e.status ?? "  -  "}"),
//         DataGridCell<String>(
//             columnName: 'မှတ်ချက်',
//             value: "       ${e.note ?? "       -       "}       "),
//       ]);
//     }).toList();
//   }

//   List<DataGridRow> _memberData = [];

//   @override
//   List<DataGridRow> get rows => _memberData;

//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//         cells: row.getCells().map<Widget>((e) {
//       if (e.value.toString() == "available") {
//         return Container(
//           width: 100,
//           alignment: Alignment.center,
//           padding: const EdgeInsets.all(10),
//           child: SvgPicture.asset(
//             "assets/images/choosen.svg",
//             width: 24,
//           ),
//         );
//       } else if (e.value.toString() == "not_available") {
//         return Container(
//           width: 100,
//           alignment: Alignment.center,
//           padding: const EdgeInsets.all(10),
//           child: SvgPicture.asset(
//             "assets/images/unchoosen.svg",
//             width: 24,
//           ),
//         );
//       } else {
//         return Container(
//           alignment: Utils.isNumeric(e.value.toString().replaceAll("-", "")) ||
//                   e.value.toString().contains(" ကြိမ်")
//               ? Alignment.centerRight
//               : Alignment.centerLeft,
//           padding: const EdgeInsets.all(8.0),
//           child: Text(e.value.toString()),
//         );
//       }
//     }).toList());
//   }
// }
