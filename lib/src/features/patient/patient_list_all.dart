// import 'dart:async';

// import 'package:donation/src/features/donation/controller/donation_list_controller_by_year.dart';
// import 'package:donation/src/features/home/mobile_home.dart';
// import 'package:donation/src/features/home/mobile_home/humberger.dart';
// import 'package:donation/src/features/patient/patient_data_source.dart';
// import 'package:donation/src/providers/providers.dart';
// // import 'package:fluent_ui/fluent_ui.dart' as fluent;
// import 'package:flutter/material.dart';
// import 'package:donation/responsive.dart';
// import 'package:donation/utils/Colors.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// class PatientListAll extends ConsumerStatefulWidget {
//   static const routeName = "/patient_list_all";
//   const PatientListAll({
//     Key? key,
//   }) : super(key: key);

//   @override
//   ConsumerState<PatientListAll> createState() => _PatientListAllState();
// }

// class _PatientListAllState extends ConsumerState<PatientListAll> {
//   //List<SpecialEventData>? data = [];
//   bool notloaded = true;
//   Timer? _debounceTimer;
//   String searchKey = "";

//   @override
//   void dispose() {
//     _debounceTimer?.cancel();
//     super.dispose();
//   }

//   TextEditingController searchController = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var patients = ref.watch(patientProvider);
//
//     if (notloaded) {
//       //
//       notloaded = false;
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         flexibleSpace: Container(
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: [primaryColor, primaryDark],
//         ))),
//         centerTitle: true,
//         leading: Responsive.isMobile(context)
//             ? Padding(
//                 padding: const EdgeInsets.only(top: 4, left: 8),
//                 child: Humberger(
//                   onTap: () {
//                     ref.watch(drawerControllerProvider)!.toggle!.call();
//                   },
//                 ),
//               )
//             : Padding(
//                 padding: const EdgeInsets.only(top: 4, left: 8),
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//         title: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Text("လူနာများ",
//               textScaleFactor: 1.0,
//               style: TextStyle(
//                   fontSize: Responsive.isMobile(context) ? 15 : 16,
//                   color: Colors.white)),
//         ),
//       ),
//       body: Padding(
//           padding: const EdgeInsets.only(left: 20, top: 30, right: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "လူနာများစာရင်း - " + patients.length.toString() + " ဦး",
//                 style: TextStyle(
//                     fontSize: Responsive.isMobile(context) ? 15 : 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//               ),
//               SizedBox(
//                 height: 24,
//               ),
//               Expanded(
//                 child: buildSimpleTable(searchKey == ""
//                     ? patients
//                     : patients
//                         .where((element) =>
//                             element.patientName!.contains(searchKey))
//                         .toList()),
//               ),
//             ],
//           )),
//     );
//   }

//   buildSimpleTable(List<Patient> data) {
//     PatientDataSource patientDataSource = PatientDataSource(patient: data);

//     return Container(
//       margin: EdgeInsets.only(
//           right: Responsive.isMobile(context) ? 20 : 20, bottom: 20),
//       child: SfDataGrid(
//         source: patientDataSource,
//         onCellTap: (details) async {},
//         gridLinesVisibility: GridLinesVisibility.both,
//         headerGridLinesVisibility: GridLinesVisibility.both,
//         columnWidthMode: Responsive.isMobile(context)
//             ? ColumnWidthMode.fitByCellValue
//             : ColumnWidthMode.fitByCellValue,
//         columns: <GridColumn>[
//           GridColumn(
//               columnName: 'စဥ်',
//               label: Container(
//                   width: MediaQuery.of(context).size.width * 0.3,
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'စဥ်',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'အမည်',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'အမည်',
//                     style: TextStyle(color: Colors.white),
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//           GridColumn(
//               columnName: 'အကြိမ်ရေ',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'အကြိမ်ရေ',
//                     style: TextStyle(color: Colors.white),
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//           GridColumn(
//               columnName: 'လှူဒါန်းသည့်နေရာ',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'လှူဒါန်းသည့်နေရာ',
//                     style: TextStyle(color: Colors.white),
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//           GridColumn(
//               columnName: 'ဖြစ်ပွားသည့်ရောဂါ',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'ဖြစ်ပွားသည့်ရောဂါ',
//                     style: TextStyle(color: Colors.white),
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//           GridColumn(
//               columnName: 'အသက်',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'အသက်',
//                     style: TextStyle(color: Colors.white),
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//           GridColumn(
//               columnName: 'နေရပ်လိပ်စာ',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'နေရပ်လိပ်စာ',
//                     style: TextStyle(color: Colors.white),
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//         ],
//       ),
//     );
//   }
// }
